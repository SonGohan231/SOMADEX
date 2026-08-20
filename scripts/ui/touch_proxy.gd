extends Control

# Full-screen GUI input bridge for Android.
# Godot delivers _gui_input coordinates in the receiving Control's local space,
# so this normalizes taps before forwarding them to legacy screen handlers that
# were written against the 360x800 SOMADEX design canvas.

var target: Control

func setup(screen: Control) -> void:
	target = screen

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_NONE

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			_forward_pressed(touch.position)
			accept_event()
	elif event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index == MOUSE_BUTTON_LEFT and mouse.pressed:
			_forward_pressed(mouse.position)
			accept_event()

func _forward_pressed(local_position: Vector2) -> void:
	if not is_instance_valid(target):
		return
	if not target.has_method("_unhandled_input"):
		return
	var forwarded := InputEventScreenTouch.new()
	forwarded.index = 0
	forwarded.pressed = true
	forwarded.position = local_position
	target.call("_unhandled_input", forwarded)
