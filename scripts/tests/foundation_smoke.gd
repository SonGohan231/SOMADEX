extends SceneTree

const STATE = preload("res://scripts/core/game_state.gd")
const DB = preload("res://scripts/data/monster_db.gd")
const PROGRESSION = preload("res://scripts/data/progression_db.gd")
const ZONES = preload("res://scripts/data/zone_db.gd")
const EQUIPMENT = preload("res://scripts/data/equipment_db.gd")
const ITEMS = preload("res://scripts/data/item_db.gd")
const STATUS = preload("res://scripts/data/status_db.gd")
const RULES = preload("res://scripts/battle/battle_rules.gd")
const DIALOGUE = preload("res://scripts/data/dialogue_db.gd")

func _initialize() -> void:
	var errors: Array[String] = []
	_test_save_migration(errors)
	_test_party_model(errors)
	_test_equipment_and_items(errors)
	_test_trainer_paths(errors)
	_test_status_and_battle_rules(errors)
	_test_zones_and_dialogue(errors)
	_test_monster_schema(errors)
	if errors.is_empty():
		print("FOUNDATION_1_0_SMOKE: PASS")
		quit(0)
		return
	for error_text: String in errors:
		printerr("FOUNDATION_1_0_SMOKE: " + error_text)
	quit(1)

