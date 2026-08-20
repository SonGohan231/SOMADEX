extends Control

const SAVE = preload("res://scripts/core/save_manager.gd")
const STATE = preload("res://scripts/core/game_state.gd")
const DB = preload("res://scripts/data/monster_db.gd")
const PROGRESSION = preload("res://scripts/data/progression_db.gd")
const ZONES = preload("res://scripts/data/zone_db.gd")
const EQUIPMENT = preload("res://scripts/data/equipment_db.gd")
const TITLE_SCREEN = preload("res://scripts/ui/title_screen.gd")
const INTRO_SCREEN = preload("res://scripts/ui/intro_screen.gd")
const STARTER_SCREEN = preload("res://scripts/ui/starter_screen.gd")
const WORLD_SCREEN = preload("res://scripts/world/world_screen.gd")
const PAUSE_MENU = preload("res://scripts/ui/pause_menu.gd")
const BATTLE_SCREEN = preload("res://scripts/battle/battle_screen.gd")

var current_screen: Control
var profile: Dictionary = STATE.new_profile()
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	set_process_unhandled_input(true)
	_show_title()

func _switch_to(screen: Control) -> void:
	if current_screen != null:
		remove_child(current_screen)
		current_screen.queue_free()
	current_screen = screen
	add_child(current_screen)
	current_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	current_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _show_title(message: String = "") -> void:
	var screen: Control = TITLE_SCREEN.new()
	screen.setup(SAVE.has_save(), message)
	screen.new_game_requested.connect(_start_new_game)
	screen.load_requested.connect(_load_game)
	_switch_to(screen)

func _start_new_game() -> void:
	profile = STATE.new_profile()
	var screen: Control = INTRO_SCREEN.new()
	screen.finished.connect(_show_starter_choice)
	_switch_to(screen)

func _show_starter_choice() -> void:
	var screen: Control = STARTER_SCREEN.new()
	screen.starter_chosen.connect(_on_starter_chosen)
	_switch_to(screen)

func _on_starter_chosen(name: String) -> void:
	profile = STATE.new_profile(name)
	profile["quest_stage"] = 1
	profile["zone_id"] = "vela"
	STATE.set_player_tile(profile, STATE.START_TILE)
	_save_game()
	_show_world()

func _show_world() -> void:
	var party: Array = profile.get("party", []) as Array
	if party.is_empty():
		_show_starter_choice()
		return
	var zone_id: String = str(profile.get("zone_id", "vela"))
	if not ZONES.has_zone(zone_id):
		zone_id = "vela"
		profile["zone_id"] = zone_id
		STATE.set_player_tile(profile, ZONES.spawn_tile(zone_id))
	var screen: Control = WORLD_SCREEN.new()
	var quest_stage: int = int(profile.get("quest_stage", 0))
	screen.setup(
		STATE.active_name(profile),
		STATE.player_tile(profile),
		int(profile.get("trainer_level", 1)),
		bool(profile.get("haptics", true)),
		zone_id,
		PROGRESSION.quest_short(quest_stage),
		profile.get("dialogue_flags", {}) as Dictionary
	)
	screen.menu_requested.connect(_open_menu)
	screen.battle_requested.connect(_start_battle)
	screen.station_requested.connect(_on_station_requested)
	screen.zone_change_requested.connect(_on_zone_change_requested)
	screen.dialogue_flag_requested.connect(_on_dialogue_flag_requested)
	_switch_to(screen)

func _open_menu(tile: Vector2i) -> void:
	STATE.set_player_tile(profile, tile)
	var screen: Control = PAUSE_MENU.new()
	screen.setup(profile)
	screen.close_requested.connect(_show_world)
	screen.save_requested.connect(_on_save_requested.bind(screen))
	screen.haptics_changed.connect(_on_haptics_changed)
	screen.talent_spend_requested.connect(_on_talent_spend_requested.bind(screen))
	screen.equipment_cycle_requested.connect(_on_equipment_cycle_requested.bind(screen))
	screen.active_member_requested.connect(_on_active_member_requested.bind(screen))
	_switch_to(screen)

