extends Control

signal close_requested
signal save_requested
signal haptics_changed(value: bool)
signal talent_spend_requested(path_id: String)

const DB = preload("res://scripts/data/monster_db.gd")
const ART = preload("res://scripts/data/monster_art.gd")
const PROGRESSION = preload("res://scripts/data/progression_db.gd")

var font: Font
var selected: int = 0
var section_selected: int = 0
var section: String = "root"
var profile: Dictionary = {}
var starter: String = "Luzik"
var trainer_level: int = 1
var trainer_xp: int = 0
var haptics: bool = true
var message: String = ""
var message_until: int = 0
var texture: Texture2D

var items: Array[String] = ["DRUŻYNA", "SOMADEX", "PLECAK", "TRENER", "MISJA", "ZAPISZ", "USTAWIENIA", "WRÓĆ DO GRY"]

func setup(profile_data: Dictionary) -> void:
	_apply_profile(profile_data)

func refresh_profile(profile_data: Dictionary, text: String = "") -> void:
	_apply_profile(profile_data)
	if not text.is_empty():
		show_message(text)
	queue_redraw()

func _apply_profile(profile_data: Dictionary) -> void:
	profile = profile_data.duplicate(true)
	starter = str(profile.get("starter", "Luzik"))
	trainer_level = maxi(1, int(profile.get("trainer_level", 1)))
	trainer_xp = maxi(0, int(profile.get("trainer_xp", 0)))
	haptics = bool(profile.get("haptics", true))
	if is_inside_tree():
		texture = ART.texture_for(starter)

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
	draw_string(font, Vector2(22, 62), "Trener Lv.%d  ·  EXP %d/%d" % [trainer_level, trainer_xp, PROGRESSION.xp_to_next_level(trainer_level)], HORIZONTAL_ALIGNMENT_LEFT, 250, 9, Color("7eacad"))
	draw_string(font, Vector2(288, 37), "v0.8", HORIZONTAL_ALIGNMENT_RIGHT, 50, 10, Color("698b90"))
	if section == "root":
		_draw_root()
	else:
		_draw_section()
	if not message.is_empty() and Time.get_ticks_msec() < message_until:
		var r: Rect2 = Rect2(42, 728, 276, 48)
		draw_rect(r, Color("183842"))
		draw_rect(r, Color("4de0d9"), false, 2.0)
		draw_string(font, Vector2(55, 758), message, HORIZONTAL_ALIGNMENT_CENTER, 250, 11, Color("edfffc"))

func _draw_root() -> void:
	var card: Rect2 = Rect2(18, 104, 324, 132)
	draw_rect(card, Color("102730"))
	draw_rect(card, Color("2c5d65"), false, 2.0)
	if texture != null:
		draw_texture_rect(texture, Rect2(26, 112, 124, 93), false)
	var info: Dictionary = DB.get_monster(starter)
	var accent: Color = info.get("accent", Color("55e8de"))
	draw_string(font, Vector2(164, 132), starter, HORIZONTAL_ALIGNMENT_LEFT, 160, 17, Color("f3fffc"))
	draw_string(font, Vector2(164, 151), str(info.get("type", "?")) + " · partner", HORIZONTAL_ALIGNMENT_LEFT, 160, 9, accent)
	var seen: Array = profile.get("seen", []) as Array
	var caught: Array = profile.get("caught", []) as Array
	draw_string(font, Vector2(164, 176), "Widziane %d · Schwytane %d" % [seen.size(), caught.size()], HORIZONTAL_ALIGNMENT_LEFT, 160, 9, Color("adc7c9"))
	var stage: int = int(profile.get("quest_stage", 0))
	draw_string(font, Vector2(164, 197), "CEL: " + PROGRESSION.quest_short(stage), HORIZONTAL_ALIGNMENT_LEFT, 160, 8, Color("66c4c1"))
	draw_string(font, Vector2(164, 218), "Punkty talentów: %d" % int(profile.get("talent_points", 0)), HORIZONTAL_ALIGNMENT_LEFT, 160, 9, Color("d9c96c"))
	for i: int in range(items.size()):
		var r: Rect2 = _item_rect(i)
		var active: bool = i == selected
		draw_rect(r, Color("173a44") if active else Color("0d242d"))
		draw_rect(r, Color("50dfd8") if active else Color("294b54"), false, 2.0)
		if active:
			draw_rect(Rect2(r.position, Vector2(5, r.size.y)), Color("50dfd8"))
		draw_string(font, Vector2(r.position.x + 16, r.position.y + 25), items[i], HORIZONTAL_ALIGNMENT_LEFT, 240, 11, Color("edfffc") if active else Color("adc5c6"))
		if i in [0, 1, 2, 3, 4, 6]:
			draw_string(font, Vector2(r.end.x - 24, r.position.y + 25), "›", HORIZONTAL_ALIGNMENT_CENTER, 20, 14, Color("65a7a7"))

