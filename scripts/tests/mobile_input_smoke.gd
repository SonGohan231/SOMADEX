extends SceneTree

const TITLE_SCREEN = preload("res://scripts/ui/title_screen.gd")

var new_game_called: bool = false

func _initialize() -> void:
	var errors: Array[String] = []
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
	if errors.is_empty():
		print("MOBILE_INPUT_SMOKE: PASS")
		quit(0)
		return
	for error_text: String in errors:
		printerr("MOBILE_INPUT_SMOKE: " + error_text)
	quit(1)

func _on_new_game() -> void:
	new_game_called = true

func _expect(condition: bool, message: String, errors: Array[String]) -> void:
	if not condition:
		errors.append(message)
