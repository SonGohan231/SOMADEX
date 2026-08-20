extends Control

signal finished

const DB = preload("res://scripts/data/monster_db.gd")
const ART = preload("res://scripts/data/monster_art.gd")
const EVOLUTION = preload("res://scripts/data/evolution_db.gd")

var event_data: Dictionary = {}
var font: Font
var elapsed: float = 0.0
var from_tex: Texture2D
var to_tex: Texture2D
var accepted: bool = false

func setup(evolution_event: Dictionary) -> void:
	event_data = evolution_event.duplicate(true)

func _ready() -> void:
	font = ThemeDB.fallback_font
	var from_name: String = str(event_data.get("from", "Luzik"))
	var to_name: String = str(event_data.get("to", from_name))
	from_tex = ART.texture_for(from_name)
	to_tex = ART.texture_for(to_name)
	set_process(true)
	set_process_unhandled_input(true)
	queue_redraw()

func _process(delta: float) -> void:
	elapsed += delta
	queue_redraw()

func _draw() -> void:
	var from_name: String = str(event_data.get("from", "Luzik"))
	var to_name: String = str(event_data.get("to", from_name))
	var level: int = maxi(1, int(event_data.get("level", 1)))
	var from_data: Dictionary = DB.get_monster(from_name)
	var to_data: Dictionary = DB.get_monster(to_name)
	var pulse: float = 0.5 + 0.5 * sin(elapsed * 5.0)

	draw_rect(Rect2(0, 0, 360, 800), Color("07161d"))
	for y: int in range(0, 800, 32):
		draw_line(Vector2(0, y), Vector2(360, y), Color(0.22, 0.75, 0.72, 0.025 + pulse * 0.018), 1.0)

	draw_string(font, Vector2(20, 54), "REZONANS EWOLUCYJNY", HORIZONTAL_ALIGNMENT_CENTER, 320, 20, Color("76e8e0"))
	draw_string(font, Vector2(20, 82), "Lv.%d · rodzina %02d" % [level, EVOLUTION.family_id(to_name)], HORIZONTAL_ALIGNMENT_CENTER, 320, 10, Color("87a9ab"))

	_draw_form_panel(Rect2(18, 124, 324, 210), from_name, from_data, from_tex, false, pulse)

	var beam_alpha: float = 0.25 + pulse * 0.50
	draw_line(Vector2(80, 378), Vector2(280, 378), Color(0.32, 0.92, 0.86, beam_alpha), 4.0)
	draw_circle(Vector2(180, 378), 23.0 + pulse * 8.0, Color(0.30, 0.91, 0.84, 0.08 + pulse * 0.12))
	draw_string(font, Vector2(142, 385), "▼", HORIZONTAL_ALIGNMENT_CENTER, 76, 22, Color("aafaf4"))

	_draw_form_panel(Rect2(18, 422, 324, 224), to_name, to_data, to_tex, true, pulse)

	draw_string(font, Vector2(24, 686), "%s ewoluował w %s!" % [from_name, to_name], HORIZONTAL_ALIGNMENT_CENTER, 312, 15, Color("f1fbf8"))
	var button: Rect2 = Rect2(78, 724, 204, 52)
	draw_rect(button, Color("17464d"))
	draw_rect(button, Color("5ee1d8"), false, 2.0)
	draw_string(font, button.position + Vector2(8, 33), "KONTYNUUJ", HORIZONTAL_ALIGNMENT_CENTER, button.size.x - 16, 14, Color("edfffc"))

func _draw_form_panel(rect: Rect2, creature_name: String, data: Dictionary, texture: Texture2D, evolved: bool, pulse: float) -> void:
	var accent: Color = data.get("accent", Color("5fcfc9")) as Color
	var bg: Color = accent.darkened(0.72)
	bg.a = 0.62
	draw_rect(rect, bg)
	draw_rect(rect, accent.lightened(0.12), false, 2.0 if not evolved else 3.0)
	if evolved:
		draw_rect(rect.grow(5.0), Color(accent.r, accent.g, accent.b, 0.10 + pulse * 0.10), false, 3.0)

	var art_rect: Rect2 = Rect2(rect.position + Vector2(12, 34), Vector2(140, 132))
	if texture != null:
		draw_texture_rect(texture, art_rect, false)
	else:
		_draw_runtime_emblem(art_rect, accent, EVOLUTION.stage(creature_name), pulse if evolved else 0.25)

	draw_string(font, rect.position + Vector2(166, 62), creature_name, HORIZONTAL_ALIGNMENT_LEFT, 142, 18, Color("f4fffd"))
	var stage: int = maxi(1, EVOLUTION.stage(creature_name))
	var stage_name: String = "FORMA BAZOWA"
	if stage == 2:
		stage_name = "EWOLUCJA I"
	elif stage >= 3:
		stage_name = "FORMA FINALNA"
	draw_string(font, rect.position + Vector2(166, 88), stage_name, HORIZONTAL_ALIGNMENT_LEFT, 142, 9, accent.lightened(0.32))
	draw_string(font, rect.position + Vector2(166, 118), "HP %d" % int(data.get("max_hp", 0)), HORIZONTAL_ALIGNMENT_LEFT, 130, 10, Color("aac4c4"))
	draw_string(font, rect.position + Vector2(166, 140), "ATK %d   OBR %d" % [int(data.get("attack", 0)), int(data.get("defense", 0))], HORIZONTAL_ALIGNMENT_LEFT, 140, 9, Color("aac4c4"))
	draw_string(font, rect.position + Vector2(166, 162), "SZYB %d" % int(data.get("speed", 0)), HORIZONTAL_ALIGNMENT_LEFT, 130, 9, Color("aac4c4"))
	var type_text: String = str(data.get("type", "REZONANS"))
	draw_string(font, rect.position + Vector2(166, 190), type_text, HORIZONTAL_ALIGNMENT_LEFT, 140, 9, accent.lightened(0.20))

func _draw_runtime_emblem(rect: Rect2, accent: Color, stage: int, pulse: float) -> void:
	var center: Vector2 = rect.get_center()
	var glow: float = 0.10 + pulse * 0.12
	draw_circle(center, 50.0, Color(accent.r, accent.g, accent.b, glow))
	var radius: float = 27.0 + float(maxi(1, stage) - 1) * 6.0
	draw_circle(center, radius, accent.darkened(0.30))
	draw_circle(center, radius, accent.lightened(0.28), false, 3.0)
	for i: int in range(3 + maxi(1, stage)):
		var angle: float = TAU * float(i) / float(3 + maxi(1, stage)) + elapsed * (0.15 if stage > 1 else 0.06)
		var p: Vector2 = center + Vector2(cos(angle), sin(angle)) * (radius + 13.0)
		draw_circle(p, 3.0 + float(stage), Color(accent.r, accent.g, accent.b, 0.72))
	draw_string(font, center + Vector2(-28, 7), "%d" % maxi(1, stage), HORIZONTAL_ALIGNMENT_CENTER, 56, 18, Color("f6fffd"))

func _unhandled_input(event: InputEvent) -> void:
	if accepted or elapsed < 0.30:
		return
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			_accept()
	elif event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		_accept()

func _accept() -> void:
	if accepted:
		return
	accepted = true
	finished.emit()
