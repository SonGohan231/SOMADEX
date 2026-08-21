extends RefCounted

# Reverse visual-production pass: family 009 (Kotwiczek -> Bramnik -> Fundamentor).
# The approved source cards define a rocky coastal stabilizer line: compact
# anchor-crab -> plated gate guardian -> bridge-sized anchor titan.
# Each form is redrawn as a transparent 64px pixel seed and expanded nearest-
# neighbour to the battle contract 128x128. Every action owns distinct frames.

const ACTIONS: Array[String] = ["idle", "attack", "hurt", "faint", "special"]
const ACTION_FRAME_COUNTS: Dictionary = {"idle":4, "attack":6, "hurt":3, "faint":5, "special":6}
const NAMES: Array[String] = ["Kotwiczek", "Bramnik", "Fundamentor"]

const OUTLINE := Color("171821")
const ROCK_D := Color("343641")
const ROCK := Color("575965")
const ROCK_L := Color("8a8c93")
const RUST_D := Color("7a321f")
const RUST := Color("b7512d")
const RUST_L := Color("e37b43")
const SAND := Color("c9aa70")
const MOSS_D := Color("485a32")
const MOSS := Color("71824a")
const CYAN := Color("54d7e7")
const AMBER := Color("ffc45a")
const WHITE := Color("f7efe1")

static var _base_cache: Dictionary = {}
static var _frame_cache: Dictionary = {}

static func has_animation(creature_name: String) -> bool:
	return creature_name in NAMES

static func animation_count() -> int:
	return NAMES.size()

static func frame_count(action: String) -> int:
	return maxi(1, int(ACTION_FRAME_COUNTS.get(action, 1)))

static func frame_texture(creature_name: String, action: String, frame: int) -> Texture2D:
	if not has_animation(creature_name): return null
	if action not in ACTIONS: action = "idle"
	var safe_frame: int = clampi(frame, 0, frame_count(action) - 1)
	var key: String = "%s|%s|%d" % [creature_name, action, safe_frame]
	if _frame_cache.has(key): return _frame_cache[key] as Texture2D
	var base: Image = _base_image(creature_name)
	if base == null: return null
	var image: Image = _make_frame(base, action, safe_frame)
	var texture: Texture2D = ImageTexture.create_from_image(image)
	_frame_cache[key] = texture
	return texture

static func _base_image(creature_name: String) -> Image:
	if _base_cache.has(creature_name): return _base_cache[creature_name] as Image
	var image := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	match creature_name:
		"Kotwiczek": _draw_kotwiczek(image)
		"Bramnik": _draw_bramnik(image)
		"Fundamentor": _draw_fundamentor(image)
		_: return null
	image.resize(128, 128, Image.INTERPOLATE_NEAREST)
	_base_cache[creature_name] = image
	return image

