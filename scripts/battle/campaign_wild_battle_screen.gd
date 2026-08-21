extends "res://scripts/battle/loadout_battle_screen.gd"

const CAMPAIGN_BALANCE = preload("res://scripts/data/campaign_battle_balance.gd")
const CAMPAIGN_CAPTURE = preload("res://scripts/data/campaign_capture_balance.gd")
const BATTLE_MUSIC = preload("res://scripts/audio/retro_music.gd")
const SCENE_TRANSITION = preload("res://scripts/ui/scene_transition.gd")
const CC0_PIXEL = preload("res://scripts/art/cc0_pixel_runtime.gd")

var _battle_music: Node = null

func setup(
	party_data: Array,
	start_active_index: int,
	level: int,
	enemy_name: String = "Wahlik",
	encounter_level: int = 3,
	battle_inventory: Dictionary = {},
	talent_levels: Dictionary = {},
	loadout: Dictionary = {}
) -> void:
	super.setup(party_data,start_active_index,level,enemy_name,encounter_level,battle_inventory,talent_levels,loadout)
	enemy_data = CAMPAIGN_CAPTURE.apply(enemy_data)
	var enemy_base_hp: int = int(enemy_data.get("max_hp", 20))
	enemy_max_hp = CAMPAIGN_BALANCE.scaled_max_hp(enemy_base_hp, enemy_level)
	enemy_hp = enemy_max_hp

func _ready() -> void:
	super._ready()
	var external_font: Font = CC0_PIXEL.pixel_font()
	if external_font != null:
		font = external_font
	_battle_music = BATTLE_MUSIC.new()
	add_child(_battle_music)
	_battle_music.play_theme("battle")
	var transition: Control = SCENE_TRANSITION.new()
	add_child(transition)
	transition.play_in(0.20)
	queue_redraw()

func _draw_background() -> void:
	# Clean handheld composition: scenery first, UI second. No developer headers.
	draw_rect(Rect2(0, 0, 360, 512), Color("b8dfcf"))
	draw_rect(Rect2(0, 0, 360, 112), Color("d9eee1"))
	draw_rect(Rect2(0, 112, 360, 68), Color("93c7a0"))
	for x: int in range(-12, 372, 24):
		var tree: Texture2D = CC0_PIXEL.tile_texture("T", int(x / 24))
		if tree != null:
			draw_texture_rect(tree, Rect2(x, 124, 40, 40), false)
	for y: int in range(180, 512, 24):
		for x: int in range(0, 360, 24):
			var grass: Texture2D = CC0_PIXEL.tile_texture("G", x / 24 + y / 24)
			if grass != null:
				draw_texture_rect(grass, Rect2(x, y, 24, 24), false)
	# A soft pixel band keeps the arena readable behind the creatures.
	draw_rect(Rect2(0, 180, 360, 332), Color(0.82, 0.93, 0.72, 0.20))
	_draw_rezonans_pips()

func _draw_enemy_side() -> void:
	var enemy_name: String = str(enemy_data.get("name", "Somaskan"))
	_draw_info_box(Rect2(14, 26, 176, 64), enemy_name, enemy_level, enemy_hp, enemy_max_hp, false)
	_draw_platform(Vector2(275, 263), 138.0, 30.0, Color(0.24, 0.44, 0.25, 0.34))
	var art_rect := Rect2(202, 104, 142, 150)
	_draw_actor_visual("enemy", enemy_name, art_rect, enemy_tex, true)

func _draw_player_side() -> void:
	var member: Dictionary = _active_member()
	_draw_platform(Vector2(101, 444), 168.0, 34.0, Color(0.22, 0.40, 0.24, 0.38))
	var art_rect := Rect2(18, 270, 182, 178)
	_draw_actor_visual("player", _active_name(), art_rect, player_tex, false)
	_draw_info_box(Rect2(164, 374, 182, 76), _active_name(), int(member.get("level", 1)), player_hp, player_max_hp, true)

