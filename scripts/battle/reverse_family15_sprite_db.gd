extends RefCounted

# Reverse visual-production pass: family 015 (Nucik -> Wibrospiew -> Rezonar).
# Seeds are drawn as deterministic transparent pixel art in-engine. This avoids
# transport corruption and gives every state real per-frame artwork instead of
# reusing a portrait texture.

const ACTIONS: Array[String] = ["idle", "attack", "hurt", "faint", "special"]
const ACTION_FRAME_COUNTS: Dictionary = {"idle":4, "attack":6, "hurt":3, "faint":5, "special":6}
const NAMES: Array[String] = ["Nucik", "Wibrospiew", "Rezonar"]

const OUTLINE := Color("1b142b")
const PURPLE_D := Color("432b67")
const PURPLE := Color("694497")
const PURPLE_L := Color("9867c8")
const GOLD_D := Color("916126")
const GOLD := Color("d99f48")
const GOLD_L := Color("ffd47a")
const CREAM := Color("ead9bd")
const WHITE := Color("fff7df")
const EYE := Color("0a0810")
const CYAN := Color("69dfff")
const MAGENTA := Color("e66cff")

static var _base_cache: Dictionary = {}
static var _frame_cache: Dictionary = {}

static func has_animation(creature_name: String) -> bool:
	return creature_name in NAMES

static func animation_count() -> int:
	return NAMES.size()

static func frame_count(action: String) -> int:
	return maxi(1, int(ACTION_FRAME_COUNTS.get(action, 1)))

static func frame_texture(creature_name: String, action: String, frame: int) -> Texture2D:
	if not has_animation(creature_name):
		return null
	if action not in ACTIONS:
		action = "idle"
	var safe_frame: int = clampi(frame, 0, frame_count(action) - 1)
	var key: String = "%s|%s|%d" % [creature_name, action, safe_frame]
	if _frame_cache.has(key):
		return _frame_cache[key] as Texture2D
	var base: Image = _base_image(creature_name)
	if base == null:
		return null
	var image: Image = _make_frame(base, action, safe_frame)
	var texture: Texture2D = ImageTexture.create_from_image(image)
	_frame_cache[key] = texture
	return texture

static func _base_image(creature_name: String) -> Image:
	if _base_cache.has(creature_name):
		return _base_cache[creature_name] as Image
	var image := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	match creature_name:
		"Nucik": _draw_nucik(image)
		"Wibrospiew": _draw_wibrospiew(image)
		"Rezonar": _draw_rezonar(image)
		_: return null
	image.resize(128, 128, Image.INTERPOLATE_NEAREST)
	_base_cache[creature_name] = image
	return image

static func _draw_nucik(image: Image) -> void:
	# Rounded owl-like resonance creature: violet body, gold chest resonator.
	_poly(image, [Vector2i(17,38),Vector2i(5,43),Vector2i(10,48),Vector2i(23,44),Vector2i(29,39)], PURPLE_D)
	_poly(image, [Vector2i(26,29),Vector2i(12,32),Vector2i(8,40),Vector2i(19,42),Vector2i(31,35)], PURPLE)
	_ellipse_outline(image, Rect2i(19,19,29,33), OUTLINE, PURPLE)
	_ellipse_outline(image, Rect2i(24,8,28,25), OUTLINE, PURPLE_L)
	_poly(image, [Vector2i(27,11),Vector2i(24,3),Vector2i(31,9)], PURPLE_D)
	_poly(image, [Vector2i(33,10),Vector2i(33,2),Vector2i(38,9)], PURPLE_D)
	_poly(image, [Vector2i(39,11),Vector2i(44,4),Vector2i(42,12)], PURPLE_D)
	_ellipse(image, Rect2i(37,13,10,10), WHITE)
	_ellipse(image, Rect2i(40,15,5,6), EYE)
	_set_block(image, 42, 16, WHITE, 0)
	_poly(image, [Vector2i(47,18),Vector2i(59,22),Vector2i(48,27)], GOLD)
	_ellipse(image, Rect2i(30,30,15,18), GOLD_D)
	_ellipse(image, Rect2i(33,32,9,13), GOLD_L)
	for x: int in [34,37,40]: _line(image, Vector2i(x,33), Vector2i(x,44), GOLD_D, 0)
	_line(image, Vector2i(27,48), Vector2i(25,56), GOLD_D, 1)
	_line(image, Vector2i(39,48), Vector2i(40,56), GOLD_D, 1)
	_line(image, Vector2i(22,57), Vector2i(28,57), GOLD, 0)
	_line(image, Vector2i(37,57), Vector2i(43,57), GOLD, 0)

