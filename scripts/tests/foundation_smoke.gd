extends SceneTree

const STATE = preload("res://scripts/core/game_state.gd")
const DB = preload("res://scripts/data/monster_db.gd")
const PROGRESSION = preload("res://scripts/data/progression_db.gd")
const ZONES = preload("res://scripts/data/zone_db.gd")

func _initialize() -> void:
	var errors: Array[String] = []
	_test_save_migration(errors)
	_test_collection_and_party(errors)
	_test_trainer_paths(errors)
	_test_zone_encounters(errors)
	_test_monster_schema(errors)
	if errors.is_empty():
		print("FOUNDATION_V8_SMOKE: PASS")
		quit(0)
		return
	for error_text: String in errors:
		printerr("FOUNDATION_V8_SMOKE: " + error_text)
	quit(1)

func _test_save_migration(errors: Array[String]) -> void:
	var legacy: Dictionary = {
		"version": 2,
		"starter": "Luzik",
		"player_x": 6,
		"player_y": 18,
		"player_hp": 17,
		"trainer_level": 3,
		"trainer_xp": 4,
		"discovered": 2,
		"haptics": false
	}
	var migrated: Dictionary = STATE.migrate(legacy)
	_expect(int(migrated.get("version", 0)) == 8, "legacy save did not migrate to schema v8", errors)
	_expect(str(migrated.get("starter", "")) == "Luzik", "starter lost during migration", errors)
	_expect(STATE.player_tile(migrated) == Vector2i(6, 18), "player tile lost during migration", errors)
	_expect(int(migrated.get("trainer_level", 0)) == 3, "trainer level lost during migration", errors)
	_expect(not bool(migrated.get("haptics", true)), "haptics setting lost during migration", errors)
	var seen: Array = migrated.get("seen", []) as Array
	_expect(seen.has("Luzik") and seen.has("Wahlik"), "legacy discovered state was not migrated", errors)
	var inventory: Dictionary = migrated.get("inventory", {}) as Dictionary
	_expect(int(inventory.get("capture_modules", 0)) > 0, "default inventory missing after migration", errors)

func _test_collection_and_party(errors: Array[String]) -> void:
	var profile: Dictionary = STATE.new_profile("Bocznik")
	STATE.add_seen(profile, "Wahlik")
	STATE.add_caught(profile, "Wahlik")
	var party: Array = profile.get("party", []) as Array
	var caught: Array = profile.get("caught", []) as Array
	_expect(party.has("Bocznik") and party.has("Wahlik"), "captured monster was not added to party", errors)
	_expect(party.size() <= 6, "party exceeded six slots", errors)
	_expect(caught.has("Wahlik"), "captured monster missing from collection", errors)

func _test_trainer_paths(errors: Array[String]) -> void:
	var talents: Dictionary = PROGRESSION.default_talents()
	_expect(PROGRESSION.path_ids().size() == 5, "trainer does not expose five development paths", errors)
	var spent: Dictionary = PROGRESSION.spend(talents, 1, PROGRESSION.PATH_TACTICIAN)
	_expect(bool(spent.get("spent", false)), "talent point could not be spent", errors)
	_expect(int(spent.get("points", 99)) == 0, "talent point was not consumed", errors)
	var updated: Dictionary = spent.get("talents", {}) as Dictionary
	_expect(PROGRESSION.rank(updated, PROGRESSION.PATH_TACTICIAN) == 1, "talent rank did not increase", errors)
	var bonuses: Dictionary = PROGRESSION.bonuses(updated)
	_expect(int(bonuses.get("attack_bonus", 0)) == 1, "tactician bonus is not applied", errors)

func _test_zone_encounters(errors: Array[String]) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 808
	_expect(ZONES.has_zone("vela"), "Vela zone missing", errors)
	var encounter: Dictionary = ZONES.roll_encounter("vela", rng)
	var enemy_name: String = str(encounter.get("name", ""))
	_expect(DB.has_monster(enemy_name), "zone rolled an unknown monster: " + enemy_name, errors)
	_expect(int(encounter.get("level", 0)) > 0, "zone rolled an invalid level", errors)

func _test_monster_schema(errors: Array[String]) -> void:
	var names: Array[String] = DB.all_names()
	_expect(names.size() >= 4, "monster database contains fewer than four implemented species", errors)
	for monster_name: String in names:
		var data: Dictionary = DB.get_monster(monster_name)
		_expect(data.has("id") and data.has("types") and data.has("capture_rate") and data.has("habitat"), monster_name + " is missing scalable species metadata", errors)
		var moves: Array = data.get("moves", []) as Array
		_expect(moves.size() == 4, monster_name + " does not have four active moves", errors)
		for move_value: Variant in moves:
			var move_data: Dictionary = move_value as Dictionary
			_expect(move_data.has("kind") and move_data.has("power") and move_data.has("accuracy") and move_data.has("priority") and move_data.has("cost") and move_data.has("status"), monster_name + " has an incomplete move schema", errors)

func _expect(condition: bool, message: String, errors: Array[String]) -> void:
	if not condition:
		errors.append(message)
