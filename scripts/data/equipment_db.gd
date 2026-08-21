extends RefCounted

const SLOT_HEAD: String = "head"
const SLOT_OUTFIT: String = "outfit"
const SLOT_GLOVES: String = "gloves"
const SLOT_BOOTS: String = "boots"
const SLOT_MODULE: String = "module"
const SLOT_RELIC: String = "relic"

static var _GEAR: Dictionary = {
	"vela_cap": {"name":"Czapka Vela","slot":SLOT_HEAD,"description":"Lekka osłona terenowa.","bonuses":{"defense_bonus":1}},
	"analysis_visor": {"name":"Wizjer Analityczny","slot":SLOT_HEAD,"description":"Wspiera analizę i synchronizację chwytu.","bonuses":{"capture_bonus":0.04}},
	"focus_headset": {"name":"Opaska Koncentracji","slot":SLOT_HEAD,"description":"Stabilizuje pracę trenera z Focus.","bonuses":{"trainer_focus_bonus":1,"stability_resist":0.03}},
	"echo_hood": {"name":"Kaptur Echa","slot":SLOT_HEAD,"description":"Tłumi zakłócenia i wzmacnia reakcje pola.","bonuses":{"defense_bonus":1,"combo_bonus":1}},

	"field_jacket": {"name":"Kurtka Terenowa","slot":SLOT_OUTFIT,"description":"Podstawowa ochrona na Szlaku.","bonuses":{"max_hp_bonus":2}},
	"resonance_coat": {"name":"Płaszcz Rezonansu","slot":SLOT_OUTFIT,"description":"Rozprasza część presji pola.","bonuses":{"defense_bonus":1,"stability_resist":0.04}},
	"medic_harness": {"name":"Uprząż Medyczna","slot":SLOT_OUTFIT,"description":"Ułatwia szybką regenerację partnera.","bonuses":{"heal_bonus":2,"item_heal_bonus":1}},
	"vanguard_vest": {"name":"Kamizelka Awangardy","slot":SLOT_OUTFIT,"description":"Chroni przy aktywnym przechwycie.","bonuses":{"max_hp_bonus":3,"defense_bonus":1}},

	"grip_gloves": {"name":"Rękawice Chwytu","slot":SLOT_GLOVES,"description":"Stabilizują pracę z Modułem Chwytu.","bonuses":{"capture_bonus":0.03}},
	"relay_gloves": {"name":"Rękawice Przekaźnikowe","slot":SLOT_GLOVES,"description":"Pierwsze komendy wymagają mniej energii w zaawansowanym buildzie.","bonuses":{"special_focus_discount":1}},
	"craft_gloves": {"name":"Rękawice Warsztatowe","slot":SLOT_GLOVES,"description":"Precyzyjna praca z urządzeniami terenowymi.","bonuses":{"crafting_bonus":1,"gadget_power_bonus":1}},
	"guard_gauntlets": {"name":"Karwasze Przechwytu","slot":SLOT_GLOVES,"description":"Wzmacniają aktywną ochronę partnera.","bonuses":{"defense_bonus":1,"counter_bonus":1}},

	"trail_boots": {"name":"Buty Szlaku","slot":SLOT_BOOTS,"description":"Ułatwiają bezpieczny odwrót.","bonuses":{"escape_bonus":0.03}},
	"wanderer_boots": {"name":"Buty Wędrowca","slot":SLOT_BOOTS,"description":"Zmniejszają presję losowych starć i ułatwiają odwrót.","bonuses":{"escape_bonus":0.07}},
	"phase_boots": {"name":"Buty Fazowe","slot":SLOT_BOOTS,"description":"Wspierają zmianę pozycji i uniki.","bonuses":{"escape_bonus":0.04,"counter_bonus":1}},
	"stability_boots": {"name":"Buty Kotwiczące","slot":SLOT_BOOTS,"description":"Poprawiają stabilność podczas ciężkich pojedynków.","bonuses":{"stability_resist":0.05,"defense_bonus":1}},

	"basic_module": {"name":"Moduł Vela-I","slot":SLOT_MODULE,"description":"Wzmacnia podstawowe komendy trenera.","bonuses":{"attack_bonus":1,"trainer_focus_bonus":1}},
	"capture_lens": {"name":"Soczewka Badacza","slot":SLOT_MODULE,"description":"Moduł nastawiony na analizę i chwyt.","bonuses":{"capture_bonus":0.08}},
	"field_generator": {"name":"Generator Pola","slot":SLOT_MODULE,"description":"Zwiększa skuteczność gadżetów i Focus.","bonuses":{"gadget_power_bonus":2,"trainer_focus_bonus":1}},
	"combo_processor": {"name":"Procesor Kombinacji","slot":SLOT_MODULE,"description":"Wzmacnia złożone reakcje statusowe.","bonuses":{"combo_bonus":2,"attack_bonus":1}},

	"resonance_charm": {"name":"Talizman Rezonansu","slot":SLOT_RELIC,"description":"Wzmacnia regenerację partnera.","bonuses":{"heal_bonus":2}},
	"guard_relic": {"name":"Relikt Strażnika","slot":SLOT_RELIC,"description":"Zwiększa odporność i maksymalne HP.","bonuses":{"defense_bonus":1,"max_hp_bonus":2}},
	"echo_relic": {"name":"Relikt Echa","slot":SLOT_RELIC,"description":"Wzmacnia kontry i reakcje pola.","bonuses":{"counter_bonus":1,"combo_bonus":1}},
	"focus_relic": {"name":"Relikt Skupienia","slot":SLOT_RELIC,"description":"Dodatkowa rezerwa Focus w ważnych pojedynkach.","bonuses":{"trainer_focus_bonus":2,"special_focus_discount":1}}
}

