extends RefCounted

static var _ZONES: Dictionary = {
	"vela": {
		"name": "Vela",
		"biome": "miasteczko / kanały",
		"recommended_level": 2,
		"spawn": [7, 20],
		"map_rows": [
			"TTTTTTTETTTTTTT","TGGGGGGCGGGGGGT","TGGHHGPPPGHHGGT","TGGHHGPPPGHHGGT","TGGGGGPPPGGGGGT","EGGGNGPPPGGGGGT","TGGGGGPPPGGGGGT","TGGSSGPPPGGGGGT","TGGGGGPPPGGGGGT","TGGGGGPPPGGGGGT","TWWWWGPPPGGGGGT","TWWWWGPPPGGGGGT","TWWWWBPPPGGGGGT","TGGGGGPPPGGGGGT","TGGGPPPPPPPGGGT","TGGGPGGGGPGGGGT","TGGGPGGGGPGGGGT","TGGGPPPPPPPGGGT","TGGGGGPPPSGGGGT","TGGGGGPPPGGGGGT","TGGGGGPPPGGGGGT","TGGGGGPPPGGGGGT","TTTTTTTTTTTTTTT"
		],
		"exits": {"7,0":{"zone_id":"resonance_route","spawn":[7,21]},"0,5":{"zone_id":"vela_outskirts","spawn":[13,11]}},
		"encounters": []
	},
	"vela_outskirts": {
		"name":"Obrzeża Veli","biome":"łąki / gospodarstwa","recommended_level":2,"spawn":[13,11],
		"map_rows":[
			"TTTTTTTTTTTTTTT","TGGGGGGGGGGGGGT","TGGFFFGGGFFFGGT","TGGGGGPPPGGGGGT","TGGGGGPPPGGGGGT","TGGGGGPPPGGGGGT","TGGGGGPPPGGGGGT","TGGGPPPPPPPGGGT","TGGGPGGGGPGGGGT","TGGGPGGOGPGGGGT","TGGGPGGGGPGGGGT","TGGGPPPPPPPGGGE","TGGGGGGGGPGGGGT","TGGFFFGGGPGGGGT","TGGGGGGGGPGGGGT","TGGGGPPPPPGGGGT","TGGGGPGGGGGGGGT","TGGGGPGGFFGGGGT","TGGGGPGGGGGGGGT","TGGGGPPPPPGGGGT","TGGGGGGGGGGGGGT","TGGGGGGGGGGGGGT","TTTTTTTTTTTTTTT"
		],
		"exits":{"14,11":{"zone_id":"vela","spawn":[1,5]}},
		"encounters":[{"name":"Wahlik","weight":100,"min_level":2,"max_level":4}]
	},
	"resonance_route": {
		"name":"Szlak Rezonansu","biome":"łąki / zagajniki","recommended_level":4,"spawn":[7,21],
		"map_rows":[
			"TTTTTTTETTTTTTT","TGGGGGGPGGGGGGT","TGGFFGGPGGFFGGT","TGGGGGGPGGGGGGT","TGGGGPPPPPGGGGT","TGGGGPGGGPGGGGT","TGGFGPGGGPGFGGT","TGGGGPGGGPGGGGT","TGGGGPPPPPGGGGT","TGGGGGGPGGGGGGT","EGGGGGGPGGGGGGE","TGGGGGGPGGGGGGT","TGGGGGGPGGGGGGT","TGGGPPPPPPPGGGT","TGGGPGGGGPGGGGT","TGGGPGGOGPGGGGT","TGGGPPPPPPPGGGT","TGGGGGGPGGGGGGT","TGGFFGGPGGFFGGT","TGGGGGGPGGGGGGT","TGGGGGGPGGGGGGT","TGGGGGGPGGGGGGT","TTTTTTTETTTTTTT"
		],
		"exits":{"7,22":{"zone_id":"vela","spawn":[7,1]},"7,0":{"zone_id":"whispering_grove","spawn":[7,21]},"0,10":{"zone_id":"echo_cave","spawn":[13,10]},"14,10":{"zone_id":"tideglass_coast","spawn":[1,10]}},
		"encounters":[{"name":"Wahlik","weight":100,"min_level":3,"max_level":6}]
	},
	"whispering_grove": {
		"name":"Gaj Szeptów","biome":"gęsty las / stare ścieżki","recommended_level":5,"spawn":[7,21],
		"map_rows":[
			"TTTTTTTETTTTTTT","TFFFFFGPGFFFFFT","TFTTTFGPGFTTTFT","TFFFGGPPPGGFFFT","TFTFGPGGGPGFTFT","TFFFGPGFGPGFFFT","TFTFGPGGGPGFTFT","TFFFGPPPPPGFFFT","TFTFFFFPFFFFTFT","TFFFFFGPGFFFFFT","TFTTTFGPGFTTTFT","TFFFFPPPPFFFFFT","TFTFFPGGGGFFTFT","TFFFFPGFGPFFFFT","TFTFFPPPPPFFTFT","TFFFFFGPGFFFFFT","TFTTTFGPGFTTTFT","TFFFFPPPPFFFFFT","TFFFFFGPGFFFFFT","TFTFFFGPGFFFTFT","TFFFFFGPGFFFFFT","TFFFFFGPGFFFFFT","TTTTTTTETTTTTTT"
		],
		"exits":{"7,22":{"zone_id":"resonance_route","spawn":[7,1]},"7,0":{"zone_id":"north_gate","spawn":[7,21]}},
		"encounters":[{"name":"Wahlik","weight":100,"min_level":4,"max_level":7}]
	},
	"tideglass_coast": {
		"name":"Szkliste Wybrzeże","biome":"piasek / płytkie morze","recommended_level":5,"spawn":[1,10],
		"map_rows":[
			"TTTTTTTTTTTTTTT","TGGGGGGGAAAAAAT","TGGFFGGGAAAAAAT","TGGGGGGGAAWWWAT","TGGGGPPPAWWWWAT","TGGGGPGGAWWWWAT","TGGGGPGGAAWWWAT","TGGGGPPPAABBBAT","TGGGGGGGAAWWWAT","TGGGGGGGAAWWWAT","EGGGPPPPAAWWWAT","TGGGPGGGAAWWWAT","TGGGPGGGAAWWWAT","TGGGPPPPAAWWWAT","TGGGGGGGAAWWWAT","TGGFFGGGAAWWWAT","TGGGGGGGAAWWWAT","TGGGGPPPAABBBAT","TGGGGPGGAAWWWAT","TGGGGPGGAAWWWAT","TGGGGPPPAAWWWAT","TGGGGGGGAAAAAAT","TTTTTTTTTTTTTTT"
		],
		"exits":{"0,10":{"zone_id":"resonance_route","spawn":[13,10]}},
		"encounters":[{"name":"Wahlik","weight":100,"min_level":4,"max_level":7}]
	},
	"echo_cave": {
		"name":"Jaskinia Echa","biome":"jaskinia / rezonujące kryształy","recommended_level":6,"spawn":[13,10],
		"map_rows":[
			"KKKKKKKKKKKKKKK","KVVVVVVVVVVVVVK","KVVOOOOVVOOOOVK","KVVVVVVVVVVVVVK","KVVVPPPPPVVVVVK","KVVVPGGGPGVVVVK","KVOVPGOGPGVVOVK","KVVVPGGGPGVVVVK","KVVVPPPPPVVVVVK","KVVVVVVPGVVVVVK","KVVVVVVPGVVVVVE","KVVVVVVPGVVVVVK","KVVOOVVPGVVOOVK","KVVVPPPPPVVVVVK","KVVVPGGGPGVVVVK","KVOVPGOGPGVVOVK","KVVVPPPPPVVVVVK","KVVVVVVPGVVVVVK","KVVOOVVPGVVOOVK","KVVVVVVPGVVVVVK","KVVVVVVPGVVVVVK","KVVVVVVVVVVVVVK","KKKKKKKKKKKKKKK"
		],
		"exits":{"14,10":{"zone_id":"resonance_route","spawn":[1,10]}},
		"encounters":[{"name":"Wahlik","weight":100,"min_level":5,"max_level":8}]
	},
	"north_gate": {
		"name":"Północna Brama","biome":"fort / arena próby","recommended_level":7,"spawn":[7,21],
		"map_rows":[
			"TTTTTTTTTTTTTTT","TGGGGGGPGGGGGGT","TGGKKGGPGGKKGGT","TGGKKGPPPGKKGGT","TGGGGGPDPGGGGGT","TGGGGGPDPGGGGGT","TGGGGGPDPGGGGGT","TGGGGGPPPGGGGGT","TGGGGGGPGGGGGGT","TGGGGGGPGGGGGGT","TGGGPPPPPPPGGGT","TGGGPGGGGPGGGGT","TGGGPGGNGPGGGGT","TGGGPGGGGPGGGGT","TGGGPPPPPPPGGGT","TGGGGGGPGGGGGGT","TGGGGGGPGGGGGGT","TGGGGGGPGGGGGGT","TGGGGGGPGGGGGGT","TGGGGGGPGGGGGGT","TGGGGGGPGGGGGGT","TGGGGGGPGGGGGGT","TTTTTTTETTTTTTT"
		],
		"exits":{"7,22":{"zone_id":"whispering_grove","spawn":[7,1]}},
		"encounters":[]
	}
}

