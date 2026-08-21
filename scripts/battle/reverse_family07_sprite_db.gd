extends RefCounted

# Reverse visual-production pass: family 007 (Srubik -> Torsys -> Spiralion).
# Source identity: torsion/spiral creatures from the crystal cave line. The
# base form is a cream-purple spiral snail, the middle form a turquoise-purple
# reptilian runner with curled horns/shell, and the final form a purple-gold
# phoenix whose wings and tail end in strong spiral curls.

const ACTIONS: Array[String] = ["idle", "attack", "hurt", "faint", "special"]
const ACTION_FRAME_COUNTS: Dictionary = {"idle":4, "attack":6, "hurt":3, "faint":5, "special":6}
const NAMES: Array[String] = ["Srubik", "Torsys", "Spiralion"]

const OUTLINE := Color("1c1427")
const CREAM := Color("ead7a8")
const CREAM_L := Color("fff0c9")
const PURPLE_D := Color("55306d")
const PURPLE := Color("8550a8")
const PURPLE_L := Color("c47bd5")
const BLUE_D := Color("3f718d")
const BLUE := Color("61a6bd")
const BLUE_L := Color("8fd6d9")
const GOLD_D := Color("9c5c25")
const GOLD := Color("d9923e")
const GOLD_L := Color("ffd36f")
const MAGENTA := Color("e868d5")
const CYAN := Color("5fd8ec")
const WHITE := Color("fff7e8")

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
		"Srubik": _draw_srubik(image)
		"Torsys": _draw_torsys(image)
		"Spiralion": _draw_spiralion(image)
		_: return null
	image.resize(128,128,Image.INTERPOLATE_NEAREST)
	_base_cache[creature_name] = image
	return image

static func _draw_srubik(image: Image) -> void:
	# Large purple spiral shell, small cream face and twin curled antennae.
	_ellipse_outline(image, Rect2i(5,30,31,25), OUTLINE, PURPLE_D)
	_ellipse(image, Rect2i(8,33,25,19), PURPLE)
	_draw_spiral(image, Vector2i(20,42), 11, PURPLE_L, 2, 2.6)
	_draw_spiral(image, Vector2i(20,42), 7, GOLD, 1, 2.2)
	_ellipse_outline(image, Rect2i(29,29,25,22), OUTLINE, CREAM)
	_ellipse(image, Rect2i(33,32,19,16), CREAM_L)
	_ellipse(image, Rect2i(39,34,7,8), WHITE)
	_ellipse(image, Rect2i(42,35,3,5), OUTLINE)
	_set_block(image,43,35,CYAN,0)
	_set_block(image,49,41,GOLD_D,1)
	_line(image, Vector2i(35,31), Vector2i(33,20), PURPLE_D, 1)
	_draw_partial_ring(image, Vector2i(29,18), 5, 220, 530, PURPLE, 1)
	_line(image, Vector2i(44,31), Vector2i(45,20), PURPLE_D, 1)
	_draw_partial_ring(image, Vector2i(49,18), 5, 10, 320, PURPLE, 1)
	_set_block(image,29,18,GOLD_L,1)
	_set_block(image,49,18,GOLD_L,1)
	_line(image,Vector2i(35,49),Vector2i(31,57),CREAM,2)
	_line(image,Vector2i(45,49),Vector2i(48,57),CREAM,2)
	_set_block(image,30,58,OUTLINE,1)
	_set_block(image,49,58,OUTLINE,1)

