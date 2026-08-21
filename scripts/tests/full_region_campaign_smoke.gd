extends SceneTree

const ZONES = preload("res://scripts/data/campaign_zone_db.gd")
const PACK = preload("res://scripts/data/region_zone_pack.gd")
const PROGRESS = preload("res://scripts/data/campaign_progression_db.gd")
const TRAINERS = preload("res://scripts/data/runtime_trainer_db.gd")
const NPCS = preload("res://scripts/data/runtime_npc_db.gd")
const ENCOUNTERS = preload("res://scripts/data/encounter_db.gd")
const CAMPAIGN_ENCOUNTERS = preload("res://scripts/data/campaign_encounter_db.gd")
const PICKUPS = preload("res://scripts/data/pickup_db.gd")
const CAMPAIGN_PICKUPS = preload("res://scripts/data/campaign_pickup_db.gd")
const VELA_SIDEQUESTS = preload("res://scripts/data/alpha1_sidequest_db.gd")
const CAMPAIGN_SIDEQUESTS = preload("res://scripts/data/campaign_sidequest_db.gd")
const STORY_BEATS = preload("res://scripts/data/campaign_story_beat_db.gd")
const MONSTERS = preload("res://scripts/data/monster_db.gd")
const ITEMS = preload("res://scripts/data/item_db.gd")
const EQUIPMENT = preload("res://scripts/data/equipment_db.gd")
const WORLD = preload("res://scripts/world/campaign_world_screen.gd")

var failures: Array[String] = []

func _init() -> void:
	_check(ZONES.ids().size() == 28, "full region must expose exactly 28 runtime locations")
	_check(PACK.ids().size() == 21, "region pack must add 21 locations to seven Vela maps")
	_validate_maps_and_graph()
	_validate_trainers_and_bosses()
	_validate_campaign_gates()
	_validate_encounters()
	_validate_pickups_and_npcs()
	_validate_content_pass()
	_validate_world_runtime()
	_validate_main_scene()
	if failures.is_empty():
		print("FULL REGION CAMPAIGN SMOKE: PASS · 28 locations · 8 bosses · 24 sidequests · 36 secrets · 16 story beats · 150 forms")
		quit(0)
	else:
		for failure: String in failures:
			push_error("FULL REGION: " + failure)
		print("FULL REGION CAMPAIGN SMOKE: FAIL (%d)" % failures.size())
		quit(1)

func _validate_maps_and_graph() -> void:
	for zone_id: String in ZONES.ids():
		var rows: Array[String] = ZONES.map_rows(zone_id)
		_check(rows.size() == 23, "%s must have 23 rows" % zone_id)
		for row: String in rows:
			_check(row.length() == 15, "%s rows must have 15 columns" % zone_id)
		var exit_count: int = 0
		for y: int in range(23):
			for x: int in range(15):
				var exit_data: Dictionary = ZONES.exit_at(zone_id, Vector2i(x, y))
				if exit_data.is_empty():
					continue
				exit_count += 1
				var target: String = str(exit_data.get("zone_id", ""))
				_check(ZONES.has_zone(target), "%s exit points to missing zone %s" % [zone_id, target])
				_check(_has_return_exit(target, zone_id), "%s -> %s must have a return route" % [zone_id, target])
		_check(exit_count > 0, "%s must be connected to region graph" % zone_id)

func _has_return_exit(zone_id: String, expected_target: String) -> bool:
	for y: int in range(23):
		for x: int in range(15):
			var exit_data: Dictionary = ZONES.exit_at(zone_id, Vector2i(x, y))
			if str(exit_data.get("zone_id", "")) == expected_target:
				return true
	return false

func _validate_trainers_and_bosses() -> void:
	_check(TRAINERS.trainer_count() >= 63, "production pass must include Vela trainers plus expanded regional opposition")
	var bosses: Array[String] = TRAINERS.boss_ids()
	_check(bosses.size() == 8, "campaign must contain eight main bosses")
	for boss_id: String in PROGRESS.BOSS_ORDER:
		_check(bosses.has(boss_id), "missing campaign boss %s" % boss_id)
	for trainer_id: String in TRAINERS.ids():
		var data: Dictionary = TRAINERS.info(trainer_id)
		_check(not data.is_empty(), "trainer %s has no data" % trainer_id)
		var team: Array = TRAINERS.party(trainer_id)
		_check(team.size() >= 2 and team.size() <= 6, "trainer %s party must contain 2-6 creatures" % trainer_id)
		for raw: Variant in team:
			var member: Dictionary = raw as Dictionary
			_check(MONSTERS.has_monster(str(member.get("name", ""))), "trainer %s uses unknown creature" % trainer_id)
	_check(TRAINERS.has("zenith_core_duelist"), "production pass needs the optional Zenith trainer duel")