static func ids() -> Array[String]:
	var result: Array[String] = []
	for key: Variant in _ZONES.keys():
		result.append(str(key))
	result.sort()
	return result

static func has_zone(zone_id: String) -> bool:
	return _ZONES.has(zone_id)

static func zone_info(zone_id: String) -> Dictionary:
	if not _ZONES.has(zone_id):
		return (_ZONES["vela"] as Dictionary).duplicate(true)
	return (_ZONES[zone_id] as Dictionary).duplicate(true)

static func zone_name(zone_id: String) -> String:
	return str(zone_info(zone_id).get("name", "Vela"))

static func biome(zone_id: String) -> String:
	return str(zone_info(zone_id).get("biome", ""))

static func map_rows(zone_id: String) -> Array[String]:
	var result: Array[String] = []
	var raw_rows: Variant = zone_info(zone_id).get("map_rows", [])
	if typeof(raw_rows) != TYPE_ARRAY:
		return result
	for value: Variant in raw_rows as Array:
		result.append(str(value))
	return result

static func spawn_tile(zone_id: String) -> Vector2i:
	var raw_spawn: Variant = zone_info(zone_id).get("spawn", [7, 20])
	if typeof(raw_spawn) == TYPE_ARRAY:
		var arr: Array = raw_spawn as Array
		if arr.size() >= 2:
			return Vector2i(int(arr[0]), int(arr[1]))
	return Vector2i(7, 20)

