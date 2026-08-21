extends RefCounted

# Reverse visual-production pass: family 008 (Uczek -> Obiegnik -> Labiryntaur).
# Source identity: a cream forest pathfinder grows from a curled maze-tail cub
# into a horned runner and finally a moss-covered labyrinth guardian.

const ACTIONS: Array[String] = ["idle", "attack", "hurt", "faint", "special"]
const ACTION_FRAME_COUNTS: Dictionary = {"idle":4, "attack":6, "hurt":3, "faint":5, "special":6}
const NAMES: Array[String] = ["Uczek", "Obiegnik", "Labiryntaur"]

const OUTLINE := Color("182117")
const CREAM_D := Color("b7ad87")
const CREAM := Color("e5dcc1")
const WHITE := Color("fff7df")
const GREEN_D := Color("36552f")
const GREEN := Color("5f8141")
const GREEN_L := Color("94ad59")
const MOSS := Color("718849")
const GOLD_D := Color("8e641e")
const GOLD := Color("d2a343")
const GOLD_L := Color("f6d87a")
const CYAN := Color("4ccbd5")
const LEAF := Color("a8cf67")

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
	image.fill(Color(0,0,0,0))
	match creature_name:
		"Uczek": _draw_uczek(image)
		"Obiegnik": _draw_obiegnik(image)
		"Labiryntaur": _draw_labiryntaur(image)
		_: return null
	image.resize(128,128,Image.INTERPOLATE_NEAREST)
	_base_cache[creature_name] = image
	return image

static func _draw_uczek(image: Image) -> void:
	_ellipse_outline(image, Rect2i(9,31,26,22), OUTLINE, CREAM)
	_ellipse_outline(image, Rect2i(14,20,21,20), OUTLINE, WHITE)
	_poly(image,[Vector2i(16,24),Vector2i(12,18),Vector2i(18,20)],CREAM_D)
	_poly(image,[Vector2i(31,24),Vector2i(36,18),Vector2i(34,28)],CREAM_D)
	_draw_partial_ring(image,Vector2i(17,19),7,155,420,GOLD,1)
	_draw_partial_ring(image,Vector2i(31,19),7,120,385,GOLD,1)
	_ellipse(image,Rect2i(18,27,6,7),CYAN)
	_ellipse(image,Rect2i(20,28,2,4),OUTLINE)
	_set_block(image,21,28,WHITE,0)
	_ellipse(image,Rect2i(27,27,6,7),CYAN)
	_ellipse(image,Rect2i(29,28,2,4),OUTLINE)
	_set_block(image,30,28,WHITE,0)
	_set_block(image,25,35,GOLD_D,0)
	_line(image,Vector2i(22,38),Vector2i(25,40),OUTLINE,0)
	_line(image,Vector2i(25,40),Vector2i(28,38),OUTLINE,0)
	_line(image,Vector2i(14,48),Vector2i(12,59),CREAM_D,2)
	_line(image,Vector2i(27,49),Vector2i(29,59),CREAM_D,2)
	_draw_partial_ring(image,Vector2i(47,38),15,210,555,GREEN_D,3)
	_draw_partial_ring(image,Vector2i(47,38),11,210,555,GREEN,2)
	_draw_partial_ring(image,Vector2i(47,38),7,210,555,GREEN_L,1)
	_set_block(image,45,25,MOSS,1)
	_set_block(image,54,32,LEAF,1)
	_set_block(image,52,48,MOSS,1)

