extends RefCounted

static var _QUESTS: Dictionary = {
	"sena_field_cache": {
		"title": "SKRYTKI SENY",
		"start_flag": "talked_sena",
		"requirements": ["pickup_outskirts_regen_stone", "pickup_outskirts_probe_crate"],
		"complete_flag": "sidequest_sena_complete",
		"reward": {"capture_modules": 2},
		"description": "Znajdź dwie terenowe skrytki na Obrzeżach Veli."
	},
	"tess_glass_signals": {
		"title": "SZKLANE SYGNAŁY",
		"start_flag": "talked_tess",
		"requirements": ["pickup_coast_probe_shell", "pickup_coast_cell_bridge"],
		"complete_flag": "sidequest_tess_complete",
		"reward": {"resonance_cells": 1},
		"description": "Sprawdź dwa zakłócone punkty na Szklistym Wybrzeżu."
	},
	"orin_echo_cache": {
		"title": "PAMIĘĆ ECHA",
		"start_flag": "talked_orin",
		"requirements": ["pickup_cave_module_echo", "pickup_cave_cell_resonator"],
		"complete_flag": "sidequest_orin_complete",
		"reward": {"regenerators": 1, "sondas": 1},
		"description": "Odszukaj obie stare skrytki w Jaskini Echa."
	}
}

static func ids() -> Array[String]:
	return ["sena_field_cache", "tess_glass_signals", "orin_echo_cache"]

static func info(quest_id: String) -> Dictionary:
	if not _QUESTS.has(quest_id):
		return {}
	return (_QUESTS[quest_id] as Dictionary).duplicate(true)

static func is_started(quest_id: String, flags: Dictionary) -> bool:
	var data: Dictionary = info(quest_id)
	return bool(flags.get(str(data.get("start_flag", "")), false))

static func is_complete(quest_id: String, flags: Dictionary) -> bool:
	var data: Dictionary = info(quest_id)
	return bool(flags.get(str(data.get("complete_flag", "")), false))

static func can_complete(quest_id: String, flags: Dictionary) -> bool:
	if not is_started(quest_id, flags) or is_complete(quest_id, flags):
		return false
	var raw_requirements: Variant = info(quest_id).get("requirements", [])
	if typeof(raw_requirements) != TYPE_ARRAY:
		return false
	for raw_flag: Variant in raw_requirements as Array:
		if not bool(flags.get(str(raw_flag), false)):
			return false
	return true

static func complete_flag(quest_id: String) -> String:
	return str(info(quest_id).get("complete_flag", "sidequest_%s_complete" % quest_id))

static func reward(quest_id: String) -> Dictionary:
	var raw: Variant = info(quest_id).get("reward", {})
	if typeof(raw) != TYPE_DICTIONARY:
		return {}
	return (raw as Dictionary).duplicate(true)

static func progress_text(quest_id: String, flags: Dictionary) -> String:
	var data: Dictionary = info(quest_id)
	if is_complete(quest_id, flags):
		return "%s · UKOŃCZONE" % str(data.get("title", quest_id))
	if not is_started(quest_id, flags):
		return "%s · NIEODKRYTE" % str(data.get("title", quest_id))
	var raw_requirements: Variant = data.get("requirements", [])
	var done: int = 0
	var total: int = 0
	if typeof(raw_requirements) == TYPE_ARRAY:
		for raw_flag: Variant in raw_requirements as Array:
			total += 1
			if bool(flags.get(str(raw_flag), false)):
				done += 1
	return "%s · %d/%d" % [str(data.get("title", quest_id)), done, total]