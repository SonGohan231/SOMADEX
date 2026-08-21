extends SceneTree

const TALENT_DB = preload("res://scripts/data/trainer_talent_db.gd")
const PROGRESSION = preload("res://scripts/data/progression_db.gd")
const LEARNSETS = preload("res://scripts/data/learnset_db.gd")
const MOVES = preload("res://scripts/data/move_db.gd")
const DB = preload("res://scripts/data/monster_db.gd")
const STATE = preload("res://scripts/core/game_state.gd")
const MENU = preload("res://scripts/ui/rpg_pause_menu.gd")
const BATTLE = preload("res://scripts/battle/loadout_battle_screen.gd")

func _initialize() -> void:
	var errors: Array[String] = []
	_test_talent_registry(errors)
	_test_level_gates(errors)
	_test_all_learnsets(errors)
	_test_save_migration(errors)
	_test_loadout_cycle(errors)
	_test_runtime_battle_loadout(errors)
	_test_touch_menu_contract(errors)
	if errors.is_empty():
		print("TRAINER_PROGRESSION_LOADOUT_SMOKE: PASS")
		quit(0)
		return
	for text: String in errors:
		printerr("TRAINER_PROGRESSION_LOADOUT_SMOKE: " + text)
	quit(1)

func _test_talent_registry(errors: Array[String]) -> void:
	_expect(PROGRESSION.TRAINER_LEVEL_CAP == 50, "trainer level cap is not 50", errors)
	_expect(TALENT_DB.all_nodes().size() == 100, "trainer talent registry does not contain exactly 100 nodes", errors)
	for path_id: String in PROGRESSION.path_ids():
		var nodes: Array[Dictionary] = TALENT_DB.nodes_for_path(path_id)
		_expect(nodes.size() == 20, path_id + " does not contain 20 talent nodes", errors)
		_expect(PROGRESSION.max_rank(path_id) == 20, path_id + " path investment cap is not 20", errors)
		if nodes.size() == 20:
			_expect(bool(nodes[19].get("ultimate", false)), path_id + " node 20 is not an ultimate", errors)
			_expect(int(nodes[19].get("required_level", 0)) == 50, path_id + " ultimate is not gated at level 50", errors)

func _test_level_gates(errors: Array[String]) -> void:
	var talents: Dictionary = PROGRESSION.default_talents()
	var first: Dictionary = PROGRESSION.spend(talents, 2, PROGRESSION.PATH_TACTICIAN, 1)
	_expect(bool(first.get("spent", false)), "first tactician node is not available at level 1", errors)
	var after_first: Dictionary = first.get("talents", {}) as Dictionary
	var blocked: Dictionary = PROGRESSION.spend(after_first, 1, PROGRESSION.PATH_TACTICIAN, 1)
	_expect(not bool(blocked.get("spent", false)), "level gate did not block the level-3 node", errors)
	var second: Dictionary = PROGRESSION.spend(after_first, 1, PROGRESSION.PATH_TACTICIAN, 3)
	_expect(bool(second.get("spent", false)), "level-3 talent did not unlock at level 3", errors)
	var invested: Dictionary = PROGRESSION.default_talents()
	invested[PROGRESSION.PATH_GUARDIAN] = 5
	var bonuses: Dictionary = PROGRESSION.bonuses(invested)
	_expect(int(bonuses.get("max_hp_bonus", 0)) > 0, "guardian nodes do not contribute runtime HP bonuses", errors)

func _test_all_learnsets(errors: Array[String]) -> void:
	for creature_name: String in DB.all_names():
		var data: Dictionary = DB.get_monster(creature_name)
		var learnset: Array[Dictionary] = LEARNSETS.learnset_for(creature_name, data)
		_expect(learnset.size() == LEARNSETS.LEARNSET_SIZE, creature_name + " does not have a 16-move learnset", errors)
		var ids: Array[String] = []
		for entry: Dictionary in learnset:
			var move_id: String = str(entry.get("move_id", ""))
			_expect(MOVES.has(move_id), creature_name + " learnset references unknown move " + move_id, errors)
			_expect(not ids.has(move_id), creature_name + " learnset contains duplicate move " + move_id, errors)
			ids.append(move_id)
		var loadout: Array[String] = LEARNSETS.default_loadout(creature_name, 50, data)
		_expect(loadout.size() == 4, creature_name + " does not resolve four active moves", errors)
		_expect(not LEARNSETS.default_special(creature_name, 50, data).is_empty(), creature_name + " does not resolve a level-50 special move", errors)

