extends RefCounted

# Reverse visual-production pass: family 006 (Kompasik -> Oktantor -> Kartografon).
# Source identity: desert direction-mappers. Kompasik is a compact cream/brown
# feathered scout, Oktantor a taller navigator with a compass medallion and fan
# tail, Kartografon a winged cartographer with map/compass instrumentation.

const ACTIONS: Array[String] = ["idle", "attack", "hurt", "faint", "special"]
const ACTION_FRAME_COUNTS: Dictionary = {"idle":4, "attack":6, "hurt":3, "faint":5, "special":6}
const NAMES: Array[String] = ["Kompasik", "Oktantor", "Kartografon"]

const OUTLINE := Color("1f2530")
const CREAM := Color("eadcc0")
const CREAM_L := Color("fff1d0")
const BROWN_D := Color("70513c")
const BROWN := Color("9b7657")
const BROWN_L := Color("c39b6b")
const TEAL_D := Color("247487")
const TEAL := Color("38a6b5")
const TEAL_L := Color("71d0d6")
const BLUE := Color("3879a5")
const GOLD_D := Color("9c6227")
const GOLD := Color("d89b43")
const GOLD_L := Color("ffd77d")
const ORANGE := Color("e78142")
const WHITE := Color("fff9e8")
const NAVY := Color("173d61")

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
	var image := Image.create(64,64,false,Image.FORMAT_RGBA8)
	image.fill(Color(0,0,0,0))
	match creature_name:
		"Kompasik": _draw_kompasik(image)
		"Oktantor": _draw_oktantor(image)
		"Kartografon": _draw_kartografon(image)
		_: return null
	image.resize(128,128,Image.INTERPOLATE_NEAREST)
	_base_cache[creature_name] = image
	return image

static func _draw_kompasik(image: Image) -> void:
	# Round feathered scout with eight directional quills and a tiny compass.
	for i: int in range(8):
		var angle: float = float(i) * TAU / 8.0
		var start := Vector2i(25 + int(round(cos(angle)*9.0)), 30 + int(round(sin(angle)*9.0)))
		var tip := Vector2i(25 + int(round(cos(angle)*20.0)), 30 + int(round(sin(angle)*20.0)))
		_line(image,start,tip,CREAM,3)
		_set_block(image,tip.x,tip.y,TEAL if i%2==0 else ORANGE,1)
	_ellipse_outline(image,Rect2i(13,20,25,27),OUTLINE,CREAM)
	_ellipse(image,Rect2i(16,23,19,19),CREAM_L)
	_ellipse(image,Rect2i(18,27,6,7),TEAL_L)
	_ellipse(image,Rect2i(20,28,3,5),OUTLINE)
	_set_block(image,22,28,WHITE,0)
	_ellipse(image,Rect2i(27,27,6,7),TEAL_L)
	_ellipse(image,Rect2i(29,28,3,5),OUTLINE)
	_set_block(image,31,28,WHITE,0)
	_poly(image,[Vector2i(25,34),Vector2i(29,36),Vector2i(25,39),Vector2i(21,36)],GOLD)
	_ellipse_outline(image,Rect2i(20,40,12,12),GOLD_D,GOLD_L)
	_draw_compass(image,Vector2i(26,46),5)
	_line(image,Vector2i(17,44),Vector2i(12,57),BROWN_D,2)
	_line(image,Vector2i(33,44),Vector2i(37,57),BROWN_D,2)
	_set_block(image,11,58,OUTLINE,1)
	_set_block(image,38,58,OUTLINE,1)

