extends "res://scripts/world/world_screen.gd"

signal trainer_battle_requested(trainer_id: String, tile: Vector2i)
signal pickup_requested(pickup_id: String)

const NPCS = preload("res://scripts/data/alpha1_npc_db.gd")
const TRAINERS = preload("res://scripts/data/alpha1_trainer_db.gd")
const PICKUPS = preload("res://scripts/data/alpha1_pickup_db.gd")
const SIDEQUESTS = preload("res://scripts/data/alpha1_sidequest_db.gd")

func _draw_tile(tile: Vector2i, code: String) -> void:
	super._draw_tile(tile, code)
	var p: Vector2 = _tile_to_px(tile)
	var r: Rect2 = Rect2(p, Vector2(TILE, TILE))
	match code:
		"F":
			draw_rect(r, Color("3d824d"))
			draw_line(p + Vector2(5, 20), p + Vector2(8, 13), Color("78ba68"), 1.0)
			draw_line(p + Vector2(16, 21), p + Vector2(13, 14), Color("2e693d"), 1.0)
			var pulse: float = 0.65 + 0.25 * sin(elapsed * 2.0 + float(tile.x + tile.y))
			draw_circle(p + Vector2(18, 7), 1.0, Color(0.95, 0.84, 0.46, pulse))
		"A":
			draw_rect(r, Color("d3ba79"))
			draw_circle(p + Vector2(6, 8), 1.0, Color("aa925d"))
			draw_circle(p + Vector2(17, 17), 1.0, Color("ead79d"))
		"B":
			draw_rect(r, Color("6d583d"))
			for yy: int in [4, 10, 16, 22]:
				draw_line(p + Vector2(1, yy), p + Vector2(23, yy), Color("a88756"), 1.0)
		"D":
			draw_rect(r, Color("89949a"))
			draw_rect(Rect2(p + Vector2(2, 2), Vector2(20, 20)), Color("6e7a82"), false, 1.0)
		"V":
			draw_rect(r, Color("3b4353"))
			draw_circle(p + Vector2(7, 7), 2.0, Color("59677a"))
			draw_circle(p + Vector2(18, 15), 1.5, Color("647487"))
		"O":
			draw_rect(r, Color("3b4353"))
			draw_circle(p + Vector2(12, 14), 8.0, Color("5b526b"))
			draw_circle(p + Vector2(10, 11), 4.0, Color("756987"))
		"K":
			draw_rect(r, Color("252c37"))
			draw_rect(Rect2(p + Vector2(2, 2), Vector2(20, 20)), Color("414a5a"))
			draw_line(p + Vector2(3, 8), p + Vector2(20, 8), Color("5d6879"), 1.0)
		_:
			pass
	var pickup: Dictionary = PICKUPS.at(zone_id, tile)
	if not pickup.is_empty() and not PICKUPS.is_collected(str(pickup.get("id", "")), dialogue_flags):
		_draw_pickup(tile)
	var npc: Dictionary = NPCS.at(zone_id, tile)
	if not npc.is_empty():
		_draw_authored_npc(tile, npc)

func _draw_pickup(tile: Vector2i) -> void:
	var p: Vector2 = _tile_to_px(tile)
	var pulse: float = 0.65 + 0.25 * sin(elapsed * 5.0 + float(tile.x + tile.y))
	draw_circle(p + Vector2(12, 13), 4.0, Color(0.94, 0.82, 0.31, 0.18 + pulse * 0.20))
	draw_rect(Rect2(p + Vector2(10, 10), Vector2(4, 4)), Color(0.98, 0.90, 0.49, pulse))
	draw_rect(Rect2(p + Vector2(11, 7), Vector2(2, 2)), Color("f8f2bf"))

func _draw_authored_npc(tile: Vector2i, npc: Dictionary) -> void:
	var p: Vector2 = _tile_to_px(tile)
	var npc_id: String = str(npc.get("id", "npc"))
	var body_color: Color = Color(str(npc.get("color", "6d7890")))
	_draw_pixel_shadow(p + Vector2(12, 21))
	draw_rect(Rect2(p + Vector2(8, 4), Vector2(8, 6)), Color("e8bd99"))
	draw_rect(Rect2(p + Vector2(6, 10), Vector2(12, 8)), body_color)
	draw_rect(Rect2(p + Vector2(7, 18), Vector2(4, 5)), Color("26313c"))
	draw_rect(Rect2(p + Vector2(13, 18), Vector2(4, 5)), Color("26313c"))
	if bool(npc.get("trainer", false)):
		var marker: Color = Color("58d98a") if TRAINERS.is_defeated(npc_id, dialogue_flags) else Color("f2d25f")
		draw_rect(Rect2(p + Vector2(19, 4), Vector2(3, 3)), marker)

func _walkable(tile: Vector2i) -> bool:
	if not NPCS.at(zone_id, tile).is_empty():
		return false
	return _tile_code(tile) in ["P", "G", "F", "D", "E", "B", "A"]

func _after_step() -> void:
	var exit_data: Dictionary = ZONES.exit_at(zone_id, player_tile)
	if not exit_data.is_empty():
		zone_change_requested.emit(str(exit_data.get("zone_id", "vela")), ZONES.exit_spawn(exit_data))
		return
	steps_since_encounter += 1
	var code: String = _tile_code(player_tile)
	if code in ["G", "F"] and steps_since_encounter >= 4 and rng.randf() < 0.18:
		steps_since_encounter = 0
		battle_requested.emit(player_tile)

func _interact() -> void:
	if moving:
		return
	var target: Vector2i = player_tile + facing
	var pickup: Dictionary = PICKUPS.at(zone_id, target)
	if not pickup.is_empty():
		var pickup_id: String = str(pickup.get("id", ""))
		if not PICKUPS.is_collected(pickup_id, dialogue_flags):
			dialogue_flags[PICKUPS.flag_id(pickup_id)] = true
			dialog = str(pickup.get("message", "Znaleziono przedmiot."))
			var completed_titles: Array[String] = []
			for quest_id: String in SIDEQUESTS.ids():
				if SIDEQUESTS.can_complete(quest_id, dialogue_flags):
					completed_titles.append(str(SIDEQUESTS.info(quest_id).get("title", quest_id)))
			if not completed_titles.is_empty():
				dialog += "\nZADANIE UKOŃCZONE: %s" % " / ".join(completed_titles)
			pickup_requested.emit(pickup_id)
			queue_redraw()
			return

	var npc: Dictionary = NPCS.at(zone_id, target)
	if not npc.is_empty():
		var npc_id: String = str(npc.get("id", ""))
		var flag_id: String = str(npc.get("flag", ""))
		if bool(npc.get("trainer", false)):
			if TRAINERS.is_defeated(npc_id, dialogue_flags):
				dialog = NPCS.dialogue(npc, dialogue_flags)
				queue_redraw()
				return
			if not flag_id.is_empty() and not bool(dialogue_flags.get(flag_id, false)):
				dialog = NPCS.dialogue(npc, dialogue_flags)
				dialogue_flags[flag_id] = true
				dialogue_flag_requested.emit(flag_id)
				queue_redraw()
				return
			if not TRAINERS.can_challenge(npc_id, dialogue_flags):
				dialog = TRAINERS.locked_text(npc_id)
				queue_redraw()
				return
			trainer_battle_requested.emit(npc_id, player_tile)
			return
		dialog = NPCS.dialogue(npc, dialogue_flags)
		if not flag_id.is_empty():
			dialogue_flags[flag_id] = true
			dialogue_flag_requested.emit(flag_id)
		queue_redraw()
		return
	super._interact()