extends RefCounted

static var _STATUSES: Dictionary = {
	"soaked": {"name": "MOKRY", "default_turns": 2, "description": "Wzmacnia reakcje z elektrycznością i chłodem."},
	"charged": {"name": "NAŁADOWANY", "default_turns": 2, "description": "Pole jest podatne na reakcje falowe."},
	"burn": {"name": "OPARZENIE", "default_turns": 3, "description": "Traci HP na końcu rundy.", "tick_damage": 2},
	"unstable": {"name": "NIESTABILNY", "default_turns": 2, "description": "Otrzymuje więcej obrażeń rezonansowych."},
	"marked": {"name": "OZNACZONY", "default_turns": 3, "description": "Łatwiejszy chwyt po analizie."},
	"disrupted": {"name": "ZAKŁÓCONY", "default_turns": 1, "description": "Zadaje mniej obrażeń.", "outgoing_mult": 0.75},
	"rooted": {"name": "UKORZENIONY", "default_turns": 2, "description": "Trudniej ucieka, łatwiej schwytać."},
	"armor_break": {"name": "PĘKNIĘTA OSŁONA", "default_turns": 2, "description": "Podatność na ruchy fizyczne."},
	"bleed": {"name": "NARUSZENIE", "default_turns": 2, "description": "Traci HP na końcu rundy.", "tick_damage": 1},
	"chilled": {"name": "WYCHŁODZONY", "default_turns": 2, "description": "Obniżona dynamika pola."},
	"frozen": {"name": "ZAMROŻONY", "default_turns": 1, "description": "Silna kontrola po reakcji chłodu."},
	"oiled": {"name": "POKRYTY ŻYWICĄ", "default_turns": 3, "description": "Silna podatność na ogień."},
	"focused": {"name": "SKUPIONY", "default_turns": 1, "description": "Następny atak jest wzmocniony.", "outgoing_mult": 1.15},
	"regen": {"name": "REGENERACJA", "default_turns": 2, "description": "Odzyskuje HP na końcu rundy.", "tick_heal": 2},
	"stagger": {"name": "ZACHWIANIE", "default_turns": 1, "description": "Osłabiona obrona i tempo."},
	"silence": {"name": "CISZA", "default_turns": 1, "description": "Zakłóca specjalne komendy."}
}

static var _INTERACTIONS: Array[Dictionary] = [
	{"move_type": "ELECTRIC", "requires": "soaked", "multiplier": 1.35, "label": "PRZEWODZENIE"},
	{"move_type": "ICE", "requires": "soaked", "multiplier": 1.25, "label": "SZOK TERMICZNY"},
	{"move_type": "FIRE", "requires": "oiled", "multiplier": 1.40, "label": "ZAPŁON"},
	{"move_type": "PHYSICAL", "requires": "armor_break", "multiplier": 1.25, "label": "PRZEŁAMANIE"},
	{"move_type": "REZONANS", "requires": "unstable", "multiplier": 1.25, "label": "REZONANS KRYTYCZNY"},
	{"move_type": "WAVE", "requires": "charged", "multiplier": 1.20, "label": "SPRZĘŻENIE"},
	{"move_type": "OSC", "requires": "rooted", "multiplier": 1.15, "label": "ODBICIE"},
	{"move_type": "PHYSICAL", "requires": "stagger", "multiplier": 1.15, "label": "WYKORZYSTANIE ZACHWIANIA"}
]

static func ids() -> Array[String]:
	var result: Array[String] = []
	for key: Variant in _STATUSES.keys():
		result.append(str(key))
	result.sort()
	return result

static func info(status_id: String) -> Dictionary:
	if not _STATUSES.has(status_id):
		return {}
	return (_STATUSES[status_id] as Dictionary).duplicate(true)

static func default_turns(status_id: String) -> int:
	return maxi(1, int(info(status_id).get("default_turns", 1)))

static func has_status(statuses: Dictionary, status_id: String) -> bool:
	return int(statuses.get(status_id, 0)) > 0

static func apply(statuses: Dictionary, status_id: String, turns: int = -1) -> void:
	if status_id.is_empty() or not _STATUSES.has(status_id):
		return
	var duration: int = default_turns(status_id) if turns < 0 else maxi(1, turns)
	statuses[status_id] = maxi(int(statuses.get(status_id, 0)), duration)

static func remove(statuses: Dictionary, status_id: String) -> void:
	statuses.erase(status_id)

static func cleanse_stability(statuses: Dictionary) -> void:
	for status_id: String in ["unstable", "disrupted", "stagger", "silence"]:
		statuses.erase(status_id)

static func tick(statuses: Dictionary) -> Dictionary:
	var updated: Dictionary = {}
	for key: Variant in statuses.keys():
		var status_id: String = str(key)
		var turns: int = maxi(0, int(statuses[key]) - 1)
		if turns > 0:
			updated[status_id] = turns
	return updated

static func tick_damage(statuses: Dictionary) -> int:
	var total: int = 0
	for key: Variant in statuses.keys():
		var data: Dictionary = info(str(key))
		total += maxi(0, int(data.get("tick_damage", 0)))
	return total

static func tick_heal(statuses: Dictionary) -> int:
	var total: int = 0
	for key: Variant in statuses.keys():
		var data: Dictionary = info(str(key))
		total += maxi(0, int(data.get("tick_heal", 0)))
	return total

static func outgoing_multiplier(statuses: Dictionary) -> float:
	var result: float = 1.0
	for key: Variant in statuses.keys():
		var data: Dictionary = info(str(key))
		result *= float(data.get("outgoing_mult", 1.0))
	return result

static func damage_multiplier(move_type: String, target_statuses: Dictionary) -> float:
	var result: float = 1.0
	for interaction: Dictionary in _INTERACTIONS:
		if str(interaction.get("move_type", "")) != move_type:
			continue
		var required: String = str(interaction.get("requires", ""))
		if has_status(target_statuses, required):
			result *= float(interaction.get("multiplier", 1.0))
	return result

static func interaction_label(move_type: String, target_statuses: Dictionary) -> String:
	for interaction: Dictionary in _INTERACTIONS:
		if str(interaction.get("move_type", "")) != move_type:
			continue
		var required: String = str(interaction.get("requires", ""))
		if has_status(target_statuses, required):
			return str(interaction.get("label", "REAKCJA"))
	return ""

static func capture_modifier(statuses: Dictionary) -> float:
	var bonus: float = 0.0
	if has_status(statuses, "marked"): bonus += 0.10
	if has_status(statuses, "rooted"): bonus += 0.06
	if has_status(statuses, "soaked"): bonus += 0.02
	if has_status(statuses, "frozen"): bonus += 0.08
	return bonus

static func escape_modifier(statuses: Dictionary) -> float:
	var modifier: float = 0.0
	if has_status(statuses, "rooted"): modifier -= 0.18
	if has_status(statuses, "stagger"): modifier -= 0.08
	return modifier

static func summary(statuses: Dictionary, limit: int = 3) -> String:
	var labels: Array[String] = []
	for key: Variant in statuses.keys():
		if labels.size() >= limit: break
		var status_id: String = str(key)
		var data: Dictionary = info(status_id)
		labels.append(str(data.get("name", status_id.to_upper())))
	return " · ".join(labels)

static func interaction_count() -> int:
	return _INTERACTIONS.size()