static func _draw_wibrospiew(image: Image) -> void:
	# Long-eared dragon/seahorse evolution with broad sonic fins and curled tail.
	_poly(image, [Vector2i(27,24),Vector2i(11,17),Vector2i(4,24),Vector2i(18,33),Vector2i(31,29)], PURPLE_D)
	_poly(image, [Vector2i(40,24),Vector2i(56,19),Vector2i(62,27),Vector2i(48,34),Vector2i(38,30)], PURPLE_D)
	_ellipse_outline(image, Rect2i(23,23,22,27), OUTLINE, CREAM)
	_poly(image, [Vector2i(29,39),Vector2i(23,54),Vector2i(31,58),Vector2i(39,43)], PURPLE)
	_poly(image, [Vector2i(24,18),Vector2i(29,8),Vector2i(44,7),Vector2i(53,14),Vector2i(48,22),Vector2i(34,23)], PURPLE_L)
	_poly(image, [Vector2i(47,13),Vector2i(61,16),Vector2i(51,22),Vector2i(45,20)], CREAM)
	_ellipse(image, Rect2i(39,10,9,9), WHITE)
	_ellipse(image, Rect2i(42,12,4,5), EYE)
	_poly(image, [Vector2i(30,9),Vector2i(25,2),Vector2i(35,7)], GOLD)
	_poly(image, [Vector2i(36,8),Vector2i(36,1),Vector2i(41,7)], GOLD)
	_ellipse(image, Rect2i(31,28,14,16), GOLD_D)
	_ellipse(image, Rect2i(34,30,8,11), GOLD_L)
	_line(image, Vector2i(14,21), Vector2i(27,28), GOLD, 0)
	_line(image, Vector2i(53,23), Vector2i(40,29), GOLD, 0)
	# segmented curl tail
	_line(image, Vector2i(29,45), Vector2i(22,53), PURPLE_D, 2)
	_line(image, Vector2i(22,53), Vector2i(26,60), PURPLE_D, 2)
	_line(image, Vector2i(26,60), Vector2i(34,59), PURPLE_D, 2)

static func _draw_rezonar(image: Image) -> void:
	# Final form: large winged resonance dragon with gold wing ribs and chest core.
	_poly(image, [Vector2i(29,27),Vector2i(8,8),Vector2i(2,19),Vector2i(14,30),Vector2i(4,35),Vector2i(24,39),Vector2i(33,33)], PURPLE_D)
	_poly(image, [Vector2i(39,27),Vector2i(56,8),Vector2i(63,18),Vector2i(52,30),Vector2i(62,35),Vector2i(43,39),Vector2i(36,33)], PURPLE_D)
	_line(image, Vector2i(28,29), Vector2i(9,12), GOLD, 1)
	_line(image, Vector2i(28,33), Vector2i(8,22), GOLD, 1)
	_line(image, Vector2i(40,29), Vector2i(56,12), GOLD, 1)
	_line(image, Vector2i(40,33), Vector2i(57,23), GOLD, 1)
	_ellipse_outline(image, Rect2i(23,23,27,30), OUTLINE, PURPLE)
	_poly(image, [Vector2i(34,28),Vector2i(34,14),Vector2i(39,6),Vector2i(50,5),Vector2i(58,11),Vector2i(54,18),Vector2i(45,19),Vector2i(42,31)], PURPLE_L)
	_poly(image, [Vector2i(51,10),Vector2i(63,13),Vector2i(54,19),Vector2i(48,16)], PURPLE)
	_ellipse(image, Rect2i(46,8,8,8), WHITE)
	_ellipse(image, Rect2i(49,10,4,5), EYE)
	_poly(image, [Vector2i(39,8),Vector2i(35,1),Vector2i(43,6)], GOLD)
	_poly(image, [Vector2i(45,6),Vector2i(46,0),Vector2i(50,6)], GOLD)
	_poly(image, [Vector2i(51,8),Vector2i(57,2),Vector2i(54,10)], GOLD)
	_poly(image, [Vector2i(36,28),Vector2i(47,34),Vector2i(44,49),Vector2i(33,49),Vector2i(31,35)], GOLD_D)
	_ellipse(image, Rect2i(33,28,13,14), GOLD_D)
	_ellipse(image, Rect2i(36,30,7,9), GOLD_L)
	_poly(image, [Vector2i(29,46),Vector2i(24,58),Vector2i(31,61),Vector2i(37,49)], PURPLE_D)
	_poly(image, [Vector2i(42,46),Vector2i(40,58),Vector2i(49,60),Vector2i(48,49)], PURPLE_D)
	# tail curve represented by chunky connected segments
	_line(image, Vector2i(31,48), Vector2i(22,55), PURPLE_D, 2)
	_line(image, Vector2i(22,55), Vector2i(14,53), PURPLE_D, 2)
	_line(image, Vector2i(14,53), Vector2i(17,60), PURPLE_D, 2)

