extends Control

signal finished

const ART = preload("res://scripts/data/monster_art.gd")

var page := 0
var time := 0.0
var font: Font
var textures: Array[Texture2D] = []

var pages := [
	{
		"kicker":"ARCHIWUM SOMADEX · 07:42",
		"title":"Świat pozostawia ślady.",
		"body":"Każdy ruch, drganie i zmiana napięcia tworzą wzorzec.\nNiektóre wzorce nauczyły się odpowiadać.\nNazwano je Somaskanami."
	},
	{
		"kicker":"STACJA VELA · SEKTOR PÓŁNOCNY",
		"title":"Nie walczysz samą siłą.",
		"body":"Trener wpływa na przebieg starcia: rozkazami, sprzętem\ni własnym rezonansem. Zwycięża drużyna, która potrafi\nłączyć efekty i reagować na pole walki."
	},
	{
		"kicker":"PROTOKÓŁ 001 · PIERWSZY KONTAKT",
		"title":"Wybierz pierwszego partnera.",
		"body":"Dr Irena czeka w laboratorium. Trzy Somaskany\nwykazały zgodność z Twoim profilem. Od tego wyboru\nzacznie się droga przez region Vela."
	}
]

func _ready() -> void:
	font = ThemeDB.fallback_font
	textures = [ART.texture_for("Luzik"), ART.texture_for("Bocznik"), ART.texture_for("Nucik")]
	set_process(true)
	queue_redraw()

func _process(delta: float) -> void:
	time += delta
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(0,0,360,800), Color("07131a"))
	for x in range(0, 361, 24):
		draw_line(Vector2(x,0), Vector2(x,260), Color(0.2,0.8,0.78,0.055), 1.0)
	for y in range(0, 261, 24):
		draw_line(Vector2(0,y), Vector2(360,y), Color(0.2,0.8,0.78,0.055), 1.0)

	draw_string(font, Vector2(28, 54), str(pages[page]["kicker"]), HORIZONTAL_ALIGNMENT_LEFT, 304, 11, Color("64d7d2"))
	draw_string(font, Vector2(28, 102), str(pages[page]["title"]), HORIZONTAL_ALIGNMENT_LEFT, 304, 24, Color("f0fbf8"))

	var art_rect := Rect2(28, 136, 304, 228)
	draw_rect(Rect2(24,132,312,236), Color("15323d"))
	if textures[page] != null:
		draw_texture_rect(textures[page], art_rect, false)
	draw_rect(art_rect, Color(0.31,0.91,0.87,0.42), false, 2.0)
	var scanner_x := 32.0 + fmod(time * 58.0, 294.0)
	draw_line(Vector2(scanner_x,142), Vector2(scanner_x,358), Color(0.45,1.0,0.95,0.26), 1.0)

	var body_box := Rect2(28, 398, 304, 184)
	draw_rect(body_box, Color("0d222b"))
	draw_rect(body_box, Color("24505b"), false, 2.0)
	var lines := str(pages[page]["body"]).split("\n")
	for i in range(lines.size()):
		draw_string(font, Vector2(44, 438 + i * 31), str(lines[i]), HORIZONTAL_ALIGNMENT_LEFT, 274, 13, Color("d2e7e5"))

	for i in range(3):
		var c := Color("4be0da") if i == page else Color("29444b")
		draw_circle(Vector2(156 + i * 24, 616), 5.0, c)

	var next_rect := Rect2(44, 666, 272, 58)
	draw_rect(next_rect, Color("174650"))
	draw_rect(next_rect, Color("52e7df"), false, 2.0)
	var label := "WYBIERZ PARTNERA" if page == 2 else "DALEJ"
	draw_string(font, Vector2(60, 702), label, HORIZONTAL_ALIGNMENT_CENTER, 240, 15, Color("effffd"))
	draw_string(font, Vector2(268, 42), "POMIŃ", HORIZONTAL_ALIGNMENT_CENTER, 72, 10, Color("718d92"))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_ENTER, KEY_SPACE, KEY_Z, KEY_RIGHT]:
			_next()
		elif event.keycode in [KEY_ESCAPE, KEY_X]:
			finished.emit()
	elif event is InputEventScreenTouch and event.pressed:
		if Rect2(44,666,272,58).has_point(event.position):
			_next()
		elif Rect2(266,18,82,48).has_point(event.position):
			finished.emit()

func _next() -> void:
	if page >= 2:
		finished.emit()
	else:
		page += 1
		queue_redraw()
