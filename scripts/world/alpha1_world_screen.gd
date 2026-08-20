extends "res://scripts/world/world_screen.gd"

const NPCS = preload("res://scripts/data/alpha1_npc_db.gd")

func _draw_tile(tile: Vector2i, code: String) -> void:
	super._draw_tile(tile, code)
	var npc: Dictionary = NPCS.at(zone_id, tile)
	if not npc.is_empty():
		_draw_authored_npc(tile, npc)

func _draw_authored_npc(tile: Vector2i, npc: Dictionary) -> void:
	var p: Vector2 = _tile_to_px(tile) + Vector2(3, 1)
	var body_color: Color = Color(str(npc.get("color", "6d7890")))
	_draw_pixel_shadow(p + Vector2(9, 20))
	draw_rect(Rect2(p + Vector2(5, 3), Vector2(8, 6)), Color("e8bd99"))
	draw_rect(Rect2(p + Vector2(4, 0), Vector2(10, 4)), body_color.darkened(0.28))
	draw_rect(Rect2(p + Vector2(3, 9), Vector2(12, 8)), body_color)
	draw_rect(Rect2(p + Vector2(4, 17), Vector2(4, 5)), Color("25313c"))
	draw_rect(Rect2(p + Vector2(10, 17), Vector2(4, 5)), Color("25313c"))
	if bool(npc.get("trainer", false)):
		draw_rect(Rect2(p + Vector2(15, 8), Vector2(3, 3)), Color("f2d25f"))

func _walkable(tile: Vector2i) -> bool:
	if not NPCS.at(zone_id, tile).is_empty():
		return false
	return super._walkable(tile)

func _interact() -> void:
	if moving:
		return
	var target: Vector2i = player_tile + facing
	var npc: Dictionary = NPCS.at(zone_id, target)
	if not npc.is_empty():
		dialog = NPCS.dialogue(npc, dialogue_flags)
		var flag_id: String = str(npc.get("flag", ""))
		if not flag_id.is_empty():
			dialogue_flags[flag_id] = true
			dialogue_flag_requested.emit(flag_id)
		queue_redraw()
		return
	super._interact()