static func exit_at(zone_id: String, tile: Vector2i) -> Dictionary:
	var raw_exits: Variant = zone_info(zone_id).get("exits", {})
	if typeof(raw_exits) != TYPE_DICTIONARY:
		return {}
	var exits: Dictionary = raw_exits as Dictionary
	var key: String = "%d,%d" % [tile.x, tile.y]
	if not exits.has(key):
		return {}
	return (exits[key] as Dictionary).duplicate(true)

static func exit_spawn(exit_data: Dictionary) -> Vector2i:
	var raw_spawn: Variant = exit_data.get("spawn", [7, 20])
	if typeof(raw_spawn) == TYPE_ARRAY:
		var arr: Array = raw_spawn as Array
		if arr.size() >= 2:
			return Vector2i(int(arr[0]), int(arr[1]))
	return Vector2i(7, 20)

static func roll_encounter(zone_id: String, rng: RandomNumberGenerator) -> Dictionary:
	var info: Dictionary = zone_info(zone_id)
	var encounters: Array = info.get("encounters", []) as Array
	if encounters.is_empty():
		return {"name":"Wahlik","level":maxi(2, int(info.get("recommended_level", 2)))}
	var total_weight: int = 0
	for entry_value: Variant in encounters:
		var entry: Dictionary = entry_value as Dictionary
		total_weight += maxi(0, int(entry.get("weight", 0)))
	if total_weight <= 0:
		var fallback: Dictionary = encounters[0] as Dictionary
		return {"name":str(fallback.get("name","Wahlik")),"level":int(fallback.get("min_level",2))}
	var roll: int = rng.randi_range(1, total_weight)
	var cursor: int = 0
	for entry_value: Variant in encounters:
		var entry: Dictionary = entry_value as Dictionary
		cursor += maxi(0, int(entry.get("weight", 0)))
		if roll <= cursor:
			var min_level: int = int(entry.get("min_level", 2))
			var max_level: int = maxi(min_level, int(entry.get("max_level", min_level)))
			return {"name":str(entry.get("name","Wahlik")),"level":rng.randi_range(min_level, max_level)}
	var last_entry: Dictionary = encounters[encounters.size() - 1] as Dictionary
	return {"name":str(last_entry.get("name","Wahlik")),"level":int(last_entry.get("min_level",2))}