func _test_save_migration(errors: Array[String]) -> void:
	var legacy_v2: Dictionary = {
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
	var migrated_v2: Dictionary = STATE.migrate(legacy_v2)
	_expect(int(migrated_v2.get("version", 0)) == 10, "legacy v2 save did not migrate to schema v10", errors)
	_expect(STATE.player_tile(migrated_v2) == Vector2i(6, 18), "legacy player tile lost", errors)
	_expect(not bool(migrated_v2.get("haptics", true)), "legacy haptics setting lost", errors)
	var party_v2: Array = migrated_v2.get("party", []) as Array
	_expect(not party_v2.is_empty() and typeof(party_v2[0]) == TYPE_DICTIONARY, "legacy party did not become member records", errors)
	if not party_v2.is_empty():
		var member: Dictionary = party_v2[0] as Dictionary
		_expect(str(member.get("name", "")) == "Luzik", "legacy starter lost in party migration", errors)
		_expect(int(member.get("hp", 0)) == 17, "legacy active HP was not preserved", errors)

	var legacy_v8: Dictionary = {
		"version": 8,
		"starter": "Bocznik",
		"party": ["Bocznik", "Wahlik"],
		"seen": ["Bocznik", "Wahlik"],
		"caught": ["Bocznik", "Wahlik"],
		"inventory": {"capture_modules": 2, "regenerators": 1, "sondas": 1},
		"talents": {"tactician": 1},
		"quest_stage": 4,
		"zone_id": "vela"
	}
	var migrated_v8: Dictionary = STATE.migrate(legacy_v8)
	_expect(int(migrated_v8.get("version", 0)) == 10, "v8 save did not migrate to schema v10", errors)
	var party_v8: Array = migrated_v8.get("party", []) as Array
	_expect(party_v8.size() == 2, "v8 party size changed during migration", errors)
	_expect((party_v8[1] as Dictionary).has("uid"), "v8 party member has no stable uid", errors)
	var inventory: Dictionary = migrated_v8.get("inventory", {}) as Dictionary
	_expect(inventory.has("resonance_cells"), "new inventory key missing after v8 migration", errors)

func _test_party_model(errors: Array[String]) -> void:
	var profile: Dictionary = STATE.new_profile("Nucik")
	var party: Array = profile.get("party", []) as Array
	_expect(party.size() == 1, "new profile should start with one party member", errors)
	var starter: Dictionary = party[0] as Dictionary
	_expect(str(starter.get("name", "")) == "Nucik", "starter member name invalid", errors)
	_expect(int(starter.get("level", 0)) == STATE.STARTER_LEVEL, "starter level invalid", errors)
	_expect(int(starter.get("hp", 0)) > 0, "starter HP invalid", errors)

	STATE.add_caught(profile, "Wahlik", 3)
	party = profile.get("party", []) as Array
	_expect(party.size() == 2, "captured member not added to party", errors)
	_expect(STATE.set_active_member(profile, 1), "living captured member cannot become active", errors)
	_expect(STATE.active_name(profile) == "Wahlik", "active member switch failed", errors)

	var old_level: int = int((party[1] as Dictionary).get("level", 1))
	var levels_gained: int = STATE.add_member_exp(profile, 1, 100)
	var updated_party: Array = profile.get("party", []) as Array
	_expect(levels_gained > 0, "member XP did not produce a level-up", errors)
	_expect(int((updated_party[1] as Dictionary).get("level", 1)) > old_level, "member level did not increase", errors)

	for i: int in range(7):
		STATE.add_caught(profile, "Wahlik", 2 + i)
	party = profile.get("party", []) as Array
	var storage: Array = profile.get("storage", []) as Array
	_expect(party.size() == STATE.PARTY_LIMIT, "party limit is not enforced", errors)
	_expect(storage.size() > 0, "overflow captures are not routed to storage", errors)

func _test_equipment_and_items(errors: Array[String]) -> void:
	var profile: Dictionary = STATE.new_profile("Luzik")
	var slots: Array[String] = EQUIPMENT.slot_ids()
	_expect(slots.size() == 6, "trainer equipment does not expose six slots", errors)
	var loadout: Dictionary = profile.get("equipment", {}) as Dictionary
	for slot_id: String in slots:
		_expect(loadout.has(slot_id), "loadout missing slot " + slot_id, errors)
		var gear_id: String = str(loadout.get(slot_id, ""))
		_expect(str(EQUIPMENT.info(gear_id).get("slot", "")) == slot_id, "gear assigned to wrong slot " + slot_id, errors)

	var before_module: String = str(loadout.get(EQUIPMENT.SLOT_MODULE, ""))
	var after_module: String = STATE.cycle_equipment(profile, EQUIPMENT.SLOT_MODULE)
	_expect(not after_module.is_empty() and after_module != before_module, "module slot does not cycle through owned equipment", errors)
	var gear_bonus: Dictionary = EQUIPMENT.aggregate(profile.get("equipment", {}) as Dictionary)
	_expect(gear_bonus.has("capture_bonus") and gear_bonus.has("trainer_focus_bonus"), "equipment aggregation missing combat bonuses", errors)

	var inventory: Dictionary = ITEMS.default_inventory()
	_expect(ITEMS.ids().size() >= 4, "item registry missing foundation items", errors)
	var before_count: int = ITEMS.count(inventory, "capture_modules")
	_expect(ITEMS.consume(inventory, "capture_modules"), "item consumption failed", errors)
	_expect(ITEMS.count(inventory, "capture_modules") == before_count - 1, "item count did not decrement", errors)

func _test_trainer_paths(errors: Array[String]) -> void:
	var talents: Dictionary = PROGRESSION.default_talents()
	_expect(PROGRESSION.path_ids().size() == 5, "trainer does not expose five development paths", errors)
	_expect(PROGRESSION.trainer_action_count() == 5, "trainer does not expose five battle actions", errors)
	for i: int in range(PROGRESSION.trainer_action_count()):
		var path_id: String = PROGRESSION.trainer_action_path(i)
		var spent: Dictionary = PROGRESSION.spend(talents, 1, path_id)
		_expect(bool(spent.get("spent", false)), "cannot spend point in path " + path_id, errors)
		var upgraded: Dictionary = spent.get("talents", {}) as Dictionary
		var action: Dictionary = PROGRESSION.trainer_action_info(i, upgraded)
		_expect(int(action.get("rank", 0)) == 1, "battle action rank not linked to trainer tree " + path_id, errors)
		_expect(not str(action.get("name", "")).is_empty(), "battle action has no name " + path_id, errors)

func _test_status_and_battle_rules(errors: Array[String]) -> void:
	_expect(STATUS.ids().size() >= 16, "status registry contains fewer than 16 statuses", errors)
	_expect(STATUS.interaction_count() >= 8, "status interaction table contains fewer than 8 reactions", errors)
	var target_statuses: Dictionary = {}
	STATUS.apply(target_statuses, "armor_break", 2)
	var normal_damage: int = RULES.calculate_damage(8, 8, 7, 5, 0, "PHYSICAL", {}, {}, 1.0)
	var combo_damage: int = RULES.calculate_damage(8, 8, 7, 5, 0, "PHYSICAL", target_statuses, {}, 1.0)
	_expect(combo_damage > normal_damage, "status interaction does not modify damage", errors)

	var unmarked_chance: float = RULES.capture_chance(0.30, 10, 20, 0.0, 0.0, {})
	var marked: Dictionary = {}
	STATUS.apply(marked, "marked", 3)
	var marked_chance: float = RULES.capture_chance(0.30, 10, 20, 0.0, 0.0, marked)
	_expect(marked_chance > unmarked_chance, "marked status does not improve capture", errors)

	var disrupted: Dictionary = {}
	STATUS.apply(disrupted, "disrupted", 1)
	_expect(STATUS.outgoing_multiplier(disrupted) < 1.0, "disrupted status does not reduce outgoing damage", errors)

func _test_zones_and_dialogue(errors: Array[String]) -> void:
	_expect(ZONES.ids().size() >= 2, "fewer than two data-driven zones", errors)
	for zone_id: String in ZONES.ids():
		var rows: Array[String] = ZONES.map_rows(zone_id)
		_expect(rows.size() == 23, zone_id + " map does not have 23 rows", errors)
		for row: String in rows:
			_expect(row.length() == 15, zone_id + " map row is not 15 tiles wide", errors)
	var north_exit: Dictionary = ZONES.exit_at("vela", Vector2i(7, 0))
	_expect(str(north_exit.get("zone_id", "")) == "resonance_route", "Vela north exit is not wired", errors)
	var return_exit: Dictionary = ZONES.exit_at("resonance_route", Vector2i(7, 22))
	_expect(str(return_exit.get("zone_id", "")) == "vela", "route return exit is not wired", errors)

	var flags: Dictionary = {}
	var first_text: String = DIALOGUE.text("vela", "N", flags)
	_expect(not first_text.is_empty(), "Vela NPC dialogue missing", errors)
	var flag_id: String = DIALOGUE.flag_for("vela", "N")
	_expect(flag_id == "talked_mira", "dialogue does not expose persistent flag", errors)

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
			_expect(
				move_data.has("kind")
					and move_data.has("power")
					and move_data.has("accuracy")
					and move_data.has("priority")
					and move_data.has("cost")
					and move_data.has("status")
					and move_data.has("status_chance")
					and move_data.has("move_type"),
				monster_name + " has an incomplete move schema",
				errors
			)

func _expect(condition: bool, message: String, errors: Array[String]) -> void:
	if not condition:
		errors.append(message)
