extends "res://scripts/ui/pause_menu.gd"

const DEX_DB = preload("res://scripts/data/monster_db.gd")
const DEX_ART = preload("res://scripts/data/monster_art.gd")
const EVOLUTION = preload("res://scripts/data/evolution_db.gd")

func _dex_names() -> Array[String]:
	var seen: Array = profile.get("seen", []) as Array
	var result: Array[String] = []
	for creature_name: String in DEX_DB.all_names():
		if seen.has(creature_name):
			result.append(creature_name)
	return result

func _section_count() -> int:
	if section == "dex":
		return _dex_names().size()
	return super._section_count()

func _draw_dex(panel: Rect2) -> void:
	var seen: Array = profile.get("seen", []) as Array
	var caught: Array = profile.get("caught", []) as Array
	var total: int = maxi(1, DEX_DB.all_names().size())
	draw_string(font, panel.position + Vector2(18, 28), "WIDZIANE %d/%d   SCHWYTANE %d/%d" % [seen.size(), total, caught.size(), total], HORIZONTAL_ALIGNMENT_LEFT, 288, 9, Color("5be2dc"))
	draw_rect(Rect2(panel.position + Vector2(18, 40), Vector2(288, 8)), Color("17353e"))
	draw_rect(Rect2(panel.position + Vector2(18, 40), Vector2(288.0 * float(seen.size()) / float(total), 8)), Color("52d9d3"))

	var names: Array[String] = _dex_names()
	if names.is_empty():
		draw_string(font, panel.position + Vector2(20, 100), "Brak wpisów. Wyjdź w teren.", HORIZONTAL_ALIGNMENT_LEFT, 280, 11, Color("9bb8ba"))
		return
	section_selected = clampi(section_selected, 0, names.size() - 1)
	var creature_name: String = names[section_selected]
	var data: Dictionary = DEX_DB.get_monster(creature_name)
	var texture: Texture2D = DEX_ART.texture_for(creature_name)
	var accent: Color = data.get("accent", Color("55e8de")) as Color
	var portrait_rect := Rect2(panel.position + Vector2(18, 66), Vector2(150, 124))
	draw_rect(portrait_rect, Color("102f38"))
	if texture != null:
		draw_texture_rect(texture, portrait_rect.grow(-5.0), false)
	draw_rect(portrait_rect, accent, false, 2.0)

	var stage: int = maxi(1, EVOLUTION.stage(creature_name))
	var stage_text: String = "BAZOWA" if stage == 1 else ("EWOLUCJA I" if stage == 2 else "FINALNA")
	draw_string(font, panel.position + Vector2(184, 86), creature_name, HORIZONTAL_ALIGNMENT_LEFT, 120, 16, Color("effaf8"))
	draw_string(font, panel.position + Vector2(184, 108), "Rodzina %02d · %s" % [EVOLUTION.family_id(creature_name), stage_text], HORIZONTAL_ALIGNMENT_LEFT, 120, 8, accent)
	draw_string(font, panel.position + Vector2(184, 132), "%s · %s" % [str(data.get("type", "?")), str(data.get("role", ""))], HORIZONTAL_ALIGNMENT_LEFT, 120, 8, Color("8facaf"))
	var state_text: String = "SCHWYTANY" if caught.has(creature_name) else "WIDZIANY"
	draw_string(font, panel.position + Vector2(184, 158), state_text, HORIZONTAL_ALIGNMENT_LEFT, 120, 9, Color("d8c96c") if caught.has(creature_name) else Color("718f92"))
	draw_string(font, panel.position + Vector2(184, 181), "HP %d · ATK %d · DEF %d" % [int(data.get("max_hp", 0)), int(data.get("attack", 0)), int(data.get("defense", 0))], HORIZONTAL_ALIGNMENT_LEFT, 120, 7, Color("92afb1"))

	var description: String = str(data.get("description", ""))
	var lines: Array[String] = _wrap(description, 43)
	for i: int in range(mini(4, lines.size())):
		draw_string(font, panel.position + Vector2(22, 226 + i * 18), lines[i], HORIZONTAL_ALIGNMENT_LEFT, 278, 9, Color("b4cacc"))

	var previous_name: String = EVOLUTION.previous_form(creature_name)
	var next_name: String = EVOLUTION.next_form(creature_name)
	var evo_text: String = "Linia: " + (previous_name if not previous_name.is_empty() else "—") + "  ←  " + creature_name + "  →  " + (next_name if not next_name.is_empty() else "—")
	draw_string(font, panel.position + Vector2(22, 322), evo_text, HORIZONTAL_ALIGNMENT_LEFT, 278, 8, Color("77a6a8"))

	var prev_rect := Rect2(panel.position + Vector2(22, 372), Vector2(90, 44))
	var next_rect := Rect2(panel.position + Vector2(212, 372), Vector2(90, 44))
	draw_rect(prev_rect, Color("173841"))
	draw_rect(next_rect, Color("173841"))
	draw_rect(prev_rect, Color("438a8c"), false, 1.0)
	draw_rect(next_rect, Color("438a8c"), false, 1.0)
	draw_string(font, prev_rect.position + Vector2(8, 28), "‹ POPRZEDNI", HORIZONTAL_ALIGNMENT_CENTER, 74, 9, Color("dff4f2"))
	draw_string(font, next_rect.position + Vector2(8, 28), "NASTĘPNY ›", HORIZONTAL_ALIGNMENT_CENTER, 74, 9, Color("dff4f2"))
	draw_string(font, panel.position + Vector2(116, 402), "%d / %d" % [section_selected + 1, names.size()], HORIZONTAL_ALIGNMENT_CENTER, 92, 9, Color("789a9d"))

func _handle_section_touch(pos: Vector2) -> void:
	if section != "dex":
		super._handle_section_touch(pos)
		return
	if Rect2(18, 674, 126, 44).has_point(pos):
		section = "root"
		section_selected = 0
		queue_redraw()
		return
	var names: Array[String] = _dex_names()
	if names.is_empty():
		return
	var panel := Rect2(18, 148, 324, 500)
	var prev_rect := Rect2(panel.position + Vector2(22, 372), Vector2(90, 44))
	var next_rect := Rect2(panel.position + Vector2(212, 372), Vector2(90, 44))
	if prev_rect.has_point(pos):
		section_selected = (section_selected + names.size() - 1) % names.size()
		queue_redraw()
	elif next_rect.has_point(pos):
		section_selected = (section_selected + 1) % names.size()
		queue_redraw()
