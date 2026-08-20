extends SceneTree

const TARGETS = preload("res://scripts/data/game_design_targets.gd")
const MOVES = preload("res://scripts/data/move_db.gd")
const PASSIVES = preload("res://scripts/data/passive_db.gd")
const STATUS = preload("res://scripts/data/status_db.gd")
const MODES = preload("res://scripts/data/battle_mode_db.gd")
const REGIONS = preload("res://scripts/data/region_db.gd")
const DB = preload("res://scripts/data/monster_db.gd")
const STATE = preload("res://scripts/core/game_state.gd")
const EQUIPMENT = preload("res://scripts/data/equipment_db.gd")
const RPG_SCREEN = preload("res://scripts/battle/rpg_battle_screen.gd")
const TRAINER_SCREEN = preload("res://scripts/battle/alpha1_trainer_battle_screen.gd")

func _initialize() -> void:
	var errors: Array[String] = []
	_test_design_contract(errors)
	_test_move_registry(errors)
	_test_passives(errors)
	_test_status_combo_matrix(errors)
	_test_battle_modes(errors)
	_test_region_plan(errors)
	_test_runtime_bridge(errors)
	if errors.is_empty():
		print("RPG_SYSTEMS_SMOKE: PASS")
		quit(0)
		return
	for text: String in errors:
		printerr("RPG_SYSTEMS_SMOKE: " + text)
	quit(1)

func _test_design_contract(errors: Array[String]) -> void:
	_expect(TARGETS.MAIN_STORY_HOURS_MIN == 18 and TARGETS.MAIN_STORY_HOURS_MAX == 25, "main-story duration target drifted", errors)
	_expect(TARGETS.COMPLETION_HOURS_MIN == 35 and TARGETS.COMPLETION_HOURS_MAX == 50, "completion duration target drifted", errors)
	_expect(TARGETS.FAMILY_TARGET_FIRST_VERSION == 50, "first-version family target is not 50", errors)
	_expect(TARGETS.FORM_TARGET_FIRST_VERSION == 150, "first-version form target is not 150", errors)
	_expect(TARGETS.MOVE_TARGET_MIN == 180 and TARGETS.MOVE_TARGET_MAX == 220, "move target is not 180-220", errors)
	_expect(TARGETS.TRAINER_LEVEL_CAP == 50, "trainer level target is not 50", errors)
	_expect(TARGETS.TRAINER_PATHS.size() == 5, "trainer path target is not five", errors)
	_expect(TARGETS.BATTLE_MODES.size() == 3, "battle mode target is not three", errors)

func _test_move_registry(errors: Array[String]) -> void:
	_expect(MOVES.count() >= 48, "foundation move library has fewer than 48 authored moves", errors)
	var patterns: Dictionary = {}
	for move_id: String in MOVES.ids():
		var data: Dictionary = MOVES.info(move_id)
		_expect(MOVES.validate(data), "move schema invalid: " + move_id, errors)
		patterns[str(data.get("pattern", ""))] = true
	for pattern: String in ["direct", "multi", "conditional", "prepared", "counter", "control"]:
		_expect(patterns.has(pattern), "move library missing pattern " + pattern, errors)

func _test_passives(errors: Array[String]) -> void:
	_expect(PASSIVES.ids().size() >= 20, "passive foundation contains fewer than 20 effects", errors)
	var luzik: Dictionary = DB.get_monster("Luzik")
	var passive_id: String = PASSIVES.default_for_creature(luzik)
	_expect(not passive_id.is_empty(), "Luzik did not resolve a passive", errors)
	_expect(not PASSIVES.info(passive_id).is_empty(), "resolved passive has no metadata", errors)
	var target: Dictionary = {"unstable":2}
	var test_move: Dictionary = {"kind":"attack","move_type":"REZONANS","priority":0}
	_expect(PASSIVES.attack_flat_bonus("layer_anchor", test_move, {}, target, 1.0) > 0, "conditional passive does not affect matching combat state", errors)

func _test_status_combo_matrix(errors: Array[String]) -> void:
	_expect(STATUS.ids().size() == 20, "status registry must contain 20 foundation statuses", errors)
	_expect(STATUS.interaction_count() >= 20 and STATUS.interaction_count() <= 30, "status combo matrix must contain 20-30 reactions", errors)
	var wet: Dictionary = {}
	STATUS.apply(wet, "soaked", 2)
	_expect(STATUS.damage_multiplier("ELECTRIC", wet) > 1.0, "soaked + electric has no damage synergy", errors)
	var reaction: Dictionary = STATUS.resolve_reaction("ELECTRIC", wet)
	_expect(str(reaction.get("label", "")) == "PRZEWODZENIE", "soaked + electric reaction label missing", errors)
	_expect(STATUS.has_status(wet, "paralyzed"), "soaked + electric does not apply paralysis", errors)

