extends RefCounted

const BOSS_IDS: Array[String] = [
	"vela_trial", "marea_resonance", "ferrum_construct", "nivra_guardian",
	"lumen_keeper", "aster_warden", "koral_tide", "zenith_final"
]

const _PROFILES: Dictionary = {
	"vela_trial": {
		"name":"Próba Warstw", "mechanic":"stability_break", "cycle":["control","direct","direct","guard"],
		"preferred_types":["REZONANS","PHYSICAL"], "phase_thresholds":[0.55], "phase_names":["Kalibracja","Próba właściwa"],
		"status_every":3, "status":"unstable", "status_turns":2,
		"intro":"Eron bada stabilność drużyny i karze wejście bez przygotowania.",
		"phase_text":["Eron zwiększa nacisk na stabilność pola."]
	},
	"marea_resonance": {
		"name":"Przypływ Sory", "mechanic":"tide_cycle", "cycle":["setup","conditional","control","direct"],
		"preferred_types":["WAVE","ELECTRIC","ICE"], "phase_thresholds":[0.60], "phase_names":["Prąd przybrzeżny","Wysoki przypływ"],
		"status_every":2, "status":"soaked", "status_turns":2,
		"intro":"Sora zalewa pole, a potem próbuje zamienić MOKRY w reakcję przewodzenia albo chłodu.",
		"phase_text":["Fala rośnie — kolejne reakcje Sory stają się bardziej agresywne."]
	},
	"ferrum_construct": {
		"name":"Przeciążenie AX-7", "mechanic":"overclock", "cycle":["direct","prepared","direct","guard"],
		"preferred_types":["ELECTRIC","NAPIĘCIE","PHYSICAL"], "phase_thresholds":[0.50], "phase_names":["Tryb roboczy","OVERCLOCK"],
		"status_every":3, "status":"paralyzed", "status_turns":1,
		"intro":"AX-7 buduje tempo, a przy połowie HP przechodzi w przeciążenie kosztem własnej stabilności.",
		"phase_text":["OVERCLOCK: AX-7 zyskuje siłę, ale otwiera własne pole na kontrę."]
	},
	"nivra_guardian": {
		"name":"Biała Blokada", "mechanic":"freeze_lock", "cycle":["control","prepared","direct","guard"],
		"preferred_types":["ICE","STABIL","PHYSICAL"], "phase_thresholds":[0.58], "phase_names":["Mróz powierzchniowy","Biała cisza"],
		"status_every":2, "status":"chilled", "status_turns":2,
		"intro":"Hail najpierw wychładza, potem szuka okna na zamrożenie i rozkruszenie.",
		"phase_text":["BIAŁA CISZA: Hail skraca rytm między kontrolą a uderzeniem."]
	},
	"lumen_keeper": {
		"name":"Pamięć Sol", "mechanic":"prediction", "cycle":["control","direct","counter","direct"],
		"preferred_types":["CZUCIE","KIERUNEK","REZONANS"], "phase_thresholds":[0.62], "phase_names":["Odczyt","Rekonstrukcja"],
		"status_every":3, "status":"marked", "status_turns":3,
		"intro":"Sol oznacza aktywnego partnera i premiuje ruchy, które wykorzystują odczytaną słabość.",
		"phase_text":["REKONSTRUKCJA: Sol zaczyna częściej odpowiadać kontrą i skanem."]
	},
	"aster_warden": {
		"name":"Korony Elow", "mechanic":"spore_regen", "cycle":["setup","control","heal","direct"],
		"preferred_types":["WAVE","STABIL","REZONANS"], "phase_thresholds":[0.55], "phase_names":["Zarodniki","Gęsta korona"],
		"status_every":3, "status":"poisoned", "status_turns":2,
		"intro":"Elow przeciąga walkę: zatruwa pole, regeneruje się i zmusza do szybkiego przełamania.",
		"phase_text":["GĘSTA KORONA: regeneracja Elow przyspiesza, dopóki pole nie zostanie przełamane."]
	},
	"koral_tide": {
		"name":"Próba Prądu", "mechanic":"current_combo", "cycle":["setup","conditional","direct","control"],
		"preferred_types":["WAVE","ELECTRIC","ICE"], "phase_thresholds":[0.65,0.32], "phase_names":["Odpływ","Przypływ","Sztorm"],
		"status_every":2, "status":"soaked", "status_turns":2,
		"intro":"Veya cyklicznie zmienia prąd: najpierw przygotowuje MOKRY, później eskaluje reakcje.",
		"phase_text":["PRZYPŁYW: prąd przyspiesza.","SZTORM: Veya przechodzi na agresywne kombinacje." ]
	},
	"zenith_final": {
		"name":"Rdzeń Veyra", "mechanic":"three_phase_finale", "cycle":["control","direct","prepared","counter","direct"],
		"preferred_types":["REZONANS","TORSJA","CZUCIE","WAVE"], "phase_thresholds":[0.66,0.33], "phase_names":["Synchronizacja","Rozszczepienie","Rdzeń otwarty"],
		"status_every":2, "status":"vulnerable", "status_turns":1,
		"intro":"Veyr walczy w trzech fazach. Im bliżej rdzenia, tym większa presja, ale również większe okno na kontrę.",
		"phase_text":["ROZSZCZEPIENIE: rdzeń zmienia wzorzec i wzmacnia obrażenia.","RDZEŃ OTWARTY: Veyr jest najbardziej niebezpieczny, lecz jego osłona staje się niestabilna."]
	}
}

