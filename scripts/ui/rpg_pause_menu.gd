extends "res://scripts/ui/alpha1_pause_menu_art.gd"

signal move_cycle_requested(party_index: int, slot_index: int)

const RPG_MOVES = preload("res://scripts/data/move_db.gd")
const LEARNSETS = preload("res://scripts/data/learnset_db.gd")

func setup(profile_data: Dictionary) -> void:
	_configure_items()
	super.setup(profile_data)

func _ready() -> void:
	_configure_items()
	super._ready()

func _configure_items() -> void:
	items = [
		"DRUŻYNA",
		"RUCHY",
		"SOMADEX",
		"PLECAK",
		"EKWIPUNEK",
		"TRENER",
		"MISJA",
		"ZAPISZ",
		"USTAWIENIA",
		"WRÓĆ DO GRY"
	]

func _activate() -> void:
	section_selected = 0
	match selected:
		0: section = "party"
		1: section = "moves"
		2: section = "dex"
		3: section = "bag"
		4: section = "equipment"
		5: section = "trainer"
		6: section = "quest"
		7: save_requested.emit()
		8: section = "settings"
		9: close_requested.emit()
	queue_redraw()

func _draw_section() -> void:
	if section != "moves":
		super._draw_section()
		return
	draw_string(font, Vector2(22, 126), "RUCHY", HORIZONTAL_ALIGNMENT_LEFT, 300, 17, Color("58e2dc"))
	var panel: Rect2 = Rect2(18, 148, 324, 500)
	draw_rect(panel, Color("0c222b"))
	draw_rect(panel, Color("294f59"), false, 2.0)
	_draw_moves(panel)
	var back: Rect2 = Rect2(18, 674, 126, 44)
	draw_rect(back, Color("17323b"))
	draw_rect(back, Color("37616a"), false, 2.0)
	draw_string(font, Vector2(28, back.position.y + 28), "‹ WSTECZ", HORIZONTAL_ALIGNMENT_CENTER, 106, 11, Color("dbeeed"))

func _draw_moves(panel: Rect2) -> void:
	var party: Array = profile.get("party", []) as Array
	if party.is_empty():
		draw_string(font, panel.position + Vector2(20, 60), "Brak partnera w drużynie.", HORIZONTAL_ALIGNMENT_LEFT, 280, 10, Color("9bb8ba"))
		return
	var party_index: int = STATE.active_index(profile)
	var member: Dictionary = party[party_index] as Dictionary
	var name: String = str(member.get("name", "?"))
	var level: int = maxi(1, int(member.get("level", 1)))
	var data: Dictionary = DB.get_monster(name)
	var available: Array[String] = LEARNSETS.available_move_ids(name, level, data)
	var loadout: Array[String] = LEARNSETS.normalize_loadout(name, level, member.get("move_ids", []), data)
	draw_string(font, panel.position + Vector2(18, 28), "%s · Lv.%d · ODBLOKOWANE %d/%d" % [name, level, available.size(), LEARNSETS.LEARNSET_SIZE], HORIZONTAL_ALIGNMENT_LEFT, 288, 9, Color("5be2dc"))
	draw_string(font, panel.position + Vector2(18, 48), "Dotknij slotu, aby przełączyć na kolejny poznany ruch.", HORIZONTAL_ALIGNMENT_LEFT, 288, 7, Color("7f9fa1"))
	for i: int in range(LEARNSETS.ACTIVE_LIMIT):
		var r: Rect2 = _move_rect(panel, i)
		var active: bool = i == section_selected
		draw_rect(r, Color("183b45") if active else Color("12303a"))
		draw_rect(r, Color("55ddd6") if active else Color("355e68"), false, 2.0)
		var move_id: String = loadout[i] if i < loadout.size() else ""
		var move_data: Dictionary = RPG_MOVES.info(move_id)
		draw_string(font, r.position + Vector2(12, 21), "%d. %s" % [i + 1, str(move_data.get("name", "—"))], HORIZONTAL_ALIGNMENT_LEFT, 184, 10, Color("effaf8"))
		draw_string(font, r.position + Vector2(204, 21), str(move_data.get("move_type", "?")), HORIZONTAL_ALIGNMENT_RIGHT, 70, 8, Color("d9c96c"))
		draw_string(font, r.position + Vector2(12, 43), "PWR %d · CEL %d%% · KOSZT %d · %s" % [int(move_data.get("power", 0)), int(round(float(move_data.get("accuracy", 1.0)) * 100.0)), int(move_data.get("cost", 0)), str(move_data.get("pattern", "direct")).to_upper()], HORIZONTAL_ALIGNMENT_LEFT, 262, 7, Color("819fa2"))
	var special_id: String = LEARNSETS.normalize_special(name, level, member.get("special_move_id", ""), data)
	var special_box: Rect2 = Rect2(panel.position + Vector2(18, 330), Vector2(288, 78))
	draw_rect(special_box, Color("142b39"))
	draw_rect(special_box, Color("846ccf") if not special_id.is_empty() else Color("3b4c53"), false, 2.0)
	draw_string(font, special_box.position + Vector2(12, 23), "ZDOLNOŚĆ SPECJALNA", HORIZONTAL_ALIGNMENT_LEFT, 260, 8, Color("b9a8ef"))
	if special_id.is_empty():
		draw_string(font, special_box.position + Vector2(12, 50), "Odblokowanie na Lv.%d" % LEARNSETS.SPECIAL_UNLOCK_LEVEL, HORIZONTAL_ALIGNMENT_LEFT, 260, 10, Color("70888c"))
	else:
		var special: Dictionary = RPG_MOVES.info(special_id)
		draw_string(font, special_box.position + Vector2(12, 50), str(special.get("name", special_id)), HORIZONTAL_ALIGNMENT_LEFT, 260, 11, Color("f0eaff"))

