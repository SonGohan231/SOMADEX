extends "res://scripts/world/campaign_world_screen.gd"

const WORLD_ART = preload("res://scripts/art/world_pixel_art.gd")
const WORLD_NPCS = preload("res://scripts/data/runtime_npc_db.gd")
const WORLD_PICKUPS = preload("res://scripts/data/pickup_db.gd")
const WORLD_TRAINERS = preload("res://scripts/data/runtime_trainer_db.gd")

func _draw_tile(tile: Vector2i, code: String) -> void:
	var p: Vector2 = _tile_to_px(tile)
	var texture: Texture2D = WORLD_ART.tile_texture(code, tile.x + tile.y * 3)
	if texture != null:
		draw_texture_rect(texture, Rect2(p, Vector2(TILE, TILE)), false)
	var pickup: Dictionary = WORLD_PICKUPS.at(zone_id, tile)
	if not pickup.is_empty():
		var pickup_id: String = str(pickup.get("id", ""))
		if not WORLD_PICKUPS.is_collected(pickup_id, dialogue_flags):
			_draw_sprite_pickup(tile, pickup)
	var npc: Dictionary = WORLD_NPCS.at(zone_id, tile)
	if not npc.is_empty():
		_draw_sprite_npc(tile, npc)

func _draw_player() -> void:
	var frame: int = 0
	if moving:
		frame = posmod(int(elapsed * 10.0), 4)
	var texture: Texture2D = WORLD_ART.player_texture(facing, frame)
	if texture == null:
		super._draw_player()
		return
	var p: Vector2 = player_px
	draw_texture_rect(texture, Rect2(p, Vector2(TILE, TILE)), false)

func _draw_sprite_npc(tile: Vector2i, npc: Dictionary) -> void:
	var p: Vector2 = _tile_to_px(tile)
	var npc_id: String = str(npc.get("id", "npc"))
	var frame: int = 0
	var texture: Texture2D = WORLD_ART.npc_texture(npc, "down", frame)
	if texture != null:
		draw_texture_rect(texture, Rect2(p, Vector2(TILE, TILE)), false)
	if bool(npc.get("trainer", false)):
		var defeated: bool = WORLD_TRAINERS.is_defeated(npc_id, dialogue_flags)
		var marker: Color = Color("58d98a") if defeated else Color("f2d25f")
		draw_circle(p + Vector2(20, 4), 3.0, Color(0.05, 0.10, 0.12, 0.72))
		draw_circle(p + Vector2(20, 4), 2.0, marker)
		if not defeated:
			draw_string(font, p + Vector2(16, 7), "!", HORIZONTAL_ALIGNMENT_CENTER, 8, 7, Color("fff6c0"))

func _draw_sprite_pickup(tile: Vector2i, pickup: Dictionary) -> void:
	var p: Vector2 = _tile_to_px(tile)
	var kind: String = "gear" if not str(pickup.get("gear", "")).is_empty() else "item"
	var texture: Texture2D = WORLD_ART.pickup_texture(kind)
	var bob: float = sin(elapsed * 4.5 + float(tile.x + tile.y)) * 1.5
	var rect: Rect2 = Rect2(p + Vector2(6, 6 + bob), Vector2(12, 12))
	draw_circle(rect.get_center(), 7.0, Color(0.90, 0.80, 0.35, 0.10))
	if texture != null:
		draw_texture_rect(texture, rect, false)
