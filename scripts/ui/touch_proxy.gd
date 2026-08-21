extends Control

# Full-screen GUI input bridge for Android.
# Every gameplay screen is authored in SOMADEX's logical 360x800 canvas.
# Android can report a larger local GUI surface depending on stretch/aspect and
# device resolution, so taps must be mapped back to the target screen space.

const FALLBACK_CANVAS := Vector2(360.0, 800.0)
const DUPLICATE_MOUSE_GUARD_MS: int = 140

var target: Control
var _last_native_touch_ms: int = -1000

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
			_last_native_touch_ms = Time.get_ticks_msec()
			_forward_pressed(_map_to_target(touch.position))
			accept_event()
		return

	# Some Android/webview/device combinations reach GUI as an emulated mouse
	# press. Accept it as a fallback, but never execute the same physical tap twice.
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index == MOUSE_BUTTON_LEFT and mouse.pressed:
			if Time.get_ticks_msec() - _last_native_touch_ms <= DUPLICATE_MOUSE_GUARD_MS:
				accept_event()
				return
			_forward_pressed(_map_to_target(mouse.position))
			accept_event()

func _map_to_target(local_position: Vector2) -> Vector2:
	var source_size: Vector2 = size
	if source_size.x <= 0.0 or source_size.y <= 0.0:
		source_size = get_viewport_rect().size
	var target_size: Vector2 = FALLBACK_CANVAS
	if is_instance_valid(target) and target.size.x > 0.0 and target.size.y > 0.0:
		target_size = target.size
	return map_position(local_position, source_size, target_size)

static func map_position(local_position: Vector2, source_size: Vector2, target_size: Vector2 = FALLBACK_CANVAS) -> Vector2:
	if source_size.x <= 0.0 or source_size.y <= 0.0:
		return local_position
	return Vector2(
		local_position.x * target_size.x / source_size.x,
		local_position.y * target_size.y / source_size.y
	)

func _forward_pressed(mapped_position: Vector2) -> void:
	if not is_instance_valid(target):
		return
	if not target.has_method("_unhandled_input"):
		return
	var forwarded := InputEventScreenTouch.new()
	forwarded.index = 0
	forwarded.pressed = true
	forwarded.position = mapped_position
	target.call("_unhandled_input", forwarded)
