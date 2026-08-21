extends RefCounted

# Reverse visual-production pass: family 005 (Wahlik -> Oscylot -> Fazoryb).
# Source identity: deep-sea oscillation/shear creatures. Wahlik is a compact
# crescent-finned aquatic scout, Oscylot a dolphin-like mid evolution, Fazoryb
# a massive whale-like final form with magenta phase markings.

const ACTIONS: Array[String] = ["idle", "attack", "hurt", "faint", "special"]
const ACTION_FRAME_COUNTS: Dictionary = {"idle":4, "attack":6, "hurt":3, "faint":5, "special":6}
const NAMES: Array[String] = ["Wahlik", "Oscylot", "Fazoryb"]

const OUTLINE := Color("151c35")
const BLUE_D := Color("274d7d")
const BLUE := Color("437bb1")
const BLUE_L := Color("73add7")
const CYAN := Color("72e5ee")
const CYAN_L := Color("b5fbff")
const MAGENTA := Color("f16bd6")
const MAGENTA_L := Color("ff9de9")
const VIOLET := Color("8d67d9")
const BELLY := Color("d8e9e9")
const WHITE := Color("fff9fb")
const EYE := Color("100e1b")
const STAR := Color("ffd9ff")

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
		"Wahlik": _draw_wahlik(image)
		"Oscylot": _draw_oscylot(image)
		"Fazoryb": _draw_fazoryb(image)
		_: return null
	image.resize(128,128,Image.INTERPOLATE_NEAREST)
	_base_cache[creature_name] = image
	return image

static func _draw_wahlik(image: Image) -> void:
	# Round juvenile body with oversized crescent phase fins and pendant crystal.
	_poly(image,[Vector2i(20,30),Vector2i(4,12),Vector2i(6,5),Vector2i(19,13),Vector2i(24,25)],VIOLET)
	_poly(image,[Vector2i(18,29),Vector2i(8,13),Vector2i(10,8),Vector2i(18,15),Vector2i(22,27)],MAGENTA)
	_poly(image,[Vector2i(43,30),Vector2i(59,13),Vector2i(58,5),Vector2i(47,13),Vector2i(39,25)],VIOLET)
	_poly(image,[Vector2i(45,29),Vector2i(55,14),Vector2i(53,9),Vector2i(46,16),Vector2i(41,27)],MAGENTA)
	_ellipse_outline(image,Rect2i(18,19,29,29),OUTLINE,BLUE)
	_ellipse(image,Rect2i(22,24,21,19),BLUE_L)
	_ellipse(image,Rect2i(35,25,7,7),WHITE)
	_ellipse(image,Rect2i(37,26,4,5),EYE)
	_set_block(image,39,26,CYAN_L,0)
	_poly(image,[Vector2i(42,34),Vector2i(49,35),Vector2i(44,39)],BELLY)
	_poly(image,[Vector2i(19,39),Vector2i(10,43),Vector2i(20,46),Vector2i(26,42)],BLUE_D)
	_poly(image,[Vector2i(43,38),Vector2i(52,43),Vector2i(44,46),Vector2i(38,42)],BLUE_D)
	_line(image,Vector2i(31,47),Vector2i(31,55),MAGENTA,1)
	_poly(image,[Vector2i(31,54),Vector2i(35,59),Vector2i(31,63),Vector2i(27,59)],MAGENTA_L)
	_draw_phase_sparks(image,[Vector2i(15,15),Vector2i(50,16),Vector2i(24,22),Vector2i(41,20)])

static func _draw_oscylot(image: Image) -> void:
	# Streamlined dolphin-like body with a crescent dorsal fin and split tail.
	_poly(image,[Vector2i(12,35),Vector2i(22,24),Vector2i(38,19),Vector2i(55,23),Vector2i(62,29),Vector2i(55,36),Vector2i(37,41),Vector2i(20,42)],BLUE)
	_poly(image,[Vector2i(22,34),Vector2i(38,31),Vector2i(56,29),Vector2i(53,35),Vector2i(36,40),Vector2i(22,40)],BELLY)
	_poly(image,[Vector2i(31,22),Vector2i(24,7),Vector2i(38,13),Vector2i(41,20)],VIOLET)
	_poly(image,[Vector2i(29,22),Vector2i(27,10),Vector2i(36,14),Vector2i(38,21)],MAGENTA)
	_poly(image,[Vector2i(12,35),Vector2i(3,27),Vector2i(8,37),Vector2i(2,46),Vector2i(16,40)],VIOLET)
	_poly(image,[Vector2i(18,41),Vector2i(10,51),Vector2i(25,47),Vector2i(30,42)],BLUE_D)
	_ellipse(image,Rect2i(50,25,6,6),WHITE)
	_ellipse(image,Rect2i(52,26,3,4),EYE)
	_set_block(image,54,26,MAGENTA_L,0)
	_line(image,Vector2i(19,29),Vector2i(48,25),MAGENTA,1)
	_line(image,Vector2i(22,33),Vector2i(49,30),CYAN,1)
	_draw_phase_sparks(image,[Vector2i(27,27),Vector2i(34,25),Vector2i(42,24),Vector2i(47,33)])