func _test_save_migration(errors: Array[String]) -> void:
	var legacy: Dictionary = {
		"version":10,
		"starter":"Luzik",
		"trainer_level":42,
		"talent_points":3,
		"talents":{"tactician":12,"guardian":7,"researcher":2,"technician":0,"vanguard":1},
		"party":[{"name":"Luzik","level":20,"hp":20,"moves":[0,1,2,3]}]
	}
	var migrated: Dictionary = STATE.migrate(legacy)
	_expect(int(migrated.get("trainer_level", 0)) == 42, "trainer level was lost during extended migration", errors)
	var talents: Dictionary = migrated.get("talents", {}) as Dictionary
	_expect(int(talents.get("tactician", 0)) == 12, "talent investment above old rank 5 was truncated", errors)
	var party: Array = migrated.get("party", []) as Array
	_expect(party.size() == 1, "legacy party disappeared during loadout migration", errors)
	if party.size() == 1:
		var member: Dictionary = party[0] as Dictionary
		_expect((member.get("move_ids", []) as Array).size() == 4, "legacy member did not receive a four-move id loadout", errors)
		_expect(not str(member.get("special_move_id", "")).is_empty(), "level-20 legacy member did not receive a special move", errors)

func _test_loadout_cycle(errors: Array[String]) -> void:
	var profile: Dictionary = STATE.new_profile("Luzik")
	var party: Array = profile.get("party", []) as Array
	var member: Dictionary = party[0] as Dictionary
	var before: Array = (member.get("move_ids", []) as Array).duplicate()
	_expect(before.size() == 4, "new member does not start with four move ids", errors)
	var updated: Dictionary = STATE.cycle_member_move(profile, 0, 0)
	var after: Array = updated.get("move_ids", []) as Array
	_expect(after.size() == 4, "cycling a move broke the four-slot loadout", errors)
	_expect(after[0] != before[0], "cycling slot 1 did not choose another learned move", errors)

func _test_runtime_battle_loadout(errors: Array[String]) -> void:
	var profile: Dictionary = STATE.new_profile("Luzik")
	STATE.cycle_member_move(profile, 0, 0)
	var party: Array = profile.get("party", []) as Array
	var member: Dictionary = party[0] as Dictionary
	var expected: Array[Dictionary] = STATE.member_move_data(member)
	var screen: Control = BATTLE.new()
	screen.setup(party, 0, 1, "Wahlik", 3, {}, PROGRESSION.default_talents(), {})
	var actual: Array = screen.player_data.get("moves", []) as Array
	_expect(actual.size() == 4, "battle runtime did not expose four persisted active moves", errors)
	if actual.size() == 4 and expected.size() == 4:
		_expect(str((actual[0] as Dictionary).get("id", "")) == str(expected[0].get("id", "")), "battle ignored persisted slot 1", errors)
	screen.free()

func _test_touch_menu_contract(errors: Array[String]) -> void:
	var menu: Control = MENU.new()
	menu.setup(STATE.new_profile("Luzik"))
	_expect(menu.has_signal("move_cycle_requested"), "RPG menu has no move-cycle signal", errors)
	_expect(menu.has_method("_draw_moves"), "RPG menu has no move loadout renderer", errors)
	_expect(menu.has_method("_draw_trainer"), "RPG menu has no expanded trainer renderer", errors)
	menu.section = "moves"
	_expect(menu._section_count() == 4, "move menu does not expose four active slots", errors)
	menu.free()

func _expect(condition: bool, message: String, errors: Array[String]) -> void:
	if not condition:
		errors.append(message)
