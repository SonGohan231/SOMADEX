extends Control

signal close_requested
signal save_requested
signal haptics_changed(value: bool)
signal talent_spend_requested(path_id: String)
signal equipment_cycle_requested(slot_id: String)
signal active_member_requested(index: int)

const DB = preload("res://scripts/data/monster_db.gd")
const ART = preload("res://scripts/data/monster_art.gd")
const PROGRESSION = preload("res://scripts/data/progression_db.gd")
const STATE = preload("res://scripts/core/game_state.gd")
const ITEMS = preload("res://scripts/data/item_db.gd")
const EQUIPMENT = preload("res://scripts/data/equipment_db.gd")

var font: Font
var selected: int = 0
var section_selected: int = 0
var section: String = "root"
var profile: Dictionary = {}
var haptics: bool = true
var message: String = ""
var message_until: int = 0
var texture: Texture2D

var items: Array[String] = [
	"DRUŻYNA",
	"SOMADEX",
	"PLECAK",
	"EKWIPUNEK",
	"TRENER",
	"MISJA",
	"ZAPISZ",
	"USTAWIENIA",
	"WRÓĆ DO GRY"
]

func setup(profile_data: Dictionary) -> void:
	_apply_profile(profile_data)

func refresh_profile(profile_data: Dictionary, text: String = "") -> void:
	_apply_profile(profile_data)
	if not text.is_empty():
		show_message(text)
	queue_redraw()

func _apply_profile(profile_data: Dictionary) -> void:
	profile = profile_data.duplicate(true)
	haptics = bool(profile.get("haptics", true))
	if is_inside_tree():
		texture = ART.texture_for(STATE.active_name(profile))

func _ready() -> void:
	font = ThemeDB.fallback_font
	texture = ART.texture_for(STATE.active_name(profile))
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
	var trainer_level: int = maxi(1, int(profile.get("trainer_level", 1)))
	var trainer_xp: int = maxi(0, int(profile.get("trainer_xp", 0)))
	draw_string(font, Vector2(22, 37), "SOMADEX · MENU", HORIZONTAL_ALIGNMENT_LEFT, 220, 18, Color("edfffc"))
	draw_string(font, Vector2(22, 62), "Trener Lv.%d · EXP %d/%d" % [trainer_level, trainer_xp, PROGRESSION.xp_to_next_level(trainer_level)], HORIZONTAL_ALIGNMENT_LEFT, 250, 9, Color("7eacad"))
	draw_string(font, Vector2(286, 37), "F1.0", HORIZONTAL_ALIGNMENT_RIGHT, 52, 10, Color("698b90"))
	if section == "root":
		_draw_root()
	else:
		_draw_section()
	if not message.is_empty() and Time.get_ticks_msec() < message_until:
		var r: Rect2 = Rect2(42, 728, 276, 48)
		draw_rect(r, Color("183842"))
		draw_rect(r, Color("4de0d9"), false, 2.0)
		draw_string(font, Vector2(55, 758), message, HORIZONTAL_ALIGNMENT_CENTER, 250, 10, Color("edfffc"))

func _draw_root() -> void:
	var card: Rect2 = Rect2(18, 104, 324, 128)
	draw_rect(card, Color("102730"))
	draw_rect(card, Color("2c5d65"), false, 2.0)
	if texture != null:
		draw_texture_rect(texture, Rect2(26, 112, 116, 87), false)
	var member: Dictionary = STATE.active_member(profile)
	var name: String = str(member.get("name", "—"))
	var data: Dictionary = DB.get_monster(name)
	var accent: Color = data.get("accent", Color("55e8de"))
	draw_string(font, Vector2(154, 132), name, HORIZONTAL_ALIGNMENT_LEFT, 174, 16, Color("f3fffc"))
	draw_string(font, Vector2(154, 151), "%s · Lv.%d" % [str(data.get("type", "?")), int(member.get("level", 1))], HORIZONTAL_ALIGNMENT_LEFT, 174, 9, accent)
	var party: Array = profile.get("party", []) as Array
	var caught: Array = profile.get("caught", []) as Array
	draw_string(font, Vector2(154, 174), "Drużyna %d/6 · Schwytane %d" % [party.size(), caught.size()], HORIZONTAL_ALIGNMENT_LEFT, 174, 9, Color("adc7c9"))
	draw_string(font, Vector2(154, 195), "Cel: %s" % PROGRESSION.quest_short(int(profile.get("quest_stage", 0))), HORIZONTAL_ALIGNMENT_LEFT, 174, 8, Color("66c4c1"))
	draw_string(font, Vector2(154, 215), "Talenty: %d pkt" % int(profile.get("talent_points", 0)), HORIZONTAL_ALIGNMENT_LEFT, 174, 9, Color("d9c96c"))
	for i: int in range(items.size()):
		var r: Rect2 = _item_rect(i)
		var active: bool = i == selected
		draw_rect(r, Color("173a44") if active else Color("0d242d"))
		draw_rect(r, Color("50dfd8") if active else Color("294b54"), false, 2.0)
		if active:
			draw_rect(Rect2(r.position, Vector2(5, r.size.y)), Color("50dfd8"))
		draw_string(font, r.position + Vector2(16, 24), items[i], HORIZONTAL_ALIGNMENT_LEFT, 240, 10, Color("edfffc") if active else Color("adc5c6"))
		if i in [0, 1, 2, 3, 4, 5, 7]:
			draw_string(font, Vector2(r.end.x - 24, r.position.y + 24), "›", HORIZONTAL_ALIGNMENT_CENTER, 20, 13, Color("65a7a7"))

