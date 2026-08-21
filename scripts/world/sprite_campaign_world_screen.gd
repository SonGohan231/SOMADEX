extends "res://scripts/world/campaign_world_screen.gd"

const WORLD_ART = preload("res://scripts/art/world_pixel_art.gd")
const CC0_PIXEL = preload("res://scripts/art/cc0_pixel_runtime.gd")
const WORLD_NPCS = preload("res://scripts/data/runtime_npc_db.gd")
const WORLD_PICKUPS = preload("res://scripts/data/pickup_db.gd")
const WORLD_TRAINERS = preload("res://scripts/data/runtime_trainer_db.gd")
const WORLD_DISCOVERIES = preload("res://scripts/data/campaign_discovery_db.gd")
const WORLD_EVENTS = preload("res://scripts/data/campaign_event_db.gd")
const RETRO_SFX = preload("res://scripts/audio/retro_sfx.gd")
const RETRO_MUSIC = preload("res://scripts/audio/retro_music.gd")
const SCENE_TRANSITION = preload("res://scripts/ui/scene_transition.gd")

var _sfx: Node = null
var _music: Node = null

func _ready() -> void:
	super._ready()
	var external_font: Font = CC0_PIXEL.pixel_font()
	if external_font != null:
		font = external_font
	_music = RETRO_MUSIC.new()
	add_child(_music)
	var zone_data: Dictionary = CAMPAIGN_ZONES.zone_info(zone_id)
	_music.play_theme(RETRO_MUSIC.theme_for_zone(zone_id, str(zone_data.get("biome", "")), CAMPAIGN_ZONES.is_post_game(zone_id)))
	var transition: Control = SCENE_TRANSITION.new()
	add_child(transition)
	transition.play_in(0.24)

func _draw() -> void:
	super._draw()
	_draw_chapter_badge()

func _draw_tile(tile: Vector2i, code: String) -> void:
	var p: Vector2 = _tile_to_px(tile)
	var variant: int = tile.x + tile.y * 3
	var texture: Texture2D = CC0_PIXEL.tile_texture(code, variant)
	if texture == null:
		texture = WORLD_ART.tile_texture(code, variant)
	if texture != null:
		draw_texture_rect(texture, Rect2(p, Vector2(TILE, TILE)), false)
	_draw_environment_motion(tile, code, p)
	_draw_event_hint(tile, p)
	var pickup: Dictionary = WORLD_PICKUPS.at(zone_id, tile)
	if not pickup.is_empty():
		var pickup_id: String = str(pickup.get("id", ""))
		if not WORLD_PICKUPS.is_collected(pickup_id, dialogue_flags):
			_draw_sprite_pickup(tile, pickup)
	var npc: Dictionary = WORLD_NPCS.at(zone_id, tile)
	if not npc.is_empty():
		_draw_sprite_npc(tile, npc)

func _draw_player() -> void:
	var frame: int = posmod(int(elapsed * 8.0), 4) if moving else 0
	var texture: Texture2D = CC0_PIXEL.player_texture(facing, moving, frame)
	if texture == null:
		texture = WORLD_ART.player_texture(facing, frame)
	if texture == null:
		super._draw_player()
		return
	var draw_rect := Rect2(player_px + Vector2(0, -4), Vector2(TILE, TILE))
	draw_texture_rect(texture, draw_rect, false)

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
			var bob: float = sin(elapsed * 5.0 + float(tile.x))
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

func _draw_event_hint(tile: Vector2i, p: Vector2) -> void:
	if abs(tile.x - player_tile.x) + abs(tile.y - player_tile.y) > 2:
		return
	var event: Dictionary = WORLD_EVENTS.at(zone_id, tile, dialogue_flags)
	if event.is_empty():
		return
	var pulse: float = 0.55 + 0.35 * sin(elapsed * 5.0 + float(tile.x + tile.y))
	var center: Vector2 = p + Vector2(TILE / 2.0, 5.0)
	draw_circle(center, 4.0, Color(0.30, 0.95, 0.88, 0.10 + pulse * 0.12))
	draw_line(center + Vector2(-2, 0), center + Vector2(2, 0), Color(0.70, 1.0, 0.94, pulse), 1.0)
	draw_line(center + Vector2(0, -2), center + Vector2(0, 2), Color(0.70, 1.0, 0.94, pulse), 1.0)

