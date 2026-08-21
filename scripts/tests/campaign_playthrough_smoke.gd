extends SceneTree

const ZONES = preload("res://scripts/data/campaign_zone_db.gd")
const PROGRESS = preload("res://scripts/data/campaign_progression_db.gd")
const TRAINERS = preload("res://scripts/data/runtime_trainer_db.gd")
const NPCS = preload("res://scripts/data/runtime_npc_db.gd")
const CAMPAIGN_PICKUPS = preload("res://scripts/data/campaign_pickup_db.gd")
const STATE = preload("res://scripts/core/game_state.gd")

const WALKABLE: Array[String] = ["P", "G", "F", "D", "E", "B", "A", "V"]
const DIRS: Array[Vector2i] = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]

var failures: Array[String] = []

func _init() -> void:
	_validate_physical_zone_routes()
	_validate_all_interactables()
	_simulate_full_campaign_and_loss_recovery()
	if failures.is_empty():
		print("CAMPAIGN PLAYTHROUGH: PASS · full route · interactables · loss recovery · save migration")
		quit(0)
		return
	for failure: String in failures:
		push_error("PLAYTHROUGH: " + failure)
	print("CAMPAIGN PLAYTHROUGH: FAIL (%d)" % failures.size())
	quit(1)

func _validate_physical_zone_routes() -> void:
	var flags: Dictionary = _fully_unlocked_flags()
	for zone_id: String in ZONES.ids():
		var spawn: Vector2i = ZONES.spawn_tile(zone_id)
		var reachable: Dictionary = _reachable_tiles(zone_id, spawn)
		_check(reachable.has(spawn), "%s spawn is not physically walkable" % zone_id)
		var exit_count: int = 0
		var rows: Array[String] = ZONES.map_rows(zone_id)
		for y: int in range(rows.size()):
			for x: int in range(rows[y].length()):
				var tile: Vector2i = Vector2i(x, y)
				var exit_data: Dictionary = ZONES.exit_at(zone_id, tile)
				if exit_data.is_empty():
					continue
				exit_count += 1
				var target: String = str(exit_data.get("zone_id", ""))
				if PROGRESS.can_enter(zone_id, target, flags):
					_check(reachable.has(tile), "%s exit to %s is physically unreachable from spawn" % [zone_id, target])
		_check(exit_count > 0, "%s has no exits" % zone_id)

func _validate_all_interactables() -> void:
	for zone_id: String in ZONES.ids():
		var reachable: Dictionary = _reachable_tiles(zone_id, ZONES.spawn_tile(zone_id))
		for npc: Dictionary in NPCS.in_zone(zone_id):
			var npc_id: String = str(npc.get("id", "npc"))
			var tile: Vector2i = NPCS.tile_of(npc)
			_check(_has_reachable_neighbor(tile, reachable), "%s NPC/trainer %s cannot be interacted with" % [zone_id, npc_id])

	for pickup_id: String in CAMPAIGN_PICKUPS.ids():
		var pickup: Dictionary = CAMPAIGN_PICKUPS.by_id(pickup_id)
		var zone_id: String = str(pickup.get("zone", ""))
		var tile: Vector2i = CAMPAIGN_PICKUPS.tile_of(pickup)
		var reachable: Dictionary = _reachable_tiles(zone_id, ZONES.spawn_tile(zone_id))
		_check(_has_reachable_neighbor(tile, reachable), "%s pickup %s cannot be interacted with" % [zone_id, pickup_id])