static func _draw_obiegnik(image: Image) -> void:
	_ellipse_outline(image,Rect2i(18,30,31,18),OUTLINE,CREAM)
	_poly(image,[Vector2i(37,32),Vector2i(43,18),Vector2i(55,15),Vector2i(60,23),Vector2i(54,33),Vector2i(46,37)],WHITE)
	_line(image,Vector2i(47,18),Vector2i(43,8),GOLD_D,2)
	_line(image,Vector2i(43,8),Vector2i(39,4),GOLD,1)
	_line(image,Vector2i(50,17),Vector2i(49,6),GOLD_D,2)
	_line(image,Vector2i(49,6),Vector2i(53,2),GOLD,1)
	_line(image,Vector2i(43,10),Vector2i(38,10),GOLD_L,1)
	_line(image,Vector2i(49,8),Vector2i(55,8),GOLD_L,1)
	_ellipse(image,Rect2i(52,20,5,5),CYAN)
	_ellipse(image,Rect2i(54,21,2,3),OUTLINE)
	_poly(image,[Vector2i(57,26),Vector2i(63,27),Vector2i(58,31)],CREAM_D)
	_line(image,Vector2i(21,32),Vector2i(39,36),GREEN_D,2)
	_line(image,Vector2i(24,29),Vector2i(41,32),GREEN,1)
	for p: Vector2i in [Vector2i(24,28),Vector2i(30,31),Vector2i(35,30),Vector2i(40,33)]:
		_set_block(image,p.x,p.y,LEAF,1)
	_line(image,Vector2i(23,43),Vector2i(12,55),CREAM_D,2)
	_line(image,Vector2i(12,55),Vector2i(7,55),OUTLINE,1)
	_line(image,Vector2i(31,45),Vector2i(26,60),CREAM_D,2)
	_line(image,Vector2i(38,44),Vector2i(46,58),CREAM_D,2)
	_line(image,Vector2i(45,42),Vector2i(57,50),CREAM_D,2)
	_draw_partial_ring(image,Vector2i(15,35),10,110,430,GREEN,2)
	_draw_partial_ring(image,Vector2i(15,35),6,110,430,GREEN_L,1)

static func _draw_labiryntaur(image: Image) -> void:
	_ellipse_outline(image,Rect2i(12,25,42,30),OUTLINE,GREEN_D)
	_ellipse(image,Rect2i(16,28,35,24),GREEN)
	_draw_partial_ring(image,Vector2i(31,39),14,20,690,GOLD_D,2)
	_draw_partial_ring(image,Vector2i(31,39),9,20,690,GREEN_L,2)
	_draw_partial_ring(image,Vector2i(31,39),5,20,690,GOLD,1)
	_poly(image,[Vector2i(38,29),Vector2i(44,17),Vector2i(57,16),Vector2i(63,24),Vector2i(57,34),Vector2i(47,36)],CREAM_D)
	_poly(image,[Vector2i(43,25),Vector2i(47,18),Vector2i(57,19),Vector2i(60,25),Vector2i(55,31),Vector2i(47,32)],CREAM)
	_line(image,Vector2i(47,18),Vector2i(41,5),GOLD_D,3)
	_line(image,Vector2i(41,5),Vector2i(35,1),GOLD,2)
	_line(image,Vector2i(53,18),Vector2i(56,5),GOLD_D,3)
	_line(image,Vector2i(56,5),Vector2i(62,1),GOLD,2)
	_set_block(image,43,9,GOLD_L,1)
	_set_block(image,56,9,GOLD_L,1)
	_ellipse(image,Rect2i(53,22,5,5),CYAN)
	_ellipse(image,Rect2i(55,23,2,3),OUTLINE)
	for p: Vector2i in [Vector2i(39,20),Vector2i(35,23),Vector2i(33,27),Vector2i(38,31)]:
		_set_block(image,p.x,p.y,LEAF,2)
	_line(image,Vector2i(18,49),Vector2i(15,61),GREEN_D,3)
	_line(image,Vector2i(27,51),Vector2i(27,62),GREEN_D,3)
	_line(image,Vector2i(42,50),Vector2i(46,61),GREEN_D,3)
	_set_block(image,14,61,OUTLINE,1)
	_set_block(image,27,62,OUTLINE,1)
	_set_block(image,47,61,OUTLINE,1)

