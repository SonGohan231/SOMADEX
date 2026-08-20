extends SceneTree

const TITLE_SCREEN = preload("res://scripts/ui/title_screen.gd")
const INTRO_SCREEN = preload("res://scripts/ui/intro_screen.gd")
const STARTER_SCREEN = preload("res://scripts/ui/starter_screen.gd")
const TOUCH_PROXY = preload("res://scripts/ui/touch_proxy.gd")

var new_game_called: bool = false
var starter_called: bool = false

func _initialize() -> void:
	var errors: Array[String] = []
	_test_title_buttons(errors)
	_test_proxy_intro(errors)
	_test_proxy_starter(errors)
	if errors.is_empty():
		print("MOBILE_INPUT_SMOKE: PASS")
		quit(0)
		return
	for error_text: String in errors:
		printerr("MOBILE_INPUT_SMOKE: " + error_text)
	quit(1)

func _test_title_buttons(errors: Array[String]) -> void:
	var title: Control = TITLE_SCREEN.new()
	title.setup(false)
	title.new_game_requested.connect(_on_new_game)
	get_root().add_child(title)
	_expect(title.touch_buttons.size() == 3, "title screen must expose three real touch buttons", errors)
	if title.touch_buttons.size() == 3:
		for i: int in range(3):
			var button: Button = title.touch_buttons[i]
			_expect(button.mouse_filter == Control.MOUSE_FILTER_STOP, "touch button %d does not capture GUI touch" % i, errors)
			_expect(button.size.x >= 260.0 and button.size.y >= 50.0, "touch button %d hit target is too small" % i, errors)
		title.touch_buttons[0].emit_signal("pressed")
		_expect(new_game_called, "touch button press is not wired to New Game", errors)
	title.queue_free()

func _test_proxy_intro(errors: Array[String]) -> void:
	var intro: Control = INTRO_SCREEN.new()
	get_root().add_child(intro)
	var proxy: Control = TOUCH_PROXY.new()
	proxy.setup(intro)
	intro.add_child(proxy)
	var page_before: int = intro.page
	proxy._forward_pressed(Vector2(180, 695))
	_expect(intro.page == page_before + 1, "touch proxy did not advance intro in design coordinates", errors)
	intro.queue_free()

func _test_proxy_starter(errors: Array[String]) -> void:
	var starter: Control = STARTER_SCREEN.new()
	starter.starter_chosen.connect(_on_starter)
	get_root().add_child(starter)
	var proxy: Control = TOUCH_PROXY.new()
	proxy.setup(starter)
	starter.add_child(proxy)
	proxy._forward_pressed(Vector2(180, 400))
	_expect(starter.selected == 1, "touch proxy did not select the second starter card", errors)
	proxy._forward_pressed(Vector2(180, 715))
	_expect(starter_called, "touch proxy did not activate starter confirmation", errors)
	starter.queue_free()

func _on_new_game() -> void:
	new_game_called = true

func _on_starter(_name: String) -> void:
	starter_called = true

func _expect(condition: bool, message: String, errors: Array[String]) -> void:
	if not condition:
		errors.append(message)
