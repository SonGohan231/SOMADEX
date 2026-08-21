extends "res://scripts/game_art.gd"

const ANIM_STATE = preload("res://scripts/core/game_state.gd")
const ANIM_ENCOUNTERS = preload("res://scripts/data/alpha1_encounter_db.gd")
const ANIM_BATTLE_SCREEN = preload("res://scripts/battle/loadout_battle_screen.gd")
const ANIM_PROGRESSION = preload("res://scripts/data/progression_db.gd")
const ANIM_PAUSE_MENU = preload("res://scripts/ui/rpg_pause_menu.gd")

func _start_battle(tile: Vector2i) -> void:
	ANIM_STATE.set_player_tile(profile, tile)
	var zone_id: String = str(profile.get("zone_id", "vela"))
	var encounter: Dictionary = ANIM_ENCOUNTERS.roll(zone_id, rng)
	var enemy_name: String = str(encounter.get("name", "Wahlik"))
	ANIM_STATE.add_seen(profile, enemy_name)
	if int(profile.get("quest_stage", 0)) == 1:
		profile["quest_stage"] = 2
	var screen: Control = ANIM_BATTLE_SCREEN.new()
	screen.setup(
		profile.get("party", []) as Array,
		ANIM_STATE.active_index(profile),
		int(profile.get("trainer_level", 1)),
		enemy_name,
		int(encounter.get("level", 3)),
		profile.get("inventory", {}) as Dictionary,
		profile.get("talents", {}) as Dictionary,
		profile.get("equipment", {}) as Dictionary
	)
	screen.finished.connect(_on_battle_finished)
	_switch_to(screen)

func _open_menu(tile: Vector2i) -> void:
	ANIM_STATE.set_player_tile(profile, tile)
	var screen: Control = ANIM_PAUSE_MENU.new()
	screen.setup(profile)
	screen.close_requested.connect(_show_world)
	screen.save_requested.connect(_on_save_requested.bind(screen))
	screen.haptics_changed.connect(_on_haptics_changed)
	screen.talent_spend_requested.connect(_on_talent_spend_requested.bind(screen))
	screen.equipment_cycle_requested.connect(_on_equipment_cycle_requested.bind(screen))
	screen.active_member_requested.connect(_on_active_member_requested.bind(screen))
	screen.move_cycle_requested.connect(_on_move_cycle_requested.bind(screen))
	_switch_to(screen)

func _on_move_cycle_requested(party_index: int, slot_index: int, menu_screen: Control) -> void:
	var member: Dictionary = ANIM_STATE.cycle_member_move(profile, party_index, slot_index)
	if member.is_empty():
		if is_instance_valid(menu_screen) and menu_screen.has_method("show_message"):
			menu_screen.show_message("Nie można zmienić tego slotu")
		return
	_save_game()
	var moves: Array[Dictionary] = ANIM_STATE.member_move_data(member)
	var move_name: String = "Ruch zmieniony"
	if slot_index >= 0 and slot_index < moves.size():
		move_name = str((moves[slot_index] as Dictionary).get("name", move_name))
	if is_instance_valid(menu_screen) and menu_screen.has_method("refresh_profile"):
		menu_screen.refresh_profile(profile, "Slot %d: %s" % [slot_index + 1, move_name])

func _on_talent_spend_requested(path_id: String, menu_screen: Control) -> void:
	var talents: Dictionary = profile.get("talents", ANIM_PROGRESSION.default_talents()) as Dictionary
	var points: int = int(profile.get("talent_points", 0))
	var trainer_level: int = clampi(int(profile.get("trainer_level", 1)), 1, ANIM_PROGRESSION.TRAINER_LEVEL_CAP)
	var result: Dictionary = ANIM_PROGRESSION.spend(talents, points, path_id, trainer_level)
	if bool(result.get("spent", false)):
		profile["talents"] = (result.get("talents", {}) as Dictionary).duplicate(true)
		profile["talent_points"] = int(result.get("points", points))
		_save_game()
		var node: Dictionary = result.get("node", {}) as Dictionary
		var text: String = str(node.get("name", "%s +1" % ANIM_PROGRESSION.path_name(path_id)))
		if is_instance_valid(menu_screen) and menu_screen.has_method("refresh_profile"):
			menu_screen.refresh_profile(profile, "Odblokowano: " + text)
		return
	var next: Dictionary = ANIM_PROGRESSION.next_talent(talents, path_id)
	var requirement: int = int(next.get("required_level", 0))
	var message: String = "Brak punktów lub ścieżka ukończona"
	if not next.is_empty() and trainer_level < requirement:
		message = "Następny talent wymaga Lv.%d" % requirement
	if is_instance_valid(menu_screen) and menu_screen.has_method("show_message"):
		menu_screen.show_message(message)

func _apply_trainer_level_ups() -> void:
	var level: int = clampi(int(profile.get("trainer_level", 1)), 1, ANIM_PROGRESSION.TRAINER_LEVEL_CAP)
	var xp: int = maxi(0, int(profile.get("trainer_xp", 0)))
	var points: int = maxi(0, int(profile.get("talent_points", 0)))
	while level < ANIM_PROGRESSION.TRAINER_LEVEL_CAP:
		var threshold: int = ANIM_PROGRESSION.xp_to_next_level(level)
		if xp < threshold:
			break
		xp -= threshold
		level += 1
		points += 1
	if level >= ANIM_PROGRESSION.TRAINER_LEVEL_CAP:
		level = ANIM_PROGRESSION.TRAINER_LEVEL_CAP
		xp = 0
	profile["trainer_level"] = level
	profile["trainer_xp"] = xp
	profile["talent_points"] = points