func _simulate_full_campaign_and_loss_recovery() -> void:
	var flags: Dictionary = {"trainer_rhea_defeated":true}
	var profile: Dictionary = STATE.new_profile("Luzik")
	profile["quest_stage"] = PROGRESS.STAGE_VELA_TRIAL
	profile["dialogue_flags"] = flags.duplicate(true)

	var initial_path: Array[String] = _zone_path("vela", "north_gate", flags)
	_check(not initial_path.is_empty(), "new-game route from Vela to North Gate is disconnected")

	for index: int in range(PROGRESS.BOSS_ORDER.size()):
		var boss_id: String = PROGRESS.BOSS_ORDER[index]
		var boss_info: Dictionary = TRAINERS.info(boss_id)
		var boss_zone: String = str(boss_info.get("zone", ""))
		_check(not boss_zone.is_empty(), "boss %s has no zone" % boss_id)

		# A loss anywhere in the campaign sends the player back to Vela. Every
		# unlocked chapter therefore must remain reachable again from Vela.
		var recovery_path: Array[String] = _zone_path("vela", boss_zone, flags)
		_check(not recovery_path.is_empty(), "loss recovery cannot return from Vela to %s for boss %s" % [boss_zone, boss_id])

		_check(TRAINERS.can_challenge(boss_id, flags), "boss %s cannot be challenged when its chapter is reached" % boss_id)
		var npc: Dictionary = _npc_by_id(boss_zone, boss_id)
		_check(not npc.is_empty(), "boss %s has no runtime NPC in %s" % [boss_id, boss_zone])
		if not npc.is_empty():
			var reachable: Dictionary = _reachable_tiles(boss_zone, ZONES.spawn_tile(boss_zone))
			_check(_has_reachable_neighbor(NPCS.tile_of(npc), reachable), "boss %s cannot be physically approached" % boss_id)

		flags[TRAINERS.defeated_flag(boss_id)] = true
		profile["zone_id"] = boss_zone
		profile["dialogue_flags"] = flags.duplicate(true)
		profile["quest_stage"] = PROGRESS.stage_for(flags, PROGRESS.STAGE_VELA_TRIAL)
		profile = STATE.migrate(profile)
		var restored_flags: Dictionary = profile.get("dialogue_flags", {}) as Dictionary
		_check(bool(restored_flags.get(TRAINERS.defeated_flag(boss_id), false)), "save migration lost boss flag %s" % boss_id)
		flags = restored_flags.duplicate(true)

		var expected_stage: int = mini(PROGRESS.STAGE_VELA_TRIAL + index + 1, PROGRESS.STAGE_POST_GAME)
		_check(PROGRESS.stage_for(flags, PROGRESS.STAGE_VELA_TRIAL) == expected_stage, "campaign stage mismatch after %s" % boss_id)

	_check(PROGRESS.completed_boss_count(flags) == PROGRESS.BOSS_ORDER.size(), "full playthrough did not retain all boss victories")
	_check(PROGRESS.stage_for(flags, PROGRESS.STAGE_VELA_TRIAL) == PROGRESS.STAGE_POST_GAME, "full playthrough did not reach post-game stage")
	for post_zone: String in ["echo_depths", "resonance_lab", "outer_shelf"]:
		_check(not _zone_path("vela", post_zone, flags).is_empty(), "post-game zone %s is unreachable after finale" % post_zone)

func _fully_unlocked_flags() -> Dictionary:
	var flags: Dictionary = {"trainer_rhea_defeated":true}
	for boss_id: String in PROGRESS.BOSS_ORDER:
		flags[TRAINERS.defeated_flag(boss_id)] = true
	return flags

func _zone_path(start_zone: String, target_zone: String, flags: Dictionary) -> Array[String]:
	if start_zone == target_zone:
		return [start_zone]
	var queue: Array[String] = [start_zone]
	var parent: Dictionary = {start_zone:""}
	while not queue.is_empty():
		var zone_id: String = queue.pop_front()
		for target: String in _zone_neighbors(zone_id, flags):
			if parent.has(target):
				continue
			parent[target] = zone_id
			if target == target_zone:
				return _reconstruct_zone_path(parent, target_zone)
			queue.append(target)
	return []

func _zone_neighbors(zone_id: String, flags: Dictionary) -> Array[String]:
	var result: Array[String] = []
	var rows: Array[String] = ZONES.map_rows(zone_id)
	for y: int in range(rows.size()):
		for x: int in range(rows[y].length()):
			var exit_data: Dictionary = ZONES.exit_at(zone_id, Vector2i(x, y))
			if exit_data.is_empty():
				continue
			var target: String = str(exit_data.get("zone_id", ""))
			if not target.is_empty() and PROGRESS.can_enter(zone_id, target, flags) and not result.has(target):
				result.append(target)
	return result

func _reconstruct_zone_path(parent: Dictionary, target: String) -> Array[String]:
	var result: Array[String] = []
	var cursor: String = target
	while not cursor.is_empty():
		result.push_front(cursor)
		cursor = str(parent.get(cursor, ""))
	return result

func _reachable_tiles(zone_id: String, start: Vector2i) -> Dictionary:
	var result: Dictionary = {}
	if not _walkable(zone_id, start):
		return result
	var queue: Array[Vector2i] = [start]
	result[start] = true
	while not queue.is_empty():
		var tile: Vector2i = queue.pop_front()
		for direction: Vector2i in DIRS:
			var next: Vector2i = tile + direction
			if result.has(next) or not _walkable(zone_id, next):
				continue
			result[next] = true
			queue.append(next)
	return result

func _walkable(zone_id: String, tile: Vector2i) -> bool:
	var rows: Array[String] = ZONES.map_rows(zone_id)
	if tile.y < 0 or tile.y >= rows.size():
		return false
	var row: String = rows[tile.y]
	if tile.x < 0 or tile.x >= row.length():
		return false
	if not NPCS.at(zone_id, tile).is_empty():
		return false
	return WALKABLE.has(row.substr(tile.x, 1))

func _has_reachable_neighbor(tile: Vector2i, reachable: Dictionary) -> bool:
	for direction: Vector2i in DIRS:
		if reachable.has(tile + direction):
			return true
	return false

func _npc_by_id(zone_id: String, npc_id: String) -> Dictionary:
	for npc: Dictionary in NPCS.in_zone(zone_id):
		if str(npc.get("id", "")) == npc_id:
			return npc
	return {}

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
