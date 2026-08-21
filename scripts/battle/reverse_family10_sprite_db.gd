extends RefCounted

# Reverse visual-production pass: family 010 (Nasuch -> Echouszek -> Sensoryks).
# Transparent 64px pixel seeds are drawn deterministically and expanded to
# 128x128 battle frames. Every action owns distinct frames.

const ACTIONS: Array[String] = ["idle", "attack", "hurt", "faint", "special"]
const ACTION_FRAME_COUNTS: Dictionary = {"idle":4, "attack":6, "hurt":3, "faint":5, "special":6}
const NAMES: Array[String] = ["Nasuch", "Echouszek", "Sensoryks"]

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
		"Nasuch": _draw_nasuch(image)
		"Echouszek": _draw_echouszek(image)
		"Sensoryks": _draw_sensoryks(image)
		_: return null
	image.resize(128, 128, Image.INTERPOLATE_NEAREST)
	_base_cache[creature_name] = image
	return image

static func _draw_nasuch(image: Image) -> void:
	# Compact owl/bat-like listener with oversized cream sensory fins.
	_poly(image, [Vector2i(26,23),Vector2i(11,9),Vector2i(2,15),Vector2i(8,30),Vector2i(21,34)], CREAM)
	_poly(image, [Vector2i(39,23),Vector2i(54,9),Vector2i(62,15),Vector2i(56,30),Vector2i(43,34)], CREAM)
	_line(image, Vector2i(10,12), Vector2i(22,30), GOLD, 1)
	_line(image, Vector2i(54,12), Vector2i(42,30), GOLD, 1)
	_ellipse_outline(image, Rect2i(20,25,27,30), OUTLINE, PURPLE)
	_ellipse_outline(image, Rect2i(22,15,23,22), OUTLINE, PURPLE_L)
	_poly(image, [Vector2i(27,18),Vector2i(27,10),Vector2i(31,17)], GOLD)
	_poly(image, [Vector2i(37,18),Vector2i(39,10),Vector2i(41,19)], GOLD)
	_ellipse(image, Rect2i(34,20,7,7), WHITE)
	_ellipse(image, Rect2i(36,21,4,5), EYE)
	_poly(image, [Vector2i(32,16),Vector2i(35,19),Vector2i(32,22),Vector2i(29,19)], CYAN)
	_ellipse(image, Rect2i(26,33,15,18), CREAM)
	_ellipse(image, Rect2i(30,34,9,10), GOLD_D)
	_ellipse(image, Rect2i(32,35,5,7), CYAN)
	_poly(image, [Vector2i(22,37),Vector2i(13,43),Vector2i(21,46),Vector2i(27,42)], PURPLE_D)
	_poly(image, [Vector2i(43,37),Vector2i(51,43),Vector2i(43,46),Vector2i(38,42)], PURPLE_D)
	_line(image, Vector2i(27,50), Vector2i(25,58), GOLD_D, 1)
	_line(image, Vector2i(38,50), Vector2i(40,58), GOLD_D, 1)

static func _draw_echouszek(image: Image) -> void:
	# Mid evolution: broad echo fins, longer body and a stronger sensor core.
	_poly(image, [Vector2i(27,26),Vector2i(10,5),Vector2i(2,13),Vector2i(8,29),Vector2i(21,37)], CREAM)
	_poly(image, [Vector2i(39,26),Vector2i(55,5),Vector2i(63,14),Vector2i(56,30),Vector2i(45,37)], CREAM)
	_poly(image, [Vector2i(23,27),Vector2i(11,12),Vector2i(8,17),Vector2i(13,28),Vector2i(22,33)], PURPLE_D)
	_poly(image, [Vector2i(43,27),Vector2i(53,12),Vector2i(57,17),Vector2i(52,29),Vector2i(44,33)], PURPLE_D)
	_ellipse_outline(image, Rect2i(20,29,31,22), OUTLINE, PURPLE)
	_ellipse_outline(image, Rect2i(22,15,25,20), OUTLINE, PURPLE_L)
	_poly(image, [Vector2i(42,22),Vector2i(57,24),Vector2i(48,30),Vector2i(42,29)], CREAM)
	_ellipse(image, Rect2i(37,19,7,7), WHITE)
	_ellipse(image, Rect2i(39,20,4,5), EYE)
	_poly(image, [Vector2i(27,17),Vector2i(25,8),Vector2i(31,16)], GOLD)
	_poly(image, [Vector2i(34,16),Vector2i(36,7),Vector2i(39,17)], GOLD)
	_poly(image, [Vector2i(33,15),Vector2i(36,18),Vector2i(33,21),Vector2i(30,18)], CYAN)
	_ellipse(image, Rect2i(30,31,14,15), GOLD_D)
	_ellipse(image, Rect2i(33,33,8,10), CYAN)
	_poly(image, [Vector2i(23,43),Vector2i(18,57),Vector2i(27,58),Vector2i(31,47)], PURPLE_D)
	_poly(image, [Vector2i(41,43),Vector2i(40,57),Vector2i(49,58),Vector2i(47,47)], PURPLE_D)
	_line(image, Vector2i(24,45), Vector2i(12,50), PURPLE_D, 2)
	_line(image, Vector2i(12,50), Vector2i(8,43), PURPLE_D, 2)

