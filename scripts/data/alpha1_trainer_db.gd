extends RefCounted

static var _TRAINERS: Dictionary = {
	"karo": {
		"id": "karo",
		"name": "Karo",
		"title": "Trener Szlaku",
		"party": [
			{"name": "Wahlik", "level": 4},
			{"name": "Srubik", "level": 5}
		],
		"reward_xp": 34,
		"reward_items": {"regenerators": 1},
		"defeated_flag": "trainer_karo_defeated",
		"prerequisite_flags": [],
		"locked_text": "Karo: Najpierw porozmawiajmy, potem zaczniemy próbę."
	},
	"vera": {
		"id": "vera",
		"name": "Vera",
		"title": "Trenerka Gaju",
		"party": [
			{"name": "Kompasik", "level": 6},
			{"name": "Milimik", "level": 6}
		],
		"reward_xp": 42,
		"reward_items": {"sondas": 1},
		"defeated_flag": "trainer_vera_defeated",
		"prerequisite_flags": [],
		"locked_text": "Vera: Najpierw poznaj rytm Gaju. Potem sprawdzimy twoje decyzje."
	},
	"rival_kael": {
		"id": "rival_kael",
		"name": "Kael",
		"title": "Rywal Veli",
		"party": [
			{"name": "Pufek", "level": 7},
			{"name": "Uczek", "level": 8},
			{"name": "Nasuch", "level": 8}
		],
		"reward_xp": 58,
		"reward_items": {"resonance_cells": 1},
		"defeated_flag": "trainer_kael_defeated",
		"prerequisite_flags": ["trainer_karo_defeated", "trainer_vera_defeated"],
		"locked_text": "Kael: Pokonaj Karo i Verę. Nie chcę sprawdzać drużyny, która nie przeszła prób Veli."
	},
	"gate_guard": {
		"id": "gate_guard",
		"name": "Rhea",
		"title": "Strażniczka Północnej Bramy",
		"party": [
			{"name": "Kotwiczek", "level": 9},
			{"name": "Dwumik", "level": 9},
			{"name": "Nucik", "level": 10}
		],
		"reward_xp": 74,
		"reward_items": {"regenerators": 2, "resonance_cells": 1},
		"defeated_flag": "trainer_rhea_defeated",
		"prerequisite_flags": ["trainer_kael_defeated"],
		"locked_text": "Rhea: Najpierw zakończ pojedynek z Kaelem. Brama otwiera się dopiero po pełnej próbie."
	}
}

static func ids() -> Array[String]:
	var result: Array[String] = []
	for raw_id: Variant in _TRAINERS.keys():
		result.append(str(raw_id))
	result.sort()
	return result

static func has(trainer_id: String) -> bool:
	return _TRAINERS.has(trainer_id)

static func info(trainer_id: String) -> Dictionary:
	if not _TRAINERS.has(trainer_id):
		return {}
	return (_TRAINERS[trainer_id] as Dictionary).duplicate(true)

static func party(trainer_id: String) -> Array:
	var data: Dictionary = info(trainer_id)
	var raw: Variant = data.get("party", [])
	if typeof(raw) != TYPE_ARRAY:
		return []
	return (raw as Array).duplicate(true)

static func defeated_flag(trainer_id: String) -> String:
	return str(info(trainer_id).get("defeated_flag", "trainer_%s_defeated" % trainer_id))

static func is_defeated(trainer_id: String, flags: Dictionary) -> bool:
	return bool(flags.get(defeated_flag(trainer_id), false))

static func can_challenge(trainer_id: String, flags: Dictionary) -> bool:
	if not has(trainer_id) or is_defeated(trainer_id, flags):
		return false
	var required: Variant = info(trainer_id).get("prerequisite_flags", [])
	if typeof(required) != TYPE_ARRAY:
		return true
	for raw_flag: Variant in required as Array:
		if not bool(flags.get(str(raw_flag), false)):
			return false
	return true

static func locked_text(trainer_id: String) -> String:
	return str(info(trainer_id).get("locked_text", "Jeszcze nie możesz rozpocząć tego pojedynku."))

static func reward_xp(trainer_id: String) -> int:
	return maxi(0, int(info(trainer_id).get("reward_xp", 0)))

static func reward_items(trainer_id: String) -> Dictionary:
	var raw: Variant = info(trainer_id).get("reward_items", {})
	if typeof(raw) != TYPE_DICTIONARY:
		return {}
	return (raw as Dictionary).duplicate(true)
