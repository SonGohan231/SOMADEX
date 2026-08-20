extends "res://scripts/game_alpha.gd"

const ART_STATE = preload("res://scripts/core/game_state.gd")
const ART_PAUSE_MENU = preload("res://scripts/ui/alpha1_pause_menu_art.gd")

func _open_menu(tile: Vector2i) -> void:
	ART_STATE.set_player_tile(profile, tile)
	var screen: Control = ART_PAUSE_MENU.new()
	screen.setup(profile)
	screen.close_requested.connect(_show_world)
	screen.save_requested.connect(_on_save_requested.bind(screen))
	screen.haptics_changed.connect(_on_haptics_changed)
	screen.talent_spend_requested.connect(_on_talent_spend_requested.bind(screen))
	screen.equipment_cycle_requested.connect(_on_equipment_cycle_requested.bind(screen))
	screen.active_member_requested.connect(_on_active_member_requested.bind(screen))
	_switch_to(screen)
