extends "res://scripts/ui/pause_menu.gd"

const ALPHA_ART = preload("res://scripts/data/monster_art_alpha.gd")
const ALPHA_QUESTS = preload("res://scripts/data/alpha1_quest_db.gd")
const SIDEQUESTS = preload("res://scripts/data/alpha1_sidequest_db.gd")
const ALPHA_STATE = preload("res://scripts/core/game_state.gd")

func _ready() -> void:
	super._ready()
	texture = ALPHA_ART.texture_for(ALPHA_STATE.active_name(profile))
	queue_redraw()

func _apply_profile(profile_data: Dictionary) -> void:
	super._apply_profile(profile_data)
	texture = ALPHA_ART.texture_for(ALPHA_STATE.active_name(profile))

func _draw() -> void:
	super._draw()
	draw_rect(Rect2(278, 16, 66, 28), Color("0d2a34"))
	draw_string(font, Vector2(282, 36), "A1 VELA", HORIZONTAL_ALIGNMENT_CENTER, 58, 9, Color("79e5df"))

func _draw_quest(panel: Rect2) -> void:
	var stage: int = int(profile.get("quest_stage", 0))
	if stage < 5:
		super._draw_quest(panel)
		return

	draw_string(font, panel.position + Vector2(20, 46), ALPHA_QUESTS.title(stage), HORIZONTAL_ALIGNMENT_LEFT, 284, 16, Color("5be2dc"))
	var box: Rect2 = Rect2(panel.position + Vector2(18, 72), Vector2(288, 118))
	draw_rect(box, Color("12303a"))
	draw_string(font, box.position + Vector2(14, 28), "AKTUALNY CEL", HORIZONTAL_ALIGNMENT_LEFT, 250, 9, Color("789a9d"))
	var lines: Array[String] = _wrap(ALPHA_QUESTS.objective(stage), 40)
	for i: int in range(mini(4, lines.size())):
		draw_string(font, box.position + Vector2(14, 53 + i * 18), lines[i], HORIZONTAL_ALIGNMENT_LEFT, 258, 10, Color("effaf8"))

	var world_flags: Dictionary = profile.get("flags", {}) as Dictionary
	var dialogue_flags: Dictionary = profile.get("dialogue_flags", {}) as Dictionary
	_draw_alpha_progress_line(panel, 218, "Trzy biomy poznane", bool(world_flags.get("visited_whispering_grove", false)) and bool(world_flags.get("visited_tideglass_coast", false)) and bool(world_flags.get("visited_echo_cave", false)))
	_draw_alpha_progress_line(panel, 250, "Karo i Vera pokonani", bool(dialogue_flags.get("trainer_karo_defeated", false)) and bool(dialogue_flags.get("trainer_vera_defeated", false)))
	_draw_alpha_progress_line(panel, 282, "Kael pokonany", bool(dialogue_flags.get("trainer_kael_defeated", false)))
	_draw_alpha_progress_line(panel, 314, "Próba Rhei ukończona", bool(dialogue_flags.get("trainer_rhea_defeated", false)))
	draw_string(font, panel.position + Vector2(22, 350), "Alpha 1 · Vela · etap %d/10" % stage, HORIZONTAL_ALIGNMENT_LEFT, 260, 9, Color("789a9d"))
	draw_string(font, panel.position + Vector2(22, 382), "ZADANIA POBOCZNE", HORIZONTAL_ALIGNMENT_LEFT, 260, 9, Color("d9c96c"))
	var side_ids: Array[String] = SIDEQUESTS.ids()
	for i: int in range(side_ids.size()):
		var quest_id: String = side_ids[i]
		var complete: bool = SIDEQUESTS.is_complete(quest_id, dialogue_flags)
		var text: String = SIDEQUESTS.progress_text(quest_id, dialogue_flags)
		draw_string(font, panel.position + Vector2(24, 410 + i * 25), text, HORIZONTAL_ALIGNMENT_LEFT, 274, 8, Color("61d975") if complete else Color("9bb8ba"))

func _draw_alpha_progress_line(panel: Rect2, y: int, label: String, complete: bool) -> void:
	draw_string(font, panel.position + Vector2(22, y), label, HORIZONTAL_ALIGNMENT_LEFT, 220, 9, Color("9bb8ba"))
	draw_string(font, panel.position + Vector2(252, y), "OK" if complete else "—", HORIZONTAL_ALIGNMENT_RIGHT, 44, 9, Color("61d975") if complete else Color("718f92"))

func _draw_settings(panel: Rect2) -> void:
	draw_string(font, panel.position + Vector2(20, 42), "STEROWANIE", HORIZONTAL_ALIGNMENT_LEFT, 260, 12, Color("5be2dc"))
	draw_string(font, panel.position + Vector2(20, 84), "Wibracje dotykowe", HORIZONTAL_ALIGNMENT_LEFT, 200, 13, Color("e4f3f1"))
	var toggle: Rect2 = Rect2(panel.position + Vector2(236, 60), Vector2(62, 32))
	draw_rect(toggle, Color("24605f") if haptics else Color("26383d"))
	draw_circle(toggle.position + Vector2(46 if haptics else 16, 16), 11, Color("65e5df") if haptics else Color("72878b"))
	draw_string(font, panel.position + Vector2(20, 128), "Dotknij przełącznika, aby zmienić ustawienie.", HORIZONTAL_ALIGNMENT_LEFT, 280, 10, Color("7f9fa1"))
	draw_string(font, panel.position + Vector2(20, 188), "Wersja: SOMADEX Alpha 1 · Vela", HORIZONTAL_ALIGNMENT_LEFT, 280, 11, Color("9bb8ba"))
	draw_string(font, panel.position + Vector2(20, 216), "Build: 1.1.0-alpha1-vela · Android arm64", HORIZONTAL_ALIGNMENT_LEFT, 280, 9, Color("708f93"))
	draw_string(font, panel.position + Vector2(20, 246), "Foundation 1.0: zamrożony rdzeń + warstwa Alpha", HORIZONTAL_ALIGNMENT_LEFT, 280, 8, Color("708f93"))
