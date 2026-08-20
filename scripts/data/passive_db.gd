extends RefCounted

const EVOLUTION = preload("res://scripts/data/evolution_db.gd")

static var _PASSIVES: Dictionary = {
	"layer_anchor": {"name":"KOTWICA WARSTW", "description":"Ruchy REZONANS zyskują +2 mocy, gdy przeciwnik jest NIESTABILNY.", "attack_type":"REZONANS", "attack_flat":2, "requires_target":"unstable"},
	"sideflow": {"name":"BOCZNY PRZEPŁYW", "description":"Ruchy fizyczne zyskują +1 mocy; przy ZACHWIANIU celu +2.", "attack_type":"PHYSICAL", "attack_flat":1, "conditional_target":"stagger", "conditional_flat":2},
	"microtempo": {"name":"MIKROTEMPO", "description":"Ruchy priorytetowe zyskują +1 mocy.", "priority_flat":1},
	"soft_buffer": {"name":"MIĘKKI BUFOR", "description":"Na końcu rundy odzyskuje 2% maks. HP.", "round_heal_ratio":0.02},
	"osc_feedback": {"name":"SPRZĘŻENIE OSCYLACJI", "description":"Ruchy OSC zyskują +2 mocy przeciw UKORZENIONYM.", "attack_type":"OSC", "attack_flat":2, "requires_target":"rooted"},
	"vector_lock": {"name":"BLOKADA WEKTORA", "description":"Ruchy KIERUNEK/REZONANS zyskują +2 mocy przeciw OZNACZONYM.", "attack_types":["KIERUNEK","REZONANS"], "attack_flat":2, "requires_target":"marked"},
	"torsion_core": {"name":"RDZEŃ TORSYJNY", "description":"Przeciw PĘKNIĘTEJ OSŁONIE ruchy ofensywne zyskują +2 mocy.", "attack_flat":2, "requires_target":"armor_break"},
	"bypass_instinct": {"name":"INSTYNKT OBEJŚCIA", "description":"Przeciw UKORZENIONYM lub ZAKŁÓCONYM zyskuje +1 mocy.", "attack_flat":1, "target_any":["rooted","disrupted"]},
	"fixed_point": {"name":"PUNKT STAŁY", "description":"Odzyskuje 1% HP na końcu rundy i zwiększa odporność stabilności.", "round_heal_ratio":0.01, "stability_resist":0.20},
	"sensor_echo": {"name":"ECHO CZUJNIKA", "description":"Przeciw OZNACZONYM zyskuje +2 mocy; trener otrzymuje +1 Focus w walce rezonansowej.", "attack_flat":2, "requires_target":"marked", "focus_bonus":1},
	"harmonic_link": {"name":"WIĘŹ HARMONICZNA", "description":"Ruchy WAVE/FALA zyskują +2 mocy przeciw NAŁADOWANYM.", "attack_types":["WAVE","FALA"], "attack_flat":2, "requires_target":"charged"},
	"field_mender": {"name":"NAPRAWA POLA", "description":"Na końcu rundy odzyskuje 3% maks. HP, jeśli ma REGENERACJĘ.", "round_heal_ratio":0.03, "requires_self_heal":"regen"},
	"conductive_skin": {"name":"PRZEWODZĄCA POWŁOKA", "description":"Ruchy elektryczne zyskują +2 mocy przeciw MOKRYM.", "attack_type":"ELECTRIC", "attack_flat":2, "requires_target":"soaked"},
	"thermal_memory": {"name":"PAMIĘĆ TERMICZNA", "description":"Ruchy lodowe zyskują +2 mocy przeciw WYCHŁODZONYM.", "attack_type":"ICE", "attack_flat":2, "requires_target":"chilled"},
	"resin_spark": {"name":"ISKRA ŻYWICZNA", "description":"Ruchy ogniste zyskują +2 mocy przeciw POKRYTYM ŻYWICĄ.", "attack_type":"FIRE", "attack_flat":2, "requires_target":"oiled"},
	"last_impulse": {"name":"OSTATNI IMPULS", "description":"Poniżej 30% HP ruchy ofensywne zyskują +2 mocy.", "low_hp_threshold":0.30, "low_hp_flat":2},
	"calm_channel": {"name":"SPOKOJNY KANAŁ", "description":"Przy statusie SKUPIONY zyskuje +2 mocy.", "attack_flat":2, "requires_self":"focused"},
	"predator_mark": {"name":"ZNAK ŁOWCY", "description":"Zwiększa premię chwytu o 4% po oznaczeniu celu.", "capture_bonus":0.04, "requires_target":"marked"},
	"stability_shell": {"name":"POWŁOKA STABILNOŚCI", "description":"Zmniejsza obrażenia stabilności trenera o 25%.", "stability_resist":0.25},
	"resonant_battery": {"name":"BATERIA REZONANSOWA", "description":"Trener rozpoczyna walkę rezonansową z +1 Focus.", "focus_bonus":1}
}