func _validate_campaign_gates() -> void:
	var flags: Dictionary = {}
	_check(not TRAINERS.can_challenge("vela_trial", flags), "Vela Trial must wait for Rhea")
	flags["trainer_rhea_defeated"] = true
	_check(TRAINERS.can_challenge("vela_trial", flags), "Vela Trial must unlock after Rhea")
	_check(not PROGRESS.can_enter("north_gate", "orin_gate", flags), "Orin gate must wait for Vela Trial")
	var expected_stage: int = PROGRESS.STAGE_VELA_TRIAL
	for boss_id: String in PROGRESS.BOSS_ORDER:
		flags[PROGRESS.defeated_flag(boss_id)] = true
		expected_stage += 1
		_check(PROGRESS.stage_for(flags, PROGRESS.STAGE_VELA_TRIAL) == mini(expected_stage, PROGRESS.STAGE_POST_GAME), "campaign stage failed after %s" % boss_id)
	_check(PROGRESS.completed_boss_count(flags) == 8, "all eight boss flags must resolve")
	_check(PROGRESS.can_enter("north_gate", "orin_gate", flags), "Orin must open after Vela Trial")
	_check(PROGRESS.can_enter("marea", "ferrum_line", flags), "Ferrum line gate must resolve")
	_check(PROGRESS.can_enter("ferrum", "nivra_pass", flags), "Nivra gate must resolve")
	_check(PROGRESS.can_enter("nivra", "lumen_ruins", flags), "Lumen gate must resolve")
	_check(PROGRESS.can_enter("lumen", "aster_woods", flags), "Aster gate must resolve")
	_check(PROGRESS.can_enter("aster", "silent_basin", flags), "Koral path gate must resolve")
	_check(PROGRESS.can_enter("koral", "zenith_approach", flags), "Zenith approach gate must resolve")
	_check(PROGRESS.can_enter("zenith", "echo_depths", flags), "post-game gate must resolve")

func _validate_encounters() -> void:
	_check(MONSTERS.all_names().size() == 150, "monster runtime must still expose 150 forms")
	_check(ENCOUNTERS.all_species().size() == 150, "regional encounter system must cover all 150 forms")
	_check(CAMPAIGN_ENCOUNTERS.post_game_completion_pool().size() == 150, "post-game ecosystem must expose all 150 forms")
	for zone_id: String in PACK.ids():
		if CAMPAIGN_ENCOUNTERS.is_safe_zone(zone_id):
			_check(ENCOUNTERS.pool(zone_id).is_empty(), "%s is a safe town and must not roll wild battles" % zone_id)
			_check(CAMPAIGN_ENCOUNTERS.rare_species(zone_id).is_empty(), "%s safe town must not expose rare wild encounters" % zone_id)
		else:
			_check(not ENCOUNTERS.pool(zone_id).is_empty(), "%s field zone needs an encounter pool" % zone_id)
			_check(CAMPAIGN_ENCOUNTERS.rare_species(zone_id).size() == 2, "%s field zone needs exactly two low-weight rare encounters" % zone_id)

func _validate_pickups_and_npcs() -> void:
	_check(CAMPAIGN_PICKUPS.ids().size() == 78, "campaign must expose 42 visible pickups plus 36 hidden secrets")
	_check(CAMPAIGN_PICKUPS.secret_count() == 36, "production pass must contain exactly 36 hidden secrets")
	var gear_rewards: int = 0
	for pickup_id: String in CAMPAIGN_PICKUPS.ids():
		var pickup: Dictionary = PICKUPS.by_id(pickup_id)
		_check(not pickup.is_empty(), "pickup %s must resolve through aggregate DB" % pickup_id)
		var gear_id: String = str(pickup.get("gear", ""))
		var item_id: String = str(pickup.get("item", ""))
		_check(not gear_id.is_empty() or not item_id.is_empty(), "pickup %s has no reward" % pickup_id)
		if pickup_id.begins_with("secret_"):
			_check(bool(pickup.get("secret", false)), "secret pickup %s must be marked hidden" % pickup_id)
			var zone_id: String = str(pickup.get("zone", ""))
			var tile: Vector2i = CAMPAIGN_PICKUPS.tile_of(pickup)
			var rows: Array[String] = ZONES.map_rows(zone_id)
			if tile.y >= 0 and tile.y < rows.size() and tile.x >= 0 and tile.x < rows[tile.y].length():
				var code: String = rows[tile.y].substr(tile.x, 1)
				_check(code in ["P", "G", "F", "D", "E", "B", "A", "V"], "secret %s must sit on interactable terrain" % pickup_id)
		if not gear_id.is_empty():
			gear_rewards += 1
			_check(not EQUIPMENT.info(gear_id).is_empty(), "pickup %s references unknown equipment" % pickup_id)
	_check(gear_rewards >= 12, "campaign must distribute meaningful equipment upgrades")
	_check(NPCS.count() >= 88, "full region production pass needs a denser NPC/trainer population")
	for zone_id: String in ZONES.ids():
		var occupied: Dictionary = {}
		for npc: Dictionary in NPCS.in_zone(zone_id):
			var tile: Vector2i = NPCS.tile_of(npc)
			var key: String = "%d,%d" % [tile.x, tile.y]
			_check(not occupied.has(key), "%s has overlapping runtime NPCs at %s" % [zone_id, key])
			occupied[key] = str(npc.get("id", "npc"))
		for secret: Dictionary in CAMPAIGN_PICKUPS.in_zone(zone_id):
			if not bool(secret.get("secret", false)):
				continue
			var secret_tile: Vector2i = CAMPAIGN_PICKUPS.tile_of(secret)
			var secret_key: String = "%d,%d" % [secret_tile.x, secret_tile.y]
			_check(not occupied.has(secret_key), "%s secret overlaps NPC at %s" % [zone_id, secret_key])
	var eron: Dictionary = NPCS.at("north_gate", Vector2i(7, 4))
	_check(str(eron.get("id", "")) == "vela_trial", "Vela Trial must not overlap Rhea")