func _on_save_requested(menu_screen: Control) -> void:
	var ok: bool = _save_game()
	if is_instance_valid(menu_screen) and menu_screen.has_method("show_message"):
		menu_screen.show_message("Gra zapisana" if ok else "Błąd zapisu")

func _on_haptics_changed(value: bool) -> void:
	profile["haptics"] = value
	_save_game()

func _on_active_member_requested(index: int, menu_screen: Control) -> void:
	var changed: bool = STATE.set_active_member(profile, index)
	if changed:
		_save_game()
		if is_instance_valid(menu_screen) and menu_screen.has_method("refresh_profile"):
			menu_screen.refresh_profile(profile, "Aktywny partner: %s" % STATE.active_name(profile))
	elif is_instance_valid(menu_screen) and menu_screen.has_method("show_message"):
		menu_screen.show_message("Nie można aktywować tego slotu")

func _on_equipment_cycle_requested(slot_id: String, menu_screen: Control) -> void:
	var gear_id: String = STATE.cycle_equipment(profile, slot_id)
	if gear_id.is_empty():
		if is_instance_valid(menu_screen) and menu_screen.has_method("show_message"):
			menu_screen.show_message("Brak alternatywnego wyposażenia")
		return
	_save_game()
	var info: Dictionary = EQUIPMENT.info(gear_id)
	if is_instance_valid(menu_screen) and menu_screen.has_method("refresh_profile"):
		menu_screen.refresh_profile(profile, "%s: %s" % [EQUIPMENT.slot_name(slot_id), str(info.get("name", gear_id))])

func _on_talent_spend_requested(path_id: String, menu_screen: Control) -> void:
	var talents: Dictionary = profile.get("talents", PROGRESSION.default_talents()) as Dictionary
	var points: int = int(profile.get("talent_points", 0))
	var result: Dictionary = PROGRESSION.spend(talents, points, path_id)
	if bool(result.get("spent", false)):
		profile["talents"] = (result["talents"] as Dictionary).duplicate(true)
		profile["talent_points"] = int(result["points"])
		_save_game()
		if is_instance_valid(menu_screen) and menu_screen.has_method("refresh_profile"):
			menu_screen.refresh_profile(profile, "%s +1" % PROGRESSION.path_name(path_id))
	elif is_instance_valid(menu_screen) and menu_screen.has_method("show_message"):
		menu_screen.show_message("Brak punktów lub maksymalna ranga")

func _start_battle(tile: Vector2i) -> void:
	STATE.set_player_tile(profile, tile)
	var zone_id: String = str(profile.get("zone_id", "vela"))
	var encounter: Dictionary = ZONES.roll_encounter(zone_id, rng)
	var enemy_name: String = str(encounter.get("name", "Wahlik"))
	STATE.add_seen(profile, enemy_name)
	if int(profile.get("quest_stage", 0)) == 1:
		profile["quest_stage"] = 2
	var screen: Control = BATTLE_SCREEN.new()
	screen.setup(
		profile.get("party", []) as Array,
		STATE.active_index(profile),
		int(profile.get("trainer_level", 1)),
		enemy_name,
		int(encounter.get("level", 3)),
		profile.get("inventory", {}) as Dictionary,
		profile.get("talents", {}) as Dictionary,
		profile.get("equipment", {}) as Dictionary
	)
	screen.finished.connect(_on_battle_finished)
	_switch_to(screen)