func _draw_info_box(rect: Rect2, creature_name: String, level: int, hp: int, max_hp: int, show_numbers: bool) -> void:
	var shadow := Rect2(rect.position + Vector2(3, 4), rect.size)
	draw_rect(shadow, Color(0.10, 0.18, 0.16, 0.28))
	draw_rect(rect, Color("f4f1d9"))
	draw_rect(rect, Color("384b43"), false, 2.0)
	draw_string(font, rect.position + Vector2(10, 22), creature_name, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 66, 12, Color("26372f"))
	draw_string(font, rect.position + Vector2(rect.size.x - 58, 21), "Lv.%d" % level, HORIZONTAL_ALIGNMENT_RIGHT, 48, 9, Color("53665d"))
	draw_string(font, rect.position + Vector2(10, 42), "HP", HORIZONTAL_ALIGNMENT_LEFT, 22, 7, Color("66756b"))
	_draw_hp_bar(Rect2(rect.position + Vector2(34, 34), Vector2(rect.size.x - 46, 10)), hp, max_hp)
	if show_numbers:
		draw_string(font, rect.position + Vector2(rect.size.x - 93, 61), "%d / %d" % [hp, max_hp], HORIZONTAL_ALIGNMENT_RIGHT, 82, 8, Color("4c5d54"))
	var status_text: String = STATUS.summary(player_statuses if show_numbers else enemy_statuses)
	if not status_text.is_empty():
		draw_string(font, rect.position + Vector2(10, rect.size.y - 7), status_text, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 20, 6, Color("9b6a35"))

func _draw_platform(center: Vector2, width: float, height: float, color: Color) -> void:
	var half_h: int = maxi(1, int(height * 0.5))
	for iy: int in range(-half_h, half_h + 1):
		var ny: float = float(iy) / float(half_h)
		var extent: float = width * 0.5 * sqrt(maxf(0.0, 1.0 - ny * ny))
		draw_line(Vector2(center.x - extent, center.y + iy), Vector2(center.x + extent, center.y + iy), color, 1.0)

func _draw_rezonans_pips() -> void:
	var start := Vector2(278, 26)
	draw_string(font, Vector2(215, 31), "REZONANS", HORIZONTAL_ALIGNMENT_RIGHT, 55, 7, Color("365e57"))
	for i: int in range(trainer_focus_max):
		var p := start + Vector2(i * 18, 0)
		var fill := Color("47cfc4") if i < trainer_focus else Color("718b84")
		var points := PackedVector2Array([p + Vector2(6,0), p + Vector2(12,6), p + Vector2(6,12), p + Vector2(0,6)])
		draw_colored_polygon(points, fill)

func _draw_log() -> void:
	var r := Rect2(14, 502, 332, 104)
	draw_rect(r, Color("faf7e5"))
	draw_rect(r, Color("40534b"), false, 2.0)
	var wrapped: Array[String] = _wrap(log_text, 46)
	for i: int in range(mini(3, wrapped.size())):
		draw_string(font, Vector2(28, 533 + i * 22), wrapped[i], HORIZONTAL_ALIGNMENT_LEFT, 304, 10, Color("273b33"))

func _draw_root_menu() -> void:
	var labels: Array[String] = ["ATAK", "SOMASKANY", "PLECAK", "UCIECZKA"]
	var accents: Array[Color] = [Color("d75b4b"), Color("5b8dcc"), Color("d3a848"), Color("6f8b72")]
	for i: int in range(4):
		var r: Rect2 = _root_rect(i)
		var active: bool = i == selected
		var fill := Color("f4f1d9") if not active else Color("fff9e9")
		draw_rect(Rect2(r.position + Vector2(2, 3), r.size), Color(0.08,0.14,0.12,0.22))
		draw_rect(r, fill)
		draw_rect(r, accents[i] if active else Color("718078"), false, 2.0)
		if active:
			draw_rect(Rect2(r.position, Vector2(6, r.size.y)), accents[i])
		draw_string(font, r.position + Vector2(10, 36), labels[i], HORIZONTAL_ALIGNMENT_CENTER, r.size.x - 20, 11, Color("26372f"))

func _draw() -> void:
	super._draw()
	if mode == "root" and not battle_done:
		draw_string(font, Vector2(18, 788), "Wybierz akcję", HORIZONTAL_ALIGNMENT_LEFT, 160, 7, Color("64766e"))
