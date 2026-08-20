extends Control

const SAVE = preload("res://scripts/core/save_manager.gd")
const STATE = preload("res://scripts/core/game_state.gd")
const DB = preload("res://scripts/data/monster_db.gd")
const PROGRESSION = preload("res://scripts/data/progression_db.gd")
const ZONES = preload("res://scripts/data/zone_db.gd")
const ENCOUNTERS = preload("res://scripts/data/alpha1_encounter_db.gd")
const TRAINERS = preload("res://scripts/data/alpha1_trainer_db.gd")
const PICKUPS = preload("res://scripts/data/alpha1_pickup_db.gd")
const ALPHA_QUESTS = preload("res://scripts/data/alpha1_quest_db.gd")
const EQUIPMENT = preload("res://scripts/data/equipment_db.gd")
const TITLE_SCREEN = preload("res://scripts/ui/title_screen.gd")
const INTRO_SCREEN = preload("res://scripts/ui/intro_screen.gd")
const STARTER_SCREEN = preload("res://scripts/ui/starter_screen.gd")
const WORLD_SCREEN = preload("res://scripts/world/alpha1_world_screen.gd")
const PAUSE_MENU = preload("res://scripts/ui/alpha1_pause_menu.gd")
const BATTLE_SCREEN = preload("res://scripts/battle/alpha1_battle_screen.gd")
const TRAINER_BATTLE_SCREEN = preload("res://scripts/battle/alpha1_trainer_battle_screen.gd")

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
	var quest_short: String = PROGRESSION.quest_short(quest_stage)
	if quest_stage >= 5:
		quest_short = ALPHA_QUESTS.short(quest_stage)
	screen.setup(
		STATE.active_name(profile),
		STATE.player_tile(profile),
		int(profile.get("trainer_level", 1)),
		bool(profile.get("haptics", true)),
		zone_id,
		quest_short,
		profile.get("dialogue_flags", {}) as Dictionary
	)
	screen.menu_requested.connect(_open_menu)
	screen.battle_requested.connect(_start_battle)
	screen.station_requested.connect(_on_station_requested)
	screen.zone_change_requested.connect(_on_zone_change_requested)
	screen.dialogue_flag_requested.connect(_on_dialogue_flag_requested)
	screen.trainer_battle_requested.connect(_start_trainer_battle)
	screen.pickup_requested.connect(_on_pickup_requested)
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
	var encounter: Dictionary = ENCOUNTERS.roll(zone_id, rng)
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

func _start_trainer_battle(trainer_id: String, tile: Vector2i) -> void:
	if not TRAINERS.has(trainer_id):
		return
	var dialogue_flags: Dictionary = profile.get("dialogue_flags", {}) as Dictionary
	if not TRAINERS.can_challenge(trainer_id, dialogue_flags):
		return
	STATE.set_player_tile(profile, tile)
	for raw_member: Variant in TRAINERS.party(trainer_id):
		var entry: Dictionary = raw_member as Dictionary
		var enemy_name: String = str(entry.get("name", ""))
		if not enemy_name.is_empty():
			STATE.add_seen(profile, enemy_name)
	var screen: Control = TRAINER_BATTLE_SCREEN.new()
	screen.setup_trainer(
		trainer_id,
		profile.get("party", []) as Array,
		STATE.active_index(profile),
		int(profile.get("trainer_level", 1)),
		profile.get("inventory", {}) as Dictionary,
		profile.get("talents", {}) as Dictionary,
		profile.get("equipment", {}) as Dictionary
	)
	screen.finished.connect(_on_trainer_battle_finished)
	_switch_to(screen)

func _on_trainer_battle_finished(result: Dictionary) -> void:
	var trainer_id: String = str(result.get("trainer_id", ""))
	if str(result.get("outcome", "")) == "win" and TRAINERS.has(trainer_id):
		STATE.set_dialogue_flag(profile, TRAINERS.defeated_flag(trainer_id))
		_merge_trainer_rewards_into_result(result, trainer_id)
		_refresh_alpha_quest_stage()
	_on_battle_finished(result)

func _merge_trainer_rewards_into_result(result: Dictionary, trainer_id: String) -> void:
	var inventory: Dictionary = {}
	var raw_inventory: Variant = result.get("inventory", {})
	if typeof(raw_inventory) == TYPE_DICTIONARY:
		inventory = (raw_inventory as Dictionary).duplicate(true)
	var rewards: Dictionary = TRAINERS.reward_items(trainer_id)
	for raw_item: Variant in rewards.keys():
		var item_id: String = str(raw_item)
		inventory[item_id] = maxi(0, int(inventory.get(item_id, 0))) + maxi(0, int(rewards[raw_item]))
	result["inventory"] = inventory

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
	if target_zone in ["whispering_grove", "tideglass_coast", "echo_cave", "north_gate"]:
		flags["visited_%s" % target_zone] = true
	profile["flags"] = flags
	_refresh_alpha_quest_stage()
	_save_game()
	_show_world()

func _on_dialogue_flag_requested(flag_id: String) -> void:
	STATE.set_dialogue_flag(profile, flag_id)
	_save_game()

func _on_pickup_requested(pickup_id: String) -> void:
	var pickup: Dictionary = PICKUPS.by_id(pickup_id)
	if pickup.is_empty():
		return
	var flag_id: String = PICKUPS.flag_id(pickup_id)
	var dialogue_flags: Dictionary = profile.get("dialogue_flags", {}) as Dictionary
	if bool(dialogue_flags.get(flag_id, false)):
		return
	var item_id: String = str(pickup.get("item", ""))
	var amount: int = maxi(1, int(pickup.get("amount", 1)))
	var inventory: Dictionary = profile.get("inventory", {}) as Dictionary
	inventory[item_id] = maxi(0, int(inventory.get(item_id, 0))) + amount
	profile["inventory"] = inventory
	STATE.set_dialogue_flag(profile, flag_id)
	_save_game()

func _refresh_alpha_quest_stage() -> void:
	var world_flags: Dictionary = profile.get("flags", {}) as Dictionary
	var dialogue_flags: Dictionary = profile.get("dialogue_flags", {}) as Dictionary
	profile["quest_stage"] = ALPHA_QUESTS.stage_for(world_flags, dialogue_flags, int(profile.get("quest_stage", 0)))

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
	_refresh_alpha_quest_stage()
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
