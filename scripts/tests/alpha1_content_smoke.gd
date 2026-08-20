extends SceneTree

const ZONES = preload("res://scripts/data/zone_db.gd")
const ENCOUNTERS = preload("res://scripts/data/alpha1_encounter_db.gd")
const TRAINERS = preload("res://scripts/data/alpha1_trainer_db.gd")
const NPCS = preload("res://scripts/data/alpha1_npc_db.gd")
const PICKUPS = preload("res://scripts/data/alpha1_pickup_db.gd")
const SIDEQUESTS = preload("res://scripts/data/alpha1_sidequest_db.gd")
const QUESTS = preload("res://scripts/data/alpha1_quest_db.gd")
const MONSTERS = preload("res://scripts/data/monster_db.gd")

func _initialize() -> void:
	var errors: Array[String] = []
	var expected_zones: Array[String] = [
		"vela", "vela_outskirts", "resonance_route", "whispering_grove",
		"tideglass_coast", "echo_cave", "north_gate"
	]
	_expect(ZONES.ids().size() == 7, "expected exactly seven Vela zones", errors)
	for zone_id: String in expected_zones:
		_expect(ZONES.has_zone(zone_id), "missing zone: %s" % zone_id, errors)
		var rows: Array[String] = ZONES.map_rows(zone_id)
		_expect(rows.size() == 23, "%s must have 23 rows" % zone_id, errors)
		for row_index: int in range(rows.size()):
			_expect(rows[row_index].length() == 15, "%s row %d must have 15 columns" % [zone_id, row_index], errors)

	var encounter_species: Array[String] = ENCOUNTERS.all_species()
	_expect(encounter_species.size() >= 8, "Vela should expose at least eight wild species", errors)
	for species: String in encounter_species:
		_expect(MONSTERS.has_monster(species), "encounter species missing from monster DB: %s" % species, errors)

	_expect(TRAINERS.ids().size() == 4, "expected four authored trainer battles", errors)
	var npc_trainers: Array[String] = NPCS.trainer_ids()
	for trainer_id: String in TRAINERS.ids():
		_expect(npc_trainers.has(trainer_id), "trainer has no world NPC: %s" % trainer_id, errors)
		var team: Array = TRAINERS.party(trainer_id)
		_expect(not team.is_empty(), "trainer has empty party: %s" % trainer_id, errors)
		for raw_member: Variant in team:
			var entry: Dictionary = raw_member as Dictionary
			var species: String = str(entry.get("name", ""))
			_expect(MONSTERS.has_monster(species), "trainer %s references missing species %s" % [trainer_id, species], errors)

	_expect(NPCS.count() == 17, "expected 17 authored Vela NPCs", errors)
	_expect(PICKUPS.count() == 12, "expected 12 authored Vela pickups", errors)
	_expect(SIDEQUESTS.ids().size() == 3, "expected three Vela sidequests", errors)

	var prerequisite_flags: Dictionary = {
		"trainer_karo_defeated": true,
		"trainer_vera_defeated": true
	}
	_expect(not TRAINERS.can_challenge("rival_kael", {}), "Kael must be gated behind Karo and Vera", errors)
	_expect(TRAINERS.can_challenge("rival_kael", prerequisite_flags), "Kael should unlock after Karo and Vera", errors)

	var world_flags: Dictionary = {
		"route_entered": true,
		"visited_whispering_grove": true,
		"visited_tideglass_coast": true,
		"visited_echo_cave": true,
		"visited_north_gate": true
	}
	var completed_flags: Dictionary = {
		"trainer_karo_defeated": true,
		"trainer_vera_defeated": true,
		"trainer_kael_defeated": true,
		"trainer_rhea_defeated": true
	}
	_expect(QUESTS.stage_for(world_flags, completed_flags, 5) == 10, "completed Vela graph must resolve to stage 10", errors)

	if errors.is_empty():
		print("ALPHA1_CONTENT_SMOKE: PASS")
		quit(0)
		return
	for error_text: String in errors:
		printerr("ALPHA1_CONTENT_SMOKE: " + error_text)
	quit(1)

func _expect(condition: bool, message: String, errors: Array[String]) -> void:
	if not condition:
		errors.append(message)