extends SceneTree

const STATE = preload("res://scripts/core/game_state.gd")
const PROGRESSION = preload("res://scripts/data/progression_db.gd")
const EQUIPMENT = preload("res://scripts/data/equipment_db.gd")
const ZONES = preload("res://scripts/data/zone_db.gd")
const BATTLE_SCREEN = preload("res://scripts/battle/battle_screen.gd")
const PAUSE_MENU = preload("res://scripts/ui/pause_menu.gd")
const WORLD_SCREEN = preload("res://scripts/world/world_screen.gd")

func _initialize() -> void:
	var errors: Array[String] = []
	var profile: Dictionary = STATE.new_profile("Luzik")
	var talents: Dictionary = PROGRESSION.default_talents()
	for path_id: String in PROGRESSION.path_ids():
		talents[path_id] = 1
	profile["talents"] = talents
	STATE.add_caught(profile, "Wahlik", 3)
	_test_menu(profile, errors)
	_test_world(profile, errors)
	_test_battle(profile, errors)
	if errors.is_empty():
		print("FOUNDATION_1_0_INTEGRATION: PASS")
		quit(0)
		return
	for error_text: String in errors:
		printerr("FOUNDATION_1_0_INTEGRATION: " + error_text)
	quit(1)

func _test_menu(profile: Dictionary, errors: Array[String]) -> void:
	var menu: Control = PAUSE_MENU.new()
	menu.setup(profile)
	get_root().add_child(menu)
	_expect(menu.items.size() == 9, "pause menu does not expose the complete Foundation 1.0 sections", errors)
	var menu_profile: Dictionary = menu.profile as Dictionary
	_expect((menu_profile.get("party", []) as Array).size() == 2, "pause menu did not receive the full party", errors)
	var loadout: Dictionary = menu_profile.get("equipment", {}) as Dictionary
	_expect(loadout.size() == EQUIPMENT.slot_ids().size(), "pause menu did not receive all equipment slots", errors)
	menu.queue_free()

func _test_world(profile: Dictionary, errors: Array[String]) -> void:
	var world: Control = WORLD_SCREEN.new()
	var zone_id: String = str(profile.get("zone_id", "vela"))
	world.setup(
		STATE.active_name(profile),
		ZONES.spawn_tile(zone_id),
		int(profile.get("trainer_level", 1)),
		bool(profile.get("haptics", true)),
		zone_id,
		PROGRESSION.quest_short(int(profile.get("quest_stage", 0))),
		profile.get("dialogue_flags", {}) as Dictionary
	)
	get_root().add_child(world)
	_expect(world.map_rows.size() == 23, "world screen did not load a complete map", errors)
	_expect(world.zone_id == zone_id, "world screen lost the requested zone id", errors)
	var exit_data: Dictionary = ZONES.exit_at("vela", Vector2i(7, 0))
	_expect(str(exit_data.get("zone_id", "")) == "resonance_route", "world transition contract Vela -> Resonance Route is broken", errors)
	world.queue_free()

func _test_battle(profile: Dictionary, errors: Array[String]) -> void:
	var battle: Control = BATTLE_SCREEN.new()
	battle.setup(
		profile.get("party", []) as Array,
		STATE.active_index(profile),
		int(profile.get("trainer_level", 1)),
		"Wahlik",
		3,
		profile.get("inventory", {}) as Dictionary,
		profile.get("talents", {}) as Dictionary,
		profile.get("equipment", {}) as Dictionary
	)
	get_root().add_child(battle)
	_expect(battle.party.size() == 2, "battle screen did not receive the whole party", errors)
	_expect(battle.active_index == 0, "battle screen did not preserve the active party index", errors)
	var first_name: String = battle._active_name()
	battle._switch_party(1)
	_expect(battle.active_index == 1, "battle party switching is not functional", errors)
	_expect(battle._active_name() != first_name, "battle party switching did not change the active Somaskan", errors)
	battle._switch_party(0)
	battle._queue_move(0)
	_expect(battle.mode == "trainer", "creature move does not enter the trainer-action phase", errors)
	_expect(battle.pending_move_index == 0, "queued creature move was not retained for the trainer phase", errors)
	var focus_before: int = battle.trainer_focus
	battle._use_trainer_action(0)
	_expect(battle.trainer_focus == focus_before - 1, "trainer command did not consume Focus", errors)
	_expect(battle.pending_move_index == -1 or battle.battle_done, "trainer phase did not resolve the queued creature move", errors)
	battle.queue_free()

func _expect(condition: bool, message: String, errors: Array[String]) -> void:
	if not condition:
		errors.append(message)