static func has(boss_id: String) -> bool:
	return _PROFILES.has(boss_id)

static func info(boss_id: String) -> Dictionary:
	if not has(boss_id):
		return {}
	return (_PROFILES[boss_id] as Dictionary).duplicate(true)

static func mechanic(boss_id: String) -> String:
	return str(info(boss_id).get("mechanic", ""))

static func phase_index(boss_id: String, hp: int, max_hp: int) -> int:
	var data: Dictionary = info(boss_id)
	if data.is_empty():
		return 0
	var ratio: float = float(maxi(0, hp)) / float(maxi(1, max_hp))
	var index: int = 0
	for raw_threshold: Variant in data.get("phase_thresholds", []) as Array:
		if ratio <= float(raw_threshold):
			index += 1
	return index

static func phase_name(boss_id: String, hp: int, max_hp: int) -> String:
	var data: Dictionary = info(boss_id)
	var names: Array = data.get("phase_names", []) as Array
	if names.is_empty():
		return ""
	var index: int = clampi(phase_index(boss_id, hp, max_hp), 0, names.size() - 1)
	return str(names[index])

static func cycle_pattern(boss_id: String, turn_index: int, hp: int, max_hp: int) -> String:
	var data: Dictionary = info(boss_id)
	var cycle: Array = data.get("cycle", []) as Array
	if cycle.is_empty():
		return "direct"
	var phase: int = phase_index(boss_id, hp, max_hp)
	var offset: int = phase * 2
	return str(cycle[posmod(turn_index + offset, cycle.size())])

static func preferred_types(boss_id: String) -> Array[String]:
	var result: Array[String] = []
	for raw_type: Variant in info(boss_id).get("preferred_types", []) as Array:
		result.append(str(raw_type))
	return result

static func periodic_status(boss_id: String, turn_index: int) -> Dictionary:
	var data: Dictionary = info(boss_id)
	var every: int = maxi(0, int(data.get("status_every", 0)))
	if every <= 0 or turn_index <= 0 or turn_index % every != 0:
		return {}
	return {"status":str(data.get("status", "")), "turns":maxi(1, int(data.get("status_turns", 1)))}

static func phase_text(boss_id: String, phase: int) -> String:
	if phase <= 0:
		return ""
	var texts: Array = info(boss_id).get("phase_text", []) as Array
	var index: int = phase - 1
	if index < 0 or index >= texts.size():
		return ""
	return str(texts[index])

static func validate() -> Array[String]:
	var errors: Array[String] = []
	var mechanics: Dictionary = {}
	for boss_id: String in BOSS_IDS:
		if not has(boss_id):
			errors.append("missing boss profile %s" % boss_id)
			continue
		var data: Dictionary = info(boss_id)
		var mechanic_id: String = str(data.get("mechanic", ""))
		if mechanic_id.is_empty():
			errors.append("boss %s has no mechanic" % boss_id)
		if mechanics.has(mechanic_id):
			errors.append("boss mechanic is not unique: %s" % mechanic_id)
		mechanics[mechanic_id] = true
		if (data.get("cycle", []) as Array).size() < 4:
			errors.append("boss %s AI cycle too short" % boss_id)
		if (data.get("phase_names", []) as Array).size() < 2:
			errors.append("boss %s requires at least two phases" % boss_id)
	return errors