static func _make_frame(base: Image, action: String, frame: int) -> Image:
	match action:
		"idle":
			var ys: Array[int] = [0, -2, 0, 1]
			return _place(base, 0, ys[frame], 1.0, 1.0, 1.0)
		"attack":
			var dx: Array[int] = [0, 5, 12, 20, 10, 2]
			var dy: Array[int] = [0, -1, -4, -6, -2, 1]
			var result: Image = _place(base, dx[frame], dy[frame], 1.05 if frame in [2,3] else 1.0, 0.97 if frame == 3 else 1.0, 1.0)
			if frame in [2,3,4]: _draw_wave(result, 86 + int(dx[frame] / 2), frame)
			return result
		"hurt":
			var hx: Array[int] = [-6, 5, 1]
			var hurt: Image = _place(base, hx[frame], 2 if frame < 2 else 0, 0.98, 0.98, 1.0)
			_tint_red(hurt, 0.48 if frame < 2 else 0.18)
			return hurt
		"faint":
			var t: float = float(frame) / float(maxi(1, frame_count("faint") - 1))
			return _place(base, int(round(2.0 * t)), int(round(22.0 * t)), 1.0 + 0.08 * t, 1.0 - 0.55 * t, 1.0 - 0.75 * t)
		"special":
			var p: float = float(frame) / float(maxi(1, frame_count("special") - 1))
			var pulse: float = 1.0 + 0.08 * sin(p * PI)
			var special: Image = _place(base, 0, -int(round(3.0 * sin(p * PI))), pulse, pulse, 1.0)
			_draw_ring(special, 25 + int(round(16.0 * sin(p * PI))), MAGENTA)
			_draw_ring(special, 38 + int(round(18.0 * p)), CYAN)
			_draw_notes(special, frame)
			return special
	return base.duplicate()

static func _place(base: Image, dx: int, dy: int, sx: float, sy: float, alpha: float) -> Image:
	var transformed: Image = base.duplicate()
	var width: int = maxi(1, int(round(128.0 * sx)))
	var height: int = maxi(1, int(round(128.0 * sy)))
	if width != 128 or height != 128: transformed.resize(width, height, Image.INTERPOLATE_NEAREST)
	if alpha < 0.999: _multiply_alpha(transformed, alpha)
	var canvas := Image.create(128, 128, false, Image.FORMAT_RGBA8)
	canvas.fill(Color(0, 0, 0, 0))
	var target_x: int = int((128 - width) / 2) + dx
	var target_y: int = 128 - height + dy
	_blit_clipped(canvas, transformed, target_x, target_y)
	return canvas

static func _blit_clipped(canvas: Image, source: Image, target_x: int, target_y: int) -> void:
	var source_x: int = maxi(0, -target_x)
	var source_y: int = maxi(0, -target_y)
	var dest_x: int = maxi(0, target_x)
	var dest_y: int = maxi(0, target_y)
	var width: int = mini(source.get_width() - source_x, 128 - dest_x)
	var height: int = mini(source.get_height() - source_y, 128 - dest_y)
	if width > 0 and height > 0:
		canvas.blit_rect(source, Rect2i(source_x, source_y, width, height), Vector2i(dest_x, dest_y))

static func _multiply_alpha(image: Image, alpha: float) -> void:
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			var color: Color = image.get_pixel(x, y)
			if color.a > 0.0:
				color.a *= alpha
				image.set_pixel(x, y, color)

static func _tint_red(image: Image, strength: float) -> void:
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			var color: Color = image.get_pixel(x, y)
			if color.a > 0.0:
				color.r = lerpf(color.r, 1.0, strength)
				color.g = lerpf(color.g, 0.28, strength)
				color.b = lerpf(color.b, 0.28, strength)
				image.set_pixel(x, y, color)

static func _draw_wave(image: Image, center_x: int, phase: int) -> void:
	for radius: int in [18, 25, 32]:
		for degree: int in range(-65, 66, 10):
			var angle: float = deg_to_rad(float(degree))
			var x: int = center_x + int(round(cos(angle) * float(radius)))
			var y: int = 63 + int(round(sin(angle) * float(radius))) + (phase - 3) * 2
			_set_block(image, x, y, Color(0.40, 0.88, 1.0, 0.72), 1)