func _on_battle_finished(result: Dictionary) -> void:
	var returned_party: Variant = result.get("party", [])
	if typeof(returned_party) == TYPE_ARRAY:
		STATE.replace_party(profile, returned_party as Array, int(result.get("active_party_index", 0)))

	var returned_inventory: Variant = result.get("inventory", {})
	if typeof(returned_inventory) == TYPE_DICTIONARY:
		profile["inventory"] = (returned_inventory as Dictionary).duplicate(true)

	var seen_name: String = str(result.get("seen_name", ""))
	if not seen_name.is_empty():
		STATE.add_seen(profile, seen_name)

	var xp_gain: int = maxi(0, int(result.get("xp", 0)))
	if xp_gain > 0:
		var active_index: int = STATE.active_index(profile)
		STATE.add_member_exp(profile, active_index, xp_gain)
		profile["trainer_xp"] = maxi(0, int(profile.get("trainer_xp", 0)) + xp_gain)

	var captured_name: String = str(result.get("captured_name", ""))
	if not captured_name.is_empty():
		STATE.add_caught(profile, captured_name, maxi(1, int(result.get("captured_level", 1))))
		if int(profile.get("quest_stage", 0)) <= 2:
			profile["quest_stage"] = 3

	_apply_trainer_level_ups()

	if str(result.get("outcome", "")) == "loss":
		profile["zone_id"] = "vela"
		STATE.set_player_tile(profile, STATE.START_TILE)
		STATE.heal_party(profile)

	_save_game()
	_show_world()

func _apply_trainer_level_ups() -> void:
	var level: int = maxi(1, int(profile.get("trainer_level", 1)))
	var xp: int = maxi(0, int(profile.get("trainer_xp", 0)))
	var points: int = maxi(0, int(profile.get("talent_points", 0)))
	var threshold: int = PROGRESSION.xp_to_next_level(level)
	while xp >= threshold:
		xp -= threshold
		level += 1
		points += 1
		threshold = PROGRESSION.xp_to_next_level(level)
	profile["trainer_level"] = level
	profile["trainer_xp"] = xp
	profile["talent_points"] = points

func _on_station_requested(tile: Vector2i) -> void:
	STATE.set_player_tile(profile, tile)
	STATE.heal_party(profile)
	var stage: int = int(profile.get("quest_stage", 0))
	if stage >= 3 and stage < 4:
		profile["quest_stage"] = 4
	var flags: Dictionary = profile.get("flags", {}) as Dictionary
	flags["vela_station_synced"] = true
	profile["flags"] = flags
	_save_game()

func _on_zone_change_requested(target_zone: String, spawn_tile: Vector2i) -> void:
	if not ZONES.has_zone(target_zone):
		return
	profile["zone_id"] = target_zone
	STATE.set_player_tile(profile, spawn_tile)
	var flags: Dictionary = profile.get("flags", {}) as Dictionary
	if target_zone == "resonance_route":
		flags["route_entered"] = true
		if int(profile.get("quest_stage", 0)) == 4:
			profile["quest_stage"] = 5
	profile["flags"] = flags
	_save_game()
	_show_world()

func _on_dialogue_flag_requested(flag_id: String) -> void:
	STATE.set_dialogue_flag(profile, flag_id)
	_save_game()

func _save_game() -> bool:
	var party: Array = profile.get("party", []) as Array
	if party.is_empty():
		return false
	profile["version"] = STATE.SAVE_VERSION
	return SAVE.save_game(profile)

func _load_game() -> void:
	var raw: Dictionary = SAVE.load_game()
	if raw.is_empty():
		_show_title("Brak prawidłowego zapisu gry")
		return
	profile = STATE.migrate(raw)
	var starter_name: String = str(profile.get("starter", ""))
	if starter_name.is_empty() or not DB.has_monster(starter_name):
		var member: Dictionary = STATE.active_member(profile)
		starter_name = str(member.get("name", "Luzik"))
		profile["starter"] = starter_name
	var zone_id: String = str(profile.get("zone_id", "vela"))
	if not ZONES.has_zone(zone_id):
		profile["zone_id"] = "vela"
		STATE.set_player_tile(profile, ZONES.spawn_tile("vela"))
	if int(profile.get("quest_stage", 0)) == 0:
		profile["quest_stage"] = 1
	var party: Array = profile.get("party", []) as Array
	var any_alive: bool = false
	for value: Variant in party:
		var member: Dictionary = value as Dictionary
		if int(member.get("hp", 0)) > 0:
			any_alive = true
			break
	if not any_alive:
		STATE.heal_party(profile)
	_save_game()
	_show_world()
