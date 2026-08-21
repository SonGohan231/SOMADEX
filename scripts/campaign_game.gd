extends "res://scripts/game_animations.gd"

const CAMPAIGN_STATE = preload("res://scripts/core/game_state.gd")
const CAMPAIGN_SAVE = preload("res://scripts/core/save_manager.gd")
const CAMPAIGN_CHECKPOINT = preload("res://scripts/core/campaign_checkpoint.gd")
const CAMPAIGN_MONSTERS = preload("res://scripts/data/monster_db.gd")
const CAMPAIGN_ZONES = preload("res://scripts/data/campaign_zone_db.gd")
const CAMPAIGN_ENCOUNTERS = preload("res://scripts/data/encounter_db.gd")
const CAMPAIGN_TRAINERS = preload("res://scripts/data/runtime_trainer_db.gd")
const CAMPAIGN_PICKUPS = preload("res://scripts/data/pickup_db.gd")
const CAMPAIGN_PROGRESS = preload("res://scripts/data/campaign_progression_db.gd")
const CAMPAIGN_ALPHA_QUESTS = preload("res://scripts/data/alpha1_quest_db.gd")
const CAMPAIGN_SIDEQUESTS = preload("res://scripts/data/campaign_sidequest_db.gd")
const CAMPAIGN_STORY_BEATS = preload("res://scripts/data/campaign_story_beat_db.gd")
const CAMPAIGN_WORLD = preload("res://scripts/world/sprite_campaign_world_screen.gd")
const CAMPAIGN_TRAINER_BATTLE = preload("res://scripts/battle/campaign_trainer_battle_screen.gd")
const CAMPAIGN_EQUIPMENT = preload("res://scripts/data/equipment_db.gd")