static func _draw_kotwiczek(image: Image) -> void:
	_ellipse_outline(image, Rect2i(12, 24, 32, 25), OUTLINE, RUST)
	_ellipse(image, Rect2i(15, 27, 27, 18), RUST_L)
	_poly(image, [Vector2i(14,27),Vector2i(19,20),Vector2i(25,21),Vector2i(27,28)], SAND)
	_poly(image, [Vector2i(24,23),Vector2i(29,18),Vector2i(36,21),Vector2i(37,28)], ROCK_L)
	_poly(image, [Vector2i(32,24),Vector2i(38,20),Vector2i(44,25),Vector2i(41,31)], SAND)
	_set_block(image, 22, 21, MOSS, 1); _set_block(image, 34, 20, MOSS_D, 1)
	_ellipse(image, Rect2i(20, 29, 7, 9), CYAN); _ellipse(image, Rect2i(22, 30, 3, 6), OUTLINE); _set_block(image, 23, 31, WHITE, 0)
	_ellipse(image, Rect2i(32, 29, 7, 9), CYAN); _ellipse(image, Rect2i(34, 30, 3, 6), OUTLINE); _set_block(image, 35, 31, WHITE, 0)
	_line(image, Vector2i(27,39), Vector2i(30,41), OUTLINE, 0); _line(image, Vector2i(30,41), Vector2i(33,39), OUTLINE, 0)
	var legs: Array = [
		[Vector2i(16,42),Vector2i(7,48),Vector2i(4,54)],
		[Vector2i(19,45),Vector2i(12,53),Vector2i(10,58)],
		[Vector2i(23,46),Vector2i(20,56),Vector2i(18,60)],
		[Vector2i(37,45),Vector2i(43,53),Vector2i(45,58)],
		[Vector2i(40,42),Vector2i(48,48),Vector2i(52,54)]
	]
	for leg: Array in legs:
		_line(image, leg[0] as Vector2i, leg[1] as Vector2i, RUST_D, 2)
		_line(image, leg[1] as Vector2i, leg[2] as Vector2i, RUST_L, 2)
	_line(image, Vector2i(42,39), Vector2i(53,43), ROCK_D, 2); _line(image, Vector2i(53,43), Vector2i(55,25), ROCK_D, 2)
	_line(image, Vector2i(55,25), Vector2i(59,21), ROCK_L, 1); _line(image, Vector2i(55,25), Vector2i(51,21), ROCK_L, 1)
	_line(image, Vector2i(55,43), Vector2i(49,50), ROCK_D, 2); _line(image, Vector2i(55,43), Vector2i(61,50), ROCK_D, 2)
	_line(image, Vector2i(49,50), Vector2i(46,47), ROCK_L, 1); _line(image, Vector2i(61,50), Vector2i(63,47), ROCK_L, 1); _set_block(image, 55, 36, ROCK_L, 1)

static func _draw_bramnik(image: Image) -> void:
	_ellipse_outline(image, Rect2i(7, 23, 43, 28), OUTLINE, ROCK)
	for r: Rect2i in [Rect2i(10,21,11,9),Rect2i(18,18,12,10),Rect2i(28,19,12,10),Rect2i(37,22,11,9)]: _ellipse_outline(image, r, ROCK_D, ROCK_L)
	_set_block(image, 15, 21, MOSS, 1); _set_block(image, 27, 18, MOSS_D, 1); _set_block(image, 40, 22, MOSS, 1)
	_poly(image, [Vector2i(36,29),Vector2i(49,24),Vector2i(58,29),Vector2i(56,38),Vector2i(47,41),Vector2i(37,37)], ROCK_L)
	_poly(image, [Vector2i(45,26),Vector2i(51,22),Vector2i(54,29)], WHITE); _poly(image, [Vector2i(38,29),Vector2i(43,24),Vector2i(46,31)], WHITE)
	_ellipse(image, Rect2i(48,29,5,5), CYAN); _ellipse(image, Rect2i(50,30,2,3), OUTLINE); _ellipse(image, Rect2i(55,33,5,4), OUTLINE)
	var legs: Array = [
		[Vector2i(14,45),Vector2i(11,56),Vector2i(6,59)],
		[Vector2i(25,47),Vector2i(23,58),Vector2i(18,60)],
		[Vector2i(39,46),Vector2i(41,57),Vector2i(46,59)]
	]
	for leg: Array in legs:
		_line(image, leg[0] as Vector2i, leg[1] as Vector2i, ROCK_D, 3)
		_line(image, leg[1] as Vector2i, leg[2] as Vector2i, ROCK_L, 2)
	_line(image, Vector2i(43,39), Vector2i(48,48), ROCK_D, 2)
	_draw_partial_ring(image, Vector2i(52,49), 8, 205, 520, ROCK_D, 2); _draw_partial_ring(image, Vector2i(52,49), 6, 205, 520, ROCK_L, 1)
	_line(image, Vector2i(56,53), Vector2i(61,57), ROCK_D, 2); _line(image, Vector2i(61,57), Vector2i(63,53), ROCK_L, 1)