static func _draw_torsys(image: Image) -> void:
	# Reptilian middle evolution with layered turquoise plates and spiral shell.
	_ellipse_outline(image, Rect2i(7,30,36,20), OUTLINE, BLUE_D)
	_ellipse(image, Rect2i(10,32,31,16), BLUE)
	for p: Vector2i in [Vector2i(15,34),Vector2i(21,31),Vector2i(28,33),Vector2i(34,31)]:
		_set_block(image,p.x,p.y,PURPLE_L,1)
	_ellipse_outline(image, Rect2i(4,18,28,27), OUTLINE, PURPLE_D)
	_ellipse(image, Rect2i(7,21,22,21), PURPLE)
	_draw_spiral(image,Vector2i(18,31),10,PURPLE_L,2,2.8)
	_draw_spiral(image,Vector2i(18,31),6,CYAN,1,2.2)
	_poly(image,[Vector2i(34,32),Vector2i(40,19),Vector2i(52,16),Vector2i(60,23),Vector2i(57,32),Vector2i(46,36)],BLUE_L)
	_poly(image,[Vector2i(43,20),Vector2i(47,15),Vector2i(52,17),Vector2i(49,23)],CREAM)
	_ellipse(image,Rect2i(51,21,6,6),WHITE)
	_ellipse(image,Rect2i(53,22,3,4),OUTLINE)
	_set_block(image,55,22,CYAN,0)
	_poly(image,[Vector2i(57,28),Vector2i(63,30),Vector2i(58,33)],CREAM)
	_line(image,Vector2i(42,20),Vector2i(39,10),PURPLE_D,2)
	_draw_partial_ring(image,Vector2i(36,8),5,190,510,PURPLE_L,1)
	_line(image,Vector2i(48,18),Vector2i(49,8),PURPLE_D,2)
	_draw_partial_ring(image,Vector2i(52,6),5,-20,300,PURPLE_L,1)
	_line(image,Vector2i(14,45),Vector2i(9,58),BLUE_D,2)
	_line(image,Vector2i(27,46),Vector2i(25,60),BLUE_D,2)
	_line(image,Vector2i(38,45),Vector2i(44,58),BLUE_D,2)
	_set_block(image,8,59,OUTLINE,1)
	_set_block(image,25,60,OUTLINE,1)
	_set_block(image,45,58,OUTLINE,1)
	_line(image,Vector2i(9,37),Vector2i(1,43),PURPLE_D,2)
	_draw_partial_ring(image,Vector2i(4,49),7,130,440,PURPLE,1)

static func _draw_spiralion(image: Image) -> void:
	# Final phoenix-like torsion form; readable wings and two curled tail plumes.
	_poly(image,[Vector2i(31,32),Vector2i(18,13),Vector2i(3,9),Vector2i(7,25),Vector2i(24,39)],PURPLE_D)
	_poly(image,[Vector2i(29,31),Vector2i(19,16),Vector2i(8,13),Vector2i(12,24),Vector2i(26,36)],GOLD)
	_poly(image,[Vector2i(36,32),Vector2i(46,12),Vector2i(61,7),Vector2i(58,25),Vector2i(42,39)],PURPLE_D)
	_poly(image,[Vector2i(38,31),Vector2i(47,16),Vector2i(56,12),Vector2i(53,24),Vector2i(41,36)],GOLD)
	for p: Vector2i in [Vector2i(10,18),Vector2i(14,25),Vector2i(52,18),Vector2i(49,26)]:
		_set_block(image,p.x,p.y,PURPLE_L,2)
	_poly(image,[Vector2i(27,27),Vector2i(32,18),Vector2i(39,20),Vector2i(43,31),Vector2i(37,45),Vector2i(29,43)],PURPLE)
	_ellipse(image,Rect2i(29,22,10,14),CREAM)
	_poly(image,[Vector2i(33,20),Vector2i(37,13),Vector2i(44,11),Vector2i(48,16),Vector2i(43,23)],CREAM_L)
	_ellipse(image,Rect2i(41,15,5,5),WHITE)
	_ellipse(image,Rect2i(43,16,2,3),OUTLINE)
	_poly(image,[Vector2i(47,18),Vector2i(54,19),Vector2i(48,22)],GOLD_L)
	_line(image,Vector2i(38,14),Vector2i(36,6),PURPLE_D,2)
	_draw_partial_ring(image,Vector2i(33,5),5,180,500,PURPLE_L,1)
	_line(image,Vector2i(43,13),Vector2i(45,5),PURPLE_D,2)
	_draw_partial_ring(image,Vector2i(49,4),5,-30,300,PURPLE_L,1)
	_line(image,Vector2i(30,43),Vector2i(21,53),PURPLE_D,3)
	_draw_partial_ring(image,Vector2i(13,51),10,110,470,PURPLE,2)
	_draw_partial_ring(image,Vector2i(13,51),7,110,470,GOLD,1)
	_line(image,Vector2i(37,44),Vector2i(45,53),PURPLE_D,3)
	_draw_partial_ring(image,Vector2i(54,51),10,-110,250,PURPLE,2)
	_draw_partial_ring(image,Vector2i(54,51),7,-110,250,GOLD,1)
	_line(image,Vector2i(31,44),Vector2i(29,59),GOLD_D,1)
	_line(image,Vector2i(37,44),Vector2i(39,59),GOLD_D,1)
	_set_block(image,28,60,OUTLINE,1)
	_set_block(image,40,60,OUTLINE,1)

