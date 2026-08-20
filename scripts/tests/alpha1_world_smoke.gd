extends SceneTree

const ZONES = preload("res://scripts/data/zone_db.gd")
const TILE_ART = preload("res://scripts/world/vela_tile_art.gd")

func _initialize() -> void:
	var errors: Array[String] = []
	var expected: Array[String] = [
		"vela",
		"vela_outskirts",
		"resonance_route",
		"whispering_grove",
		"tideglass_coast",
		"echo_cave",
		"north_gate"
	]
	for zone_id: String in expected:
		_expect(ZONES.has_zone(zone_id), "missing zone: " + zone_id, errors)
		var rows: Array[String] = ZONES.map_rows(zone_id)
		_expect(rows.size() == 23, zone_id + " does not have 23 rows", errors)
		for row: String in rows:
			_expect(row.length() == 15, zone_id + " has a row that is not 15 tiles wide", errors)
		var spawn: Vector2i = ZONES.spawn_tile(zone_id)
		_expect(spawn.x >= 0 and spawn.x < 15 and spawn.y >= 0 and spawn.y < 23, zone_id + " spawn is out of bounds", errors)

	var supported: Array[String] = TILE_ART.supported_codes()
	var world_codes: Dictionary = {}
	for zone_id: String in expected:
		for row: String in ZONES.map_rows(zone_id):
			for i: int in range(row.length()):
				var code: String = row.substr(i, 1)
				world_codes[code] = true
	for raw_code: Variant in world_codes.keys():
		var code: String = str(raw_code)
		if code == "N":
			continue
		_expect(supported.has(code), "tileset loader does not support map code: " + code, errors)

	_expect(str(ZONES.exit_at("vela", Vector2i(7, 0)).get("zone_id", "")) == "resonance_route", "Vela north exit is broken", errors)
	_expect(str(ZONES.exit_at("vela", Vector2i(0, 5)).get("zone_id", "")) == "vela_outskirts", "Vela outskirts exit is broken", errors)
	_expect(str(ZONES.exit_at("resonance_route", Vector2i(7, 0)).get("zone_id", "")) == "whispering_grove", "route -> grove exit is broken", errors)
	_expect(str(ZONES.exit_at("resonance_route", Vector2i(0, 10)).get("zone_id", "")) == "echo_cave", "route -> cave exit is broken", errors)
	_expect(str(ZONES.exit_at("resonance_route", Vector2i(14, 10)).get("zone_id", "")) == "tideglass_coast", "route -> coast exit is broken", errors)
	_expect(str(ZONES.exit_at("whispering_grove", Vector2i(7, 0)).get("zone_id", "")) == "north_gate", "grove -> north gate exit is broken", errors)

	if errors.is_empty():
		print("ALPHA1_VELA_WORLD: PASS")
		quit(0)
		return
	for error_text: String in errors:
		printerr("ALPHA1_VELA_WORLD: " + error_text)
	quit(1)

func _expect(condition: bool, message: String, errors: Array[String]) -> void:
	if not condition:
		errors.append(message)
