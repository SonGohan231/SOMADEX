extends RefCounted

const PATH_TACTICIAN: String = "tactician"
const PATH_GUARDIAN: String = "guardian"
const PATH_RESEARCHER: String = "researcher"
const PATH_TECHNICIAN: String = "technician"
const PATH_VANGUARD: String = "vanguard"

static var _PATHS: Dictionary = {
	PATH_TACTICIAN: {
		"name": "TAKTYK",
		"max_rank": 5,
		"description": "+1 obrażenie ruchów ofensywnych / rangę",
		"bonus_key": "attack_bonus"
	},
	PATH_GUARDIAN: {
		"name": "OPIEKUN",
		"max_rank": 5,
		"description": "+2 HP leczenia i +2 maks. HP / rangę",
		"bonus_key": "heal_bonus"
	},
	PATH_RESEARCHER: {
		"name": "BADACZ",
		"max_rank": 5,
		"description": "+4% szansy synchronizacji chwytu / rangę",
		"bonus_key": "capture_bonus"
	},
	PATH_TECHNICIAN: {
		"name": "TECHNIK",
		"max_rank": 5,
		"description": "+2 HP skuteczności Regeneratora / rangę",
		"bonus_key": "item_heal_bonus"
	},
	PATH_VANGUARD: {
		"name": "AWANGARDZISTA",
		"max_rank": 5,
		"description": "+4% szansy bezpiecznego odwrotu / rangę",
		"bonus_key": "escape_bonus"
	}
}

static func path_ids() -> Array[String]:
	return [PATH_TACTICIAN, PATH_GUARDIAN, PATH_RESEARCHER, PATH_TECHNICIAN, PATH_VANGUARD]

static func default_talents() -> Dictionary:
	return {
		PATH_TACTICIAN: 0,
		PATH_GUARDIAN: 0,
		PATH_RESEARCHER: 0,
		PATH_TECHNICIAN: 0,
		PATH_VANGUARD: 0
	}

static func path_info(path_id: String) -> Dictionary:
	if not _PATHS.has(path_id):
		return {}
	return (_PATHS[path_id] as Dictionary).duplicate(true)

static func path_name(path_id: String) -> String:
	return str(path_info(path_id).get("name", path_id))

static func rank(talents: Dictionary, path_id: String) -> int:
	return maxi(0, int(talents.get(path_id, 0)))

static func can_spend(talents: Dictionary, points: int, path_id: String) -> bool:
	if points <= 0 or not _PATHS.has(path_id):
		return false
	var max_rank: int = int((_PATHS[path_id] as Dictionary).get("max_rank", 5))
	return rank(talents, path_id) < max_rank

static func spend(talents: Dictionary, points: int, path_id: String) -> Dictionary:
	var updated: Dictionary = talents.duplicate(true)
	if not can_spend(updated, points, path_id):
		return {"talents": updated, "points": points, "spent": false}
	updated[path_id] = rank(updated, path_id) + 1
	return {"talents": updated, "points": points - 1, "spent": true}

static func bonuses(talents: Dictionary) -> Dictionary:
	var tactician: int = rank(talents, PATH_TACTICIAN)
	var guardian: int = rank(talents, PATH_GUARDIAN)
	var researcher: int = rank(talents, PATH_RESEARCHER)
	var technician: int = rank(talents, PATH_TECHNICIAN)
	var vanguard: int = rank(talents, PATH_VANGUARD)
	return {
		"attack_bonus": tactician,
		"heal_bonus": guardian * 2,
		"max_hp_bonus": guardian * 2,
		"capture_bonus": float(researcher) * 0.04,
		"item_heal_bonus": technician * 2,
		"escape_bonus": float(vanguard) * 0.04
	}

static func xp_to_next_level(level: int) -> int:
	return 18 + maxi(1, level) * 7

static func quest_title(stage: int) -> String:
	match stage:
		0: return "PIERWSZY REZONANS"
		1: return "WYJŚCIE W TEREN"
		2: return "SYNCHRONIZACJA"
		3: return "POWRÓT DO VELA"
		_: return "SZLAK REZONANSU"

static func quest_objective(stage: int) -> String:
	match stage:
		0: return "Wybierz pierwszego partnera."
		1: return "Wejdź w wysoką trawę i znajdź dzikiego Somaskana."
		2: return "Osłab dzikiego Somaskana i użyj Modułu Chwytu."
		3: return "Wróć do Stacji Vela i zsynchronizuj bazę."
		_: return "Fundament regionu gotowy — Szlak Rezonansu jest aktywny."

static func quest_short(stage: int) -> String:
	match stage:
		0: return "Wybierz partnera"
		1: return "Znajdź dzikiego Somaskana"
		2: return "Spróbuj chwytu"
		3: return "Wróć do Stacji Vela"
		_: return "Szlak Rezonansu aktywny"
