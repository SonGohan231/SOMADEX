extends SceneTree

const DB = preload("res://scripts/data/monster_db.gd")
const ZONES = preload("res://scripts/data/zone_db.gd")
const NPCS = preload("res://scripts/data/alpha1_npc_db.gd")
const ENCOUNTERS = preload("res://scripts/data/alpha1_encounter_db.gd")
const TILE_ART = preload("res://scripts/world/vela_tile_art.gd")
const MONSTER_ART = preload("res://scripts/data/monster_art_alpha.gd")

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

	_expect(NPCS.count() >= 12, "Alpha 1 Vela has fewer than twelve authored NPCs", errors)
	_expect(NPCS.trainer_ids().size() >= 4, "Alpha 1 Vela has fewer than four authored trainer encounters", errors)
	for zone_id: String in expected:
		for npc: Dictionary in NPCS.in_zone(zone_id):
			var tile: Vector2i = NPCS.tile_of(npc)
			_expect(tile.x >= 0 and tile.x < 15 and tile.y >= 0 and tile.y < 23, "NPC out of bounds: " + str(npc.get("id", "?")), errors)
			_expect(not str(npc.get("name", "")).is_empty(), "NPC missing name", errors)
			_expect(not str(npc.get("first", "")).is_empty(), "NPC missing first dialogue: " + str(npc.get("id", "?")), errors)

	_expect(DB.all_names().size() >= 11, "Alpha 1 active monster database has fewer than eleven species", errors)
	var wild_species: Array[String] = ENCOUNTERS.all_species()
	_expect(wild_species.size() == 8, "Alpha 1 Vela must expose eight distinct wild species in biome pools", errors)
	for monster_name: String in wild_species:
		_expect(DB.has_monster(monster_name), "encounter pool references unknown species: " + monster_name, errors)
	for zone_id: String in ["vela_outskirts", "resonance_route", "whispering_grove", "tideglass_coast", "echo_cave"]:
		_expect(ENCOUNTERS.species(zone_id).size() >= 4, zone_id + " has insufficient encounter diversity", errors)

	var remastered: Array[String] = MONSTER_ART.remastered_names()
	_expect(remastered.size() == 10, "first Alpha portrait batch must contain ten Somaskans", errors)
	_expect(remastered.has("Luzik") and remastered.has("Bocznik") and remastered.has("Wahlik"), "core Alpha monsters are missing from remastered portrait batch", errors)

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