func _draw_section() -> void:
	var title_map: Dictionary = {"party": "DRUŻYNA", "dex": "SOMADEX", "bag": "PLECAK", "trainer": "TRENER", "quest": "MISJA", "settings": "USTAWIENIA"}
	draw_string(font, Vector2(22, 126), str(title_map.get(section, "MENU")), HORIZONTAL_ALIGNMENT_LEFT, 300, 17, Color("58e2dc"))
	var panel: Rect2 = Rect2(18, 148, 324, 500)
	draw_rect(panel, Color("0c222b"))
	draw_rect(panel, Color("294f59"), false, 2.0)
	match section:
		"party": _draw_party(panel)
		"dex": _draw_dex(panel)
		"bag": _draw_bag(panel)
		"trainer": _draw_trainer(panel)
		"quest": _draw_quest(panel)
		"settings": _draw_settings(panel)
	var back: Rect2 = Rect2(18, 674, 126, 44)
	draw_rect(back, Color("17323b"))
	draw_rect(back, Color("37616a"), false, 2.0)
	draw_string(font, Vector2(28, back.position.y + 28), "‹ WSTECZ", HORIZONTAL_ALIGNMENT_CENTER, 106, 11, Color("dbeeed"))

func _draw_party(panel: Rect2) -> void:
	var party: Array = profile.get("party", []) as Array
	draw_string(font, panel.position + Vector2(18, 32), "AKTYWNA DRUŻYNA · %d/6" % party.size(), HORIZONTAL_ALIGNMENT_LEFT, 280, 11, Color("5be2dc"))
	for i: int in range(mini(6, party.size())):
		var name: String = str(party[i])
		var data: Dictionary = DB.get_monster(name)
		var y: int = 54 + i * 68
		var card: Rect2 = Rect2(panel.position + Vector2(16, y), Vector2(292, 56))
		draw_rect(card, Color("12303a"))
		var accent: Color = data.get("accent", Color("55e8de"))
		draw_rect(Rect2(card.position, Vector2(5, card.size.y)), accent)
		draw_string(font, card.position + Vector2(16, 23), "%d. %s" % [i + 1, name], HORIZONTAL_ALIGNMENT_LEFT, 150, 12, Color("effaf8"))
		draw_string(font, card.position + Vector2(16, 42), str(data.get("role", "Somaskan")), HORIZONTAL_ALIGNMENT_LEFT, 210, 8, Color("809fa2"))
		draw_string(font, card.position + Vector2(236, 31), "HP %d" % int(data.get("max_hp", 0)), HORIZONTAL_ALIGNMENT_RIGHT, 42, 9, accent)
	if party.is_empty():
		draw_string(font, panel.position + Vector2(20, 82), "Brak aktywnych Somaskanów.", HORIZONTAL_ALIGNMENT_LEFT, 280, 11, Color("9bb8ba"))

func _draw_dex(panel: Rect2) -> void:
	var seen: Array = profile.get("seen", []) as Array
	var caught: Array = profile.get("caught", []) as Array
	draw_string(font, panel.position + Vector2(20, 36), "WIDZIANE %d / 50    SCHWYTANE %d / 50" % [seen.size(), caught.size()], HORIZONTAL_ALIGNMENT_LEFT, 284, 10, Color("5be2dc"))
	draw_rect(Rect2(panel.position + Vector2(20, 52), Vector2(284, 10)), Color("17353e"))
	draw_rect(Rect2(panel.position + Vector2(20, 52), Vector2(284.0 * float(seen.size()) / 50.0, 10)), Color("52d9d3"))
	var shown: int = 0
	for monster_name: String in DB.all_names():
		if not seen.has(monster_name):
			continue
		var data: Dictionary = DB.get_monster(monster_name)
		var y: int = 82 + shown * 58
		var state_text: String = "SCHWYTANY" if caught.has(monster_name) else "WIDZIANY"
		draw_string(font, panel.position + Vector2(24, y), "#%03d  %s" % [int(data.get("id", 0)), monster_name], HORIZONTAL_ALIGNMENT_LEFT, 180, 11, Color("e8f5f3"))
		draw_string(font, panel.position + Vector2(218, y), state_text, HORIZONTAL_ALIGNMENT_RIGHT, 82, 8, Color("d8c96c") if caught.has(monster_name) else Color("718f92"))
		draw_string(font, panel.position + Vector2(40, y + 18), str(data.get("type", "?")), HORIZONTAL_ALIGNMENT_LEFT, 180, 8, Color("759da0"))
		shown += 1
	if shown == 0:
		draw_string(font, panel.position + Vector2(20, 100), "Brak wpisów. Wyjdź w teren.", HORIZONTAL_ALIGNMENT_LEFT, 280, 11, Color("9bb8ba"))

