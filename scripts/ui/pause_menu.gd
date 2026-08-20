extends Control

signal close_requested
signal save_requested
signal haptics_changed(value: bool)

const DB = preload("res://scripts/data/monster_db.gd")
const ART = preload("res://scripts/data/monster_art.gd")

var font: Font
var selected: int = 0
var section: String = "root"
var starter: String = "Luzik"
var trainer_level: int = 1
var trainer_xp: int = 0
var discovered: int = 1
var haptics: bool = true
var message: String = ""
var message_until: int = 0
var texture: Texture2D

var items: Array[String] = ["DRUŻYNA", "SOMADEX", "PLECAK", "TRENER", "ZAPISZ", "USTAWIENIA", "WRÓĆ DO GRY"]

func setup(starter_name: String, level: int, xp: int, found: int, use_haptics: bool) -> void:
	starter = starter_name
	trainer_level = level
	trainer_xp = xp
	discovered = found
	haptics = use_haptics

func _ready() -> void:
	font = ThemeDB.fallback_font
	texture = ART.texture_for(starter)
	queue_redraw()

func show_message(text: String) -> void:
	message = text
	message_until = Time.get_ticks_msec() + 2200
	queue_redraw()

func _process(_delta: float) -> void:
	if not message.is_empty() and Time.get_ticks_msec() < message_until:
		queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(0, 0, 360, 800), Color("07151c"))
	draw_rect(Rect2(0, 0, 360, 92), Color("0d2a34"))
	draw_string(font, Vector2(22, 37), "SOMADEX · MENU", HORIZONTAL_ALIGNMENT_LEFT, 240, 18, Color("edfffc"))
	draw_string(font, Vector2(22, 62), "Trener Lv.%d  ·  EXP %d" % [trainer_level, trainer_xp], HORIZONTAL_ALIGNMENT_LEFT, 220, 10, Color("7eacad"))
	draw_string(font, Vector2(288, 37), "ESC", HORIZONTAL_ALIGNMENT_RIGHT, 50, 10, Color("698b90"))
	if section == "root":
		_draw_root()
	else:
		_draw_section()
	if not message.is_empty() and Time.get_ticks_msec() < message_until:
		var r: Rect2 = Rect2(42, 728, 276, 48)
		draw_rect(r, Color("183842"))
		draw_rect(r, Color("4de0d9"), false, 2.0)
		draw_string(font, Vector2(55, 758), message, HORIZONTAL_ALIGNMENT_CENTER, 250, 12, Color("edfffc"))

func _draw_root() -> void:
	var card: Rect2 = Rect2(18, 108, 324, 124)
	draw_rect(card, Color("102730"))
	draw_rect(card, Color("2c5d65"), false, 2.0)
	if texture != null:
		draw_texture_rect(texture, Rect2(26, 116, 136, 102), false)
	var info: Dictionary = DB.get_monster(starter)
	draw_string(font, Vector2(178, 140), starter, HORIZONTAL_ALIGNMENT_LEFT, 150, 18, Color("f3fffc"))
	draw_string(font, Vector2(178, 160), str(info["type"]) + " · partner", HORIZONTAL_ALIGNMENT_LEFT, 150, 9, info["accent"])
	draw_string(font, Vector2(178, 188), "Odkryte: %d / 50" % discovered, HORIZONTAL_ALIGNMENT_LEFT, 150, 11, Color("adc7c9"))
	draw_string(font, Vector2(178, 207), "Drzewka trenera: 5", HORIZONTAL_ALIGNMENT_LEFT, 150, 11, Color("adc7c9"))
	for i: int in range(items.size()):
		var r: Rect2 = _item_rect(i)
		var active: bool = i == selected
		draw_rect(r, Color("173a44") if active else Color("0d242d"))
		draw_rect(r, Color("50dfd8") if active else Color("294b54"), false, 2.0)
		if active:
			draw_rect(Rect2(r.position, Vector2(5, r.size.y)), Color("50dfd8"))
		draw_string(font, Vector2(r.position.x + 16, r.position.y + 29), items[i], HORIZONTAL_ALIGNMENT_LEFT, 240, 13, Color("edfffc") if active else Color("adc5c6"))
		if i in [0, 1, 2, 3, 5]:
			draw_string(font, Vector2(r.end.x - 24, r.position.y + 28), "›", HORIZONTAL_ALIGNMENT_CENTER, 20, 16, Color("65a7a7"))

