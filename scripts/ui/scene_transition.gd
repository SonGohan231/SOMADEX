extends Control

var progress: float = 0.0
var duration: float = 0.28
var active: bool = false

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 900

func play_in(custom_duration: float = 0.28) -> void:
	duration = clampf(custom_duration, 0.12, 0.65)
	progress = 0.0
	active = true
	visible = true
	queue_redraw()
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_method(_set_progress, 0.0, 1.0, duration)
	tween.finished.connect(_finish)

func _set_progress(value: float) -> void:
	progress = clampf(value, 0.0, 1.0)
	queue_redraw()

func _finish() -> void:
	progress = 1.0
	active = false
	visible = false
	queue_redraw()

func _draw() -> void:
	if not active and progress >= 1.0:
		return
	var size: Vector2 = get_size()
	if size.x <= 0.0 or size.y <= 0.0:
		size = Vector2(360, 800)
	var cover: float = 1.0 - progress
	var alpha: float = clampf(cover * 1.12, 0.0, 1.0)
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.015, 0.035, 0.045, alpha))
	var reveal_y: float = size.y * progress
	for y: int in range(0, int(size.y), 8):
		if float(y) > reveal_y + 48.0:
			continue
		var line_alpha: float = 0.20 * cover * clampf(1.0 - abs(float(y) - reveal_y) / 64.0, 0.0, 1.0)
		if line_alpha > 0.001:
			draw_line(Vector2(0, y), Vector2(size.x, y), Color(0.38, 0.94, 0.88, line_alpha), 1.0)
	var band_y: float = clampf(reveal_y - 2.0, 0.0, size.y)
	draw_rect(Rect2(0, band_y, size.x, 3), Color(0.50, 1.0, 0.92, 0.18 * cover))