static func slot_ids() -> Array[String]:
	return [SLOT_HEAD, SLOT_OUTFIT, SLOT_GLOVES, SLOT_BOOTS, SLOT_MODULE, SLOT_RELIC]

static func slot_name(slot_id: String) -> String:
	var names: Dictionary = {SLOT_HEAD:"GŁOWA",SLOT_OUTFIT:"STRÓJ",SLOT_GLOVES:"RĘKAWICE",SLOT_BOOTS:"BUTY",SLOT_MODULE:"MODUŁ",SLOT_RELIC:"RELIKT"}
	return str(names.get(slot_id, slot_id.to_upper()))

static func ids() -> Array[String]:
	var result: Array[String] = []
	for key: Variant in _GEAR.keys():
		result.append(str(key))
	result.sort()
	return result

static func info(gear_id: String) -> Dictionary:
	if not _GEAR.has(gear_id):
		return {}
	return (_GEAR[gear_id] as Dictionary).duplicate(true)

static func default_owned() -> Array[String]:
	return ["vela_cap", "field_jacket", "grip_gloves", "trail_boots", "basic_module", "capture_lens", "resonance_charm", "guard_relic"]

static func default_loadout() -> Dictionary:
	return {SLOT_HEAD:"vela_cap",SLOT_OUTFIT:"field_jacket",SLOT_GLOVES:"grip_gloves",SLOT_BOOTS:"trail_boots",SLOT_MODULE:"basic_module",SLOT_RELIC:"resonance_charm"}

static func normalize_owned(raw: Variant) -> Array[String]:
	var result: Array[String] = []
	if typeof(raw) == TYPE_ARRAY:
		for value: Variant in raw as Array:
			var gear_id: String = str(value)
			if _GEAR.has(gear_id) and not result.has(gear_id):
				result.append(gear_id)
	if result.is_empty():
		return default_owned()
	return result

static func normalize_loadout(raw: Variant, owned: Array[String]) -> Dictionary:
	var result: Dictionary = default_loadout()
	if typeof(raw) == TYPE_DICTIONARY:
		var incoming: Dictionary = raw as Dictionary
		for slot_id: String in slot_ids():
			var gear_id: String = str(incoming.get(slot_id, result[slot_id]))
			if owned.has(gear_id):
				var data: Dictionary = info(gear_id)
				if str(data.get("slot", "")) == slot_id:
					result[slot_id] = gear_id
	for slot_id: String in slot_ids():
		var current_id: String = str(result.get(slot_id, ""))
		if not owned.has(current_id):
			result[slot_id] = first_owned_for_slot(owned, slot_id)
	return result

static func first_owned_for_slot(owned: Array[String], slot_id: String) -> String:
	for gear_id: String in owned:
		var data: Dictionary = info(gear_id)
		if str(data.get("slot", "")) == slot_id:
			return gear_id
	return ""

static func next_owned_for_slot(owned: Array[String], slot_id: String, current_id: String) -> String:
	var candidates: Array[String] = []
	for gear_id: String in owned:
		var data: Dictionary = info(gear_id)
		if str(data.get("slot", "")) == slot_id:
			candidates.append(gear_id)
	if candidates.is_empty():
		return ""
	var current_index: int = candidates.find(current_id)
	if current_index < 0:
		return candidates[0]
	return candidates[(current_index + 1) % candidates.size()]

static func aggregate(loadout: Dictionary) -> Dictionary:
	var totals: Dictionary = {
		"attack_bonus":0,"defense_bonus":0,"max_hp_bonus":0,"heal_bonus":0,"capture_bonus":0.0,"escape_bonus":0.0,"trainer_focus_bonus":0,
		"stability_resist":0.0,"combo_bonus":0,"counter_bonus":0,"gadget_power_bonus":0,"crafting_bonus":0,"item_heal_bonus":0,"special_focus_discount":0
	}
	for slot_id: String in slot_ids():
		var gear_id: String = str(loadout.get(slot_id, ""))
		var data: Dictionary = info(gear_id)
		var raw_bonuses: Variant = data.get("bonuses", {})
		if typeof(raw_bonuses) != TYPE_DICTIONARY:
			continue
		var bonuses: Dictionary = raw_bonuses as Dictionary
		for key: Variant in bonuses.keys():
			var bonus_key: String = str(key)
			if not totals.has(bonus_key):
				continue
			if typeof(totals[bonus_key]) == TYPE_FLOAT or typeof(bonuses[key]) == TYPE_FLOAT:
				totals[bonus_key] = float(totals[bonus_key]) + float(bonuses[key])
			else:
				totals[bonus_key] = int(totals[bonus_key]) + int(bonuses[key])
	return totals

static func catalog_count() -> int:
	return _GEAR.size()