func _draw_section() -> void:
	var title_map: Dictionary = {"party": "DRUŻYNA", "dex": "SOMADEX", "bag": "PLECAK", "trainer": "TRENER", "settings": "USTAWIENIA"}
	draw_string(font, Vector2(22, 126), str(title_map.get(section, "MENU")), HORIZONTAL_ALIGNMENT_LEFT, 300, 17, Color("58e2dc"))
	var panel: Rect2 = Rect2(18, 148, 324, 500)
	draw_rect(panel, Color("0c222b"))
	draw_rect(panel, Color("294f59"), false, 2.0)
	match section:
		"party": _draw_party(panel)
		"dex": _draw_dex(panel)
		"bag": _draw_bag(panel)
		"trainer": _draw_trainer(panel)
		"settings": _draw_settings(panel)
	var back: Rect2 = Rect2(18, 674, 126, 44)
	draw_rect(back, Color("17323b"))
	draw_rect(back, Color("37616a"), false, 2.0)
	draw_string(font, Vector2(28, back.position.y + 28), "‹ WSTECZ", HORIZONTAL_ALIGNMENT_CENTER, 106, 11, Color("dbeeed"))

func _draw_party(panel: Rect2) -> void:
	if texture != null:
		draw_texture_rect(texture, Rect2(panel.position + Vector2(16, 18), Vector2(144, 108)), false)
	var info: Dictionary = DB.get_monster(starter)
	draw_string(font, panel.position + Vector2(176, 44), starter, HORIZONTAL_ALIGNMENT_LEFT, 130, 18, Color("f3fffc"))
	draw_string(font, panel.position + Vector2(176, 66), str(info["role"]), HORIZONTAL_ALIGNMENT_LEFT, 130, 10, info["accent"])
	draw_string(font, panel.position + Vector2(176, 91), "HP %d" % int(info["max_hp"]), HORIZONTAL_ALIGNMENT_LEFT, 130, 11, Color("afc8c8"))
	draw_string(font, panel.position + Vector2(16, 160), "Aktywne ruchy", HORIZONTAL_ALIGNMENT_LEFT, 280, 12, Color("5be2dc"))
	var moves: Array = info["moves"]
	for i: int in range(moves.size()):
		var move_data: Dictionary = moves[i]
		draw_string(font, panel.position + Vector2(24, 196 + i * 54), "%d. %s" % [i + 1, str(move_data["name"])], HORIZONTAL_ALIGNMENT_LEFT, 270, 12, Color("e1f1ef"))
		draw_string(font, panel.position + Vector2(40, 214 + i * 54), str(move_data["note"]), HORIZONTAL_ALIGNMENT_LEFT, 260, 9, Color("76979b"))

func _draw_dex(panel: Rect2) -> void:
	draw_string(font, panel.position + Vector2(20, 42), "ODKRYTE GATUNKI", HORIZONTAL_ALIGNMENT_LEFT, 260, 12, Color("5be2dc"))
	draw_string(font, panel.position + Vector2(20, 78), "%d / 50" % discovered, HORIZONTAL_ALIGNMENT_LEFT, 260, 28, Color("f2fffc"))
	draw_rect(Rect2(panel.position + Vector2(20, 102), Vector2(284, 12)), Color("17353e"))
	draw_rect(Rect2(panel.position + Vector2(20, 102), Vector2(284.0 * float(discovered) / 50.0, 12)), Color("52d9d3"))
	draw_string(font, panel.position + Vector2(20, 152), "Pierwszy region zawiera 50 linii ewolucyjnych.", HORIZONTAL_ALIGNMENT_LEFT, 284, 10, Color("9cb8ba"))
	draw_string(font, panel.position + Vector2(20, 178), "Baza danych jest przygotowana do dalszej rozbudowy.", HORIZONTAL_ALIGNMENT_LEFT, 284, 10, Color("9cb8ba"))

func _draw_bag(panel: Rect2) -> void:
	var bag_items: Array = [["Regenerator ×3", "Leczenie Somaskana"], ["Moduł chwytu ×5", "Próba pozyskania dzikiego Somaskana"], ["Sonda Vela ×1", "Analiza pola i ukrytych sygnałów"]]
	for i: int in range(bag_items.size()):
		var y: int = 32 + i * 104
		var entry: Array = bag_items[i]
		draw_rect(Rect2(panel.position + Vector2(16, y), Vector2(292, 84)), Color("122f38"))
		draw_string(font, panel.position + Vector2(30, y + 30), str(entry[0]), HORIZONTAL_ALIGNMENT_LEFT, 250, 13, Color("effaf8"))
		draw_string(font, panel.position + Vector2(30, y + 53), str(entry[1]), HORIZONTAL_ALIGNMENT_LEFT, 250, 9, Color("809fa2"))

