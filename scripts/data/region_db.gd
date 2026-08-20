extends RefCounted

const REGION_VELA: String = "vela_region"

static var _REGIONS: Dictionary = {
	REGION_VELA: {
		"name":"VELA",
		"order":1,
		"description":"Pierwszy pełny region SOMADEX: wybrzeże, lasy, góry, jaskinie, ruiny, technologia i obszary rezonansu.",
		"towns":[
			{"id":"vela","name":"Vela","kind":"town","biome":"coast","implemented":true},
			{"id":"marea","name":"Marea","kind":"town","biome":"coast","implemented":false},
			{"id":"orin_gate","name":"Brama Orin","kind":"town","biome":"plains","implemented":false},
			{"id":"ferrum","name":"Ferrum","kind":"town","biome":"technology","implemented":false},
			{"id":"nivra","name":"Nivra","kind":"town","biome":"mountain","implemented":false},
			{"id":"lumen","name":"Lumen","kind":"town","biome":"ruins","implemented":false},
			{"id":"aster","name":"Aster","kind":"town","biome":"forest","implemented":false},
			{"id":"koral","name":"Koral","kind":"town","biome":"coast","implemented":false},
			{"id":"zenith","name":"Zenith","kind":"town","biome":"finale","implemented":false}
		],
		"field_areas":[
			{"id":"vela_outskirts","name":"Obrzeża Veli","kind":"route","biome":"meadow","implemented":true},
			{"id":"resonance_route","name":"Szlak Rezonansu","kind":"route","biome":"plains","implemented":true},
			{"id":"whispering_grove","name":"Gaj Szeptów","kind":"forest","biome":"forest","implemented":true},
			{"id":"tideglass_coast","name":"Szkliste Wybrzeże","kind":"coast","biome":"water","implemented":true},
			{"id":"echo_cave","name":"Jaskinia Echa","kind":"cave","biome":"cave","implemented":true},
			{"id":"north_gate","name":"Północna Brama","kind":"route","biome":"plains","implemented":true},
			{"id":"reed_marsh","name":"Mokradła Stroików","kind":"wetland","biome":"water","implemented":false},
			{"id":"ferrum_line","name":"Linia Ferrum","kind":"route","biome":"technology","implemented":false},
			{"id":"coil_plant","name":"Elektrownia Cewkowa","kind":"facility","biome":"technology","implemented":false},
			{"id":"nivra_pass","name":"Przełęcz Nivra","kind":"mountain","biome":"mountain","implemented":false},
			{"id":"deep_fault","name":"Głęboki Uskok","kind":"cave","biome":"cave","implemented":false},
			{"id":"lumen_ruins","name":"Ruiny Lumen","kind":"ruins","biome":"ruins","implemented":false},
			{"id":"aster_woods","name":"Las Aster","kind":"forest","biome":"forest","implemented":false},
			{"id":"koral_shelf","name":"Rafa Koral","kind":"coast","biome":"water","implemented":false},
			{"id":"silent_basin","name":"Cicha Niecka","kind":"special","biome":"mystic","implemented":false},
			{"id":"zenith_approach","name":"Podejście Zenith","kind":"route","biome":"finale","implemented":false}
		],
		"boss_slots":["vela_trial","marea_resonance","ferrum_construct","nivra_guardian","lumen_keeper","aster_warden","koral_tide","zenith_final"],
		"post_game":[
			{"id":"echo_depths","name":"Głębie Echa"},
			{"id":"resonance_lab","name":"Laboratorium Rezonansu"},
			{"id":"outer_shelf","name":"Zewnętrzna Rafa"}
		]
	}
}

static func ids() -> Array[String]:
	var result: Array[String] = []
	for key: Variant in _REGIONS.keys():
		result.append(str(key))
	result.sort()
	return result

static func info(region_id: String) -> Dictionary:
	if not _REGIONS.has(region_id):
		return {}
	return (_REGIONS[region_id] as Dictionary).duplicate(true)

static func towns(region_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for raw: Variant in info(region_id).get("towns", []) as Array:
		result.append((raw as Dictionary).duplicate(true))
	return result

static func field_areas(region_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for raw: Variant in info(region_id).get("field_areas", []) as Array:
		result.append((raw as Dictionary).duplicate(true))
	return result

static func boss_slots(region_id: String) -> Array[String]:
	var result: Array[String] = []
	for raw: Variant in info(region_id).get("boss_slots", []) as Array:
		result.append(str(raw))
	return result

static func location_ids(region_id: String) -> Array[String]:
	var result: Array[String] = []
	for data: Dictionary in towns(region_id):
		result.append(str(data.get("id", "")))
	for data: Dictionary in field_areas(region_id):
		result.append(str(data.get("id", "")))
	return result

static func implemented_locations(region_id: String) -> Array[String]:
	var result: Array[String] = []
	for data: Dictionary in towns(region_id):
		if bool(data.get("implemented", false)):
			result.append(str(data.get("id", "")))
	for data: Dictionary in field_areas(region_id):
		if bool(data.get("implemented", false)):
			result.append(str(data.get("id", "")))
	return result

static func planned_location_count(region_id: String) -> int:
	return towns(region_id).size() + field_areas(region_id).size()