static func _draw_oktantor(image: Image) -> void:
	# Taller fox/owl navigator with a large feather fan and octant chest device.
	for i: int in range(7):
		var angle: float = deg_to_rad(135.0 + float(i)*20.0)
		var base := Vector2i(20,35)
		var tip := Vector2i(20 + int(round(cos(angle)*25.0)),35 + int(round(sin(angle)*25.0)))
		_line(image,base,tip,CREAM,4)
		_set_block(image,tip.x,tip.y,TEAL if i%2==0 else ORANGE,2)
	_ellipse_outline(image,Rect2i(20,29,24,25),OUTLINE,BROWN)
	_poly(image,[Vector2i(31,31),Vector2i(35,17),Vector2i(47,14),Vector2i(55,21),Vector2i(52,33),Vector2i(42,38)],CREAM)
	_poly(image,[Vector2i(37,19),Vector2i(39,10),Vector2i(44,17)],GOLD)
	_poly(image,[Vector2i(45,16),Vector2i(50,8),Vector2i(51,19)],TEAL)
	_ellipse(image,Rect2i(46,20,6,6),WHITE)
	_ellipse(image,Rect2i(48,21,3,4),OUTLINE)
	_set_block(image,50,21,TEAL_L,0)
	_poly(image,[Vector2i(53,26),Vector2i(63,28),Vector2i(54,32)],ORANGE)
	_ellipse_outline(image,Rect2i(29,37,14,14),GOLD_D,NAVY)
	_draw_compass(image,Vector2i(36,44),6)
	_line(image,Vector2i(24,49),Vector2i(20,60),BROWN_D,2)
	_line(image,Vector2i(39,50),Vector2i(44,60),BROWN_D,2)
	_set_block(image,19,61,OUTLINE,1)
	_set_block(image,45,61,OUTLINE,1)
	_line(image,Vector2i(20,40),Vector2i(9,48),BROWN,2)
	_set_block(image,7,50,GOLD_L,2)

static func _draw_kartografon(image: Image) -> void:
	# Winged final cartographer with broad map-feathers and an instrument core.
	_poly(image,[Vector2i(30,34),Vector2i(19,13),Vector2i(2,7),Vector2i(7,27),Vector2i(24,40)],NAVY)
	_poly(image,[Vector2i(28,33),Vector2i(18,17),Vector2i(7,12),Vector2i(11,25),Vector2i(25,36)],TEAL)
	_poly(image,[Vector2i(37,34),Vector2i(47,12),Vector2i(63,7),Vector2i(58,28),Vector2i(42,40)],NAVY)
	_poly(image,[Vector2i(39,33),Vector2i(48,17),Vector2i(58,12),Vector2i(54,25),Vector2i(42,36)],TEAL)
	for p: Vector2i in [Vector2i(10,17),Vector2i(15,23),Vector2i(53,17),Vector2i(49,24)]:
		_set_block(image,p.x,p.y,ORANGE,1)
		_set_block(image,p.x+2,p.y,TEAL_L,1)
	_poly(image,[Vector2i(27,27),Vector2i(32,17),Vector2i(40,19),Vector2i(45,32),Vector2i(40,49),Vector2i(29,48)],BROWN)
	_poly(image,[Vector2i(34,20),Vector2i(39,12),Vector2i(49,12),Vector2i(56,18),Vector2i(52,28),Vector2i(43,31)],CREAM)
	_poly(image,[Vector2i(39,13),Vector2i(39,4),Vector2i(45,11)],GOLD)
	_poly(image,[Vector2i(47,12),Vector2i(51,3),Vector2i(53,14)],TEAL)
	_ellipse(image,Rect2i(48,16,6,6),WHITE)
	_ellipse(image,Rect2i(50,17,3,4),OUTLINE)
	_poly(image,[Vector2i(54,22),Vector2i(63,24),Vector2i(55,28)],GOLD_L)
	_ellipse_outline(image,Rect2i(30,31,17,17),GOLD_D,NAVY)
	_draw_compass(image,Vector2i(38,39),7)
	_line(image,Vector2i(31,48),Vector2i(27,61),GOLD_D,1)
	_line(image,Vector2i(40,48),Vector2i(44,61),GOLD_D,1)
	_set_block(image,26,62,OUTLINE,1)
	_set_block(image,45,62,OUTLINE,1)
	# Instrument hoop behind right wing.
	_draw_partial_ring(image,Vector2i(53,34),10,0,360,GOLD_D,1)
	_line(image,Vector2i(53,24),Vector2i(53,44),GOLD,1)
	_line(image,Vector2i(43,34),Vector2i(63,34),GOLD,1)