static func ids() -> Array[String]:
	var result: Array[String] = []
	for key: Variant in _PASSIVES.keys():
		result.append(str(key))
	result.sort()
	return result

static func info(passive_id: String) -> Dictionary:
	if not _PASSIVES.has(passive_id):
		return {}
	return (_PASSIVES[passive_id] as Dictionary).duplicate(true)

static func default_for_family(family_id: int) -> String:
	var keys: Array[String] = ids()
	if keys.is_empty():
		return ""
	return keys[posmod(maxi(1, family_id) - 1, keys.size())]

static func default_for_creature(creature: Dictionary) -> String:
	var explicit: String = str(creature.get("passive_id", creature.get("passive", "")))
	if _PASSIVES.has(explicit):
		return explicit
	var name: String = str(creature.get("name", ""))
	var evo: Dictionary = EVOLUTION.form_info(name)
	var family_id: int = int(evo.get("family_id", creature.get("id", 1)))
	return default_for_family(maxi(1, family_id))

static func attack_flat_bonus(passive_id: String, move_data: Dictionary, self_statuses: Dictionary, target_statuses: Dictionary, hp_ratio: float) -> int:
	var data: Dictionary = info(passive_id)
	if data.is_empty():
		return 0
	var move_type: String = str(move_data.get("move_type", ""))
	var allowed: bool = true
	if data.has("attack_type"):
		allowed = move_type == str(data.get("attack_type", ""))
	if data.has("attack_types"):
		allowed = (data.get("attack_types", []) as Array).has(move_type)
	if not allowed:
		return 0
	var required_target: String = str(data.get("requires_target", ""))
	if not required_target.is_empty() and int(target_statuses.get(required_target, 0)) <= 0:
		return 0
	var required_self: String = str(data.get("requires_self", ""))
	if not required_self.is_empty() and int(self_statuses.get(required_self, 0)) <= 0:
		return 0
	var target_any: Array = data.get("target_any", []) as Array
	if not target_any.is_empty():
		var found: bool = false
		for raw_status: Variant in target_any:
			if int(target_statuses.get(str(raw_status), 0)) > 0:
				found = true
				break
		if not found:
			return 0
	var bonus: int = int(data.get("attack_flat", 0))
	var conditional_target: String = str(data.get("conditional_target", ""))
	if not conditional_target.is_empty() and int(target_statuses.get(conditional_target, 0)) > 0:
		bonus += int(data.get("conditional_flat", 0))
	var threshold: float = float(data.get("low_hp_threshold", -1.0))
	if threshold >= 0.0 and hp_ratio <= threshold:
		bonus += int(data.get("low_hp_flat", 0))
	if int(move_data.get("priority", 0)) > 0:
		bonus += int(data.get("priority_flat", 0))
	return bonus

static func round_heal(passive_id: String, max_hp: int, self_statuses: Dictionary) -> int:
	var data: Dictionary = info(passive_id)
	var ratio: float = float(data.get("round_heal_ratio", 0.0))
	if ratio <= 0.0:
		return 0
	var required: String = str(data.get("requires_self_heal", ""))
	if not required.is_empty() and int(self_statuses.get(required, 0)) <= 0:
		return 0
	return maxi(1, int(round(float(maxi(1, max_hp)) * ratio)))

static func focus_bonus(passive_id: String) -> int:
	return maxi(0, int(info(passive_id).get("focus_bonus", 0)))

static func capture_bonus(passive_id: String, target_statuses: Dictionary) -> float:
	var data: Dictionary = info(passive_id)
	var bonus: float = float(data.get("capture_bonus", 0.0))
	var required: String = str(data.get("requires_target", ""))
	if not required.is_empty() and int(target_statuses.get(required, 0)) <= 0:
		return 0.0
	return bonus

static func stability_resist(passive_id: String) -> float:
	return clampf(float(info(passive_id).get("stability_resist", 0.0)), 0.0, 0.75)
