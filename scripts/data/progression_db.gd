extends RefCounted

const TALENT_DB = preload("res://scripts/data/trainer_talent_db.gd")

const PATH_TACTICIAN: String = "tactician"
const PATH_GUARDIAN: String = "guardian"
const PATH_RESEARCHER: String = "researcher"
const PATH_TECHNICIAN: String = "technician"
const PATH_VANGUARD: String = "vanguard"
const TRAINER_LEVEL_CAP: int = 50
const MAX_PATH_INVESTMENT: int = 20

static var _PATHS: Dictionary = {
	PATH_TACTICIAN: {
		"name":"TAKTYK","max_rank":MAX_PATH_INVESTMENT,
		"description":"Tempo, kolejność, kontry i kombinacje.",
		"action_name":"ROZKAZ: NATARCIE","action_description":"Wzmacnia ruch partnera w tej rundzie."
	},
	PATH_GUARDIAN: {
		"name":"OPIEKUN","max_rank":MAX_PATH_INVESTMENT,
		"description":"Więź, leczenie, odporność i rozwój partnerów.",
		"action_name":"DOSTROJENIE","action_description":"Leczy aktywnego partnera przed jego ruchem."
	},
	PATH_RESEARCHER: {
		"name":"BADACZ","max_rank":MAX_PATH_INVESTMENT,
		"description":"SOMADEX, chwyt, rzadkie spotkania i sekrety.",
		"action_name":"SKAN SŁABOŚCI","action_description":"Nadaje status OZNACZONY i ułatwia chwyt."
	},
	PATH_TECHNICIAN: {
		"name":"TECHNIK","max_rank":MAX_PATH_INVESTMENT,
		"description":"Gadżety, przedmioty, crafting i generatory pola.",
		"action_name":"IMPULS ZAKŁÓCAJĄCY","action_description":"Osłabia następną odpowiedź przeciwnika."
	},
	PATH_VANGUARD: {
		"name":"AWANGARDZISTA","max_rank":MAX_PATH_INVESTMENT,
		"description":"Przechwyt, stabilność, tarcze i aktywna obecność trenera.",
		"action_name":"PRZECHWYT","action_description":"Trener osłania partnera przed odpowiedzią."
	}
}

static func path_ids() -> Array[String]:
	return [PATH_TACTICIAN, PATH_GUARDIAN, PATH_RESEARCHER, PATH_TECHNICIAN, PATH_VANGUARD]

static func default_talents() -> Dictionary:
	return {PATH_TACTICIAN:0, PATH_GUARDIAN:0, PATH_RESEARCHER:0, PATH_TECHNICIAN:0, PATH_VANGUARD:0}

static func path_info(path_id: String) -> Dictionary:
	if not _PATHS.has(path_id):
		return {}
	var result: Dictionary = (_PATHS[path_id] as Dictionary).duplicate(true)
	result["nodes"] = TALENT_DB.nodes_for_path(path_id)
	return result

static func path_name(path_id: String) -> String:
	return str(path_info(path_id).get("name", path_id))

static func rank(talents: Dictionary, path_id: String) -> int:
	return clampi(int(talents.get(path_id, 0)), 0, MAX_PATH_INVESTMENT)

static func max_rank(path_id: String) -> int:
	return int(path_info(path_id).get("max_rank", MAX_PATH_INVESTMENT))

static func next_talent(talents: Dictionary, path_id: String) -> Dictionary:
	return TALENT_DB.next_node(path_id, rank(talents, path_id))

static func can_spend(talents: Dictionary, points: int, path_id: String, trainer_level: int = TRAINER_LEVEL_CAP) -> bool:
	if points <= 0 or not _PATHS.has(path_id):
		return false
	var investment: int = rank(talents, path_id)
	if investment >= max_rank(path_id):
		return false
	return TALENT_DB.can_unlock(path_id, investment, clampi(trainer_level, 1, TRAINER_LEVEL_CAP))

static func spend(talents: Dictionary, points: int, path_id: String, trainer_level: int = TRAINER_LEVEL_CAP) -> Dictionary:
	var updated: Dictionary = default_talents()
	for known_path: String in path_ids():
		updated[known_path] = rank(talents, known_path)
	if not can_spend(updated, points, path_id, trainer_level):
		return {"talents":updated,"points":points,"spent":false,"node":{}}
	var next: Dictionary = next_talent(updated, path_id)
	updated[path_id] = rank(updated, path_id) + 1
	return {"talents":updated,"points":points - 1,"spent":true,"node":next}

static func bonuses(talents: Dictionary) -> Dictionary:
	return TALENT_DB.aggregate(talents)

static func trainer_action_count() -> int:
	return 5

static func trainer_action_path(index: int) -> String:
	var paths: Array[String] = path_ids()
	if index < 0 or index >= paths.size():
		return ""
	return paths[index]

static func action_rank(talents: Dictionary, path_id: String) -> int:
	var investment: int = rank(talents, path_id)
	if investment <= 0:
		return 0
	return clampi(1 + int((investment - 1) / 4), 1, 5)

static func trainer_action_info(index: int, talents: Dictionary) -> Dictionary:
	var path_id: String = trainer_action_path(index)
	if path_id.is_empty():
		return {}
	var data: Dictionary = path_info(path_id)
	var investment: int = rank(talents, path_id)
	var focus_cost: int = 1
	var bonus: Dictionary = bonuses(talents)
	if int(bonus.get("focus_efficiency", 0)) > 0 and action_rank(talents, path_id) >= 5:
		focus_cost = 0
	return {
		"path_id":path_id,
		"name":str(data.get("action_name", path_name(path_id))),
		"description":str(data.get("action_description", "")),
		"rank":action_rank(talents, path_id),
		"investment":investment,
		"focus_cost":focus_cost,
		"next_talent":next_talent(talents, path_id)
	}

static func xp_to_next_level(level: int) -> int:
	if level >= TRAINER_LEVEL_CAP:
		return 1000000000
	return 18 + maxi(1, level) * 7

static func quest_title(stage: int) -> String:
	match stage:
		0: return "PIERWSZY REZONANS"
		1: return "WYJŚCIE W TEREN"
		2: return "SYNCHRONIZACJA"
		3: return "POWRÓT DO VELA"
		4: return "SZLAK REZONANSU"
		_: return "FUNDAMENT REGIONU"

static func quest_objective(stage: int) -> String:
	match stage:
		0: return "Wybierz pierwszego partnera."
		1: return "Wejdź w wysoką trawę i znajdź dzikiego Somaskana."
		2: return "Osłab dzikiego Somaskana i użyj Modułu Chwytu."
		3: return "Wróć do Stacji Vela i zsynchronizuj bazę."
		4: return "Przejdź północnym wyjściem na Szlak Rezonansu."
		_: return "Fundament systemów jest aktywny. Dalsza produkcja rozszerza zawartość regionu."

static func quest_short(stage: int) -> String:
	match stage:
		0: return "Wybierz partnera"
		1: return "Znajdź dzikiego Somaskana"
		2: return "Spróbuj chwytu"
		3: return "Wróć do Stacji Vela"
		4: return "Wejdź na Szlak Rezonansu"
		_: return "Fundament aktywny"
