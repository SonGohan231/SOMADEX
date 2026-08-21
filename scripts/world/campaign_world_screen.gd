extends "res://scripts/world/alpha1_world_screen.gd"

const CAMPAIGN_ZONES = preload("res://scripts/data/campaign_zone_db.gd")
const CAMPAIGN_PROGRESS = preload("res://scripts/data/campaign_progression_db.gd")
const RUNTIME_NPCS = preload("res://scripts/data/runtime_npc_db.gd")
const RUNTIME_TRAINERS = preload("res://scripts/data/runtime_trainer_db.gd")
const RUNTIME_PICKUPS = preload("res://scripts/data/pickup_db.gd")
const RUNTIME_ENCOUNTERS = preload("res://scripts/data/encounter_db.gd")
const VELA_SIDEQUESTS = preload("res://scripts/data/alpha1_sidequest_db.gd")
const CAMPAIGN_SIDEQUESTS = preload("res://scripts/data/campaign_sidequest_db.gd")

func setup(
	active_partner: String,
	start_tile: Vector2i,
	level: int,
	use_haptics: bool,
	current_zone: String,
	current_quest: String,
	flags: Dictionary = {}
) -> void:
	partner_name = active_partner
	player_tile = start_tile
	trainer_level = maxi(1, level)
	haptics = use_haptics
	zone_id = current_zone if CAMPAIGN_ZONES.has_zone(current_zone) else "vela"
	quest_short = current_quest
	dialogue_flags = flags.duplicate(true)
	map_rows = CAMPAIGN_ZONES.map_rows(zone_id)
	if map_rows.size() != ROWS:
		zone_id = "vela"
		map_rows = CAMPAIGN_ZONES.map_rows("vela")

func _draw() -> void:
	super._draw()
	draw_rect(Rect2(0, 0, 360, 56), Color("0a1f28"))
	draw_line(Vector2(0, 55), Vector2(360, 55), Color("3bd4cd"), 2.0)
	draw_string(font, Vector2(15, 22), CAMPAIGN_ZONES.zone_name(zone_id).to_upper(), HORIZONTAL_ALIGNMENT_LEFT, 205, 11, Color("dff8f4"))
	draw_string(font, Vector2(15, 42), quest_short, HORIZONTAL_ALIGNMENT_LEFT, 220, 8, Color("6d9da0"))
	draw_string(font, Vector2(254, 22), "TR Lv.%d" % trainer_level, HORIZONTAL_ALIGNMENT_RIGHT, 92, 10, Color("61d9d4"))
	draw_string(font, Vector2(254, 42), partner_name, HORIZONTAL_ALIGNMENT_RIGHT, 92, 9, Color("bcd3d4"))

func _draw_tile(tile: Vector2i, code: String) -> void:
	super._draw_tile(tile, code)
	var pickup: Dictionary = RUNTIME_PICKUPS.at(zone_id, tile)
	if not pickup.is_empty():
		var pickup_id: String = str(pickup.get("id", ""))
		# Only normal region pickups receive a marker. secret_* pickups are
		# intentionally discovered through exploration/interacting with terrain.
		if pickup_id.begins_with("region_") and not RUNTIME_PICKUPS.is_collected(pickup_id, dialogue_flags):
			_draw_pickup(tile)
	var npc: Dictionary = RUNTIME_NPCS.at(zone_id, tile)
	if not npc.is_empty():
		_draw_runtime_npc(tile, npc)

func _draw_runtime_npc(tile: Vector2i, npc: Dictionary) -> void:
	var p: Vector2 = _tile_to_px(tile)
	var npc_id: String = str(npc.get("id", "npc"))
	var body_color: Color = Color(str(npc.get("color", "6d7890")))
	_draw_pixel_shadow(p + Vector2(12, 21))
	draw_rect(Rect2(p + Vector2(8, 4), Vector2(8, 6)), Color("e8bd99"))
	draw_rect(Rect2(p + Vector2(6, 10), Vector2(12, 8)), body_color)
	draw_rect(Rect2(p + Vector2(7, 18), Vector2(4, 5)), Color("26313c"))
	draw_rect(Rect2(p + Vector2(13, 18), Vector2(4, 5)), Color("26313c"))
	if bool(npc.get("trainer", false)):
		var marker: Color = Color("58d98a") if RUNTIME_TRAINERS.is_defeated(npc_id, dialogue_flags) else Color("f2d25f")
		draw_rect(Rect2(p + Vector2(19, 4), Vector2(3, 3)), marker)