static func _draw_fazoryb(image: Image) -> void:
	# Massive whale final form with phase constellations and looping tail field.
	_poly(image,[Vector2i(5,32),Vector2i(13,19),Vector2i(29,12),Vector2i(48,13),Vector2i(61,23),Vector2i(62,33),Vector2i(52,42),Vector2i(31,48),Vector2i(14,43)],BLUE_D)
	_poly(image,[Vector2i(10,33),Vector2i(22,29),Vector2i(48,28),Vector2i(59,31),Vector2i(51,40),Vector2i(31,45),Vector2i(17,41)],BLUE)
	_poly(image,[Vector2i(25,16),Vector2i(29,5),Vector2i(35,14)],OUTLINE)
	_poly(image,[Vector2i(35,14),Vector2i(40,3),Vector2i(44,16)],OUTLINE)
	_poly(image,[Vector2i(43,16),Vector2i(49,6),Vector2i(51,19)],OUTLINE)
	_poly(image,[Vector2i(19,42),Vector2i(11,55),Vector2i(28,49),Vector2i(34,44)],VIOLET)
	_poly(image,[Vector2i(47,41),Vector2i(56,55),Vector2i(62,48),Vector2i(55,37)],VIOLET)
	_ellipse(image,Rect2i(14,25,6,6),MAGENTA_L)
	_ellipse(image,Rect2i(16,26,3,4),EYE)
	_set_block(image,18,26,WHITE,0)
	_line(image,Vector2i(10,32),Vector2i(49,32),CYAN,1)
	_line(image,Vector2i(18,23),Vector2i(52,37),MAGENTA,1)
	_line(image,Vector2i(18,38),Vector2i(48,20),MAGENTA,1)
	_draw_phase_sparks(image,[Vector2i(24,22),Vector2i(31,30),Vector2i(39,22),Vector2i(46,31),Vector2i(30,39),Vector2i(50,25)])
	_draw_partial_ring(image,Vector2i(58,34),10,210,510,MAGENTA,1)
	_draw_partial_ring(image,Vector2i(58,34),6,220,500,CYAN,1)

static func _make_frame(base: Image, action: String, frame: int) -> Image:
	match action:
		"idle":
			var ys: Array[int] = [0,-2,0,1]
			var sx: Array[float] = [1.0,1.02,1.0,0.99]
			return _place(base,0,ys[frame],sx[frame],1.0,1.0)
		"attack":
			var dx: Array[int] = [0,5,13,21,12,2]
			var dy: Array[int] = [0,-1,-3,-5,-2,0]
			var result: Image = _place(base,dx[frame],dy[frame],1.05 if frame in [2,3] else 1.0,0.97 if frame==3 else 1.0,1.0)
			if frame in [2,3,4]:
				_draw_oscillation_slash(result,frame)
			return result
		"hurt":
			var hx: Array[int] = [-6,5,0]
			var hurt: Image = _place(base,hx[frame],2 if frame<2 else 0,0.98,0.98,1.0)
			_tint_red(hurt,0.48 if frame<2 else 0.18)
			return hurt
		"faint":
			var t: float = float(frame)/float(maxi(1,frame_count("faint")-1))
			return _place(base,int(round(3.0*t)),int(round(23.0*t)),1.0+0.08*t,1.0-0.58*t,1.0-0.8*t)
		"special":
			var p: float = float(frame)/float(maxi(1,frame_count("special")-1))
			var pulse: float = 1.0+0.07*sin(p*PI)
			var special: Image = _place(base,0,-int(round(3.0*sin(p*PI))),pulse,pulse,1.0)
			_draw_phase_field(special,frame)
			return special
	return base.duplicate()

static func _draw_oscillation_slash(image: Image, phase: int) -> void:
	var center_x: int = 88 + phase*2
	for layer: int in range(3):
		for x: int in range(0,32):
			var wave: float = sin((float(x)+float(phase*4)+float(layer*5))*0.45)
			var y: int = 56 + layer*9 + int(round(wave*7.0))
			_set_block(image,center_x+x,y,Color(MAGENTA.r,MAGENTA.g,MAGENTA.b,0.72),1)
			if x%4==0:
				_set_block(image,center_x+x,y+3,Color(CYAN.r,CYAN.g,CYAN.b,0.65),0)