func _test_battle_modes(errors: Array[String]) -> void:
	_expect(MODES.ids().size() == 3, "battle mode registry does not contain three modes", errors)
	_expect(not MODES.uses_stability(MODES.MODE_STANDARD), "standard battle should not use trainer stability", errors)
	_expect(MODES.uses_stability(MODES.MODE_RESONANCE), "resonance battle does not use trainer stability", errors)
	_expect(MODES.stability_base(MODES.MODE_RESONANCE) == 100, "resonance stability base is not 100", errors)
	_expect(not MODES.capture_allowed(MODES.MODE_RESONANCE), "capture must be disabled in resonance duel", errors)
	_expect(not MODES.escape_allowed(MODES.MODE_TRAINER_DUEL), "escape must be disabled in trainer duel", errors)
	_expect(MODES.stability_base(MODES.MODE_TRAINER_DUEL) == 120, "trainer-duel stability base is not 120", errors)

func _test_region_plan(errors: Array[String]) -> void:
	var towns: Array[Dictionary] = REGIONS.towns(REGIONS.REGION_VELA)
	var fields: Array[Dictionary] = REGIONS.field_areas(REGIONS.REGION_VELA)
	_expect(towns.size() >= TARGETS.FIRST_REGION_TOWNS_MIN and towns.size() <= TARGETS.FIRST_REGION_TOWNS_MAX, "Vela region town plan is outside 8-10", errors)
	_expect(fields.size() >= TARGETS.FIRST_REGION_FIELD_AREAS_MIN and fields.size() <= TARGETS.FIRST_REGION_FIELD_AREAS_MAX, "Vela field-area plan is outside 12-18", errors)
	_expect(REGIONS.boss_slots(REGIONS.REGION_VELA).size() >= TARGETS.MAIN_BOSSES_MIN, "Vela region has fewer than eight boss slots", errors)
	for zone_id: String in ["vela", "vela_outskirts", "resonance_route", "whispering_grove", "tideglass_coast", "echo_cave", "north_gate"]:
		_expect(REGIONS.implemented_locations(REGIONS.REGION_VELA).has(zone_id), "current playable Vela zone missing from region registry: " + zone_id, errors)
	_expect(REGIONS.planned_location_count(REGIONS.REGION_VELA) >= 24, "full first-region registry is too small", errors)

func _test_runtime_bridge(errors: Array[String]) -> void:
	var party: Array = [STATE.make_member("Luzik", 5, 1)]
	var screen: Control = RPG_SCREEN.new()
	screen.setup(party, 0, 1, "Wahlik", 3, {}, {}, EQUIPMENT.default_loadout())
	screen.set_battle_mode(MODES.MODE_RESONANCE)
	_expect(screen.battle_mode_id == MODES.MODE_RESONANCE, "RPG battle screen did not switch to resonance mode", errors)
	_expect(screen.player_stability == 100 and screen.enemy_trainer_stability == 100, "resonance runtime did not initialize stability", errors)
	_expect(screen.trainer_focus_max >= MODES.focus_base(MODES.MODE_RESONANCE), "resonance runtime focus is below mode minimum", errors)
	_expect(not screen.player_passive_id.is_empty() and not screen.enemy_passive_id.is_empty(), "battle runtime did not resolve creature passives", errors)
	var normalized_moves: Array = screen.player_data.get("moves", []) as Array
	_expect(normalized_moves.size() == 4, "runtime did not preserve four active moves", errors)
	if not normalized_moves.is_empty():
		_expect(MOVES.validate(normalized_moves[0] as Dictionary), "runtime move was not upgraded to scalable schema", errors)
	screen.free()
	var trainer: Control = TRAINER_SCREEN.new()
	_expect(trainer.has_method("set_battle_mode"), "trainer battle does not inherit RPG battle modes", errors)
	_expect(trainer.has_method("_draw_actor_visual"), "trainer battle lost animated renderer", errors)
	trainer.free()

func _expect(condition: bool, message: String, errors: Array[String]) -> void:
	if not condition:
		errors.append(message)
