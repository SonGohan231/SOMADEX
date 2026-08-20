extends RefCounted

static var _POOLS: Dictionary = {
	"vela_outskirts": [
		{"name":"Wahlik","weight":34,"min_level":2,"max_level":4},
		{"name":"Milimik","weight":30,"min_level":2,"max_level":4},
		{"name":"Pufek","weight":24,"min_level":2,"max_level":4},
		{"name":"Kompasik","weight":12,"min_level":3,"max_level":4}
	],
	"resonance_route": [
		{"name":"Wahlik","weight":30,"min_level":3,"max_level":6},
		{"name":"Kompasik","weight":28,"min_level":3,"max_level":6},
		{"name":"Milimik","weight":22,"min_level":3,"max_level":5},
		{"name":"Uczek","weight":20,"min_level":4,"max_level":6}
	],
	"whispering_grove": [
		{"name":"Uczek","weight":34,"min_level":4,"max_level":7},
		{"name":"Milimik","weight":28,"min_level":4,"max_level":6},
		{"name":"Srubik","weight":22,"min_level":5,"max_level":7},
		{"name":"Wahlik","weight":16,"min_level":4,"max_level":6}
	],
	"tideglass_coast": [
		{"name":"Kompasik","weight":32,"min_level":4,"max_level":7},
		{"name":"Nasuch","weight":26,"min_level":5,"max_level":7},
		{"name":"Kotwiczek","weight":18,"min_level":5,"max_level":7},
		{"name":"Pufek","weight":24,"min_level":4,"max_level":6}
	],
	"echo_cave": [
		{"name":"Srubik","weight":32,"min_level":5,"max_level":8},
		{"name":"Kotwiczek","weight":26,"min_level":6,"max_level":8},
		{"name":"Nasuch","weight":24,"min_level":5,"max_level":8},
		{"name":"Wahlik","weight":18,"min_level":5,"max_level":7}
	]
}

static func pool(zone_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var raw: Variant = _POOLS.get(zone_id, [])
	if typeof(raw) != TYPE_ARRAY:
		return result
	for value: Variant in raw as Array:
		result.append((value as Dictionary).duplicate(true))
	return result

static func species(zone_id: String) -> Array[String]:
	var result: Array[String] = []
	for entry: Dictionary in pool(zone_id):
		var name: String = str(entry.get("name", ""))
		if not name.is_empty() and not result.has(name):
			result.append(name)
	return result

static func all_species() -> Array[String]:
	var result: Array[String] = []
	for raw_zone: Variant in _POOLS.keys():
		for name: String in species(str(raw_zone)):
			if not result.has(name):
				result.append(name)
	result.sort()
	return result

static func roll(zone_id: String, rng: RandomNumberGenerator) -> Dictionary:
	var entries: Array[Dictionary] = pool(zone_id)
	if entries.is_empty():
		return {"name":"Wahlik","level":2}
	var total: int = 0
	for entry: Dictionary in entries:
		total += maxi(0, int(entry.get("weight", 0)))
	if total <= 0:
		return {"name":str(entries[0].get("name", "Wahlik")),"level":int(entries[0].get("min_level", 2))}
	var roll_value: int = rng.randi_range(1, total)
	var cursor: int = 0
	for entry: Dictionary in entries:
		cursor += maxi(0, int(entry.get("weight", 0)))
		if roll_value <= cursor:
			var min_level: int = int(entry.get("min_level", 2))
			var max_level: int = maxi(min_level, int(entry.get("max_level", min_level)))
			return {"name":str(entry.get("name", "Wahlik")),"level":rng.randi_range(min_level, max_level)}
	return {"name":str(entries.back().get("name", "Wahlik")),"level":int(entries.back().get("min_level", 2))}