func _draw_trainer(panel: Rect2) -> void:
	var paths: Array[String] = ["TAKTYK", "OPIEKUN", "BADACZ", "TECHNIK", "AWANGARDZISTA"]
	draw_string(font, panel.position + Vector2(20, 36), "5 DRÓG ROZWOJU", HORIZONTAL_ALIGNMENT_LEFT, 260, 12, Color("5be2dc"))
	for i: int in range(paths.size()):
		var y: int = 66 + i * 72
		draw_rect(Rect2(panel.position + Vector2(18, y), Vector2(288, 54)), Color("12303a"))
		draw_rect(Rect2(panel.position + Vector2(18, y), Vector2(6, 54)), Color("355e68"))
		draw_string(font, panel.position + Vector2(38, y + 24), paths[i], HORIZONTAL_ALIGNMENT_LEFT, 180, 12, Color("e6f4f2"))
		draw_string(font, panel.position + Vector2(252, y + 24), "0 pkt", HORIZONTAL_ALIGNMENT_RIGHT, 52, 10, Color("789a9d"))
	draw_string(font, panel.position + Vector2(20, 456), "Punkty talentów odblokują się wraz z fabułą.", HORIZONTAL_ALIGNMENT_LEFT, 280, 10, Color("76979b"))

func _draw_settings(panel: Rect2) -> void:
	draw_string(font, panel.position + Vector2(20, 42), "STEROWANIE", HORIZONTAL_ALIGNMENT_LEFT, 260, 12, Color("5be2dc"))
	draw_string(font, panel.position + Vector2(20, 84), "Wibracje dotykowe", HORIZONTAL_ALIGNMENT_LEFT, 200, 13, Color("e4f3f1"))
	var toggle: Rect2 = Rect2(panel.position + Vector2(236, 60), Vector2(62, 32))
	draw_rect(toggle, Color("24605f") if haptics else Color("26383d"))
	draw_circle(toggle.position + Vector2(46 if haptics else 16, 16), 11, Color("65e5df") if haptics else Color("72878b"))
	draw_string(font, panel.position + Vector2(20, 128), "Dotknij przełącznika, aby zmienić ustawienie.", HORIZONTAL_ALIGNMENT_LEFT, 280, 10, Color("7f9fa1"))
	draw_string(font, panel.position + Vector2(20, 188), "Wersja: SOMADEX Core v0.2", HORIZONTAL_ALIGNMENT_LEFT, 280, 11, Color("9bb8ba"))

func _item_rect(i: int) -> Rect2:
	return Rect2(30, 250 + i * 59, 300, 47)

func _toggle_rect() -> Rect2:
	return Rect2(254, 208, 62, 32)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if not key_event.pressed or key_event.echo:
			return
		if section != "root":
			if key_event.keycode in [KEY_ESCAPE, KEY_X, KEY_BACKSPACE]:
				section = "root"
				queue_redraw()
			return
		if key_event.keycode in [KEY_UP, KEY_W]: selected = (selected + items.size() - 1) % items.size()
		elif key_event.keycode in [KEY_DOWN, KEY_S]: selected = (selected + 1) % items.size()
		elif key_event.keycode in [KEY_ENTER, KEY_SPACE, KEY_Z]: _activate()
		elif key_event.keycode in [KEY_ESCAPE, KEY_X, KEY_M]: close_requested.emit()
		queue_redraw()
	elif event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event as InputEventScreenTouch
		if not touch.pressed:
			return
		var pos: Vector2 = touch.position
		if section != "root":
			if Rect2(18, 674, 126, 44).has_point(pos):
				section = "root"
				queue_redraw()
			elif section == "settings" and _toggle_rect().has_point(pos):
				haptics = not haptics
				haptics_changed.emit(haptics)
				queue_redraw()
			return
		for i: int in range(items.size()):
			if _item_rect(i).has_point(pos):
				selected = i
				_activate()
				return

func _activate() -> void:
	match selected:
		0: section = "party"
		1: section = "dex"
		2: section = "bag"
		3: section = "trainer"
		4: save_requested.emit()
		5: section = "settings"
		6: close_requested.emit()
	queue_redraw()
