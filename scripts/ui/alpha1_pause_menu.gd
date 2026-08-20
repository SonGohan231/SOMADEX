extends "res://scripts/ui/pause_menu.gd"

const ALPHA_ART = preload("res://scripts/data/monster_art_alpha.gd")
const ALPHA_QUESTS = preload("res://scripts/data/alpha1_quest_db.gd")
const ALPHA_STATE = preload("res://scripts/core/game_state.gd")

func _ready() -> void:
	super._ready()
	texture = ALPHA_ART.texture_for(ALPHA_STATE.active_name(profile))
	queue_redraw()

func _apply_profile(profile_data: Dictionary) -> void:
	super._apply_profile(profile_data)
	texture = ALPHA_ART.texture_for(ALPHA_STATE.active_name(profile))

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
	_draw_alpha_progress_line(panel, 226, "Trzy biomy poznane", bool(world_flags.get("visited_whispering_grove", false)) and bool(world_flags.get("visited_tideglass_coast", false)) and bool(world_flags.get("visited_echo_cave", false)))
	_draw_alpha_progress_line(panel, 266, "Karo i Vera pokonani", bool(dialogue_flags.get("trainer_karo_defeated", false)) and bool(dialogue_flags.get("trainer_vera_defeated", false)))
	_draw_alpha_progress_line(panel, 306, "Kael pokonany", bool(dialogue_flags.get("trainer_kael_defeated", false)))
	_draw_alpha_progress_line(panel, 346, "Próba Rhei ukończona", bool(dialogue_flags.get("trainer_rhea_defeated", false)))
	draw_string(font, panel.position + Vector2(22, 406), "Alpha 1 · Vela · etap %d/10" % stage, HORIZONTAL_ALIGNMENT_LEFT, 260, 10, Color("789a9d"))

func _draw_alpha_progress_line(panel: Rect2, y: int, label: String, complete: bool) -> void:
	draw_string(font, panel.position + Vector2(22, y), label, HORIZONTAL_ALIGNMENT_LEFT, 220, 10, Color("9bb8ba"))
	draw_string(font, panel.position + Vector2(252, y), "OK" if complete else "—", HORIZONTAL_ALIGNMENT_RIGHT, 44, 10, Color("61d975") if complete else Color("718f92"))