static func _draw_sensoryks(image: Image) -> void:
	# Final sensory dragon: aerodynamic ear-wings, gold ribs and cyan signal core.
	_poly(image, [Vector2i(28,29),Vector2i(8,3),Vector2i(1,14),Vector2i(11,31),Vector2i(23,40)], CREAM)
	_poly(image, [Vector2i(40,29),Vector2i(57,3),Vector2i(63,14),Vector2i(55,31),Vector2i(45,40)], CREAM)
	_poly(image, [Vector2i(25,29),Vector2i(10,10),Vector2i(7,16),Vector2i(14,29),Vector2i(24,35)], PURPLE_D)
	_poly(image, [Vector2i(43,29),Vector2i(55,10),Vector2i(58,16),Vector2i(52,30),Vector2i(44,35)], PURPLE_D)
	_line(image, Vector2i(12,9), Vector2i(25,30), GOLD, 1)
	_line(image, Vector2i(55,9), Vector2i(43,30), GOLD, 1)
	_ellipse_outline(image, Rect2i(22,26,29,27), OUTLINE, PURPLE)
	_poly(image, [Vector2i(34,30),Vector2i(33,14),Vector2i(39,6),Vector2i(50,6),Vector2i(58,12),Vector2i(54,20),Vector2i(45,21),Vector2i(42,32)], PURPLE_L)
	_poly(image, [Vector2i(50,12),Vector2i(63,15),Vector2i(54,21),Vector2i(48,19)], CREAM)
	_poly(image, [Vector2i(40,8),Vector2i(37,1),Vector2i(44,6)], GOLD)
	_poly(image, [Vector2i(47,7),Vector2i(48,0),Vector2i(52,7)], GOLD)
	_ellipse(image, Rect2i(46,9,8,8), WHITE)
	_ellipse(image, Rect2i(49,11,4,5), EYE)
	_poly(image, [Vector2i(43,10),Vector2i(46,13),Vector2i(43,16),Vector2i(40,13)], CYAN)
	_poly(image, [Vector2i(34,29),Vector2i(47,35),Vector2i(44,50),Vector2i(32,50),Vector2i(30,36)], GOLD_D)
	_ellipse(image, Rect2i(34,30,12,14), CYAN)
	_poly(image, [Vector2i(28,46),Vector2i(23,59),Vector2i(31,61),Vector2i(37,49)], PURPLE_D)
	_poly(image, [Vector2i(43,46),Vector2i(40,59),Vector2i(49,60),Vector2i(48,49)], PURPLE_D)
	_line(image, Vector2i(27,47), Vector2i(18,54), PURPLE_D, 2)
	_line(image, Vector2i(18,54), Vector2i(7,52), PURPLE_D, 2)
	_line(image, Vector2i(7,52), Vector2i(4,44), PURPLE_D, 2)

static func _make_frame(base: Image, action: String, frame: int) -> Image:
	match action:
		"idle":
			var ys: Array[int] = [0,-2,0,1]
			return _place(base, 0, ys[frame], 1.0, 1.0, 1.0)
		"attack":
			var dx: Array[int] = [0,5,12,20,10,2]
			var dy: Array[int] = [0,-1,-4,-6,-2,1]
			var result: Image = _place(base, dx[frame], dy[frame], 1.05 if frame in [2,3] else 1.0, 0.97 if frame == 3 else 1.0, 1.0)
			if frame in [2,3,4]: _draw_wave(result, 86 + int(dx[frame] / 2), frame)
			return result
		"hurt":
			var hx: Array[int] = [-6,5,1]
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
			_draw_ring(special, 25 + int(round(15.0 * sin(p * PI))), MAGENTA)
			_draw_ring(special, 37 + int(round(18.0 * p)), CYAN)
			_draw_sensor_pings(special, frame)
			return special
	return base.duplicate()

static func _place(base: Image, dx: int, dy: int, sx: float, sy: float, alpha: float) -> Image:
	var transformed: Image = base.duplicate()
	var width: int = maxi(1, int(round(128.0 * sx)))
	var height: int = maxi(1, int(round(128.0 * sy)))
	if width != 128 or height != 128: transformed.resize(width, height, Image.INTERPOLATE_NEAREST)
	if alpha < 0.999: _multiply_alpha(transformed, alpha)
	var canvas := Image.create(128, 128, false, Image.FORMAT_RGBA8)
	canvas.fill(Color(0,0,0,0))
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
	if width > 0 and height > 0: canvas.blit_rect(source, Rect2i(source_x, source_y, width, height), Vector2i(dest_x, dest_y))

static func _multiply_alpha(image: Image, alpha: float) -> void:
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			var color: Color = image.get_pixel(x,y)
			if color.a > 0.0:
				color.a *= alpha
				image.set_pixel(x,y,color)

