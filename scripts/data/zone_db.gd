extends RefCounted

static var _ZONES: Dictionary = {
	"vela": {
		"name": "Vela i Obrzeża",
		"biome": "łąki / miasteczko",
		"recommended_level": 2,
		"encounters": [
			{"name": "Wahlik", "weight": 100, "min_level": 2, "max_level": 4}
		]
	},
	"resonance_route": {
		"name": "Szlak Rezonansu",
		"biome": "łąki / zagajniki",
		"recommended_level": 4,
		"encounters": [
			{"name": "Wahlik", "weight": 100, "min_level": 3, "max_level": 6}
		]
	}
}

static func has_zone(zone_id: String) -> bool:
	return _ZONES.has(zone_id)

static func zone_info(zone_id: String) -> Dictionary:
	if not _ZONES.has(zone_id):
		return (_ZONES["vela"] as Dictionary).duplicate(true)
	return (_ZONES[zone_id] as Dictionary).duplicate(true)

static func zone_name(zone_id: String) -> String:
	return str(zone_info(zone_id).get("name", "Vela"))

static func roll_encounter(zone_id: String, rng: RandomNumberGenerator) -> Dictionary:
	var info: Dictionary = zone_info(zone_id)
	var encounters: Array = info.get("encounters", []) as Array
	if encounters.is_empty():
		return {"name": "Wahlik", "level": 2}
	var total_weight: int = 0
	for entry_value: Variant in encounters:
		var entry: Dictionary = entry_value as Dictionary
		total_weight += maxi(0, int(entry.get("weight", 0)))
	if total_weight <= 0:
		var fallback: Dictionary = encounters[0] as Dictionary
		return {
			"name": str(fallback.get("name", "Wahlik")),
			"level": int(fallback.get("min_level", 2))
		}
	var roll: int = rng.randi_range(1, total_weight)
	var cursor: int = 0
	for entry_value: Variant in encounters:
		var entry: Dictionary = entry_value as Dictionary
		cursor += maxi(0, int(entry.get("weight", 0)))
		if roll <= cursor:
			var min_level: int = int(entry.get("min_level", 2))
			var max_level: int = maxi(min_level, int(entry.get("max_level", min_level)))
			return {
				"name": str(entry.get("name", "Wahlik")),
				"level": rng.randi_range(min_level, max_level)
			}
	var last_entry: Dictionary = encounters[encounters.size() - 1] as Dictionary
	return {
		"name": str(last_entry.get("name", "Wahlik")),
		"level": int(last_entry.get("min_level", 2))
	}
