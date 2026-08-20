extends Control

signal new_game_requested
signal load_requested

const ART = preload("res://scripts/data/monster_art.gd")

var selected: int = 0
var has_save: bool = false
var notice: String = ""
var notice_until: int = 0
var elapsed: float = 0.0
var font: Font
var hero_texture: Texture2D
var touch_buttons: Array[Button] = []

func setup(save_exists: bool, message: String = "") -> void:
	has_save = save_exists
	notice = message
	notice_until = Time.get_ticks_msec() + 2400 if not message.is_empty() else 0

func _ready() -> void:
	font = ThemeDB.fallback_font
	hero_texture = ART.texture_for("Luzik")
	_build_touch_buttons()
	set_process(true)
	queue_redraw()

func _process(delta: float) -> void:
	elapsed += delta
	queue_redraw()

func _draw() -> void:
	_draw_background()
	_draw_brand()
	_draw_hero()
	_draw_buttons()
	if not notice.is_empty() and Time.get_ticks_msec() < notice_until:
		_draw_notice()

func _draw_background() -> void:
	draw_rect(Rect2(0, 0, 360, 800), Color("08151d"))
	for i: int in range(11):
		var shade: Color = Color(0.04 + i * 0.003, 0.11 + i * 0.005, 0.15 + i * 0.006, 1.0)
		draw_rect(Rect2(0, i * 72, 360, 74), shade)
	for i: int in range(16):
		var x: float = float((i * 47 + 31) % 360)
		var y: float = float((i * 83 + 50) % 360)
		var pulse: float = 0.45 + 0.25 * sin(elapsed * 1.7 + float(i))
		draw_circle(Vector2(x, y), 1.5 + float(i % 2), Color(0.28, 0.9, 0.86, pulse))
	for y: int in range(520, 800, 8):
		draw_line(Vector2(0, y), Vector2(360, y), Color(0.15, 0.45, 0.48, 0.06), 1.0)

func _draw_brand() -> void:
	var glow: float = 0.75 + 0.2 * sin(elapsed * 2.2)
	draw_string(font, Vector2(20, 88), "SOMADEX", HORIZONTAL_ALIGNMENT_CENTER, 320, 38, Color(0.28, 0.95, 0.91, glow))
	draw_string(font, Vector2(20, 119), "KRONIKI REZONANSU", HORIZONTAL_ALIGNMENT_CENTER, 320, 14, Color("b9d9d7"))
	draw_line(Vector2(46, 138), Vector2(314, 138), Color("2c8e90"), 2.0)
	draw_string(font, Vector2(50, 158), "ALPHA 1 · engine migration", HORIZONTAL_ALIGNMENT_CENTER, 260, 10, Color("6e9297"))

func _draw_hero() -> void:
	var card: Rect2 = Rect2(40, 184, 280, 212)
	draw_rect(Rect2(card.position - Vector2(4, 4), card.size + Vector2(8, 8)), Color("13313c"))
	draw_rect(card, Color("0b2029"))
	if hero_texture != null:
		draw_texture_rect(hero_texture, Rect2(48, 192, 264, 198), false)
	draw_rect(Rect2(48, 192, 264, 198), Color(0.25, 0.95, 0.9, 0.35), false, 2.0)
	draw_rect(Rect2(58, 344, 126, 27), Color(0.03, 0.10, 0.14, 0.82))
	draw_string(font, Vector2(68, 363), "SOMASKAN 001 · LUZIK", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("d8fffb"))

func _draw_buttons() -> void:
	var labels: Array[String] = ["NOWA GRA", "KONTYNUUJ", "INFORMACJE"]
	for i: int in range(3):
		var rect: Rect2 = _button_rect(i)
		var active: bool = i == selected
		var fill: Color = Color("173d48") if active else Color("102630")
		var border: Color = Color("4fe7df") if active else Color("285361")
		if i == 1 and not has_save:
			fill = Color("121d23")
			border = Color("26343a")
		draw_rect(rect, fill)
		draw_rect(rect, border, false, 2.0)
		if active:
			draw_rect(Rect2(rect.position, Vector2(6, rect.size.y)), Color("4fe7df"))
		var text_color: Color = Color("eafffc") if (i != 1 or has_save) else Color("596970")
		draw_string(font, Vector2(rect.position.x + 18, rect.position.y + 34), labels[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, text_color)
		if i == 1 and not has_save:
			draw_string(font, Vector2(rect.end.x - 98, rect.position.y + 32), "brak zapisu", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("586870"))
	if selected == 2:
		draw_string(font, Vector2(25, 690), "silnik: akcje wejścia · battle manager · data-driven", HORIZONTAL_ALIGNMENT_CENTER, 310, 9, Color("789aa0"))
	else:
		draw_string(font, Vector2(25, 690), "Dotknij opcji lub użyj strzałek", HORIZONTAL_ALIGNMENT_CENTER, 310, 11, Color("789aa0"))

func _draw_notice() -> void:
	var r: Rect2 = Rect2(38, 714, 284, 52)
	draw_rect(r, Color("1b3138"))
	draw_rect(r, Color("47d9d2"), false, 2.0)
	draw_string(font, Vector2(50, 746), notice, HORIZONTAL_ALIGNMENT_CENTER, 260, 11, Color("eafffc"))

func _button_rect(index: int) -> Rect2:
	return Rect2(46, 438 + index * 70, 268, 54)

func _build_touch_buttons() -> void:
	for old_button: Button in touch_buttons:
		if is_instance_valid(old_button):
			old_button.queue_free()
	touch_buttons.clear()
	for i: int in range(3):
		var hit_button := Button.new()
		hit_button.name = "TouchHit%d" % i
		hit_button.text = ""
		hit_button.flat = true
		hit_button.focus_mode = Control.FOCUS_NONE
		hit_button.mouse_filter = Control.MOUSE_FILTER_STOP
		var rect := _button_rect(i)
		hit_button.position = rect.position
		hit_button.size = rect.size
		hit_button.pressed.connect(_on_touch_button_pressed.bind(i))
		add_child(hit_button)
		touch_buttons.append(hit_button)

func _on_touch_button_pressed(index: int) -> void:
	selected = index
	_activate_selected()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if not key_event.pressed or key_event.echo:
			return
		if key_event.keycode in [KEY_UP, KEY_W]:
			selected = (selected + 2) % 3
		elif key_event.keycode in [KEY_DOWN, KEY_S]:
			selected = (selected + 1) % 3
		elif key_event.keycode in [KEY_ENTER, KEY_SPACE, KEY_Z]:
			_activate_selected()
		queue_redraw()

func _activate_selected() -> void:
	match selected:
		0:
			new_game_requested.emit()
		1:
			if has_save:
				load_requested.emit()
			else:
				notice = "Brak zapisu gry"
				notice_until = Time.get_ticks_msec() + 2400
		2:
			notice = "Alpha 1 · migracja na gotowy fundament monster-RPG"
			notice_until = Time.get_ticks_msec() + 3200
	queue_redraw()