func _draw_section() -> void:
	var title_map: Dictionary = {"party": "DRUŻYNA", "dex": "SOMADEX", "bag": "PLECAK", "equipment": "EKWIPUNEK", "trainer": "TRENER", "quest": "MISJA", "settings": "USTAWIENIA"}
	draw_string(font, Vector2(22, 126), str(title_map.get(section, "MENU")), HORIZONTAL_ALIGNMENT_LEFT, 300, 17, Color("58e2dc"))
	var panel: Rect2 = Rect2(18, 148, 324, 500)
	draw_rect(panel, Color("0c222b"))
	draw_rect(panel, Color("294f59"), false, 2.0)
	match section:
		"party": _draw_party(panel)
		"dex": _draw_dex(panel)
		"bag": _draw_bag(panel)
		"equipment": _draw_equipment(panel)
		"trainer": _draw_trainer(panel)
		"quest": _draw_quest(panel)
		"settings": _draw_settings(panel)
	var back: Rect2 = Rect2(18, 674, 126, 44)
	draw_rect(back, Color("17323b"))
	draw_rect(back, Color("37616a"), false, 2.0)
	draw_string(font, Vector2(28, back.position.y + 28), "‹ WSTECZ", HORIZONTAL_ALIGNMENT_CENTER, 106, 11, Color("dbeeed"))

func _draw_party(panel: Rect2) -> void:
	var party: Array = profile.get("party", []) as Array
	var active_index: int = STATE.active_index(profile)
	draw_string(font, panel.position + Vector2(18, 30), "AKTYWNA DRUŻYNA · %d/6 · ENTER = AKTYWUJ" % party.size(), HORIZONTAL_ALIGNMENT_LEFT, 288, 9, Color("5be2dc"))
	for i: int in range(6):
		var r: Rect2 = _party_rect(panel, i)
		var cursor: bool = i == section_selected
		draw_rect(r, Color("183b45") if cursor else Color("12303a"))
		draw_rect(r, Color("55ddd6") if cursor else Color("355e68"), false, 1.0)
		if i < party.size():
			var member: Dictionary = party[i] as Dictionary
			var name: String = str(member.get("name", "?"))
			var data: Dictionary = DB.get_monster(name)
			var marker: String = "● " if i == active_index else ""
			var max_hp: int = STATE.member_max_hp(member, profile.get("talents", {}) as Dictionary, profile.get("equipment", {}) as Dictionary)
			draw_string(font, r.position + Vector2(12, 21), "%s%s · Lv.%d" % [marker, name, int(member.get("level", 1))], HORIZONTAL_ALIGNMENT_LEFT, 160, 10, Color("effaf8"))
			draw_string(font, r.position + Vector2(12, 40), "HP %d/%d · EXP %d/%d" % [int(member.get("hp", 0)), max_hp, int(member.get("xp", 0)), 12 + int(member.get("level", 1)) * 6], HORIZONTAL_ALIGNMENT_LEFT, 230, 8, Color("809fa2"))
			draw_string(font, r.position + Vector2(238, 30), str(data.get("type", "?")), HORIZONTAL_ALIGNMENT_RIGHT, 42, 8, data.get("accent", Color("55e8de")))
		else:
			draw_string(font, r.position + Vector2(12, 29), "— pusty slot —", HORIZONTAL_ALIGNMENT_LEFT, 250, 9, Color("577176"))

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
		draw_string(font, panel.position + Vector2(40, y + 18), "%s · %s" % [str(data.get("type", "?")), str(data.get("role", ""))], HORIZONTAL_ALIGNMENT_LEFT, 240, 8, Color("759da0"))
		shown += 1
	if shown == 0:
		draw_string(font, panel.position + Vector2(20, 100), "Brak wpisów. Wyjdź w teren.", HORIZONTAL_ALIGNMENT_LEFT, 280, 11, Color("9bb8ba"))

