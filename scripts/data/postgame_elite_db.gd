extends RefCounted

const MODES = preload("res://scripts/data/battle_mode_db.gd")

const _SPECS: Array[Dictionary] = [
	{"id":"rematch_eron","boss_profile_id":"vela_trial","name":"Eron · Echo","title":"Rekalibracja Warstw","zone":"echo_sanctum","tile":[3,11],"level":52,"mode":"resonance","party":["Synkronaut","Fundamentor","Sensoryks","Rezonar","Chorogrif","Anatomorf"],"reward":{"resonance_cells":3,"echo_shard":4,"regenerators":2}},
	{"id":"rematch_hail","boss_profile_id":"nivra_guardian","name":"Hail · Echo","title":"Biała Cisza II","zone":"echo_sanctum","tile":[7,5],"level":54,"mode":"resonance","party":["Hydrainfinity","Orbitalos","Pneumost","Neurogryf","Chronozel","Galaktylion"],"reward":{"cryo_salt":5,"resonance_cells":2,"capture_modules":2}},
	{"id":"rematch_sol","boss_profile_id":"lumen_keeper","name":"Sol · Echo","title":"Rekonstrukcja Pamięci","zone":"echo_sanctum","tile":[11,11],"level":55,"mode":"trainer_duel","party":["Sensoryks","Sieciowid","Metronotron","Neurogryf","Anatomorf","Gwiezdny_Punktor"],"reward":{"echo_shard":5,"sondas":2,"resonance_cells":2}},
	{"id":"rematch_sora","boss_profile_id":"marea_resonance","name":"Sora · Annex","title":"Przypływ Zamknięty","zone":"resonance_annex","tile":[3,11],"level":53,"mode":"resonance","party":["Hydrainfinity","Elektrokoral","Cyberwibr","Pneumost","Rezonar","Fazoryb"],"reward":{"charged_crystal":4,"copper_coil":4,"resonance_cells":2}},
	{"id":"rematch_ax7","boss_profile_id":"ferrum_construct","name":"AX-7 · Mk II","title":"Overclock Laboratoryjny","zone":"resonance_annex","tile":[7,5],"level":56,"mode":"trainer_duel","party":["Elektrokoral","Metronotron","Grawititan","Spiralion","Cyberwibr","Anatomorf"],"reward":{"alloy_scrap":6,"charged_crystal":5,"focus_capacitor":1}},
	{"id":"rematch_elow","boss_profile_id":"aster_warden","name":"Elow · Annex","title":"Korona Regeneracyjna","zone":"resonance_annex","tile":[11,11],"level":56,"mode":"resonance","party":["Regenerion","Autonomir","Hydrainfinity","Ziemiomil","Potokrzew","Anatomorf"],"reward":{"bio_gel":6,"resin_pod":5,"regen_beacon":1}},
	{"id":"rematch_veya","boss_profile_id":"koral_tide","name":"Veya · Głębia","title":"Sztorm Odwróconego Prądu","zone":"outer_trench","tile":[5,11],"level":57,"mode":"resonance","party":["Hydrainfinity","Elektrokoral","Pneumost","Fazoryb","Galaktylion","Rezonansowy_Garuda"],"reward":{"cryo_salt":4,"charged_crystal":4,"capture_modules":3}},
	{"id":"rematch_veyr","boss_profile_id":"zenith_final","name":"Veyr · Rdzeń Echa","title":"Próba Końcowa+","zone":"outer_trench","tile":[9,11],"level":60,"mode":"trainer_duel","party":["Synkronaut","Spiralion","Sensoryks","Rezonar","Chimera_Pieciu_Przemian","Rezonansowy_Garuda"],"reward":{"resonance_cells":4,"echo_shard":6,"focus_capacitor":1}}
]

static func ids() -> Array[String]:
	var result: Array[String] = []
	for spec: Dictionary in _SPECS:
		result.append(str(spec.get("id", "")))
	return result

static func has(trainer_id: String) -> bool:
	return not info(trainer_id).is_empty()

static func info(trainer_id: String) -> Dictionary:
	for spec: Dictionary in _SPECS:
		if str(spec.get("id", "")) == trainer_id:
			return spec.duplicate(true)
	return {}

static func in_zone(zone_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for spec: Dictionary in _SPECS:
		if str(spec.get("zone", "")) == zone_id:
			result.append(spec.duplicate(true))
	return result

static func party(trainer_id: String) -> Array:
	var spec: Dictionary = info(trainer_id)
	if spec.is_empty():
		return []
	var level: int = maxi(1, int(spec.get("level", 52)))
	var result: Array = []
	var names: Array = spec.get("party", []) as Array
	for index: int in range(names.size()):
		result.append({"name":str(names[index]),"level":level + int(index / 2)})
	return result

static func can_challenge(trainer_id: String, flags: Dictionary) -> bool:
	return has(trainer_id) and bool(flags.get("defeated_zenith_final", false)) and not is_defeated(trainer_id, flags)

static func defeated_flag(trainer_id: String) -> String:
	return "defeated_%s" % trainer_id

static func is_defeated(trainer_id: String, flags: Dictionary) -> bool:
	return bool(flags.get(defeated_flag(trainer_id), false))

static func reward_xp(trainer_id: String) -> int:
	var level: int = int(info(trainer_id).get("level", 52))
	return level * 8

static func reward_items(trainer_id: String) -> Dictionary:
	return (info(trainer_id).get("reward", {}) as Dictionary).duplicate(true)

static func locked_text(_trainer_id: String) -> String:
	return "Echo próby uaktywni się dopiero po ukończeniu finału Zenith."

static func battle_mode(trainer_id: String) -> String:
	var raw: String = str(info(trainer_id).get("mode", MODES.MODE_RESONANCE))
	return raw if MODES.has(raw) else MODES.MODE_RESONANCE

static func boss_profile_id(trainer_id: String) -> String:
	return str(info(trainer_id).get("boss_profile_id", ""))

static func count() -> int:
	return _SPECS.size()