static func _draw_fundamentor(image: Image) -> void:
	_poly(image, [Vector2i(7,23),Vector2i(15,16),Vector2i(48,16),Vector2i(57,24),Vector2i(52,43),Vector2i(13,43)], ROCK_D)
	_poly(image, [Vector2i(12,22),Vector2i(18,18),Vector2i(46,18),Vector2i(52,23),Vector2i(48,37),Vector2i(15,37)], ROCK)
	_line(image, Vector2i(14,18), Vector2i(49,18), SAND, 1)
	for x: int in [17,27,38,47]:
		_poly(image, [Vector2i(x-2,18),Vector2i(x-2,10),Vector2i(x,7),Vector2i(x+2,10),Vector2i(x+2,19)], ROCK_L); _set_block(image, x, 12, AMBER, 1)
	_poly(image, [Vector2i(24,27),Vector2i(29,22),Vector2i(37,22),Vector2i(42,27),Vector2i(38,36),Vector2i(28,36)], ROCK_D)
	_ellipse(image, Rect2i(27,26,6,6), AMBER); _ellipse(image, Rect2i(35,26,6,6), AMBER); _set_block(image, 30, 28, OUTLINE, 0); _set_block(image, 38, 28, OUTLINE, 0)
	_line(image, Vector2i(16,22), Vector2i(24,20), MOSS, 1); _line(image, Vector2i(41,20), Vector2i(49,23), MOSS_D, 1)
	for x: int in [12,20,44,51]:
		_line(image, Vector2i(x,38), Vector2i(x-2 if x < 32 else x+2,50), ROCK_D, 3)
		_line(image, Vector2i(x-2 if x < 32 else x+2,50), Vector2i(x-5 if x < 32 else x+5,58), RUST, 2)
	_line(image, Vector2i(17,32), Vector2i(7,39), ROCK_D, 3); _line(image, Vector2i(7,39), Vector2i(3,49), RUST_D, 3)
	_line(image, Vector2i(3,49), Vector2i(8,55), RUST_L, 2); _line(image, Vector2i(3,49), Vector2i(0,55), RUST_L, 2)
	_line(image, Vector2i(50,31), Vector2i(58,38), ROCK_D, 3); _line(image, Vector2i(58,38), Vector2i(59,51), ROCK_D, 3)
	_draw_partial_ring(image, Vector2i(55,53), 8, 110, 360, ROCK_D, 2); _draw_partial_ring(image, Vector2i(55,53), 6, 110, 360, ROCK_L, 1); _line(image, Vector2i(56,58), Vector2i(62,61), ROCK_D, 2)

static func _make_frame(base: Image, action: String, frame: int) -> Image:
	match action:
		"idle":
			var ys: Array[int] = [0,-1,0,1]; return _place(base, 0, ys[frame], 1.0, 1.0, 1.0)
		"attack":
			var dx: Array[int] = [0,4,10,18,9,1]; var dy: Array[int] = [0,0,-2,-4,-1,0]
			var result: Image = _place(base, dx[frame], dy[frame], 1.04 if frame in [2,3] else 1.0, 0.98 if frame == 3 else 1.0, 1.0)
			if frame in [2,3,4]: _draw_anchor_arc(result, 88 + int(dx[frame] / 2), 61, frame)
			return result
		"hurt":
			var hx: Array[int] = [-5,5,0]; var hurt: Image = _place(base, hx[frame], 2 if frame < 2 else 0, 0.98, 0.98, 1.0); _tint_red(hurt, 0.46 if frame < 2 else 0.16); return hurt
		"faint":
			var t: float = float(frame) / float(maxi(1, frame_count("faint") - 1)); return _place(base, -int(round(2.0 * t)), int(round(23.0 * t)), 1.05 + 0.06 * t, 1.0 - 0.58 * t, 1.0 - 0.78 * t)
		"special":
			var p: float = float(frame) / float(maxi(1, frame_count("special") - 1)); var pulse: float = 1.0 + 0.05 * sin(p * PI)
			var special: Image = _place(base, 0, -int(round(2.0 * sin(p * PI))), pulse, pulse, 1.0)
			_draw_stability_ring(special, 24 + int(round(11.0 * sin(p * PI))), Color(0.93,0.67,0.35,0.70)); _draw_stability_ring(special, 36 + int(round(10.0 * p)), Color(0.35,0.84,0.88,0.50)); _draw_anchor_glyph(special, Vector2i(64,64), 10 + frame); _draw_dust(special, frame); return special
	return base.duplicate()