func _walkable(tile: Vector2i) -> bool:
	if not RUNTIME_NPCS.at(zone_id, tile).is_empty():
		return false
	return _tile_code(tile) in ["P", "G", "F", "D", "E", "B", "A", "V"]

func _after_step() -> void:
	var exit_data: Dictionary = CAMPAIGN_ZONES.exit_at(zone_id, player_tile)
	if not exit_data.is_empty():
		var target_zone: String = str(exit_data.get("zone_id", "vela"))
		if not CAMPAIGN_PROGRESS.can_enter(zone_id, target_zone, dialogue_flags):
			player_tile = _px_to_tile(from_px)
			player_px = from_px
			to_px = from_px
			dialog = CAMPAIGN_PROGRESS.lock_text(zone_id, target_zone)
			queue_redraw()
			return
		zone_change_requested.emit(target_zone, CAMPAIGN_ZONES.exit_spawn(exit_data))
		return
	steps_since_encounter += 1
	var code: String = _tile_code(player_tile)
	if not RUNTIME_ENCOUNTERS.pool(zone_id).is_empty() and code in ["G", "F", "A", "D", "V"] and steps_since_encounter >= 4 and rng.randf() < 0.18:
		steps_since_encounter = 0
		battle_requested.emit(player_tile)

func _interact() -> void:
	if moving:
		return
	var target: Vector2i = player_tile + facing
	var pickup: Dictionary = RUNTIME_PICKUPS.at(zone_id, target)
	if not pickup.is_empty():
		var pickup_id: String = str(pickup.get("id", ""))
		if not RUNTIME_PICKUPS.is_collected(pickup_id, dialogue_flags):
			dialogue_flags[RUNTIME_PICKUPS.flag_id(pickup_id)] = true
			dialog = str(pickup.get("message", "Znaleziono przedmiot."))
			var completed_titles: Array[String] = _completed_sidequest_titles(dialogue_flags)
			if not completed_titles.is_empty():
				dialog += "\nZADANIE UKOŃCZONE: %s" % " / ".join(completed_titles)
			pickup_requested.emit(pickup_id)
			queue_redraw()
			return

	var npc: Dictionary = RUNTIME_NPCS.at(zone_id, target)
	if not npc.is_empty():
		var npc_id: String = str(npc.get("id", ""))
		var flag_id: String = str(npc.get("flag", ""))
		if bool(npc.get("trainer", false)):
			if RUNTIME_TRAINERS.is_defeated(npc_id, dialogue_flags):
				dialog = RUNTIME_NPCS.dialogue(npc, dialogue_flags)
				queue_redraw()
				return
			if not flag_id.is_empty() and not bool(dialogue_flags.get(flag_id, false)):
				dialog = RUNTIME_NPCS.dialogue(npc, dialogue_flags)
				dialogue_flags[flag_id] = true
				dialogue_flag_requested.emit(flag_id)
				queue_redraw()
				return
			if not RUNTIME_TRAINERS.can_challenge(npc_id, dialogue_flags):
				dialog = RUNTIME_TRAINERS.locked_text(npc_id)
				queue_redraw()
				return
			trainer_battle_requested.emit(npc_id, player_tile)
			return
		dialog = RUNTIME_NPCS.dialogue(npc, dialogue_flags)
		if not flag_id.is_empty():
			dialogue_flags[flag_id] = true
			dialogue_flag_requested.emit(flag_id)
		queue_redraw()
		return

	if _tile_code(target) == "C":
		station_requested.emit(player_tile)
		dialog = "Stacja synchronizacji: drużyna odzyskała pełną gotowość."
		queue_redraw()
		return
	super._interact()

func _completed_sidequest_titles(flags: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for quest_id: String in VELA_SIDEQUESTS.ids():
		if VELA_SIDEQUESTS.can_complete(quest_id, flags):
			result.append(str(VELA_SIDEQUESTS.info(quest_id).get("title", quest_id)))
	for quest_id: String in CAMPAIGN_SIDEQUESTS.ids():
		if CAMPAIGN_SIDEQUESTS.can_complete(quest_id, flags):
			result.append(str(CAMPAIGN_SIDEQUESTS.info(quest_id).get("title", quest_id)))
	return result

func show_message(text: String) -> void:
	dialog = text
	queue_redraw()