static func _make_frame(base: Image, action: String, frame: int) -> Image:
	match action:
		"idle":
			var ys: Array[int] = [0,-2,0,1]
			return _place(base,0,ys[frame],1.0,1.0,1.0)
		"attack":
			var dx: Array[int] = [0,5,13,20,14,3]
			var dy: Array[int] = [0,-3,-8,-10,-4,0]
			var result: Image = _place(base,dx[frame],dy[frame],1.02 if frame in [2,3] else 1.0,1.0,1.0)
			if frame in [1,2,3,4]:
				_draw_path_arc(result,frame)
			return result
		"hurt":
			var hx: Array[int] = [-5,5,0]
			var hurt: Image = _place(base,hx[frame],2 if frame < 2 else 0,0.98,0.98,1.0)
			_tint_red(hurt,0.45 if frame < 2 else 0.17)
			return hurt
		"faint":
			var t: float = float(frame) / float(maxi(1,frame_count("faint")-1))
			return _place(base,int(round(3.0*t)),int(round(22.0*t)),1.04+0.08*t,1.0-0.57*t,1.0-0.77*t)
		"special":
			var p: float = float(frame) / float(maxi(1,frame_count("special")-1))
			var pulse: float = 1.0 + 0.06 * sin(p*PI)
			var special: Image = _place(base,0,-int(round(3.0*sin(p*PI))),pulse,pulse,1.0)
			_draw_maze(special,frame)
			_draw_leaves(special,frame)
			return special
	return base.duplicate()

static func _place(base: Image, dx: int, dy: int, sx: float, sy: float, alpha: float) -> Image:
	var transformed: Image = base.duplicate()
	var width: int = maxi(1,int(round(128.0*sx)))
	var height: int = maxi(1,int(round(128.0*sy)))
	if width != 128 or height != 128:
		transformed.resize(width,height,Image.INTERPOLATE_NEAREST)
	if alpha < 0.999:
		_multiply_alpha(transformed,alpha)
	var canvas := Image.create(128,128,false,Image.FORMAT_RGBA8)
	canvas.fill(Color(0,0,0,0))
	var target_x: int = int((128-width)/2)+dx
	var target_y: int = 128-height+dy
	_blit_clipped(canvas,transformed,target_x,target_y)
	return canvas

static func _blit_clipped(canvas: Image, source: Image, target_x: int, target_y: int) -> void:
	var source_x: int = maxi(0,-target_x)
	var source_y: int = maxi(0,-target_y)
	var dest_x: int = maxi(0,target_x)
	var dest_y: int = maxi(0,target_y)
	var width: int = mini(source.get_width()-source_x,128-dest_x)
	var height: int = mini(source.get_height()-source_y,128-dest_y)
	if width > 0 and height > 0:
		canvas.blit_rect(source,Rect2i(source_x,source_y,width,height),Vector2i(dest_x,dest_y))

static func _multiply_alpha(image: Image, alpha: float) -> void:
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			var c: Color = image.get_pixel(x,y)
			if c.a > 0.0:
				c.a *= alpha
				image.set_pixel(x,y,c)

static func _tint_red(image: Image, strength: float) -> void:
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			var c: Color = image.get_pixel(x,y)
			if c.a > 0.0:
				c.r = lerpf(c.r,1.0,strength)
				c.g = lerpf(c.g,0.28,strength)
				c.b = lerpf(c.b,0.28,strength)
				image.set_pixel(x,y,c)

static func _draw_path_arc(image: Image, phase: int) -> void:
	for i: int in range(18):
		var t: float = float(i)/17.0
		var x: int = 22 + int(round(t*78.0))
		var y: int = 84 - int(round(sin(t*PI)*24.0)) + (phase-2)*2
		_set_block(image,x,y,Color(0.65,0.84,0.40,0.62),1)

static func _draw_maze(image: Image, phase: int) -> void:
	var c: Color = Color(0.92,0.77,0.30,0.66)
	var inset: int = 17 + phase
	var left: int = inset
	var right: int = 127-inset
	var top: int = 20+phase
	var bottom: int = 108-phase
	_line(image,Vector2i(left,top),Vector2i(right,top),c,1)
	_line(image,Vector2i(right,top),Vector2i(right,bottom),c,1)
	_line(image,Vector2i(right,bottom),Vector2i(left+14,bottom),c,1)
	_line(image,Vector2i(left+14,bottom),Vector2i(left+14,top+14),c,1)
	_line(image,Vector2i(left+14,top+14),Vector2i(right-14,top+14),c,1)
	_line(image,Vector2i(right-14,top+14),Vector2i(right-14,bottom-14),c,1)
	_line(image,Vector2i(right-14,bottom-14),Vector2i(left+28,bottom-14),c,1)
	_line(image,Vector2i(left+28,bottom-14),Vector2i(64,64),c,1)