func _show_world() -> void:
	var party: Array = profile.get("party", []) as Array
	if party.is_empty():
		_show_starter_choice()
		return
	var zone_id: String = str(profile.get("zone_id", "vela"))
	if not CAMPAIGN_ZONES.has_zone(zone_id):
		zone_id = "vela"
		profile["zone_id"] = zone_id
		CAMPAIGN_STATE.set_player_tile(profile, CAMPAIGN_ZONES.spawn_tile(zone_id))
	_refresh_alpha_quest_stage()
	var stage: int = int(profile.get("quest_stage", 0))
	var quest_short: String = ""
	if stage < 5:
		quest_short = ANIM_PROGRESSION.quest_short(stage)
	elif stage < CAMPAIGN_PROGRESS.STAGE_VELA_TRIAL:
		quest_short = CAMPAIGN_ALPHA_QUESTS.short(stage)
	else:
		quest_short = CAMPAIGN_PROGRESS.short(stage)
	var screen: Control = CAMPAIGN_WORLD.new()
	screen.setup(
		CAMPAIGN_STATE.active_name(profile),
		CAMPAIGN_STATE.player_tile(profile),
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
	_show_story_beat_if_ready(screen, zone_id)

func _start_battle(tile: Vector2i) -> void:
	CAMPAIGN_STATE.set_player_tile(profile, tile)
	var zone_id: String = str(profile.get("zone_id", "vela"))
	var encounter: Dictionary = CAMPAIGN_ENCOUNTERS.roll(zone_id, rng)
	var enemy_name: String = str(encounter.get("name", "Wahlik"))
	CAMPAIGN_STATE.add_seen(profile, enemy_name)
	if int(profile.get("quest_stage", 0)) == 1:
		profile["quest_stage"] = 2
	var screen: Control = ANIM_BATTLE_SCREEN.new()
	screen.setup(
		profile.get("party", []) as Array,
		CAMPAIGN_STATE.active_index(profile),
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
	if not CAMPAIGN_TRAINERS.has(trainer_id):
		return
	var dialogue_flags: Dictionary = profile.get("dialogue_flags", {}) as Dictionary
	if not CAMPAIGN_TRAINERS.can_challenge(trainer_id, dialogue_flags):
		return
	CAMPAIGN_STATE.set_player_tile(profile, tile)
	for raw_member: Variant in CAMPAIGN_TRAINERS.party(trainer_id):
		var entry: Dictionary = raw_member as Dictionary
		var enemy_name: String = str(entry.get("name", ""))
		if not enemy_name.is_empty():
			CAMPAIGN_STATE.add_seen(profile, enemy_name)
	var screen: Control = CAMPAIGN_TRAINER_BATTLE.new()
	screen.setup_trainer(
		trainer_id,
		profile.get("party", []) as Array,
		CAMPAIGN_STATE.active_index(profile),
		int(profile.get("trainer_level", 1)),
		profile.get("inventory", {}) as Dictionary,
		profile.get("talents", {}) as Dictionary,
		profile.get("equipment", {}) as Dictionary
	)
	screen.finished.connect(_on_trainer_battle_finished)
	_switch_to(screen)

func _on_trainer_battle_finished(result: Dictionary) -> void:
	var trainer_id: String = str(result.get("trainer_id", ""))
	if str(result.get("outcome", "")) == "win" and CAMPAIGN_TRAINERS.has(trainer_id):
		CAMPAIGN_STATE.set_dialogue_flag(profile, CAMPAIGN_TRAINERS.defeated_flag(trainer_id))
		_merge_campaign_trainer_rewards(result, trainer_id)
		var returned_inventory: Variant = result.get("inventory", {})
		if typeof(returned_inventory) == TYPE_DICTIONARY:
			profile["inventory"] = (returned_inventory as Dictionary).duplicate(true)
		_resolve_sidequests()
		result["inventory"] = (profile.get("inventory", {}) as Dictionary).duplicate(true)
		_refresh_alpha_quest_stage()
	_on_battle_finished(result)

func _merge_campaign_trainer_rewards(result: Dictionary, trainer_id: String) -> void:
	var inventory: Dictionary = {}
	var raw_inventory: Variant = result.get("inventory", {})
	if typeof(raw_inventory) == TYPE_DICTIONARY:
		inventory = (raw_inventory as Dictionary).duplicate(true)
	var rewards: Dictionary = CAMPAIGN_TRAINERS.reward_items(trainer_id)
	for raw_item: Variant in rewards.keys():
		var item_id: String = str(raw_item)
		inventory[item_id] = maxi(0, int(inventory.get(item_id, 0))) + maxi(0, int(rewards[raw_item]))
	result["inventory"] = inventory

func _on_battle_finished(result: Dictionary) -> void:
	var returned_party: Variant = result.get("party", [])
	if typeof(returned_party) == TYPE_ARRAY:
		CAMPAIGN_STATE.replace_party(profile, returned_party as Array, int(result.get("active_party_index", 0)))

	var returned_inventory: Variant = result.get("inventory", {})
	if typeof(returned_inventory) == TYPE_DICTIONARY:
		profile["inventory"] = (returned_inventory as Dictionary).duplicate(true)

	var seen_name: String = str(result.get("seen_name", ""))
	if not seen_name.is_empty():
		CAMPAIGN_STATE.add_seen(profile, seen_name)

	var xp_gain: int = maxi(0, int(result.get("xp", 0)))
	if xp_gain > 0:
		var active_index: int = CAMPAIGN_STATE.active_index(profile)
		CAMPAIGN_STATE.add_member_exp(profile, active_index, xp_gain)
		profile["trainer_xp"] = maxi(0, int(profile.get("trainer_xp", 0)) + xp_gain)

	var captured_name: String = str(result.get("captured_name", ""))
	if not captured_name.is_empty():
		CAMPAIGN_STATE.add_caught(profile, captured_name, maxi(1, int(result.get("captured_level", 1))))
		if int(profile.get("quest_stage", 0)) <= 2:
			profile["quest_stage"] = 3

	_apply_trainer_level_ups()

	if str(result.get("outcome", "")) == "loss":
		var checkpoint: Dictionary = CAMPAIGN_CHECKPOINT.resolve(profile)
		profile["zone_id"] = str(checkpoint.get("zone_id", "vela"))
		CAMPAIGN_STATE.set_player_tile(profile, checkpoint.get("tile", CAMPAIGN_STATE.START_TILE) as Vector2i)
		CAMPAIGN_STATE.heal_party(profile)

	_save_game()
	_show_world()

func _on_zone_change_requested(target_zone: String, spawn_tile: Vector2i) -> void:
	if not CAMPAIGN_ZONES.has_zone(target_zone):
		return
	var current_zone: String = str(profile.get("zone_id", "vela"))
	var dialogue_flags: Dictionary = profile.get("dialogue_flags", {}) as Dictionary
	if not CAMPAIGN_PROGRESS.can_enter(current_zone, target_zone, dialogue_flags):
		if is_instance_valid(current_screen) and current_screen.has_method("show_message"):
			current_screen.show_message(CAMPAIGN_PROGRESS.lock_text(current_zone, target_zone))
		return
	profile["zone_id"] = target_zone
	CAMPAIGN_STATE.set_player_tile(profile, spawn_tile)
	var flags: Dictionary = profile.get("flags", {}) as Dictionary
	flags["visited_%s" % target_zone] = true
	if target_zone == "resonance_route":
		flags["route_entered"] = true
		if int(profile.get("quest_stage", 0)) == 4:
			profile["quest_stage"] = 5
	profile["flags"] = flags
	_refresh_alpha_quest_stage()
	_save_game()
	_show_world()

func _on_station_requested(tile: Vector2i) -> void:
	CAMPAIGN_STATE.set_player_tile(profile, tile)
	CAMPAIGN_STATE.heal_party(profile)
	var zone_id: String = str(profile.get("zone_id", "vela"))
	var flags: Dictionary = profile.get("flags", {}) as Dictionary
	flags["station_%s_synced" % zone_id] = true
	if zone_id == "vela":
		flags["vela_station_synced"] = true
		if int(profile.get("quest_stage", 0)) >= 3 and int(profile.get("quest_stage", 0)) < 4:
			profile["quest_stage"] = 4
	profile["flags"] = flags
	CAMPAIGN_CHECKPOINT.sync(profile, zone_id, tile)
	_refresh_alpha_quest_stage()
	_save_game()

func _on_pickup_requested(pickup_id: String) -> void:
	var pickup: Dictionary = CAMPAIGN_PICKUPS.by_id(pickup_id)
	if pickup.is_empty():
		return
	var flag_id: String = CAMPAIGN_PICKUPS.flag_id(pickup_id)
	var dialogue_flags: Dictionary = profile.get("dialogue_flags", {}) as Dictionary
	if bool(dialogue_flags.get(flag_id, false)):
		return
	var gear_id: String = str(pickup.get("gear", ""))
	if not gear_id.is_empty() and not CAMPAIGN_EQUIPMENT.info(gear_id).is_empty():
		var owned: Array[String] = CAMPAIGN_EQUIPMENT.normalize_owned(profile.get("owned_equipment", []))
		if not owned.has(gear_id):
			owned.append(gear_id)
		profile["owned_equipment"] = owned
	else:
		var item_id: String = str(pickup.get("item", ""))
		var amount: int = maxi(1, int(pickup.get("amount", 1)))
		var inventory: Dictionary = profile.get("inventory", {}) as Dictionary
		inventory[item_id] = maxi(0, int(inventory.get(item_id, 0))) + amount
		profile["inventory"] = inventory
	CAMPAIGN_STATE.set_dialogue_flag(profile, flag_id)
	_resolve_sidequests()
	_save_game()

func _resolve_sidequests() -> void:
	super._resolve_sidequests()
	var flags: Dictionary = profile.get("dialogue_flags", {}) as Dictionary
	var inventory: Dictionary = profile.get("inventory", {}) as Dictionary
	for quest_id: String in CAMPAIGN_SIDEQUESTS.ids():
		if not CAMPAIGN_SIDEQUESTS.can_complete(quest_id, flags):
			continue
		var rewards: Dictionary = CAMPAIGN_SIDEQUESTS.reward(quest_id)
		for raw_item: Variant in rewards.keys():
			var item_id: String = str(raw_item)
			inventory[item_id] = maxi(0, int(inventory.get(item_id, 0))) + maxi(0, int(rewards[raw_item]))
		flags[CAMPAIGN_SIDEQUESTS.complete_flag(quest_id)] = true
	profile["dialogue_flags"] = flags
	profile["inventory"] = inventory

func _show_story_beat_if_ready(screen: Control, zone_id: String) -> void:
	var flags: Dictionary = profile.get("dialogue_flags", {}) as Dictionary
	var beat: Dictionary = CAMPAIGN_STORY_BEATS.next_for(zone_id, flags)
	if beat.is_empty():
		return
	var beat_flag: String = str(beat.get("flag", ""))
	if not beat_flag.is_empty():
		CAMPAIGN_STATE.set_dialogue_flag(profile, beat_flag)
	if is_instance_valid(screen) and screen.has_method("show_message"):
		screen.show_message(str(beat.get("text", "")))
	_save_game()

func _refresh_alpha_quest_stage() -> void:
	var current: int = int(profile.get("quest_stage", 0))
	var dialogue_flags: Dictionary = profile.get("dialogue_flags", {}) as Dictionary
	if current < CAMPAIGN_PROGRESS.STAGE_VELA_TRIAL:
		var world_flags: Dictionary = profile.get("flags", {}) as Dictionary
		current = CAMPAIGN_ALPHA_QUESTS.stage_for(world_flags, dialogue_flags, current)
	profile["quest_stage"] = CAMPAIGN_PROGRESS.stage_for(dialogue_flags, current)

func _load_game() -> void:
	var raw: Dictionary = CAMPAIGN_SAVE.load_game()
	if raw.is_empty():
		_show_title("Brak prawidłowego zapisu gry")
		return
	profile = CAMPAIGN_STATE.migrate(raw)
	var starter_name: String = str(profile.get("starter", ""))
	if starter_name.is_empty() or not CAMPAIGN_MONSTERS.has_monster(starter_name):
		var member: Dictionary = CAMPAIGN_STATE.active_member(profile)
		starter_name = str(member.get("name", "Luzik"))
		profile["starter"] = starter_name
	var zone_id: String = str(profile.get("zone_id", "vela"))
	if not CAMPAIGN_ZONES.has_zone(zone_id):
		profile["zone_id"] = "vela"
		CAMPAIGN_STATE.set_player_tile(profile, CAMPAIGN_ZONES.spawn_tile("vela"))
	if int(profile.get("quest_stage", 0)) == 0:
		profile["quest_stage"] = 1
	_resolve_sidequests()
	_refresh_alpha_quest_stage()
	var party: Array = profile.get("party", []) as Array
	var any_alive: bool = false
	for value: Variant in party:
		var member: Dictionary = value as Dictionary
		if int(member.get("hp", 0)) > 0:
			any_alive = true
			break
	if not any_alive:
		CAMPAIGN_STATE.heal_party(profile)
	_save_game()
	_show_world()