static func _draw_ring(image: Image, radius: int, color: Color) -> void:
	for degree: int in range(0, 360, 12):
		var angle: float = deg_to_rad(float(degree))
		var x: int = 64 + int(round(cos(angle) * float(radius)))
		var y: int = 64 + int(round(sin(angle) * float(radius)))
		_set_block(image, x, y, Color(color.r, color.g, color.b, 0.66), 1)

static func _draw_notes(image: Image, phase: int) -> void:
	var positions: Array[Vector2i] = [Vector2i(17,40),Vector2i(104,31),Vector2i(19,88),Vector2i(108,83)]
	for i: int in range(positions.size()):
		if (i + phase) % 2 != 0: continue
		var p: Vector2i = positions[i]
		p.y += int(round(sin(float(phase + i) * 1.5) * 5.0))
		_set_block(image, p.x, p.y + 3, GOLD_L, 1)
		_set_block(image, p.x, p.y + 7, GOLD_L, 2)
		_set_block(image, p.x + 4, p.y, GOLD_L, 1)

static func _set_block(image: Image, cx: int, cy: int, color: Color, radius: int) -> void:
	for y: int in range(cy - radius, cy + radius + 1):
		for x: int in range(cx - radius, cx + radius + 1):
			if x >= 0 and x < image.get_width() and y >= 0 and y < image.get_height(): image.set_pixel(x, y, color)

static func _ellipse_outline(image: Image, rect: Rect2i, outline: Color, fill: Color) -> void:
	_ellipse(image, rect, outline)
	var inner := Rect2i(rect.position + Vector2i(2,2), rect.size - Vector2i(4,4))
	if inner.size.x > 0 and inner.size.y > 0: _ellipse(image, inner, fill)

static func _ellipse(image: Image, rect: Rect2i, color: Color) -> void:
	var rx: float = maxf(0.5, float(rect.size.x) * 0.5)
	var ry: float = maxf(0.5, float(rect.size.y) * 0.5)
	var cx: float = float(rect.position.x) + rx
	var cy: float = float(rect.position.y) + ry
	for y: int in range(rect.position.y, rect.end.y):
		for x: int in range(rect.position.x, rect.end.x):
			if x < 0 or x >= image.get_width() or y < 0 or y >= image.get_height(): continue
			var dx: float = (float(x) + 0.5 - cx) / rx
			var dy: float = (float(y) + 0.5 - cy) / ry
			if dx * dx + dy * dy <= 1.0: image.set_pixel(x, y, color)

static func _poly(image: Image, points: Array[Vector2i], color: Color) -> void:
	if points.size() < 3: return
	var min_x: int = points[0].x
	var max_x: int = points[0].x
	var min_y: int = points[0].y
	var max_y: int = points[0].y
	for p: Vector2i in points:
		min_x = mini(min_x, p.x); max_x = maxi(max_x, p.x)
		min_y = mini(min_y, p.y); max_y = maxi(max_y, p.y)
	for y: int in range(min_y, max_y + 1):
		for x: int in range(min_x, max_x + 1):
			if x >= 0 and x < image.get_width() and y >= 0 and y < image.get_height() and _inside(Vector2(float(x) + 0.5, float(y) + 0.5), points): image.set_pixel(x, y, color)

static func _inside(point: Vector2, points: Array[Vector2i]) -> bool:
	var inside: bool = false
	var j: int = points.size() - 1
	for i: int in range(points.size()):
		var pi: Vector2i = points[i]
		var pj: Vector2i = points[j]
		if (pi.y > point.y) != (pj.y > point.y):
			var cross_x: float = float(pj.x - pi.x) * (point.y - float(pi.y)) / float(pj.y - pi.y) + float(pi.x)
			if point.x < cross_x: inside = not inside
		j = i
	return inside

static func _line(image: Image, a: Vector2i, b: Vector2i, color: Color, radius: int) -> void:
	var steps: int = maxi(abs(b.x - a.x), abs(b.y - a.y))
	if steps <= 0:
		_set_block(image, a.x, a.y, color, radius)
		return
	for i: int in range(steps + 1):
		var t: float = float(i) / float(steps)
		var x: int = int(round(lerpf(float(a.x), float(b.x), t)))
		var y: int = int(round(lerpf(float(a.y), float(b.y), t)))
		_set_block(image, x, y, color, radius)