static func _tint_red(image: Image, strength: float) -> void:
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			var color: Color = image.get_pixel(x,y)
			if color.a > 0.0:
				color.r = lerpf(color.r,1.0,strength)
				color.g = lerpf(color.g,0.28,strength)
				color.b = lerpf(color.b,0.28,strength)
				image.set_pixel(x,y,color)

static func _draw_wave(image: Image, center_x: int, phase: int) -> void:
	for radius: int in [18,25,32]:
		for degree: int in range(-65,66,10):
			var angle: float = deg_to_rad(float(degree))
			var x: int = center_x + int(round(cos(angle) * float(radius)))
			var y: int = 63 + int(round(sin(angle) * float(radius))) + (phase - 3) * 2
			_set_block(image,x,y,Color(0.40,0.88,1.0,0.72),1)

static func _draw_ring(image: Image, radius: int, color: Color) -> void:
	for degree: int in range(0,360,12):
		var angle: float = deg_to_rad(float(degree))
		_set_block(image,64 + int(round(cos(angle) * float(radius))),64 + int(round(sin(angle) * float(radius))),Color(color.r,color.g,color.b,0.66),1)

static func _draw_sensor_pings(image: Image, phase: int) -> void:
	var positions: Array[Vector2i] = [Vector2i(15,38),Vector2i(109,34),Vector2i(19,90),Vector2i(106,92)]
	for i: int in range(positions.size()):
		if (i + phase) % 2 != 0: continue
		var p: Vector2i = positions[i]
		var radius: int = 3 + ((phase + i) % 3)
		for degree: int in range(215,326,18):
			var angle: float = deg_to_rad(float(degree))
			_set_block(image,p.x + int(round(cos(angle) * float(radius * 3))),p.y + int(round(sin(angle) * float(radius * 3))),CYAN,1)
		_set_block(image,p.x,p.y,GOLD_L,1)

static func _set_block(image: Image, cx: int, cy: int, color: Color, radius: int) -> void:
	for y: int in range(cy-radius,cy+radius+1):
		for x: int in range(cx-radius,cx+radius+1):
			if x >= 0 and x < image.get_width() and y >= 0 and y < image.get_height(): image.set_pixel(x,y,color)

static func _ellipse_outline(image: Image, rect: Rect2i, outline: Color, fill: Color) -> void:
	_ellipse(image,rect,outline)
	var inner := Rect2i(rect.position + Vector2i(2,2), rect.size - Vector2i(4,4))
	if inner.size.x > 0 and inner.size.y > 0: _ellipse(image,inner,fill)

static func _ellipse(image: Image, rect: Rect2i, color: Color) -> void:
	var rx: float = maxf(0.5,float(rect.size.x) * 0.5)
	var ry: float = maxf(0.5,float(rect.size.y) * 0.5)
	var cx: float = float(rect.position.x) + rx
	var cy: float = float(rect.position.y) + ry
	for y: int in range(rect.position.y,rect.end.y):
		for x: int in range(rect.position.x,rect.end.x):
			if x < 0 or x >= image.get_width() or y < 0 or y >= image.get_height(): continue
			var px: float = (float(x) + 0.5 - cx) / rx
			var py: float = (float(y) + 0.5 - cy) / ry
			if px * px + py * py <= 1.0: image.set_pixel(x,y,color)

static func _poly(image: Image, points: Array[Vector2i], color: Color) -> void:
	if points.size() < 3: return
	var min_x: int = points[0].x; var max_x: int = points[0].x
	var min_y: int = points[0].y; var max_y: int = points[0].y
	for p: Vector2i in points:
		min_x = mini(min_x,p.x); max_x = maxi(max_x,p.x)
		min_y = mini(min_y,p.y); max_y = maxi(max_y,p.y)
	for y: int in range(min_y,max_y+1):
		for x: int in range(min_x,max_x+1):
			if x >= 0 and x < image.get_width() and y >= 0 and y < image.get_height() and _inside(Vector2(float(x)+0.5,float(y)+0.5),points): image.set_pixel(x,y,color)

static func _inside(point: Vector2, points: Array[Vector2i]) -> bool:
	var inside: bool = false
	var j: int = points.size() - 1
	for i: int in range(points.size()):
		var pi: Vector2i = points[i]; var pj: Vector2i = points[j]
		if (pi.y > point.y) != (pj.y > point.y):
			var cross_x: float = float(pj.x - pi.x) * (point.y - float(pi.y)) / float(pj.y - pi.y) + float(pi.x)
			if point.x < cross_x: inside = not inside
		j = i
	return inside

static func _line(image: Image, a: Vector2i, b: Vector2i, color: Color, radius: int) -> void:
	var steps: int = maxi(abs(b.x-a.x),abs(b.y-a.y))
	if steps <= 0:
		_set_block(image,a.x,a.y,color,radius)
		return
	for i: int in range(steps+1):
		var t: float = float(i) / float(steps)
		_set_block(image,int(round(lerpf(float(a.x),float(b.x),t))),int(round(lerpf(float(a.y),float(b.y),t))),color,radius)