func _draw_environment_motion(tile: Vector2i, code: String, p: Vector2) -> void:
	var phase: float = elapsed * 2.4 + float(tile.x) * 0.73 + float(tile.y) * 0.37
	if code in ["A", "W"]:
		var y1: float = 8.0 + sin(phase) * 1.2
		var y2: float = 16.0 + sin(phase + 1.7)
		draw_line(p + Vector2(3, y1), p + Vector2(TILE - 4, y1), Color(0.62, 0.93, 0.96, 0.20), 1.0)
		draw_line(p + Vector2(6, y2), p + Vector2(TILE - 7, y2), Color(0.55, 0.84, 0.91, 0.14), 1.0)
	elif code == "F":
		var sway: float = sin(phase * 1.4) * 1.2
		for ox: float in [6.0, 12.0, 18.0]:
			draw_line(p + Vector2(ox, 20), p + Vector2(ox + sway, 15), Color(0.67, 0.90, 0.55, 0.14), 1.0)
	elif code == "D":
		var pulse: float = 0.10 + 0.09 * (0.5 + 0.5 * sin(phase * 2.0))
		draw_rect(Rect2(p + Vector2(17, 5), Vector2(2, 2)), Color(0.35, 0.95, 0.90, pulse))
	elif code == "V":
		var radius: float = 2.0 + (0.5 + 0.5 * sin(phase)) * 2.0
		draw_circle(p + Vector2(12, 12), radius, Color(0.68, 0.49, 0.95, 0.06))
	elif code == "E":
		var glow: float = 0.10 + 0.08 * (0.5 + 0.5 * sin(phase * 2.4))
		draw_rect(Rect2(p + Vector2(3, 3), Vector2(TILE - 6, TILE - 6)), Color(0.35, 0.94, 0.84, glow), false, 1.0)

func _draw_chapter_badge() -> void:
	var completed: int = CAMPAIGN_PROGRESS.completed_boss_count(dialogue_flags)
	var stage: int = mini(CAMPAIGN_PROGRESS.STAGE_VELA_TRIAL + completed, CAMPAIGN_PROGRESS.STAGE_POST_GAME)
	var title: String = CAMPAIGN_PROGRESS.title(stage)
	var badge: Rect2 = Rect2(108, 4, 144, 16)
	draw_rect(badge, Color(0.04, 0.12, 0.15, 0.88))
	draw_rect(badge, Color(0.25, 0.72, 0.69, 0.46), false, 1.0)
	var chapter_label: String = "POST · %s" % title if completed >= 8 else "R%d/8 · %s" % [completed + 1, title]
	draw_string(font, Vector2(112, 15), chapter_label, HORIZONTAL_ALIGNMENT_CENTER, 136, 6, Color("d4f6f1"))

func _interact() -> void:
	if moving:
		return
	var target: Vector2i = player_tile + facing
	var event: Dictionary = WORLD_EVENTS.at(zone_id, target, dialogue_flags)
	if not event.is_empty():
		var event_id: String = str(event.get("id", ""))
		var event_flag: String = WORLD_EVENTS.flag_id(event_id)
		dialogue_flags[event_flag] = true
		dialog = "WYDARZENIE: %s\n%s\n%d/%d zdarzeń opcjonalnych" % [str(event.get("title", "ŚLAD")), str(event.get("text", "")), WORLD_EVENTS.completed_count(dialogue_flags), WORLD_EVENTS.count()]
		dialogue_flag_requested.emit(event_flag)
		_play_cue("chapter")
		queue_redraw()
		return
	var discovery: Dictionary = WORLD_DISCOVERIES.at(zone_id, target, dialogue_flags)
	if not discovery.is_empty():
		var discovery_id: String = str(discovery.get("id", ""))
		var flag: String = WORLD_DISCOVERIES.flag_id(discovery_id)
		dialogue_flags[flag] = true
		dialog = "ODKRYCIE: %s\n%s\n%d/%d odkryć regionu" % [str(discovery.get("title", "ŚLAD")), str(discovery.get("text", "")), WORLD_DISCOVERIES.found_count(dialogue_flags), WORLD_DISCOVERIES.count()]
		dialogue_flag_requested.emit(flag)
		_play_cue("discovery")
		queue_redraw()
		return
	var pickup: Dictionary = WORLD_PICKUPS.at(zone_id, target)
	if not pickup.is_empty() and not WORLD_PICKUPS.is_collected(str(pickup.get("id", "")), dialogue_flags):
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
