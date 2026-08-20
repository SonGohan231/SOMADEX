extends SceneTree

const GAME_ANIMATIONS = preload("res://scripts/game_animations.gd")
const EVOLUTION_SCREEN = preload("res://scripts/ui/evolution_screen.gd")
const STATE = preload("res://scripts/core/game_state.gd")
const RULES = preload("res://scripts/battle/battle_rules.gd")

var _finished_count: int = 0

func _initialize() -> void:
	var errors: Array[String] = []
	_test_main_scene_controller(errors)
	_test_evolution_event_source(errors)
	_test_touch_completion(errors)
	if errors.is_empty():
		print("EVOLUTION_PRESENTATION_SMOKE: PASS")
		quit(0)
		return
	for error_text: String in errors:
		printerr("EVOLUTION_PRESENTATION_SMOKE: " + error_text)
	quit(1)

func _test_main_scene_controller(errors: Array[String]) -> void:
	var packed: PackedScene = load("res://scenes/Main.tscn") as PackedScene
	_expect(packed != null, "Main.tscn cannot be loaded", errors)
	if packed == null:
		return
	var node: Node = packed.instantiate()
	_expect(node.get_script() == GAME_ANIMATIONS, "Main.tscn does not use the evolution-aware animation controller", errors)
	node.free()

func _test_evolution_event_source(errors: Array[String]) -> void:
	var profile: Dictionary = STATE.new_profile("Luzik")
	var party: Array = profile.get("party", []) as Array
	var member: Dictionary = party[0] as Dictionary
	member["level"] = 11
	member["xp"] = 0
	member["hp"] = STATE.base_member_max_hp(member)
	party[0] = member
	profile["party"] = party
	STATE.add_member_exp(profile, 0, RULES.creature_xp_to_next(11))
	var events: Array = profile.get("last_evolutions", []) as Array
	_expect(events.size() == 1, "level progression did not create an evolution presentation event", errors)
	if events.size() == 1:
		var event: Dictionary = events[0] as Dictionary
		_expect(str(event.get("from", "")) == "Luzik", "presentation event has wrong source form", errors)
		_expect(str(event.get("to", "")) == "Warstwin", "presentation event has wrong target form", errors)

func _test_touch_completion(errors: Array[String]) -> void:
	var screen: Control = EVOLUTION_SCREEN.new()
	screen.setup({"uid":"luzik-0001","from":"Luzik","to":"Warstwin","level":12})
	screen.finished.connect(_on_finished)
	screen.elapsed = 1.0
	var touch: InputEventScreenTouch = InputEventScreenTouch.new()
	touch.pressed = true
	touch.position = Vector2(180, 752)
	screen._unhandled_input(touch)
	_expect(_finished_count == 1, "touch did not complete the evolution screen", errors)
	_expect(screen.accepted, "evolution screen did not lock after acceptance", errors)
	screen.free()

func _on_finished() -> void:
	_finished_count += 1

func _expect(condition: bool, message: String, errors: Array[String]) -> void:
	if not condition:
		errors.append(message)