static func _make_frame(base: Image, action: String, frame: int) -> Image:
	match action:
		"idle":
			var ys: Array[int] = [0,-2,0,1]
			return _place(base,0,ys[frame],1.0,1.0,1.0)
		"attack":
			var dx: Array[int] = [0,4,11,19,10,1]
			var dy: Array[int] = [0,-2,-4,-5,-2,0]
			var result: Image = _place(base,dx[frame],dy[frame],1.03 if frame in [2,3] else 1.0,0.98 if frame==3 else 1.0,1.0)
			if frame in [2,3,4]:
				_draw_direction_burst(result,frame)
			return result
		"hurt":
			var hx: Array[int] = [-5,5,0]
			var hurt: Image = _place(base,hx[frame],2 if frame<2 else 0,0.98,0.98,1.0)
			_tint_red(hurt,0.45 if frame<2 else 0.17)
			return hurt
		"faint":
			var t: float = float(frame)/float(maxi(1,frame_count("faint")-1))
			return _place(base,-int(round(2.0*t)),int(round(23.0*t)),1.05+0.06*t,1.0-0.58*t,1.0-0.78*t)
		"special":
			var p: float = float(frame)/float(maxi(1,frame_count("special")-1))
			var pulse: float = 1.0+0.06*sin(p*PI)
			var special: Image = _place(base,0,-int(round(3.0*sin(p*PI))),pulse,pulse,1.0)
			_draw_map_grid(special,frame)
			_draw_cardinal_field(special,frame)
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
	var tx: int = int((128-width)/2)+dx
	var ty: int = 128-height+dy
	_blit_clipped(canvas,transformed,tx,ty)
	return canvas

static func _blit_clipped(canvas: Image, source: Image, target_x: int, target_y: int) -> void:
	var sx: int = maxi(0,-target_x)
	var sy: int = maxi(0,-target_y)
	var dx: int = maxi(0,target_x)
	var dy: int = maxi(0,target_y)
	var w: int = mini(source.get_width()-sx,128-dx)
	var h: int = mini(source.get_height()-sy,128-dy)
	if w>0 and h>0:
		canvas.blit_rect(source,Rect2i(sx,sy,w,h),Vector2i(dx,dy))

static func _multiply_alpha(image: Image, alpha: float) -> void:
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			var c: Color=image.get_pixel(x,y)
			if c.a>0.0:
				c.a*=alpha
				image.set_pixel(x,y,c)

static func _tint_red(image: Image, strength: float) -> void:
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			var c: Color=image.get_pixel(x,y)
			if c.a>0.0:
				c.r=lerpf(c.r,1.0,strength)
				c.g=lerpf(c.g,0.28,strength)
				c.b=lerpf(c.b,0.28,strength)
				image.set_pixel(x,y,c)

static func _draw_direction_burst(image: Image, phase: int) -> void:
	var center:=Vector2i(92,63)
	var length: int=17+phase*5
	for i: int in range(8):
		var angle: float=float(i)*TAU/8.0
		var a:=Vector2i(center.x+int(round(cos(angle)*6.0)),center.y+int(round(sin(angle)*6.0)))
		var b:=Vector2i(center.x+int(round(cos(angle)*float(length))),center.y+int(round(sin(angle)*float(length))))
		_line(image,a,b,Color(TEAL_L.r,TEAL_L.g,TEAL_L.b,0.68),1)
	_set_block(image,center.x,center.y,GOLD_L,2)

static func _draw_map_grid(image: Image, phase: int) -> void:
	var alpha: float=0.30+0.05*float(phase)
	var c:=Color(TEAL_L.r,TEAL_L.g,TEAL_L.b,alpha)
	var inset: int=14+phase
	for x: int in range(inset,128-inset,16):
		_line(image,Vector2i(x,20),Vector2i(x,108),c,0)
	for y: int in range(24,109,16):
		_line(image,Vector2i(inset,y),Vector2i(127-inset,y),c,0)

static func _draw_cardinal_field(image: Image, phase: int) -> void:
	var center:=Vector2i(64,64)
	var radius: int=28+phase*3
	_draw_partial_ring(image,center,radius,0,360,Color(GOLD_L.r,GOLD_L.g,GOLD_L.b,0.62),1)
	for i: int in range(4):
		var angle: float=float(i)*TAU/4.0-float(phase)*0.08
		var tip:=Vector2i(center.x+int(round(cos(angle)*float(radius+8))),center.y+int(round(sin(angle)*float(radius+8))))
		_line(image,center,tip,Color(GOLD.r,GOLD.g,GOLD.b,0.50),1)
		_set_block(image,tip.x,tip.y,ORANGE,1)