static func _draw_leaves(image: Image, phase: int) -> void:
	var pts: Array[Vector2i] = [Vector2i(15,45),Vector2i(24,22),Vector2i(101,25),Vector2i(111,66),Vector2i(91,104)]
	for i: int in range(pts.size()):
		if (i+phase)%2 != 0:
			continue
		var p: Vector2i = pts[i]
		p.y += int(round(sin(float(phase+i))*6.0))
		_set_block(image,p.x,p.y,Color(LEAF.r,LEAF.g,LEAF.b,0.78),1)

static func _set_block(image: Image, cx: int, cy: int, color: Color, radius: int) -> void:
	for y: int in range(cy-radius,cy+radius+1):
		for x: int in range(cx-radius,cx+radius+1):
			if x >= 0 and x < image.get_width() and y >= 0 and y < image.get_height():
				image.set_pixel(x,y,color)

static func _ellipse_outline(image: Image, rect: Rect2i, outline: Color, fill: Color) -> void:
	_ellipse(image,rect,outline)
	var inner := Rect2i(rect.position+Vector2i(2,2),rect.size-Vector2i(4,4))
	if inner.size.x > 0 and inner.size.y > 0:
		_ellipse(image,inner,fill)

static func _ellipse(image: Image, rect: Rect2i, color: Color) -> void:
	var rx: float = maxf(0.5,float(rect.size.x)*0.5)
	var ry: float = maxf(0.5,float(rect.size.y)*0.5)
	var cx: float = float(rect.position.x)+rx
	var cy: float = float(rect.position.y)+ry
	for y: int in range(rect.position.y,rect.end.y):
		for x: int in range(rect.position.x,rect.end.x):
			if x < 0 or x >= image.get_width() or y < 0 or y >= image.get_height():
				continue
			var px: float = (float(x)+0.5-cx)/rx
			var py: float = (float(y)+0.5-cy)/ry
			if px*px+py*py <= 1.0:
				image.set_pixel(x,y,color)

static func _poly(image: Image, points: Array[Vector2i], color: Color) -> void:
	if points.size() < 3:
		return
	var min_x: int = points[0].x
	var max_x: int = points[0].x
	var min_y: int = points[0].y
	var max_y: int = points[0].y
	for p: Vector2i in points:
		min_x=mini(min_x,p.x); max_x=maxi(max_x,p.x)
		min_y=mini(min_y,p.y); max_y=maxi(max_y,p.y)
	for y: int in range(min_y,max_y+1):
		for x: int in range(min_x,max_x+1):
			if x >= 0 and x < image.get_width() and y >= 0 and y < image.get_height() and _inside(Vector2(float(x)+0.5,float(y)+0.5),points):
				image.set_pixel(x,y,color)

static func _inside(point: Vector2, points: Array[Vector2i]) -> bool:
	var inside: bool = false
	var j: int = points.size()-1
	for i: int in range(points.size()):
		var pi: Vector2i = points[i]
		var pj: Vector2i = points[j]
		if (pi.y > point.y) != (pj.y > point.y):
			var cross_x: float = float(pj.x-pi.x)*(point.y-float(pi.y))/float(pj.y-pi.y)+float(pi.x)
			if point.x < cross_x:
				inside = not inside
		j=i
	return inside

static func _line(image: Image, a: Vector2i, b: Vector2i, color: Color, radius: int) -> void:
	var steps: int = maxi(abs(b.x-a.x),abs(b.y-a.y))
	if steps <= 0:
		_set_block(image,a.x,a.y,color,radius)
		return
	for i: int in range(steps+1):
		var t: float = float(i)/float(steps)
		_set_block(image,int(round(lerpf(float(a.x),float(b.x),t))),int(round(lerpf(float(a.y),float(b.y),t))),color,radius)

static func _draw_partial_ring(image: Image, center: Vector2i, radius: int, start_deg: int, end_deg: int, color: Color, thickness: int) -> void:
	for degree: int in range(start_deg,end_deg+1,8):
		var angle: float = deg_to_rad(float(degree%360))
		var x: int = center.x + int(round(cos(angle)*float(radius)))
		var y: int = center.y + int(round(sin(angle)*float(radius)))
		_set_block(image,x,y,color,thickness)