func _draw_bag(panel: Rect2) -> void:
	var inventory: Dictionary = profile.get("inventory", {}) as Dictionary
	var bag_items: Array = [
		["Regenerator ×%d" % int(inventory.get("regenerators", 0)), "Leczy partnera podczas walki"],
		["Moduł Chwytu ×%d" % int(inventory.get("capture_modules", 0)), "Synchronizuje dzikiego Somaskana"],
		["Sonda Vela ×%d" % int(inventory.get("sondas", 0)), "Analiza pola i ukrytych sygnałów"]
	]
	for i: int in range(bag_items.size()):
		var y: int = 32 + i * 104
		var entry: Array = bag_items[i] as Array
		draw_rect(Rect2(panel.position + Vector2(16, y), Vector2(292, 84)), Color("122f38"))
		draw_string(font, panel.position + Vector2(30, y + 30), str(entry[0]), HORIZONTAL_ALIGNMENT_LEFT, 250, 13, Color("effaf8"))
		draw_string(font, panel.position + Vector2(30, y + 53), str(entry[1]), HORIZONTAL_ALIGNMENT_LEFT, 250, 9, Color("809fa2"))

func _draw_trainer(panel: Rect2) -> void:
	var talents: Dictionary = profile.get("talents", PROGRESSION.default_talents()) as Dictionary
	var points: int = int(profile.get("talent_points", 0))
	draw_string(font, panel.position + Vector2(20, 32), "PUNKTY DO WYDANIA: %d" % points, HORIZONTAL_ALIGNMENT_LEFT, 280, 12, Color("e1ce68"))
	var paths: Array[String] = PROGRESSION.path_ids()
	for i: int in range(paths.size()):
		var path_id: String = paths[i]
		var data: Dictionary = PROGRESSION.path_info(path_id)
		var r: Rect2 = _talent_rect(panel, i)
		var active: bool = i == section_selected
		draw_rect(r, Color("183b45") if active else Color("12303a"))
		draw_rect(r, Color("55ddd6") if active else Color("355e68"), false, 2.0)
		draw_string(font, r.position + Vector2(14, 22), str(data.get("name", path_id)), HORIZONTAL_ALIGNMENT_LEFT, 160, 11, Color("e6f4f2"))
		draw_string(font, r.position + Vector2(212, 22), "RANGA %d/5" % PROGRESSION.rank(talents, path_id), HORIZONTAL_ALIGNMENT_RIGHT, 62, 9, Color("d6c96a"))
		draw_string(font, r.position + Vector2(14, 43), str(data.get("description", "")), HORIZONTAL_ALIGNMENT_LEFT, 264, 8, Color("789a9d"))
	draw_string(font, panel.position + Vector2(20, 474), "Dotknij ścieżki, aby wydać 1 punkt.", HORIZONTAL_ALIGNMENT_LEFT, 280, 9, Color("76979b"))

func _draw_quest(panel: Rect2) -> void:
	var stage: int = int(profile.get("quest_stage", 0))
	draw_string(font, panel.position + Vector2(20, 46), PROGRESSION.quest_title(stage), HORIZONTAL_ALIGNMENT_LEFT, 284, 16, Color("5be2dc"))
	var objective_box: Rect2 = Rect2(panel.position + Vector2(18, 72), Vector2(288, 108))
	draw_rect(objective_box, Color("12303a"))
	draw_string(font, objective_box.position + Vector2(14, 30), "AKTUALNY CEL", HORIZONTAL_ALIGNMENT_LEFT, 250, 9, Color("789a9d"))
	var objective: String = PROGRESSION.quest_objective(stage)
	var lines: Array[String] = _wrap(objective, 40)
	for i: int in range(mini(3, lines.size())):
		draw_string(font, objective_box.position + Vector2(14, 55 + i * 20), lines[i], HORIZONTAL_ALIGNMENT_LEFT, 258, 11, Color("effaf8"))
	var flags: Dictionary = profile.get("flags", {}) as Dictionary
	draw_string(font, panel.position + Vector2(22, 224), "Synchronizacja Stacji Vela", HORIZONTAL_ALIGNMENT_LEFT, 220, 11, Color("d8e9e7"))
	draw_string(font, panel.position + Vector2(252, 224), "OK" if bool(flags.get("vela_station_synced", false)) else "—", HORIZONTAL_ALIGNMENT_RIGHT, 44, 10, Color("61d975") if bool(flags.get("vela_station_synced", false)) else Color("718f92"))
	draw_string(font, panel.position + Vector2(22, 272), "Etap fundamentu fabuły: %d/4" % mini(stage, 4), HORIZONTAL_ALIGNMENT_LEFT, 260, 10, Color("789a9d"))

