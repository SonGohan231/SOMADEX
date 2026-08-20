extends Control

signal starter_chosen(name: String)

const DB = preload("res://scripts/data/monster_db.gd")
const ART = preload("res://scripts/data/monster_art_alpha.gd")

var selected := 0
var font: Font
var names := DB.starters()
var textures: Array[Texture2D] = []
var time := 0.0

func _ready() -> void:
	font = ThemeDB.fallback_font
	for name in names:
		textures.append(ART.texture_for(name))
	set_process(true)
	queue_redraw()

func _process(delta: float) -> void:
	time += delta
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(0,0,360,800), Color("08171e"))
	draw_rect(Rect2(0,0,360,118), Color("0d2a34"))
	draw_string(font, Vector2(24,43), "LABORATORIUM VELA", HORIZONTAL_ALIGNMENT_LEFT, 310, 11, Color("55ded7"))
	draw_string(font, Vector2(24,76), "Wybierz pierwszego Somaskana", HORIZONTAL_ALIGNMENT_LEFT, 314, 20, Color("f3fbf8"))
	draw_string(font, Vector2(24,101), "Dotknij karty, aby zobaczyć profil.", HORIZONTAL_ALIGNMENT_LEFT, 310, 11, Color("8eaaae"))

	for i in range(3):
		_draw_card(i)

	var choose_rect := Rect2(44, 686, 272, 58)
	draw_rect(choose_rect, Color("174650"))
	draw_rect(choose_rect, Color("52e7df"), false, 2.0)
	draw_string(font, Vector2(60, 722), "WYBIERAM: %s" % names[selected].to_upper(), HORIZONTAL_ALIGNMENT_CENTER, 240, 14, Color("effffd"))
	draw_string(font, Vector2(20, 775), "Później drużynę rozbudujesz o kolejne gatunki.", HORIZONTAL_ALIGNMENT_CENTER, 320, 10, Color("6f8d91"))

func _draw_card(index: int) -> void:
	var name := names[index]
	var info := DB.get_monster(name)
	var y := 136 + index * 176
	var rect := Rect2(20, y, 320, 158)
	var active := selected == index
	var fill := Color("163641") if active else Color("0d242d")
	var border: Color = info["accent"] if active else Color("294b54")
	draw_rect(rect, fill)
	draw_rect(rect, border, false, 2.0 if not active else 3.0)
	if active:
		var pulse := 0.55 + 0.25 * sin(time * 3.2)
		draw_rect(Rect2(rect.position + Vector2(4,4), Vector2(5,150)), Color(border.r,border.g,border.b,pulse))

	if textures[index] != null:
		draw_texture_rect(textures[index], Rect2(31,y+13,126,94), false)
		draw_rect(Rect2(31,y+13,126,94), Color(border.r,border.g,border.b,0.35), false, 1.0)

	draw_string(font, Vector2(174, y+34), name, HORIZONTAL_ALIGNMENT_LEFT, 150, 19, Color("f4fffc"))
	draw_string(font, Vector2(174, y+55), str(info["type"]) + " · " + str(info["role"]), HORIZONTAL_ALIGNMENT_LEFT, 150, 9, border)
	var desc := str(info["description"])
	var pieces := _wrap(desc, 24)
	for line_i in range(min(3, pieces.size())):
		draw_string(font, Vector2(174, y+80 + line_i*17), pieces[line_i], HORIZONTAL_ALIGNMENT_LEFT, 150, 10, Color("b9cccf"))
	draw_string(font, Vector2(31, y+135), "HP %d" % int(info["max_hp"]), HORIZONTAL_ALIGNMENT_LEFT, 80, 10, Color("9cc8ca"))
	draw_string(font, Vector2(112, y+135), "4 ruchy startowe", HORIZONTAL_ALIGNMENT_LEFT, 120, 10, Color("9cc8ca"))
	if active:
		draw_string(font, Vector2(252, y+137), "WYBRANY", HORIZONTAL_ALIGNMENT_RIGHT, 72, 9, border)

func _wrap(text: String, width: int) -> Array[String]:
	var out: Array[String] = []
	var current := ""
	for word in text.split(" "):
		var candidate := word if current.is_empty() else current + " " + word
		if candidate.length() > width and not current.is_empty():
			out.append(current)
			current = word
		else:
			current = candidate
	if not current.is_empty():
		out.append(current)
	return out

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_UP, KEY_W, KEY_LEFT, KEY_A]:
			selected = (selected + 2) % 3
		elif event.keycode in [KEY_DOWN, KEY_S, KEY_RIGHT, KEY_D]:
			selected = (selected + 1) % 3
		elif event.keycode in [KEY_ENTER, KEY_SPACE, KEY_Z]:
			starter_chosen.emit(names[selected])
	elif event is InputEventScreenTouch and event.pressed:
		for i in range(3):
			if Rect2(20,136+i*176,320,158).has_point(event.position):
				selected = i
				queue_redraw()
				return
		if Rect2(44,686,272,58).has_point(event.position):
			starter_chosen.emit(names[selected])