func _validate_content_pass() -> void:
	_check(VELA_SIDEQUESTS.ids().size() == 3, "Vela must retain its three authored sidequests")
	_check(CAMPAIGN_SIDEQUESTS.ids().size() == 21, "Region 1 production pass must add 21 campaign sidequests")
	_check(VELA_SIDEQUESTS.ids().size() + CAMPAIGN_SIDEQUESTS.ids().size() == 24, "Region 1 must expose 24 sidequests total")
	for quest_id: String in CAMPAIGN_SIDEQUESTS.ids():
		var data: Dictionary = CAMPAIGN_SIDEQUESTS.info(quest_id)
		_check(not data.is_empty(), "sidequest %s must resolve" % quest_id)
		var start_flag: String = str(data.get("start_flag", ""))
		var requirements: Array = data.get("requirements", []) as Array
		_check(not start_flag.is_empty(), "sidequest %s needs a start flag" % quest_id)
		_check(not requirements.is_empty(), "sidequest %s needs requirements" % quest_id)
		var simulated: Dictionary = {start_flag:true}
		for raw_flag: Variant in requirements:
			simulated[str(raw_flag)] = true
		_check(CAMPAIGN_SIDEQUESTS.can_complete(quest_id, simulated), "sidequest %s must complete when all flags resolve" % quest_id)
		for raw_item: Variant in CAMPAIGN_SIDEQUESTS.reward(quest_id).keys():
			var item_id: String = str(raw_item)
			_check(not ITEMS.info(item_id).is_empty(), "sidequest %s references unknown reward %s" % [quest_id, item_id])
	_check(STORY_BEATS.count() == 16, "production pass must add 16 inter-boss story beats")
	for beat_id: String in STORY_BEATS.ids():
		var beat: Dictionary = STORY_BEATS.info(beat_id)
		var zone_id: String = str(beat.get("zone", ""))
		_check(ZONES.has_zone(zone_id), "story beat %s references missing zone %s" % [beat_id, zone_id])
		_check(not str(beat.get("text", "")).is_empty(), "story beat %s needs narrative text" % beat_id)
		var flags: Dictionary = {}
		for raw_flag: Variant in beat.get("requires", []) as Array:
			flags[str(raw_flag)] = true
		var resolved: Dictionary = STORY_BEATS.next_for(zone_id, flags)
		_check(not resolved.is_empty(), "story beat %s must become reachable from its requirements" % beat_id)

func _validate_world_runtime() -> void:
	var world: Control = WORLD.new()
	world.setup("Luzik", Vector2i(7, 21), 12, false, "orin_gate", "Test kampanii", {})
	_check(str(world.get("zone_id")) == "orin_gate", "campaign world must accept added zones")
	var rows: Array = world.get("map_rows") as Array
	_check(rows.size() == 23, "campaign world must load runtime map rows")
	world.free()

func _validate_main_scene() -> void:
	var file: FileAccess = FileAccess.open("res://scenes/Main.tscn", FileAccess.READ)
	_check(file != null, "Main.tscn must be readable")
	if file != null:
		var text: String = file.get_as_text()
		_check(text.contains("res://scripts/campaign_game.gd"), "Main.tscn must use campaign runtime controller")

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
