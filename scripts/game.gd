extends Control

const SAVE = preload("res://scripts/core/save_manager.gd")
const DB = preload("res://scripts/data/monster_db.gd")
const TITLE_SCREEN = preload("res://scripts/ui/title_screen.gd")
const INTRO_SCREEN = preload("res://scripts/ui/intro_screen.gd")
const STARTER_SCREEN = preload("res://scripts/ui/starter_screen.gd")
const WORLD_SCREEN = preload("res://scripts/world/world_screen.gd")
const PAUSE_MENU = preload("res://scripts/ui/pause_menu.gd")
const BATTLE_SCREEN = preload("res://scripts/battle/battle_screen.gd")

var current_screen: Control
var world_tile := Vector2i(7,20)
var starter := ""
var player_hp := 28
var trainer_level := 1
var trainer_xp := 0
var discovered := 0
var haptics := true

func _ready() -> void:
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
	var screen = TITLE_SCREEN.new()
	screen.setup(SAVE.has_save(),message)
	screen.new_game_requested.connect(_start_new_game)
	screen.load_requested.connect(_load_game)
	_switch_to(screen)

func _start_new_game() -> void:
	starter = ""
	player_hp = 28
	trainer_level = 1
	trainer_xp = 0
	discovered = 0
	world_tile = Vector2i(7,20)
	haptics = true
	var screen = INTRO_SCREEN.new()
	screen.finished.connect(_show_starter_choice)
	_switch_to(screen)

func _show_starter_choice() -> void:
	var screen = STARTER_SCREEN.new()
	screen.starter_chosen.connect(_on_starter_chosen)
	_switch_to(screen)

func _on_starter_chosen(name: String) -> void:
	starter = name
	var data := DB.get_monster(starter)
	player_hp = int(data["max_hp"])
	discovered = 1
	world_tile = Vector2i(7,20)
	_save_game()
	_show_world()

func _show_world() -> void:
	if starter.is_empty():
		_show_starter_choice()
		return
	var screen = WORLD_SCREEN.new()
	screen.setup(starter,world_tile,trainer_level,haptics)
	screen.menu_requested.connect(_open_menu)
	screen.battle_requested.connect(_start_battle)
	_switch_to(screen)

func _open_menu(tile: Vector2i) -> void:
	world_tile = tile
	var screen = PAUSE_MENU.new()
	screen.setup(starter,trainer_level,trainer_xp,discovered,haptics)
	screen.close_requested.connect(_show_world)
	screen.save_requested.connect(_on_save_requested.bind(screen))
	screen.haptics_changed.connect(_on_haptics_changed)
	_switch_to(screen)

func _on_save_requested(menu_screen: Control) -> void:
	var ok := _save_game()
	if is_instance_valid(menu_screen) and menu_screen.has_method("show_message"):
		menu_screen.show_message("Gra zapisana" if ok else "Błąd zapisu")

func _on_haptics_changed(value: bool) -> void:
	haptics = value

func _start_battle(tile: Vector2i) -> void:
	world_tile = tile
	var screen = BATTLE_SCREEN.new()
	screen.setup(starter,player_hp,trainer_level)
	screen.finished.connect(_on_battle_finished)
	_switch_to(screen)

func _on_battle_finished(result: Dictionary) -> void:
	player_hp = int(result.get("player_hp",player_hp))
	trainer_xp += int(result.get("xp",0))
	if int(result.get("discovered_delta",0)) > 0:
		discovered = max(discovered,2)
	while trainer_xp >= _xp_to_next_level():
		trainer_xp -= _xp_to_next_level()
		trainer_level += 1
	if str(result.get("outcome","")) == "loss":
		world_tile = Vector2i(7,20)
		player_hp = int(DB.get_monster(starter)["max_hp"])
	_save_game()
	_show_world()

func _xp_to_next_level() -> int:
	return 18 + trainer_level * 7

func _save_game() -> bool:
	if starter.is_empty():
		return false
	return SAVE.save_game({
		"version":2,
		"starter":starter,
		"player_x":world_tile.x,
		"player_y":world_tile.y,
		"player_hp":player_hp,
		"trainer_level":trainer_level,
		"trainer_xp":trainer_xp,
		"discovered":discovered,
		"haptics":haptics
	})

func _load_game() -> void:
	var data := SAVE.load_game()
	if data.is_empty():
		_show_title("Brak prawidłowego zapisu gry")
		return
	starter = str(data.get("starter","Luzik"))
	var monster := DB.get_monster(starter)
	world_tile = Vector2i(int(data.get("player_x",7)),int(data.get("player_y",20)))
	player_hp = clamp(int(data.get("player_hp",int(monster["max_hp"]))),1,int(monster["max_hp"]))
	trainer_level = max(1,int(data.get("trainer_level",1)))
	trainer_xp = max(0,int(data.get("trainer_xp",0)))
	discovered = max(1,int(data.get("discovered",1)))
	haptics = bool(data.get("haptics",true))
	_show_world()