static func _draw_phase_field(image: Image, phase: int) -> void:
	var radius_a: int = 22 + phase*4
	var radius_b: int = 34 + phase*3
	_draw_partial_ring(image,Vector2i(64,64),radius_a,0,360,MAGENTA,1)
	_draw_partial_ring(image,Vector2i(64,64),radius_b,0,360,CYAN,1)
	for i: int in range(8):
		var angle: float = float(i)*TAU/8.0 + float(phase)*0.17
		var r: float = 18.0 + float((i+phase)%3)*9.0
		_set_block(image,64+int(round(cos(angle)*r)),64+int(round(sin(angle)*r)),STAR,1)
	_draw_wave_axis(image,phase)

static func _draw_wave_axis(image: Image, phase: int) -> void:
	for x: int in range(18,111,3):
		var y: int = 64 + int(round(sin(float(x)*0.16 + float(phase)*0.8)*8.0))
		_set_block(image,x,y,Color(MAGENTA_L.r,MAGENTA_L.g,MAGENTA_L.b,0.72),0)

static func _draw_phase_sparks(image: Image, positions: Array[Vector2i]) -> void:
	for i: int in range(positions.size()):
		var p: Vector2i = positions[i]
		_set_block(image,p.x,p.y,MAGENTA_L if i%2==0 else CYAN_L,0)
		if i%2==0:
			_set_block(image,p.x+1,p.y,STAR,0)

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
			var c: Color = image.get_pixel(x,y)
			if c.a>0.0:
				c.a*=alpha
				image.set_pixel(x,y,c)

static func _tint_red(image: Image, strength: float) -> void:
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			var c: Color = image.get_pixel(x,y)
			if c.a>0.0:
				c.r=lerpf(c.r,1.0,strength)
				c.g=lerpf(c.g,0.26,strength)
				c.b=lerpf(c.b,0.34,strength)
				image.set_pixel(x,y,c)

static func _ellipse_outline(image: Image, rect: Rect2i, outline: Color, fill: Color) -> void:
	_ellipse(image,rect,outline)
	var inner := Rect2i(rect.position+Vector2i(2,2),rect.size-Vector2i(4,4))
	if inner.size.x>0 and inner.size.y>0:
		_ellipse(image,inner,fill)

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
			if px*px+py*py<=1.0:
				image.set_pixel(x,y,color)

static func _poly(image: Image, points: Array[Vector2i], color: Color) -> void:
	if points.size()<3: return
	var min_x: int=points[0].x; var max_x: int=points[0].x
	var min_y: int=points[0].y; var max_y: int=points[0].y
	for p: Vector2i in points:
		min_x=mini(min_x,p.x); max_x=maxi(max_x,p.x)
		min_y=mini(min_y,p.y); max_y=maxi(max_y,p.y)
	for y: int in range(min_y,max_y+1):
		for x: int in range(min_x,max_x+1):
			if x>=0 and x<image.get_width() and y>=0 and y<image.get_height() and _inside(Vector2(float(x)+0.5,float(y)+0.5),points):
				image.set_pixel(x,y,color)

static func _inside(point: Vector2, points: Array[Vector2i]) -> bool:
	var inside: bool=false
	var j: int=points.size()-1
	for i: int in range(points.size()):
		var pi: Vector2i=points[i]; var pj: Vector2i=points[j]
		if (pi.y>point.y)!=(pj.y>point.y):
			var cross_x: float=float(pj.x-pi.x)*(point.y-float(pi.y))/float(pj.y-pi.y)+float(pi.x)
			if point.x<cross_x: inside=not inside
		j=i
	return inside

static func _line(image: Image, a: Vector2i, b: Vector2i, color: Color, radius: int) -> void:
	var steps: int=maxi(abs(b.x-a.x),abs(b.y-a.y))
	if steps<=0:
		_set_block(image,a.x,a.y,color,radius)
		return
	for i: int in range(steps+1):
		var t: float=float(i)/float(steps)
		_set_block(image,int(round(lerpf(float(a.x),float(b.x),t))),int(round(lerpf(float(a.y),float(b.y),t))),color,radius)

static func _set_block(image: Image, cx: int, cy: int, color: Color, radius: int) -> void:
	for y: int in range(cy-radius,cy+radius+1):
		for x: int in range(cx-radius,cx+radius+1):
			if x>=0 and x<image.get_width() and y>=0 and y<image.get_height():
				image.set_pixel(x,y,color)

static func _draw_partial_ring(image: Image, center: Vector2i, radius: int, start_degree: int, end_degree: int, color: Color, thickness: int) -> void:
	for degree: int in range(start_degree,end_degree+1,6):
		var angle: float=deg_to_rad(float(degree))
		var x: int=center.x+int(round(cos(angle)*float(radius)))
		var y: int=center.y+int(round(sin(angle)*float(radius)))
		_set_block(image,x,y,color,thickness)
