extends "res://scripts/game.gd"

const EVOLUTION_SCREEN = preload("res://scripts/ui/evolution_screen.gd")

var _pending_evolutions: Array = []
var _presenting_evolution: bool = false

func _on_battle_finished(result: Dictionary) -> void:
	super._on_battle_finished(result)
	if str(result.get("outcome", "")) == "loss":
		return
	var raw_events: Variant = profile.get("last_evolutions", [])
	if typeof(raw_events) != TYPE_ARRAY:
		return
	var events: Array = raw_events as Array
	if events.is_empty():
		return
	_pending_evolutions = events.duplicate(true)
	profile["last_evolutions"] = []
	_presenting_evolution = true
	_show_next_evolution()

func _show_next_evolution() -> void:
	if _pending_evolutions.is_empty():
		_presenting_evolution = false
		_save_game()
		_show_world()
		return
	var raw_event: Variant = _pending_evolutions.pop_front()
	if typeof(raw_event) != TYPE_DICTIONARY:
		_show_next_evolution()
		return
	var screen: Control = EVOLUTION_SCREEN.new()
	screen.setup((raw_event as Dictionary).duplicate(true))
	screen.finished.connect(_on_evolution_screen_finished)
	_switch_to(screen)

func _on_evolution_screen_finished() -> void:
	_show_next_evolution()
