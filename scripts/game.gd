extends Control

const SAVE = preload("res://scripts/core/save_manager.gd")
const STATE = preload("res://scripts/core/game_state.gd")
const DB = preload("res://scripts/data/monster_db.gd")
const PROGRESSION = preload("res://scripts/data/progression_db.gd")
const ZONES = preload("res://scripts/data/zone_db.gd")
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
	var data: Dictionary = DB.get_monster(name)
	profile["player_hp"] = int(data["max_hp"])
	profile["quest_stage"] = 1
	STATE.set_player_tile(profile, STATE.START_TILE)
	_save_game()
	_show_world()

func _show_world() -> void:
	var starter_name: String = str(profile.get("starter", ""))
	if starter_name.is_empty():
		_show_starter_choice()
		return
	var screen: Control = WORLD_SCREEN.new()
	var quest_stage: int = int(profile.get("quest_stage", 0))
	screen.setup(
		starter_name,
		STATE.player_tile(profile),
		int(profile.get("trainer_level", 1)),
		bool(profile.get("haptics", true)),
		str(profile.get("zone_id", "vela")),
		PROGRESSION.quest_short(quest_stage)
	)
	screen.menu_requested.connect(_open_menu)
	screen.battle_requested.connect(_start_battle)
	screen.station_requested.connect(_on_station_requested)
	_switch_to(screen)

func _open_menu(tile: Vector2i) -> void:
	STATE.set_player_tile(profile, tile)
	var screen: Control = PAUSE_MENU.new()
	screen.setup(profile)
	screen.close_requested.connect(_show_world)
	screen.save_requested.connect(_on_save_requested.bind(screen))
	screen.haptics_changed.connect(_on_haptics_changed)
	screen.talent_spend_requested.connect(_on_talent_spend_requested.bind(screen))
	_switch_to(screen)

func _on_save_requested(menu_screen: Control) -> void:
	var ok: bool = _save_game()
	if is_instance_valid(menu_screen) and menu_screen.has_method("show_message"):
		menu_screen.show_message("Gra zapisana" if ok else "Błąd zapisu")

func _on_haptics_changed(value: bool) -> void:
	profile["haptics"] = value
	_save_game()

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
		str(profile["starter"]),
		int(profile.get("player_hp", _max_player_hp())),
		int(profile.get("trainer_level", 1)),
		enemy_name,
		int(encounter.get("level", 3)),
		profile.get("inventory", {}) as Dictionary,
		profile.get("talents", {}) as Dictionary
	)
	screen.finished.connect(_on_battle_finished)
	_switch_to(screen)

func _on_battle_finished(result: Dictionary) -> void:
	profile["player_hp"] = maxi(1, int(result.get("player_hp", profile.get("player_hp", 1))))
	var returned_inventory: Variant = result.get("inventory", {})
	if typeof(returned_inventory) == TYPE_DICTIONARY:
		profile["inventory"] = (returned_inventory as Dictionary).duplicate(true)
	var seen_name: String = str(result.get("seen_name", ""))
	if not seen_name.is_empty():
		STATE.add_seen(profile, seen_name)
	var captured_name: String = str(result.get("captured_name", ""))
	if not captured_name.is_empty():
		STATE.add_caught(profile, captured_name)
		if int(profile.get("quest_stage", 0)) <= 2:
			profile["quest_stage"] = 3
	profile["trainer_xp"] = maxi(0, int(profile.get("trainer_xp", 0)) + int(result.get("xp", 0)))
	_apply_level_ups()
	if str(result.get("outcome", "")) == "loss":
		STATE.set_player_tile(profile, STATE.START_TILE)
		profile["zone_id"] = "vela"
		profile["player_hp"] = _max_player_hp()
	_save_game()
	_show_world()

func _apply_level_ups() -> void:
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
	profile["player_hp"] = _max_player_hp()
	var stage: int = int(profile.get("quest_stage", 0))
	if stage >= 3:
		profile["quest_stage"] = 4
	var flags: Dictionary = profile.get("flags", {}) as Dictionary
	flags["vela_station_synced"] = true
	profile["flags"] = flags
	_save_game()

func _max_player_hp() -> int:
	var starter_name: String = str(profile.get("starter", "Luzik"))
	var data: Dictionary = DB.get_monster(starter_name)
	var talents: Dictionary = profile.get("talents", PROGRESSION.default_talents()) as Dictionary
	var bonuses: Dictionary = PROGRESSION.bonuses(talents)
	return int(data.get("max_hp", 28)) + int(bonuses.get("max_hp_bonus", 0))

func _save_game() -> bool:
	if str(profile.get("starter", "")).is_empty():
		return false
	profile["version"] = STATE.SAVE_VERSION
	return SAVE.save_game(profile)

func _load_game() -> void:
	var raw: Dictionary = SAVE.load_game()
	if raw.is_empty():
		_show_title("Brak prawidłowego zapisu gry")
		return
	profile = STATE.migrate(raw)
	var starter_name: String = str(profile.get("starter", "Luzik"))
	if not DB.has_monster(starter_name):
		starter_name = "Luzik"
		profile["starter"] = starter_name
	var max_hp: int = _max_player_hp()
	var stored_hp: int = int(profile.get("player_hp", max_hp))
	profile["player_hp"] = clampi(stored_hp if stored_hp > 0 else max_hp, 1, max_hp)
	if int(profile.get("quest_stage", 0)) == 0:
		profile["quest_stage"] = 1
	_save_game()
	_show_world()