func _draw_bag(panel: Rect2) -> void:
	var inventory: Dictionary = profile.get("inventory", {}) as Dictionary
	var ids: Array[String] = ITEMS.ids()
	for i: int in range(ids.size()):
		var item_id: String = ids[i]
		var info: Dictionary = ITEMS.info(item_id)
		var y: int = 28 + i * 100
		var r: Rect2 = Rect2(panel.position + Vector2(16, y), Vector2(292, 82))
		draw_rect(r, Color("122f38"))
		draw_string(font, r.position + Vector2(14, 28), "%s ×%d" % [str(info.get("name", item_id)), ITEMS.count(inventory, item_id)], HORIZONTAL_ALIGNMENT_LEFT, 260, 12, Color("effaf8"))
		draw_string(font, r.position + Vector2(14, 52), str(info.get("description", "")), HORIZONTAL_ALIGNMENT_LEFT, 260, 8, Color("809fa2"))

func _draw_equipment(panel: Rect2) -> void:
	var loadout: Dictionary = profile.get("equipment", {}) as Dictionary
	var gear_bonuses: Dictionary = EQUIPMENT.aggregate(loadout)
	draw_string(font, panel.position + Vector2(18, 28), "ENTER = ZMIEŃ NA KOLEJNY POSIADANY", HORIZONTAL_ALIGNMENT_LEFT, 288, 8, Color("5be2dc"))
	var slots: Array[String] = EQUIPMENT.slot_ids()
	for i: int in range(slots.size()):
		var slot_id: String = slots[i]
		var r: Rect2 = _equipment_rect(panel, i)
		var active: bool = i == section_selected
		draw_rect(r, Color("183b45") if active else Color("12303a"))
		draw_rect(r, Color("55ddd6") if active else Color("355e68"), false, 1.0)
		var gear_id: String = str(loadout.get(slot_id, ""))
		var info: Dictionary = EQUIPMENT.info(gear_id)
		draw_string(font, r.position + Vector2(12, 19), "%s · %s" % [EQUIPMENT.slot_name(slot_id), str(info.get("name", "—"))], HORIZONTAL_ALIGNMENT_LEFT, 270, 9, Color("effaf8"))
		draw_string(font, r.position + Vector2(12, 38), str(info.get("description", "")), HORIZONTAL_ALIGNMENT_LEFT, 270, 7, Color("809fa2"))
	draw_string(font, panel.position + Vector2(20, 472), "Bonusy: ATK +%d · DEF +%d · HP +%d · Focus +%d" % [int(gear_bonuses.get("attack_bonus", 0)), int(gear_bonuses.get("defense_bonus", 0)), int(gear_bonuses.get("max_hp_bonus", 0)), int(gear_bonuses.get("trainer_focus_bonus", 0))], HORIZONTAL_ALIGNMENT_LEFT, 288, 8, Color("d9c96c"))

