extends "res://scripts/world/world_screen.gd"

signal trainer_battle_requested(trainer_id: String, tile: Vector2i)
signal pickup_requested(pickup_id: String)

const NPCS = preload("res://scripts/data/alpha1_npc_db.gd")
const TRAINERS = preload("res://scripts/data/alpha1_trainer_db.gd")
const PICKUPS = preload("res://scripts/data/alpha1_pickup_db.gd")
const CHAR_ART = preload("res://scripts/world/alpha1_character_art.gd")

func _draw_tile(tile: Vector2i, code: String) -> void:
	super._draw_tile(tile, code)
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

func _draw_player() -> void:
	var phase: int = int(Time.get_ticks_msec() / 120)
	var texture: Texture2D = CHAR_ART.player_texture(facing, moving, phase)
	if texture != null:
		draw_texture_rect(texture, Rect2(player_px, Vector2(24, 24)), false)
		return
	super._draw_player()

func _draw_authored_npc(tile: Vector2i, npc: Dictionary) -> void:
	var p: Vector2 = _tile_to_px(tile)
	var npc_id: String = str(npc.get("id", "npc"))
	var texture: Texture2D = CHAR_ART.npc_texture(npc_id)
	if texture != null:
		draw_texture_rect(texture, Rect2(p, Vector2(24, 24)), false)
	else:
		var body_color: Color = Color(str(npc.get("color", "6d7890")))
		_draw_pixel_shadow(p + Vector2(12, 21))
		draw_rect(Rect2(p + Vector2(8, 4), Vector2(8, 6)), Color("e8bd99"))
		draw_rect(Rect2(p + Vector2(6, 10), Vector2(12, 8)), body_color)
	if bool(npc.get("trainer", false)):
		var marker: Color = Color("58d98a") if TRAINERS.is_defeated(npc_id, dialogue_flags) else Color("f2d25f")
		draw_rect(Rect2(p + Vector2(19, 4), Vector2(3, 3)), marker)

func _walkable(tile: Vector2i) -> bool:
	if not NPCS.at(zone_id, tile).is_empty():
		return false
	return super._walkable(tile)

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