static func _draw_compass(image: Image, center: Vector2i, radius: int) -> void:
	_draw_partial_ring(image,center,radius,0,360,GOLD_D,1)
	_line(image,Vector2i(center.x,center.y-radius+1),Vector2i(center.x,center.y+radius-1),TEAL,0)
	_line(image,Vector2i(center.x-radius+1,center.y),Vector2i(center.x+radius-1,center.y),TEAL,0)
	_poly(image,[Vector2i(center.x,center.y-radius+1),Vector2i(center.x+2,center.y),Vector2i(center.x,center.y+1),Vector2i(center.x-2,center.y)],ORANGE)
	_set_block(image,center.x,center.y,WHITE,1)

static func _set_block(image: Image, cx: int, cy: int, color: Color, radius: int) -> void:
	for y: int in range(cy-radius,cy+radius+1):
		for x: int in range(cx-radius,cx+radius+1):
			if x>=0 and x<image.get_width() and y>=0 and y<image.get_height(): image.set_pixel(x,y,color)

static func _ellipse_outline(image: Image, rect: Rect2i, outline: Color, fill: Color) -> void:
	_ellipse(image,rect,outline)
	var inner:=Rect2i(rect.position+Vector2i(2,2),rect.size-Vector2i(4,4))
	if inner.size.x>0 and inner.size.y>0: _ellipse(image,inner,fill)

static func _ellipse(image: Image, rect: Rect2i, color: Color) -> void:
	var rx: float=maxf(0.5,float(rect.size.x)*0.5)
	var ry: float=maxf(0.5,float(rect.size.y)*0.5)
	var cx: float=float(rect.position.x)+rx
	var cy: float=float(rect.position.y)+ry
	for y: int in range(rect.position.y,rect.end.y):
		for x: int in range(rect.position.x,rect.end.x):
			if x<0 or x>=image.get_width() or y<0 or y>=image.get_height(): continue
			var px: float=(float(x)+0.5-cx)/rx
			var py: float=(float(y)+0.5-cy)/ry
			if px*px+py*py<=1.0: image.set_pixel(x,y,color)

static func _poly(image: Image, points: Array[Vector2i], color: Color) -> void:
	if points.size()<3: return
	var min_x:int=points[0].x; var max_x:int=points[0].x
	var min_y:int=points[0].y; var max_y:int=points[0].y
	for p:Vector2i in points:
		min_x=mini(min_x,p.x); max_x=maxi(max_x,p.x)
		min_y=mini(min_y,p.y); max_y=maxi(max_y,p.y)
	for y:int in range(min_y,max_y+1):
		for x:int in range(min_x,max_x+1):
			if x>=0 and x<image.get_width() and y>=0 and y<image.get_height() and _inside(Vector2(float(x)+0.5,float(y)+0.5),points): image.set_pixel(x,y,color)

static func _inside(point: Vector2, points: Array[Vector2i]) -> bool:
	var inside:bool=false
	var j:int=points.size()-1
	for i:int in range(points.size()):
		var pi:Vector2i=points[i]; var pj:Vector2i=points[j]
		if (pi.y>point.y)!=(pj.y>point.y):
			var cross_x:float=float(pj.x-pi.x)*(point.y-float(pi.y))/float(pj.y-pi.y)+float(pi.x)
			if point.x<cross_x: inside=not inside
		j=i
	return inside

static func _line(image: Image, a: Vector2i, b: Vector2i, color: Color, radius: int) -> void:
	var steps:int=maxi(abs(b.x-a.x),abs(b.y-a.y))
	if steps<=0:
		_set_block(image,a.x,a.y,color,radius)
		return
	for i:int in range(steps+1):
		var t:float=float(i)/float(steps)
		_set_block(image,int(round(lerpf(float(a.x),float(b.x),t))),int(round(lerpf(float(a.y),float(b.y),t))),color,radius)

static func _draw_partial_ring(image: Image, center: Vector2i, radius: int, start_deg: int, end_deg: int, color: Color, thickness: int) -> void:
	for degree:int in range(start_deg,end_deg+1,8):
		var angle:float=deg_to_rad(float(degree%360))
		var x:int=center.x+int(round(cos(angle)*float(radius)))
		var y:int=center.y+int(round(sin(angle)*float(radius)))
		_set_block(image,x,y,color,thickness)