static func _place(base: Image, dx: int, dy: int, sx: float, sy: float, alpha: float) -> Image:
	var transformed: Image = base.duplicate(); var width: int = maxi(1, int(round(128.0 * sx))); var height: int = maxi(1, int(round(128.0 * sy)))
	if width != 128 or height != 128: transformed.resize(width, height, Image.INTERPOLATE_NEAREST)
	if alpha < 0.999: _multiply_alpha(transformed, alpha)
	var canvas := Image.create(128, 128, false, Image.FORMAT_RGBA8); canvas.fill(Color(0,0,0,0)); _blit_clipped(canvas, transformed, int((128 - width) / 2) + dx, 128 - height + dy); return canvas

static func _blit_clipped(canvas: Image, source: Image, target_x: int, target_y: int) -> void:
	var source_x: int = maxi(0, -target_x); var source_y: int = maxi(0, -target_y); var dest_x: int = maxi(0, target_x); var dest_y: int = maxi(0, target_y)
	var width: int = mini(source.get_width() - source_x, 128 - dest_x); var height: int = mini(source.get_height() - source_y, 128 - dest_y)
	if width > 0 and height > 0: canvas.blit_rect(source, Rect2i(source_x, source_y, width, height), Vector2i(dest_x, dest_y))

static func _multiply_alpha(image: Image, alpha: float) -> void:
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			var color: Color = image.get_pixel(x,y)
			if color.a > 0.0: color.a *= alpha; image.set_pixel(x,y,color)

static func _tint_red(image: Image, strength: float) -> void:
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			var color: Color = image.get_pixel(x,y)
			if color.a > 0.0:
				color.r = lerpf(color.r,1.0,strength); color.g = lerpf(color.g,0.28,strength); color.b = lerpf(color.b,0.28,strength); image.set_pixel(x,y,color)

static func _draw_anchor_arc(image: Image, center_x: int, center_y: int, phase: int) -> void:
	var radius: int = 18 + phase * 3
	for degree: int in range(-120, 41, 8):
		var angle: float = deg_to_rad(float(degree)); _set_block(image, center_x + int(round(cos(angle) * float(radius))), center_y + int(round(sin(angle) * float(radius))), Color(0.72,0.76,0.82,0.74), 1)
	for i: int in range(4): _set_block(image, center_x + radius - i * 2, center_y - 1 + i, CYAN, 1)

static func _draw_stability_ring(image: Image, radius: int, color: Color) -> void:
	for degree: int in range(0,360,12):
		var angle: float = deg_to_rad(float(degree)); _set_block(image,64 + int(round(cos(angle) * float(radius))),64 + int(round(sin(angle) * float(radius))),color,1)

static func _draw_anchor_glyph(image: Image, center: Vector2i, size: int) -> void:
	var c: Color = Color(1.0,0.78,0.35,0.80); _line(image, Vector2i(center.x,center.y-size), Vector2i(center.x,center.y+size), c, 1)
	_draw_partial_ring(image, Vector2i(center.x,center.y-size+1), maxi(2,int(size/4)), 0, 360, c, 1); _line(image, Vector2i(center.x-size,center.y+int(size*0.4)), Vector2i(center.x+size,center.y+int(size*0.4)), c, 1)
	_line(image, Vector2i(center.x-size,center.y+int(size*0.4)), Vector2i(center.x-int(size*0.55),center.y+size), c, 1); _line(image, Vector2i(center.x+size,center.y+int(size*0.4)), Vector2i(center.x+int(size*0.55),center.y+size), c, 1)

