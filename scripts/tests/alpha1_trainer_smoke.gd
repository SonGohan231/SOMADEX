extends SceneTree

const TRAINERS = preload("res://scripts/data/alpha1_trainer_db.gd")
const QUESTS = preload("res://scripts/data/alpha1_quest_db.gd")
const MONSTERS = preload("res://scripts/data/monster_db.gd")
const STATE = preload("res://scripts/core/game_state.gd")
const TRAINER_BATTLE = preload("res://scripts/battle/alpha1_trainer_battle_screen.gd")

func _initialize() -> void:
	var errors: Array[String] = []
	_test_trainer_registry(errors)
	_test_unlock_graph(errors)
	_test_quest_graph(errors)
	_test_trainer_battle_runtime(errors)

	if errors.is_empty():
		print("ALPHA1_TRAINERS: PASS")
		quit(0)
		return
	for error_text: String in errors:
		printerr("ALPHA1_TRAINERS: " + error_text)
	quit(1)

func _test_trainer_registry(errors: Array[String]) -> void:
	var ids: Array[String] = TRAINERS.ids()
	_expect(ids.size() == 4, "expected exactly four authored Alpha trainer encounters", errors)
	var defeat_flags: Dictionary = {}
	for trainer_id: String in ids:
		var data: Dictionary = TRAINERS.info(trainer_id)
		_expect(not str(data.get("name", "")).is_empty(), trainer_id + " missing trainer name", errors)
		var party: Array = TRAINERS.party(trainer_id)
		_expect(party.size() >= 2, trainer_id + " needs at least two Somaskans", errors)
		for raw_member: Variant in party:
			var member: Dictionary = raw_member as Dictionary
			var monster_name: String = str(member.get("name", ""))
			_expect(MONSTERS.has_monster(monster_name), trainer_id + " references missing monster: " + monster_name, errors)
			_expect(int(member.get("level", 0)) > 0, trainer_id + " has invalid member level", errors)
		_expect(TRAINERS.reward_xp(trainer_id) > 0, trainer_id + " has no XP reward", errors)
		var defeat_flag: String = TRAINERS.defeated_flag(trainer_id)
		_expect(not defeat_flag.is_empty(), trainer_id + " missing defeated flag", errors)
		_expect(not defeat_flags.has(defeat_flag), "duplicate trainer defeated flag: " + defeat_flag, errors)
		defeat_flags[defeat_flag] = true

func _test_unlock_graph(errors: Array[String]) -> void:
	var flags: Dictionary = {}
	_expect(TRAINERS.can_challenge("karo", flags), "Karo should be challengeable after introduction", errors)
	_expect(TRAINERS.can_challenge("vera", flags), "Vera should be challengeable after introduction", errors)
	_expect(not TRAINERS.can_challenge("rival_kael", flags), "Kael must be locked before Karo and Vera", errors)
	flags["trainer_karo_defeated"] = true
	_expect(not TRAINERS.can_challenge("rival_kael", flags), "Kael unlocked before Vera", errors)
	flags["trainer_vera_defeated"] = true
	_expect(TRAINERS.can_challenge("rival_kael", flags), "Kael did not unlock after Karo and Vera", errors)
	_expect(not TRAINERS.can_challenge("gate_guard", flags), "Rhea must be locked before Kael", errors)
	flags["trainer_kael_defeated"] = true
	_expect(TRAINERS.can_challenge("gate_guard", flags), "Rhea did not unlock after Kael", errors)

func _test_quest_graph(errors: Array[String]) -> void:
	var world_flags: Dictionary = {"route_entered": true}
	var dialogue_flags: Dictionary = {}
	_expect(QUESTS.stage_for(world_flags, dialogue_flags, 5) == 5, "Alpha quest must start on biome exploration", errors)
	world_flags["visited_whispering_grove"] = true
	world_flags["visited_tideglass_coast"] = true
	world_flags["visited_echo_cave"] = true
	_expect(QUESTS.stage_for(world_flags, dialogue_flags, 5) == 6, "three biomes should unlock trainer trials", errors)
	dialogue_flags["trainer_karo_defeated"] = true
	dialogue_flags["trainer_vera_defeated"] = true
	_expect(QUESTS.stage_for(world_flags, dialogue_flags, 6) == 7, "Karo and Vera should unlock North Gate objective", errors)
	world_flags["visited_north_gate"] = true
	_expect(QUESTS.stage_for(world_flags, dialogue_flags, 7) == 8, "North Gate arrival should unlock Kael", errors)
	dialogue_flags["trainer_kael_defeated"] = true
	_expect(QUESTS.stage_for(world_flags, dialogue_flags, 8) == 9, "Kael victory should unlock Rhea", errors)
	dialogue_flags["trainer_rhea_defeated"] = true
	_expect(QUESTS.stage_for(world_flags, dialogue_flags, 9) == 10, "Rhea victory should complete Vela chapter", errors)

func _test_trainer_battle_runtime(errors: Array[String]) -> void:
	var profile: Dictionary = STATE.new_profile("Luzik")
	var battle: Control = TRAINER_BATTLE.new()
	battle.setup_trainer(
		"karo",
		profile.get("party", []) as Array,
		0,
		1,
		profile.get("inventory", {}) as Dictionary,
		profile.get("talents", {}) as Dictionary,
		profile.get("equipment", {}) as Dictionary
	)
	get_root().add_child(battle)
	_expect(str(battle.trainer_id) == "karo", "trainer battle lost trainer id", errors)
	_expect(battle.enemy_team.size() == 2, "Karo runtime team should contain two members", errors)

	var capture_before: int = int(battle.inventory.get("capture_modules", 0))
	battle._use_bag(0)
	_expect(int(battle.inventory.get("capture_modules", 0)) == capture_before, "trainer battle consumed capture module", errors)
	battle._try_escape()
	_expect(not bool(battle.battle_done), "trainer battle allowed escape", errors)

	var lines: Array[String] = []
	battle._win(lines)
	_expect(int(battle.enemy_team_index) == 1, "trainer battle did not switch to second enemy", errors)
	_expect(not bool(battle.battle_done), "trainer battle ended before final enemy", errors)
	battle._win(lines)
	_expect(bool(battle.battle_done), "trainer battle did not end after final enemy", errors)
	_expect(str(battle.result_data.get("outcome", "")) == "win", "trainer battle final result is not win", errors)
	_expect(str(battle.result_data.get("trainer_id", "")) == "karo", "trainer result missing trainer id", errors)
	_expect(int(battle.result_data.get("xp", 0)) == TRAINERS.reward_xp("karo"), "trainer XP reward mismatch", errors)
	battle.free()

func _expect(condition: bool, message: String, errors: Array[String]) -> void:
	if not condition:
		errors.append(message)