func _draw_settings(panel: Rect2) -> void:
	draw_string(font, panel.position + Vector2(20, 42), "STEROWANIE", HORIZONTAL_ALIGNMENT_LEFT, 260, 12, Color("5be2dc"))
	draw_string(font, panel.position + Vector2(20, 84), "Wibracje dotykowe", HORIZONTAL_ALIGNMENT_LEFT, 200, 13, Color("e4f3f1"))
	var toggle: Rect2 = Rect2(panel.position + Vector2(236, 60), Vector2(62, 32))
	draw_rect(toggle, Color("24605f") if haptics else Color("26383d"))
	draw_circle(toggle.position + Vector2(46 if haptics else 16, 16), 11, Color("65e5df") if haptics else Color("72878b"))
	draw_string(font, panel.position + Vector2(20, 128), "Dotknij przełącznika, aby zmienić ustawienie.", HORIZONTAL_ALIGNMENT_LEFT, 280, 10, Color("7f9fa1"))
	draw_string(font, panel.position + Vector2(20, 188), "Wersja: SOMADEX Foundation v0.8", HORIZONTAL_ALIGNMENT_LEFT, 280, 11, Color("9bb8ba"))
	draw_string(font, panel.position + Vector2(20, 216), "Save schema: v8 · Android arm64", HORIZONTAL_ALIGNMENT_LEFT, 280, 9, Color("708f93"))

func _item_rect(i: int) -> Rect2:
	return Rect2(30, 244 + i * 58, 300, 44)

func _toggle_rect() -> Rect2:
	return Rect2(254, 208, 62, 32)

func _talent_rect(panel: Rect2, index: int) -> Rect2:
	return Rect2(panel.position + Vector2(18, 50 + index * 78), Vector2(288, 66))

func _wrap(text: String, width: int) -> Array[String]:
	var out: Array[String] = []
	var current: String = ""
	for word: String in text.split(" "):
		var candidate: String = word if current.is_empty() else current + " " + word
		if candidate.length() > width and not current.is_empty():
			out.append(current)
			current = word
		else:
			current = candidate
	if not current.is_empty():
		out.append(current)
	return out

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
			if section == "trainer":
				var paths: Array[String] = PROGRESSION.path_ids()
				if key_event.keycode in [KEY_UP, KEY_W]: section_selected = (section_selected + paths.size() - 1) % paths.size()
				elif key_event.keycode in [KEY_DOWN, KEY_S]: section_selected = (section_selected + 1) % paths.size()
				elif key_event.keycode in [KEY_ENTER, KEY_SPACE, KEY_Z]: talent_spend_requested.emit(paths[section_selected])
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
				return
			if section == "settings" and _toggle_rect().has_point(pos):
				haptics = not haptics
				profile["haptics"] = haptics
				haptics_changed.emit(haptics)
				queue_redraw()
				return
			if section == "trainer":
				var paths: Array[String] = PROGRESSION.path_ids()
				var panel: Rect2 = Rect2(18, 148, 324, 500)
				for i: int in range(paths.size()):
					if _talent_rect(panel, i).has_point(pos):
						section_selected = i
						talent_spend_requested.emit(paths[i])
						queue_redraw()
						return
			return
		for i: int in range(items.size()):
			if _item_rect(i).has_point(pos):
				selected = i
				_activate()
				return

func _activate() -> void:
	section_selected = 0
	match selected:
		0: section = "party"
		1: section = "dex"
		2: section = "bag"
		3: section = "trainer"
		4: section = "quest"
		5: save_requested.emit()
		6: section = "settings"
		7: close_requested.emit()
	queue_redraw()