static func _draw_dust(image: Image, phase: int) -> void:
	var positions: Array[Vector2i] = [Vector2i(20,95),Vector2i(35,101),Vector2i(93,98),Vector2i(108,91)]
	for i: int in range(positions.size()):
		if (i + phase) % 2 != 0: continue
		var p: Vector2i = positions[i]; p.y -= phase * 2; _set_block(image,p.x,p.y,Color(SAND.r,SAND.g,SAND.b,0.72),1)

static func _draw_partial_ring(image: Image, center: Vector2i, radius: int, start_deg: int, end_deg: int, color: Color, thickness: int) -> void:
	for degree: int in range(start_deg, end_deg + 1, 8):
		var angle: float = deg_to_rad(float(degree % 360)); _set_block(image,center.x + int(round(cos(angle) * float(radius))),center.y + int(round(sin(angle) * float(radius))),color,thickness)

static func _set_block(image: Image, cx: int, cy: int, color: Color, radius: int) -> void:
	for y: int in range(cy-radius,cy+radius+1):
		for x: int in range(cx-radius,cx+radius+1):
			if x >= 0 and x < image.get_width() and y >= 0 and y < image.get_height(): image.set_pixel(x,y,color)

static func _ellipse_outline(image: Image, rect: Rect2i, outline: Color, fill: Color) -> void:
	_ellipse(image,rect,outline); var inner := Rect2i(rect.position + Vector2i(2,2), rect.size - Vector2i(4,4))
	if inner.size.x > 0 and inner.size.y > 0: _ellipse(image,inner,fill)

static func _ellipse(image: Image, rect: Rect2i, color: Color) -> void:
	var rx: float = maxf(0.5,float(rect.size.x) * 0.5); var ry: float = maxf(0.5,float(rect.size.y) * 0.5); var cx: float = float(rect.position.x) + rx; var cy: float = float(rect.position.y) + ry
	for y: int in range(rect.position.y,rect.end.y):
		for x: int in range(rect.position.x,rect.end.x):
			if x < 0 or x >= image.get_width() or y < 0 or y >= image.get_height(): continue
			var px: float = (float(x) + 0.5 - cx) / rx; var py: float = (float(y) + 0.5 - cy) / ry
			if px * px + py * py <= 1.0: image.set_pixel(x,y,color)

static func _poly(image: Image, points: Array[Vector2i], color: Color) -> void:
	if points.size() < 3: return
	var min_x: int = points[0].x; var max_x: int = points[0].x; var min_y: int = points[0].y; var max_y: int = points[0].y
	for p: Vector2i in points: min_x = mini(min_x,p.x); max_x = maxi(max_x,p.x); min_y = mini(min_y,p.y); max_y = maxi(max_y,p.y)
	for y: int in range(min_y,max_y+1):
		for x: int in range(min_x,max_x+1):
			if x >= 0 and x < image.get_width() and y >= 0 and y < image.get_height() and _inside(Vector2(float(x)+0.5,float(y)+0.5),points): image.set_pixel(x,y,color)

static func _inside(point: Vector2, points: Array[Vector2i]) -> bool:
	var inside: bool = false; var j: int = points.size() - 1
	for i: int in range(points.size()):
		var pi: Vector2i = points[i]; var pj: Vector2i = points[j]
		if (pi.y > point.y) != (pj.y > point.y):
			var cross_x: float = float(pj.x - pi.x) * (point.y - float(pi.y)) / float(pj.y - pi.y) + float(pi.x)
			if point.x < cross_x: inside = not inside
		j = i
	return inside

static func _line(image: Image, a: Vector2i, b: Vector2i, color: Color, radius: int) -> void:
	var steps: int = maxi(abs(b.x-a.x),abs(b.y-a.y))
	if steps <= 0: _set_block(image,a.x,a.y,color,radius); return
	for i: int in range(steps+1):
		var t: float = float(i) / float(steps); _set_block(image,int(round(lerpf(float(a.x),float(b.x),t))),int(round(lerpf(float(a.y),float(b.y),t))),color,radius)