func _draw_trainer(panel: Rect2) -> void:
	var talents: Dictionary = profile.get("talents", PROGRESSION.default_talents()) as Dictionary
	var points: int = int(profile.get("talent_points", 0))
	var trainer_level: int = int(profile.get("trainer_level", 1))
	draw_string(font, panel.position + Vector2(20, 26), "Lv.%d/%d · PUNKTY: %d · 100 TALENTÓW" % [trainer_level, PROGRESSION.TRAINER_LEVEL_CAP, points], HORIZONTAL_ALIGNMENT_LEFT, 284, 8, Color("e1ce68"))
	var paths: Array[String] = PROGRESSION.path_ids()
	for i: int in range(paths.size()):
		var path_id: String = paths[i]
		var data: Dictionary = PROGRESSION.path_info(path_id)
		var investment: int = PROGRESSION.rank(talents, path_id)
		var next: Dictionary = PROGRESSION.next_talent(talents, path_id)
		var r: Rect2 = _talent_rect(panel, i)
		var active: bool = i == section_selected
		draw_rect(r, Color("183b45") if active else Color("12303a"))
		draw_rect(r, Color("55ddd6") if active else Color("355e68"), false, 2.0)
		draw_string(font, r.position + Vector2(12, 19), "%s · %d/%d" % [str(data.get("name", path_id)), investment, PROGRESSION.max_rank(path_id)], HORIZONTAL_ALIGNMENT_LEFT, 174, 9, Color("e6f4f2"))
		var action: Dictionary = PROGRESSION.trainer_action_info(i, talents)
		draw_string(font, r.position + Vector2(190, 19), "AKCJA T%d" % int(action.get("rank", 0)), HORIZONTAL_ALIGNMENT_RIGHT, 84, 7, Color("d9c96c"))
		if next.is_empty():
			draw_string(font, r.position + Vector2(12, 41), "ŚCIEŻKA UKOŃCZONA", HORIZONTAL_ALIGNMENT_LEFT, 260, 8, Color("65d995"))
		else:
			var req: int = int(next.get("required_level", 1))
			var state: String = "GOTOWY" if trainer_level >= req and points > 0 else "Lv.%d" % req
			draw_string(font, r.position + Vector2(12, 39), "Następny: %s" % str(next.get("name", "talent")), HORIZONTAL_ALIGNMENT_LEFT, 204, 7, Color("a9c2c3"))
			draw_string(font, r.position + Vector2(218, 39), state, HORIZONTAL_ALIGNMENT_RIGHT, 56, 7, Color("65d995") if state == "GOTOWY" else Color("8a9fa1"))
		draw_string(font, r.position + Vector2(12, 57), str(data.get("description", "")), HORIZONTAL_ALIGNMENT_LEFT, 262, 6, Color("789a9d"))

func _move_rect(panel: Rect2, index: int) -> Rect2:
	return Rect2(panel.position + Vector2(18, 66 + index * 64), Vector2(288, 56))

func _section_count() -> int:
	if section == "moves":
		return LEARNSETS.ACTIVE_LIMIT
	return super._section_count()

func _handle_section_key(event: InputEventKey) -> void:
	if section != "moves":
		super._handle_section_key(event)
		return
	var count: int = LEARNSETS.ACTIVE_LIMIT
	if event.keycode in [KEY_UP, KEY_W]:
		section_selected = (section_selected + count - 1) % count
	elif event.keycode in [KEY_DOWN, KEY_S]:
		section_selected = (section_selected + 1) % count
	elif event.keycode in [KEY_ENTER, KEY_SPACE, KEY_Z]:
		move_cycle_requested.emit(STATE.active_index(profile), section_selected)
	queue_redraw()

func _handle_section_touch(pos: Vector2) -> void:
	if section != "moves":
		super._handle_section_touch(pos)
		return
	if Rect2(18, 674, 126, 44).has_point(pos):
		section = "root"
		section_selected = 0
		queue_redraw()
		return
	var panel: Rect2 = Rect2(18, 148, 324, 500)
	for i: int in range(LEARNSETS.ACTIVE_LIMIT):
		if _move_rect(panel, i).has_point(pos):
			section_selected = i
			move_cycle_requested.emit(STATE.active_index(profile), i)
			return