func _draw_trainer(panel: Rect2) -> void:
	var talents: Dictionary = profile.get("talents", PROGRESSION.default_talents()) as Dictionary
	var points: int = int(profile.get("talent_points", 0))
	draw_string(font, panel.position + Vector2(20, 30), "PUNKTY DO WYDANIA: %d · KAŻDA ŚCIEŻKA = AKCJA W WALCE" % points, HORIZONTAL_ALIGNMENT_LEFT, 284, 8, Color("e1ce68"))
	var paths: Array[String] = PROGRESSION.path_ids()
	for i: int in range(paths.size()):
		var path_id: String = paths[i]
		var data: Dictionary = PROGRESSION.path_info(path_id)
		var r: Rect2 = _talent_rect(panel, i)
		var active: bool = i == section_selected
		draw_rect(r, Color("183b45") if active else Color("12303a"))
		draw_rect(r, Color("55ddd6") if active else Color("355e68"), false, 2.0)
		draw_string(font, r.position + Vector2(12, 20), "%s · RANGA %d/5" % [str(data.get("name", path_id)), PROGRESSION.rank(talents, path_id)], HORIZONTAL_ALIGNMENT_LEFT, 270, 9, Color("e6f4f2"))
		draw_string(font, r.position + Vector2(12, 39), str(data.get("action_name", "")), HORIZONTAL_ALIGNMENT_LEFT, 270, 8, Color("d9c96c"))
		draw_string(font, r.position + Vector2(12, 56), str(data.get("description", "")), HORIZONTAL_ALIGNMENT_LEFT, 270, 7, Color("789a9d"))

func _draw_quest(panel: Rect2) -> void:
	var stage: int = int(profile.get("quest_stage", 0))
	draw_string(font, panel.position + Vector2(20, 46), PROGRESSION.quest_title(stage), HORIZONTAL_ALIGNMENT_LEFT, 284, 16, Color("5be2dc"))
	var box: Rect2 = Rect2(panel.position + Vector2(18, 72), Vector2(288, 118))
	draw_rect(box, Color("12303a"))
	draw_string(font, box.position + Vector2(14, 28), "AKTUALNY CEL", HORIZONTAL_ALIGNMENT_LEFT, 250, 9, Color("789a9d"))
	var lines: Array[String] = _wrap(PROGRESSION.quest_objective(stage), 40)
	for i: int in range(mini(4, lines.size())):
		draw_string(font, box.position + Vector2(14, 53 + i * 18), lines[i], HORIZONTAL_ALIGNMENT_LEFT, 258, 10, Color("effaf8"))
	var flags: Dictionary = profile.get("flags", {}) as Dictionary
	draw_string(font, panel.position + Vector2(22, 230), "Stacja Vela zsynchronizowana", HORIZONTAL_ALIGNMENT_LEFT, 220, 10, Color("9bb8ba"))
	draw_string(font, panel.position + Vector2(252, 230), "OK" if bool(flags.get("vela_station_synced", false)) else "—", HORIZONTAL_ALIGNMENT_RIGHT, 44, 10, Color("61d975") if bool(flags.get("vela_station_synced", false)) else Color("718f92"))
	draw_string(font, panel.position + Vector2(22, 270), "Szlak Rezonansu odwiedzony", HORIZONTAL_ALIGNMENT_LEFT, 220, 10, Color("9bb8ba"))
	draw_string(font, panel.position + Vector2(252, 270), "OK" if bool(flags.get("route_entered", false)) else "—", HORIZONTAL_ALIGNMENT_RIGHT, 44, 10, Color("61d975") if bool(flags.get("route_entered", false)) else Color("718f92"))
	draw_string(font, panel.position + Vector2(22, 330), "Foundation milestone: %d/5" % mini(stage, 5), HORIZONTAL_ALIGNMENT_LEFT, 260, 10, Color("789a9d"))

func _draw_settings(panel: Rect2) -> void:
	draw_string(font, panel.position + Vector2(20, 42), "STEROWANIE", HORIZONTAL_ALIGNMENT_LEFT, 260, 12, Color("5be2dc"))
	draw_string(font, panel.position + Vector2(20, 84), "Wibracje dotykowe", HORIZONTAL_ALIGNMENT_LEFT, 200, 13, Color("e4f3f1"))
	var toggle: Rect2 = Rect2(panel.position + Vector2(236, 60), Vector2(62, 32))
	draw_rect(toggle, Color("24605f") if haptics else Color("26383d"))
	draw_circle(toggle.position + Vector2(46 if haptics else 16, 16), 11, Color("65e5df") if haptics else Color("72878b"))
	draw_string(font, panel.position + Vector2(20, 128), "Dotknij przełącznika, aby zmienić ustawienie.", HORIZONTAL_ALIGNMENT_LEFT, 280, 10, Color("7f9fa1"))
	draw_string(font, panel.position + Vector2(20, 188), "Wersja: SOMADEX Foundation 1.0", HORIZONTAL_ALIGNMENT_LEFT, 280, 11, Color("9bb8ba"))
	draw_string(font, panel.position + Vector2(20, 216), "Save schema: v10 · Android arm64", HORIZONTAL_ALIGNMENT_LEFT, 280, 9, Color("708f93"))
	draw_string(font, panel.position + Vector2(20, 246), "Rdzeń: party/equipment/status/resonance/zones/quests", HORIZONTAL_ALIGNMENT_LEFT, 280, 8, Color("708f93"))

