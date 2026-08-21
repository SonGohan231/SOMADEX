extends "res://scripts/world/campaign_world_screen.gd"

const WORLD_ART = preload("res://scripts/art/world_pixel_art.gd")
const WORLD_NPCS = preload("res://scripts/data/runtime_npc_db.gd")
const WORLD_PICKUPS = preload("res://scripts/data/pickup_db.gd")
const WORLD_TRAINERS = preload("res://scripts/data/runtime_trainer_db.gd")
const WORLD_DISCOVERIES = preload("res://scripts/data/campaign_discovery_db.gd")
const RETRO_SFX = preload("res://scripts/audio/retro_sfx.gd")

var _sfx: Node = null

func _draw() -> void:
	super._draw()
	_draw_chapter_badge()

func _draw_tile(tile: Vector2i, code: String) -> void:
	var p: Vector2 = _tile_to_px(tile)
	var texture: Texture2D = WORLD_ART.tile_texture(code, tile.x + tile.y * 3)
	if texture != null:
		draw_texture_rect(texture, Rect2(p, Vector2(TILE, TILE)), false)
	_draw_environment_motion(tile, code, p)
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
	var frame: int = posmod(int(elapsed * 2.0 + float(tile.x + tile.y)), 2)
	var texture: Texture2D = WORLD_ART.npc_texture(npc, "down", frame)
	if texture != null:
		draw_texture_rect(texture, Rect2(p, Vector2(TILE, TILE)), false)
	if bool(npc.get("trainer", false)):
		var defeated: bool = WORLD_TRAINERS.is_defeated(npc_id, dialogue_flags)
		var marker: Color = Color("58d98a") if defeated else Color("f2d25f")
		draw_circle(p + Vector2(20, 4), 3.0, Color(0.05, 0.10, 0.12, 0.72))
		draw_circle(p + Vector2(20, 4), 2.0, marker)
		if not defeated:
			var bob: float = sin(elapsed * 5.0 + float(tile.x)) * 1.0
			draw_string(font, p + Vector2(16, 7 + bob), "!", HORIZONTAL_ALIGNMENT_CENTER, 8, 7, Color("fff6c0"))

func _draw_sprite_pickup(tile: Vector2i, pickup: Dictionary) -> void:
	var p: Vector2 = _tile_to_px(tile)
	var kind: String = "gear" if not str(pickup.get("gear", "")).is_empty() else "item"
	var texture: Texture2D = WORLD_ART.pickup_texture(kind)
	var bob: float = sin(elapsed * 4.5 + float(tile.x + tile.y)) * 1.5
	var rect: Rect2 = Rect2(p + Vector2(6, 6 + bob), Vector2(12, 12))
	draw_circle(rect.get_center(), 7.0, Color(0.90, 0.80, 0.35, 0.10))
	if texture != null:
		draw_texture_rect(texture, rect, false)

func _draw_environment_motion(tile: Vector2i, code: String, p: Vector2) -> void:
	var phase: float = elapsed * 2.4 + float(tile.x) * 0.73 + float(tile.y) * 0.37
	if code in ["A", "W"]:
		var y1: float = 8.0 + sin(phase) * 1.2
		var y2: float = 16.0 + sin(phase + 1.7) * 1.0
		draw_line(p + Vector2(3, y1), p + Vector2(TILE - 4, y1), Color(0.62, 0.93, 0.96, 0.24), 1.0)
		draw_line(p + Vector2(6, y2), p + Vector2(TILE - 7, y2), Color(0.55, 0.84, 0.91, 0.18), 1.0)
	elif code == "F":
		var sway: float = sin(phase * 1.4) * 1.2
		for ox: float in [6.0, 12.0, 18.0]:
			draw_line(p + Vector2(ox, 20), p + Vector2(ox + sway, 15), Color(0.67, 0.90, 0.55, 0.20), 1.0)
	elif code == "D":
		var pulse: float = 0.14 + 0.12 * (0.5 + 0.5 * sin(phase * 2.0))
		draw_rect(Rect2(p + Vector2(17, 5), Vector2(2, 2)), Color(0.35, 0.95, 0.90, pulse))
	elif code == "V":
		var radius: float = 2.0 + (0.5 + 0.5 * sin(phase)) * 2.0
		draw_circle(p + Vector2(12, 12), radius, Color(0.68, 0.49, 0.95, 0.08))
	elif code == "E":
		var glow: float = 0.12 + 0.10 * (0.5 + 0.5 * sin(phase * 2.4))
		draw_rect(Rect2(p + Vector2(3, 3), Vector2(TILE - 6, TILE - 6)), Color(0.35, 0.94, 0.84, glow), false, 1.0)

func _draw_chapter_badge() -> void:
	var completed: int = CAMPAIGN_PROGRESS.completed_boss_count(dialogue_flags)
	var stage: int = CAMPAIGN_PROGRESS.STAGE_VELA_TRIAL + completed
	stage = mini(stage, CAMPAIGN_PROGRESS.STAGE_POST_GAME)
	var title: String = CAMPAIGN_PROGRESS.title(stage)
	var badge: Rect2 = Rect2(116, 2, 128, 16)
	draw_rect(badge, Color(0.04, 0.12, 0.15, 0.88))
	draw_rect(badge, Color(0.25, 0.72, 0.69, 0.42), false, 1.0)
	draw_string(font, Vector2(121, 13), "R%d/8 · %s" % [mini(completed + 1, 8), title], HORIZONTAL_ALIGNMENT_CENTER, 118, 6, Color("bfe8e4"))

func _interact() -> void:
	if moving:
		return
	var target: Vector2i = player_tile + facing
	var discovery: Dictionary = WORLD_DISCOVERIES.at(zone_id, target, dialogue_flags)
	if not discovery.is_empty():
		var discovery_id: String = str(discovery.get("id", ""))
		var flag: String = WORLD_DISCOVERIES.flag_id(discovery_id)
		dialogue_flags[flag] = true
		dialog = "ODKRYCIE: %s\n%s\n%d/%d odkryć regionu" % [
			str(discovery.get("title", "ŚLAD")),
			str(discovery.get("text", "")),
			WORLD_DISCOVERIES.found_count(dialogue_flags),
			WORLD_DISCOVERIES.count()
		]
		dialogue_flag_requested.emit(flag)
		_play_cue("discovery")
		queue_redraw()
		return

	var pickup: Dictionary = WORLD_PICKUPS.at(zone_id, target)
	if not pickup.is_empty():
		var pickup_id: String = str(pickup.get("id", ""))
		if not WORLD_PICKUPS.is_collected(pickup_id, dialogue_flags):
			_play_cue("pickup")
	var npc: Dictionary = WORLD_NPCS.at(zone_id, target)
	if not npc.is_empty() and bool(npc.get("trainer", false)):
		_play_cue("trainer")
	if _tile_code(target) == "C":
		_play_cue("station")
	super._interact()

func _play_cue(cue_id: String) -> void:
	if _sfx == null or not is_instance_valid(_sfx):
		_sfx = RETRO_SFX.new()
		add_child(_sfx)
	_sfx.play_cue(cue_id)