static func _make_frame(base: Image, action: String, frame: int) -> Image:
	match action:
		"idle":
			var ys: Array[int] = [0,-2,0,1]
			return _place(base,0,ys[frame],1.0,1.0,1.0)
		"attack":
			var dx: Array[int] = [0,4,11,18,10,2]
			var dy: Array[int] = [0,-2,-5,-6,-2,0]
			var result: Image = _place(base,dx[frame],dy[frame],1.04 if frame in [2,3] else 1.0,0.98 if frame == 3 else 1.0,1.0)
			if frame in [1,2,3,4]:
				_draw_corkscrew(result,frame)
			return result
		"hurt":
			var hx: Array[int] = [-5,5,0]
			var hurt: Image = _place(base,hx[frame],2 if frame < 2 else 0,0.98,0.98,1.0)
			_tint_red(hurt,0.46 if frame < 2 else 0.17)
			return hurt
		"faint":
			var t: float = float(frame)/float(maxi(1,frame_count("faint")-1))
			return _place(base,int(round(2.0*t)),int(round(22.0*t)),1.05+0.07*t,1.0-0.57*t,1.0-0.78*t)
		"special":
			var p: float = float(frame)/float(maxi(1,frame_count("special")-1))
			var pulse: float = 1.0+0.07*sin(p*PI)
			var special: Image = _place(base,0,-int(round(3.0*sin(p*PI))),pulse,pulse,1.0)
			_draw_torsion_field(special,frame)
			_draw_crystal_shards(special,frame)
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
				c.g = lerpf(c.g,0.27,strength)
				c.b = lerpf(c.b,0.28,strength)
				image.set_pixel(x,y,c)

static func _draw_corkscrew(image: Image, phase: int) -> void:
	var loops: int = 22
	for i: int in range(loops):
		var t: float = float(i)/float(loops-1)
		var angle: float = t*TAU*2.0 + float(phase)*0.7
		var x: int = 70 + int(round(t*48.0))
		var y: int = 64 + int(round(sin(angle)*(12.0-5.0*t)))
		var c: Color = CYAN if i%2==0 else MAGENTA
		_set_block(image,x,y,Color(c.r,c.g,c.b,0.72),1)

static func _draw_torsion_field(image: Image, phase: int) -> void:
	var radius: int = 24 + phase*3
	for degree: int in range(0,720,14):
		var progress: float = float(degree)/720.0
		var local_radius: float = 6.0 + progress*float(radius)
		var angle: float = deg_to_rad(float(degree+phase*25))
		var x: int = 64 + int(round(cos(angle)*local_radius))
		var y: int = 64 + int(round(sin(angle)*local_radius))
		var c: Color = PURPLE_L if degree%28==0 else GOLD_L
		_set_block(image,x,y,Color(c.r,c.g,c.b,0.58),1)

static func _draw_crystal_shards(image: Image, phase: int) -> void:
	var pts: Array[Vector2i] = [Vector2i(18,31),Vector2i(104,27),Vector2i(17,91),Vector2i(108,87)]
	for i: int in range(pts.size()):
		if (i+phase)%2 != 0:
			continue
		var p: Vector2i = pts[i]
		p.y -= phase*2
		_poly(image,[Vector2i(p.x,p.y-4),Vector2i(p.x+3,p.y),Vector2i(p.x,p.y+5),Vector2i(p.x-2,p.y)],Color(CYAN.r,CYAN.g,CYAN.b,0.75))

static func _draw_spiral(image: Image, center: Vector2i, radius: int, color: Color, thickness: int, turns: float) -> void:
	var steps: int = 72
	for i: int in range(steps):
		var t: float = float(i)/float(steps-1)
		var angle: float = t*TAU*turns
		var r: float = (1.0-t)*float(radius)
		var x: int = center.x + int(round(cos(angle)*r))
		var y: int = center.y + int(round(sin(angle)*r))
		_set_block(image,x,y,color,thickness)

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
