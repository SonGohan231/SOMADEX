extends RefCounted

const MONSTERS = preload("res://scripts/data/monster_db.gd")
const EVOLUTION = preload("res://scripts/data/evolution_db.gd")
const MODES = preload("res://scripts/data/battle_mode_db.gd")

static var _SPECS: Array[Dictionary] = [
	{"id":"vela_trial","name":"Strażnik Eron","title":"Próba Veli","zone":"north_gate","tile":[7,12],"level":9,"count":3,"seed":2,"boss":true,"mode":"resonance","requires":[]},
	{"id":"orin_patrol_1","name":"Nari","title":"Patrol Orin","zone":"orin_gate","tile":[7,8],"level":9,"count":2,"seed":4},
	{"id":"orin_patrol_2","name":"Savel","title":"Patrol Orin","zone":"orin_gate","tile":[10,11],"level":10,"count":2,"seed":7},
	{"id":"orin_resonator_3","name":"Mira","title":"Rezonatorka Bramy","zone":"orin_gate","tile":[4,15],"level":10,"count":3,"seed":8,"requires":["defeated_vela_trial"]},
	{"id":"reed_scout_1","name":"Yra","title":"Tropicielka Mokradła","zone":"reed_marsh","tile":[6,11],"level":10,"count":2,"seed":10},
	{"id":"reed_scout_2","name":"Daro","title":"Badacz Stroików","zone":"reed_marsh","tile":[9,11],"level":11,"count":3,"seed":13},
	{"id":"reed_scout_3","name":"Hesh","title":"Zbieracz Osadów","zone":"reed_marsh","tile":[7,7],"level":11,"count":3,"seed":14,"requires":["defeated_vela_trial"]},
	{"id":"marea_duelist_1","name":"Pell","title":"Pojedynkowicz Portu","zone":"marea","tile":[7,8],"level":12,"count":3,"seed":16},
	{"id":"marea_duelist_2","name":"Liva","title":"Strażniczka Nabrzeża","zone":"marea","tile":[10,11],"level":13,"count":3,"seed":19},
	{"id":"marea_duelist_3","name":"Keli","title":"Rezonator Przypływu","zone":"marea","tile":[4,15],"level":13,"count":4,"seed":20,"requires":["defeated_vela_trial"]},
	{"id":"marea_resonance","name":"Mistrzyni Sora","title":"Rezonans Marei","zone":"marea","tile":[7,5],"level":14,"count":4,"seed":22,"boss":true,"mode":"resonance","requires":["defeated_vela_trial"]},

	{"id":"ferrum_line_1","name":"Teren","title":"Mechanik Szlaku","zone":"ferrum_line","tile":[5,11],"level":14,"count":3,"seed":25},
	{"id":"ferrum_line_2","name":"Nox","title":"Operator Cewki","zone":"ferrum_line","tile":[9,11],"level":15,"count":3,"seed":28},
	{"id":"ferrum_line_3","name":"Jax","title":"Inspektor Przekaźników","zone":"ferrum_line","tile":[7,7],"level":15,"count":4,"seed":29,"requires":["defeated_marea_resonance"]},
	{"id":"ferrum_worker_1","name":"Eris","title":"Techniczka Ferrum","zone":"ferrum","tile":[7,8],"level":16,"count":3,"seed":31},
	{"id":"ferrum_worker_2","name":"Bram","title":"Konstruktor Ferrum","zone":"ferrum","tile":[10,11],"level":17,"count":3,"seed":34},
	{"id":"ferrum_worker_3","name":"Olin","title":"Stroiciel Maszyn","zone":"ferrum","tile":[4,15],"level":17,"count":4,"seed":35,"requires":["defeated_marea_resonance"]},
	{"id":"coil_guard_1","name":"Volt","title":"Strażnik Elektrowni","zone":"coil_plant","tile":[7,15],"level":17,"count":3,"seed":37},
	{"id":"coil_guard_2","name":"Mirax","title":"Operator Pola","zone":"coil_plant","tile":[7,9],"level":18,"count":4,"seed":40},
	{"id":"coil_guard_3","name":"Sorn","title":"Kontroler Przeciążenia","zone":"coil_plant","tile":[5,11],"level":18,"count":4,"seed":41,"requires":["defeated_marea_resonance"]},
	{"id":"ferrum_construct","name":"Konstruktor AX-7","title":"Konstrukt Ferrum","zone":"coil_plant","tile":[7,5],"level":19,"count":4,"seed":43,"boss":true,"mode":"resonance","requires":["defeated_marea_resonance"]},

	{"id":"nivra_pass_1","name":"Iven","title":"Wędrowiec Przełęczy","zone":"nivra_pass","tile":[5,11],"level":20,"count":3,"seed":46},
	{"id":"nivra_pass_2","name":"Sena","title":"Strażniczka Grani","zone":"nivra_pass","tile":[9,11],"level":21,"count":3,"seed":49},
	{"id":"nivra_pass_3","name":"Varr","title":"Łowca Zamieci","zone":"nivra_pass","tile":[7,7],"level":21,"count":4,"seed":50,"requires":["defeated_ferrum_construct"]},
	{"id":"nivra_climber_1","name":"Rud","title":"Alpinista Nivra","zone":"nivra","tile":[7,8],"level":22,"count":4,"seed":52},
	{"id":"nivra_climber_2","name":"Isha","title":"Przewodniczka Lodowa","zone":"nivra","tile":[4,15],"level":23,"count":4,"seed":53,"requires":["defeated_ferrum_construct"]},
	{"id":"deep_fault_1","name":"Kess","title":"Badacz Uskoku","zone":"deep_fault","tile":[7,15],"level":23,"count":4,"seed":55},
	{"id":"deep_fault_2","name":"Ona","title":"Kartografka Głębi","zone":"deep_fault","tile":[7,10],"level":24,"count":4,"seed":58},
	{"id":"deep_fault_3","name":"Rask","title":"Słuchacz Szczeliny","zone":"deep_fault","tile":[5,11],"level":24,"count":5,"seed":59,"requires":["defeated_ferrum_construct"]},
	{"id":"nivra_guardian","name":"Warden Hail","title":"Strażnik Nivry","zone":"deep_fault","tile":[7,5],"level":25,"count":5,"seed":61,"boss":true,"mode":"resonance","requires":["defeated_ferrum_construct"]},

	{"id":"lumen_ruins_1","name":"Arel","title":"Poszukiwacz Lumen","zone":"lumen_ruins","tile":[5,11],"level":25,"count":4,"seed":64},
	{"id":"lumen_ruins_2","name":"Noe","title":"Czytający Ruiny","zone":"lumen_ruins","tile":[9,11],"level":26,"count":4,"seed":67},
	{"id":"lumen_ruins_3","name":"Ena","title":"Dekoderka Znaków","zone":"lumen_ruins","tile":[7,7],"level":26,"count":5,"seed":68,"requires":["defeated_nivra_guardian"]},
	{"id":"lumen_archivist_1","name":"Talia","title":"Archiwistka","zone":"lumen","tile":[7,8],"level":27,"count":4,"seed":70},
	{"id":"lumen_archivist_2","name":"Pax","title":"Strażnik Archiwum","zone":"lumen","tile":[10,11],"level":28,"count":4,"seed":73},
	{"id":"lumen_archivist_3","name":"Veli","title":"Korektorka Sekwencji","zone":"lumen","tile":[4,15],"level":28,"count":5,"seed":74,"requires":["defeated_nivra_guardian"]},
	{"id":"lumen_keeper","name":"Opiekun Sol","title":"Strażnik Pamięci","zone":"lumen","tile":[7,5],"level":29,"count":5,"seed":76,"boss":true,"mode":"resonance","requires":["defeated_nivra_guardian"]},

	{"id":"aster_woods_1","name":"Fenn","title":"Leśny Tropiciel","zone":"aster_woods","tile":[5,11],"level":29,"count":4,"seed":79},
	{"id":"aster_woods_2","name":"Roa","title":"Opiekunka Zarodników","zone":"aster_woods","tile":[9,11],"level":30,"count":4,"seed":82},
	{"id":"aster_woods_3","name":"Moss","title":"Zbieracz Korzeni","zone":"aster_woods","tile":[7,7],"level":30,"count":5,"seed":83,"requires":["defeated_lumen_keeper"]},
	{"id":"aster_guard_1","name":"Mori","title":"Straż Aster","zone":"aster","tile":[7,8],"level":31,"count":4,"seed":85},
	{"id":"aster_guard_2","name":"Tessan","title":"Wędrowiec Koron","zone":"aster","tile":[10,11],"level":32,"count":5,"seed":88},
	{"id":"aster_guard_3","name":"Lorn","title":"Strażnik Korzeni","zone":"aster","tile":[4,15],"level":32,"count":5,"seed":89,"requires":["defeated_lumen_keeper"]},
	{"id":"aster_warden","name":"Warden Elow","title":"Strażnik Koron","zone":"aster","tile":[7,5],"level":33,"count":5,"seed":91,"boss":true,"mode":"resonance","requires":["defeated_lumen_keeper"]},

	{"id":"basin_listener_1","name":"Siel","title":"Słuchacz Niecki","zone":"silent_basin","tile":[7,7],"level":33,"count":4,"seed":94},
	{"id":"basin_listener_2","name":"Umi","title":"Badacz Ciszy","zone":"silent_basin","tile":[10,11],"level":34,"count":5,"seed":97},
	{"id":"basin_listener_3","name":"Nemm","title":"Strażnik Bezruchu","zone":"silent_basin","tile":[5,11],"level":34,"count":5,"seed":98,"requires":["defeated_aster_warden"]},
	{"id":"koral_diver_1","name":"Caro","title":"Nurek Koral","zone":"koral","tile":[7,8],"level":35,"count":5,"seed":100},
	{"id":"koral_diver_2","name":"Mirae","title":"Łowczyni Prądów","zone":"koral","tile":[4,15],"level":36,"count":5,"seed":101,"requires":["defeated_aster_warden"]},
	{"id":"koral_shelf_1","name":"Marn","title":"Strażnik Rafy","zone":"koral_shelf","tile":[5,11],"level":36,"count":5,"seed":103},
	{"id":"koral_shelf_2","name":"Lune","title":"Badaczka Płycizn","zone":"koral_shelf","tile":[9,11],"level":37,"count":5,"seed":106},
	{"id":"koral_shelf_3","name":"Perr","title":"Kartograf Prądu","zone":"koral_shelf","tile":[7,7],"level":37,"count":6,"seed":107,"requires":["defeated_aster_warden"]},
	{"id":"koral_tide","name":"Kapitan Veya","title":"Próba Przypływu","zone":"koral_shelf","tile":[12,11],"level":38,"count":6,"seed":109,"boss":true,"mode":"resonance","requires":["defeated_aster_warden"]},

	{"id":"zenith_approach_1","name":"Rhen","title":"Strażnik Podejścia","zone":"zenith_approach","tile":[7,17],"level":40,"count":5,"seed":112},
	{"id":"zenith_approach_2","name":"Aeon","title":"Rezonator Zenith","zone":"zenith_approach","tile":[7,12],"level":41,"count":6,"seed":115},
	{"id":"zenith_approach_3","name":"Kira","title":"Ostatnia Straż","zone":"zenith_approach","tile":[7,7],"level":42,"count":6,"seed":118},
	{"id":"zenith_approach_4","name":"Sey","title":"Mierniczy Rdzenia","zone":"zenith_approach","tile":[5,11],"level":42,"count":6,"seed":119,"requires":["defeated_koral_tide"]},
	{"id":"zenith_core_duelist","name":"Ora","title":"Techniczna Straż Rdzenia","zone":"zenith","tile":[4,15],"level":44,"count":6,"seed":120,"mode":"trainer_duel","requires":["defeated_koral_tide"]},
	{"id":"zenith_final","name":"Arcyrezonator Veyr","title":"Finał Zenith","zone":"zenith","tile":[7,6],"level":45,"count":6,"seed":121,"boss":true,"mode":"trainer_duel","requires":["defeated_koral_tide"]}
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

static func specs() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for spec: Dictionary in _SPECS:
		result.append(spec.duplicate(true))
	return result

static func party(trainer_id: String) -> Array:
	var spec: Dictionary = info(trainer_id)
	var result: Array = []
	if spec.is_empty():
		return result
	var level: int = maxi(1, int(spec.get("level", 5)))
	var count: int = clampi(int(spec.get("count", 2)), 1, 6)
	var seed: int = int(spec.get("seed", 1))
	var pool: Array[String] = _pool_for_level(level)
	if pool.is_empty():
		pool = MONSTERS.all_names()
	for index: int in range(count):
		var name: String = pool[posmod(seed + index * 7, pool.size())]
		result.append({"name":name,"level":maxi(1, level + int(index / 2))})
	return result

static func _pool_for_level(level: int) -> Array[String]:
	var result: Array[String] = []
	var max_stage: int = 1
	if level >= 12:
		max_stage = 2
	if level >= 24:
		max_stage = 3
	for name: String in MONSTERS.all_names():
		var stage: int = maxi(1, EVOLUTION.stage(name))
		if stage <= max_stage:
			result.append(name)
	return result

static func can_challenge(trainer_id: String, flags: Dictionary) -> bool:
	var spec: Dictionary = info(trainer_id)
	if spec.is_empty():
		return false
	var requirements: Array = spec.get("requires", []) as Array
	for raw_flag: Variant in requirements:
		if not bool(flags.get(str(raw_flag), false)):
			return false
	return true

static func defeated_flag(trainer_id: String) -> String:
	return "defeated_%s" % trainer_id

static func is_defeated(trainer_id: String, flags: Dictionary) -> bool:
	return bool(flags.get(defeated_flag(trainer_id), false))

static func reward_xp(trainer_id: String) -> int:
	var spec: Dictionary = info(trainer_id)
	var level: int = maxi(1, int(spec.get("level", 5)))
	return level * (6 if bool(spec.get("boss", false)) else 3)

static func reward_items(trainer_id: String) -> Dictionary:
	var spec: Dictionary = info(trainer_id)
	if bool(spec.get("boss", false)):
		return {"resonance_cells":2,"regenerators":2,"capture_modules":2}
	return {"regenerators":1}

static func locked_text(trainer_id: String) -> String:
	var spec: Dictionary = info(trainer_id)
	if bool(spec.get("boss", false)):
		return "Pole nie odpowiada. Najpierw dokończ poprzednią główną próbę regionu."
	return "Najpierw uporządkuj wcześniejsze wydarzenia na tej trasie."

static func battle_mode(trainer_id: String) -> String:
	var spec: Dictionary = info(trainer_id)
	return str(spec.get("mode", MODES.MODE_STANDARD))

static func boss_ids() -> Array[String]:
	var result: Array[String] = []
	for spec: Dictionary in _SPECS:
		if bool(spec.get("boss", false)):
			result.append(str(spec.get("id", "")))
	return result

static func trainer_count() -> int:
	return _SPECS.size()
