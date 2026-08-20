extends RefCounted

const PROGRESSION = preload("res://scripts/data/progression_db.gd")

const SAVE_VERSION: int = 8
const START_TILE: Vector2i = Vector2i(7, 20)

static func new_profile(starter_name: String = "") -> Dictionary:
	var party: Array[String] = []
	var seen: Array[String] = []
	var caught: Array[String] = []
	if not starter_name.is_empty():
		party.append(starter_name)
		seen.append(starter_name)
		caught.append(starter_name)
	return {
		"version": SAVE_VERSION,
		"starter": starter_name,
		"player_x": START_TILE.x,
		"player_y": START_TILE.y,
		"player_hp": 0,
		"trainer_level": 1,
		"trainer_xp": 0,
		"talent_points": 1,
		"talents": PROGRESSION.default_talents(),
		"party": party,
		"seen": seen,
		"caught": caught,
		"inventory": {
			"capture_modules": 5,
			"regenerators": 3,
			"sondas": 1
		},
		"quest_stage": 0,
		"zone_id": "vela",
		"flags": {},
		"haptics": true
	}

static func migrate(raw: Dictionary) -> Dictionary:
	var starter_name: String = str(raw.get("starter", ""))
	var profile: Dictionary = new_profile(starter_name)
	profile["player_x"] = int(raw.get("player_x", START_TILE.x))
	profile["player_y"] = int(raw.get("player_y", START_TILE.y))
	profile["player_hp"] = maxi(0, int(raw.get("player_hp", 0)))
	profile["trainer_level"] = maxi(1, int(raw.get("trainer_level", 1)))
	profile["trainer_xp"] = maxi(0, int(raw.get("trainer_xp", 0)))
	profile["haptics"] = bool(raw.get("haptics", true))
	profile["zone_id"] = str(raw.get("zone_id", "vela"))
	profile["quest_stage"] = maxi(0, int(raw.get("quest_stage", 0)))
	profile["talent_points"] = maxi(0, int(raw.get("talent_points", 1)))

	var raw_talents: Variant = raw.get("talents", {})
	if typeof(raw_talents) == TYPE_DICTIONARY:
		var talents: Dictionary = PROGRESSION.default_talents()
		var incoming: Dictionary = raw_talents as Dictionary
		for path_id: String in PROGRESSION.path_ids():
			talents[path_id] = clampi(int(incoming.get(path_id, 0)), 0, 5)
		profile["talents"] = talents

	var raw_inventory: Variant = raw.get("inventory", {})
	if typeof(raw_inventory) == TYPE_DICTIONARY:
		var incoming_inventory: Dictionary = raw_inventory as Dictionary
		profile["inventory"] = {
			"capture_modules": maxi(0, int(incoming_inventory.get("capture_modules", 5))),
			"regenerators": maxi(0, int(incoming_inventory.get("regenerators", 3))),
			"sondas": maxi(0, int(incoming_inventory.get("sondas", 1)))
		}

	profile["party"] = _string_array(raw.get("party", profile["party"]))
	profile["seen"] = _string_array(raw.get("seen", profile["seen"]))
	profile["caught"] = _string_array(raw.get("caught", profile["caught"]))

	var raw_flags: Variant = raw.get("flags", {})
	if typeof(raw_flags) == TYPE_DICTIONARY:
		profile["flags"] = (raw_flags as Dictionary).duplicate(true)

	# Migration path for v0.2 saves that only stored a numeric discovered count.
	var old_version: int = int(raw.get("version", 2))
	if old_version <= 2 and not starter_name.is_empty():
		_add_unique(profile["party"] as Array, starter_name)
		_add_unique(profile["seen"] as Array, starter_name)
		_add_unique(profile["caught"] as Array, starter_name)
		if int(raw.get("discovered", 1)) >= 2:
			_add_unique(profile["seen"] as Array, "Wahlik")
		profile["quest_stage"] = maxi(int(profile["quest_stage"]), 1)

	profile["version"] = SAVE_VERSION
	return profile

static func player_tile(profile: Dictionary) -> Vector2i:
	return Vector2i(int(profile.get("player_x", START_TILE.x)), int(profile.get("player_y", START_TILE.y)))

static func set_player_tile(profile: Dictionary, tile: Vector2i) -> void:
	profile["player_x"] = tile.x
	profile["player_y"] = tile.y

static func add_seen(profile: Dictionary, monster_name: String) -> void:
	var seen: Array = profile.get("seen", []) as Array
	_add_unique(seen, monster_name)
	profile["seen"] = seen

static func add_caught(profile: Dictionary, monster_name: String) -> void:
	add_seen(profile, monster_name)
	var caught: Array = profile.get("caught", []) as Array
	_add_unique(caught, monster_name)
	profile["caught"] = caught
	var party: Array = profile.get("party", []) as Array
	if party.size() < 6:
		_add_unique(party, monster_name)
	profile["party"] = party

static func _string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if typeof(value) != TYPE_ARRAY:
		return result
	for item: Variant in value as Array:
		var text: String = str(item)
		if not text.is_empty() and not result.has(text):
			result.append(text)
	return result

static func _add_unique(target: Array, value: String) -> void:
	if not value.is_empty() and not target.has(value):
		target.append(value)