func _item_rect(i: int) -> Rect2:
	return Rect2(30, 240 + i * 51, 300, 39)

func _toggle_rect() -> Rect2:
	return Rect2(254, 208, 62, 32)

func _party_rect(panel: Rect2, index: int) -> Rect2:
	return Rect2(panel.position + Vector2(16, 48 + index * 70), Vector2(292, 60))

func _equipment_rect(panel: Rect2, index: int) -> Rect2:
	return Rect2(panel.position + Vector2(16, 46 + index * 68), Vector2(292, 58))

func _talent_rect(panel: Rect2, index: int) -> Rect2:
	return Rect2(panel.position + Vector2(18, 46 + index * 80), Vector2(288, 68))

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
				section_selected = 0
				queue_redraw()
				return
			_handle_section_key(key_event)
			return
		if key_event.keycode in [KEY_UP, KEY_W]:
			selected = (selected + items.size() - 1) % items.size()
		elif key_event.keycode in [KEY_DOWN, KEY_S]:
			selected = (selected + 1) % items.size()
		elif key_event.keycode in [KEY_ENTER, KEY_SPACE, KEY_Z]:
			_activate()
		elif key_event.keycode in [KEY_ESCAPE, KEY_X, KEY_M]:
			close_requested.emit()
		queue_redraw()
	elif event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event as InputEventScreenTouch
		if not touch.pressed:
			return
		var pos: Vector2 = touch.position
		if section != "root":
			_handle_section_touch(pos)
			return
		for i: int in range(items.size()):
			if _item_rect(i).has_point(pos):
				selected = i
				_activate()
				return

func _handle_section_key(event: InputEventKey) -> void:
	var count: int = _section_count()
	if count <= 0:
		return
	if event.keycode in [KEY_UP, KEY_W]:
		section_selected = (section_selected + count - 1) % count
	elif event.keycode in [KEY_DOWN, KEY_S]:
		section_selected = (section_selected + 1) % count
	elif event.keycode in [KEY_ENTER, KEY_SPACE, KEY_Z]:
		if section == "party":
			active_member_requested.emit(section_selected)
		elif section == "equipment":
			var slots: Array[String] = EQUIPMENT.slot_ids()
			equipment_cycle_requested.emit(slots[section_selected])
		elif section == "trainer":
			var paths: Array[String] = PROGRESSION.path_ids()
			talent_spend_requested.emit(paths[section_selected])
	queue_redraw()

func _handle_section_touch(pos: Vector2) -> void:
	if Rect2(18, 674, 126, 44).has_point(pos):
		section = "root"
		section_selected = 0
		queue_redraw()
		return
	if section == "settings" and _toggle_rect().has_point(pos):
		haptics = not haptics
		profile["haptics"] = haptics
		haptics_changed.emit(haptics)
		queue_redraw()
		return
	var panel: Rect2 = Rect2(18, 148, 324, 500)
	if section == "party":
		for i: int in range(6):
			if _party_rect(panel, i).has_point(pos):
				section_selected = i
				active_member_requested.emit(i)
				return
	elif section == "equipment":
		var slots: Array[String] = EQUIPMENT.slot_ids()
		for i: int in range(slots.size()):
			if _equipment_rect(panel, i).has_point(pos):
				section_selected = i
				equipment_cycle_requested.emit(slots[i])
				return
	elif section == "trainer":
		var paths: Array[String] = PROGRESSION.path_ids()
		for i: int in range(paths.size()):
			if _talent_rect(panel, i).has_point(pos):
				section_selected = i
				talent_spend_requested.emit(paths[i])
				return

func _section_count() -> int:
	match section:
		"party": return 6
		"equipment": return EQUIPMENT.slot_ids().size()
		"trainer": return PROGRESSION.path_ids().size()
		_: return 0

func _activate() -> void:
	section_selected = 0
	match selected:
		0: section = "party"
		1: section = "dex"
		2: section = "bag"
		3: section = "equipment"
		4: section = "trainer"
		5: section = "quest"
		6: save_requested.emit()
		7: section = "settings"
		8: close_requested.emit()
	queue_redraw()
