extends RefCounted

# Reverse visual-production pass: family 004 (Pufek -> Pulsopuch -> Falomamut).
# Source identity: load/unload mechanics. Pufek is a porous sponge-like spring
# creature, Pulsopuch an otter-like carrier with buoyancy sacs, Falomamut a
# massive porous mammoth whose body visibly compresses and rebounds.

const ACTIONS: Array[String] = ["idle", "attack", "hurt", "faint", "special"]
const ACTION_FRAME_COUNTS: Dictionary = {"idle":4, "attack":6, "hurt":3, "faint":5, "special":6}
const NAMES: Array[String] = ["Pufek", "Pulsopuch", "Falomamut"]

const OUTLINE := Color("27202b")
const SAND_D := Color("9d712f")
const SAND := Color("d6a444")
const SAND_L := Color("f5d77b")
const TAN := Color("b98454")
const TAN_L := Color("d7ae78")
const BLUE_D := Color("37658f")
const BLUE := Color("558cb8")
const BLUE_L := Color("8fc5df")
const CYAN := Color("6ce7ef")
const CYAN_L := Color("c4fbff")
const PINK := Color("d975a8")
const IVORY := Color("f6e9c8")
const WHITE := Color("fff9ec")
const EYE := Color("0e1321")
const STEEL := Color("627386")

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
		"Pufek": _draw_pufek(image)
		"Pulsopuch": _draw_pulsopuch(image)
		"Falomamut": _draw_falomamut(image)
		_: return null
	image.resize(128,128,Image.INTERPOLATE_NEAREST)
	_base_cache[creature_name] = image
	return image

static func _draw_pufek(image: Image) -> void:
	# Porous rounded sponge cube on visible compression springs.
	_rounded_blob(image,Rect2i(16,18,33,31),SAND_D,SAND)
	_rounded_blob(image,Rect2i(19,20,27,25),SAND,SAND_L)
	for p: Vector2i in [Vector2i(23,24),Vector2i(31,21),Vector2i(40,25),Vector2i(21,34),Vector2i(36,37),Vector2i(29,41),Vector2i(44,32)]:
		_ellipse(image,Rect2i(p.x-2,p.y-2,4,4),SAND_D)
	_ellipse(image,Rect2i(22,29,7,8),BLUE_L)
	_ellipse(image,Rect2i(24,31,4,5),EYE)
	_set_block(image,26,31,WHITE,0)
	_ellipse(image,Rect2i(36,28,7,8),BLUE_L)
	_ellipse(image,Rect2i(38,30,4,5),EYE)
	_set_block(image,40,30,WHITE,0)
	_line(image,Vector2i(29,38),Vector2i(32,40),OUTLINE,0)
	_line(image,Vector2i(32,40),Vector2i(35,38),OUTLINE,0)
	for x: int in [22,42]:
		_draw_spring(image,Vector2i(x,48),Vector2i(x,59))
	_set_block(image,20,60,OUTLINE,2)
	_set_block(image,44,60,OUTLINE,2)
	_ellipse(image,Rect2i(27,11,7,7),PINK)
	_ellipse(image,Rect2i(36,13,6,6),SAND_L)

static func _draw_pulsopuch(image: Image) -> void:
	# Otter carrier with large blue pressure/bladder sacs around shoulders/chest.
	_ellipse_outline(image,Rect2i(18,25,30,29),OUTLINE,TAN)
	_poly(image,[Vector2i(30,26),Vector2i(31,14),Vector2i(39,8),Vector2i(49,12),Vector2i(54,21),Vector2i(49,31),Vector2i(41,34)],TAN_L)
	_poly(image,[Vector2i(35,12),Vector2i(35,6),Vector2i(40,11)],OUTLINE)
	_poly(image,[Vector2i(45,12),Vector2i(49,6),Vector2i(50,14)],OUTLINE)
	_ellipse(image,Rect2i(45,17,6,6),WHITE)
	_ellipse(image,Rect2i(47,18,3,4),EYE)
	_set_block(image,49,18,BLUE_L,0)
	_poly(image,[Vector2i(51,24),Vector2i(59,25),Vector2i(53,29)],IVORY)
	for rect: Rect2i in [Rect2i(16,27,13,17),Rect2i(28,33,14,17),Rect2i(39,25,12,16)]:
		_ellipse_outline(image,rect,BLUE_D,BLUE)
		_ellipse(image,Rect2i(rect.position+Vector2i(3,3),rect.size-Vector2i(6,6)),BLUE_L)
	_set_block(image,24,31,CYAN_L,0)
	_set_block(image,35,40,CYAN_L,0)
	_set_block(image,45,30,CYAN_L,0)
	_poly(image,[Vector2i(18,42),Vector2i(8,50),Vector2i(20,51),Vector2i(27,45)],TAN)
	_line(image,Vector2i(24,50),Vector2i(21,60),OUTLINE,2)
	_line(image,Vector2i(40,50),Vector2i(44,60),OUTLINE,2)
	_set_block(image,20,61,OUTLINE,1)
	_set_block(image,45,61,OUTLINE,1)
	_ellipse(image,Rect2i(30,22,5,5),PINK)

static func _draw_falomamut(image: Image) -> void:
	# Final porous mammoth with cloud-like compressible mantle and heavy tusks.
	_rounded_blob(image,Rect2i(7,18,50,35),BLUE_D,BLUE)
	for rect: Rect2i in [Rect2i(9,15,15,16),Rect2i(19,11,17,19),Rect2i(32,13,18,18),Rect2i(43,17,14,16)]:
		_ellipse_outline(image,rect,BLUE_D,BLUE_L)
	for p: Vector2i in [Vector2i(15,31),Vector2i(24,26),Vector2i(38,28),Vector2i(48,33),Vector2i(30,39),Vector2i(18,42),Vector2i(43,43)]:
		_ellipse(image,Rect2i(p.x-2,p.y-2,5,5),OUTLINE)
	_poly(image,[Vector2i(27,24),Vector2i(35,21),Vector2i(41,24),Vector2i(42,42),Vector2i(36,55),Vector2i(31,54),Vector2i(31,39)],BLUE)
	_line(image,Vector2i(32,31),Vector2i(31,52),BLUE_L,2)
	_ellipse(image,Rect2i(28,24,6,6),WHITE)
	_ellipse(image,Rect2i(30,25,3,4),EYE)
	_ellipse(image,Rect2i(39,24,6,6),WHITE)
	_ellipse(image,Rect2i(41,25,3,4),EYE)
	_draw_tusk(image,Vector2i(27,31),-1)
	_draw_tusk(image,Vector2i(45,31),1)
	for x: int in [13,23,45,54]:
		_poly(image,[Vector2i(x,46),Vector2i(x-3,61),Vector2i(x+4,61),Vector2i(x+5,46)],BLUE_D)
		_set_block(image,x,62,OUTLINE,2)

static func _make_frame(base: Image, action: String, frame: int) -> Image:
	match action:
		"idle":
			var sy: Array[float] = [1.0,0.97,1.0,1.03]
			var y: Array[int] = [0,2,0,-1]
			return _place(base,0,y[frame],1.0,sy[frame],1.0)
		"attack":
			var dx: Array[int] = [0,2,7,14,7,1]
			var squash: Array[float] = [1.0,0.92,0.84,1.12,1.05,1.0]
			var dy: Array[int] = [0,5,8,-5,-2,0]
			var result: Image = _place(base,dx[frame],dy[frame],1.05 if frame==3 else 1.0,squash[frame],1.0)
			if frame in [2,3,4]:
				_draw_rebound_wave(result,frame)
			return result
		"hurt":
			var hx: Array[int] = [-5,4,0]
			var hurt: Image = _place(base,hx[frame],5 if frame<2 else 0,1.05,0.86 if frame<2 else 0.96,1.0)
			_tint_red(hurt,0.42 if frame<2 else 0.16)
			return hurt
		"faint":
			var t: float = float(frame)/float(maxi(1,frame_count("faint")-1))
			return _place(base,0,int(round(25.0*t)),1.0+0.12*t,1.0-0.65*t,1.0-0.82*t)
		"special":
			var p: float = float(frame)/float(maxi(1,frame_count("special")-1))
			var compress: float = 0.90 + 0.20*abs(sin(p*PI*2.0))
			var special: Image = _place(base,0,int(round((1.0-compress)*9.0)),1.0,compress,1.0)
			_draw_load_field(special,frame)
			return special
	return base.duplicate()

static func _draw_rebound_wave(image: Image, phase: int) -> void:
	var center:=Vector2i(88,72)
	for radius: int in [10+phase*4,18+phase*5,27+phase*5]:
		_draw_partial_ring(image,center,radius,205,335,Color(CYAN.r,CYAN.g,CYAN.b,0.72),1)
	for i: int in range(5):
		var x: int = 86 + phase*4 + i*7
		var y: int = 72 - (i%2)*6
		_set_block(image,x,y,CYAN_L,1)

static func _draw_load_field(image: Image, phase: int) -> void:
	var level: int = 16 + phase*6
	for side: int in [-1,1]:
		var x: int = 64 + side*(24+phase*2)
		_line(image,Vector2i(x,30),Vector2i(x,98),Color(BLUE_L.r,BLUE_L.g,BLUE_L.b,0.5),1)
		_line(image,Vector2i(x,30),Vector2i(x-side*5,36),CYAN,1)
		_line(image,Vector2i(x,98),Vector2i(x-side*5,92),CYAN,1)
	for i: int in range(8):
		var angle: float = float(i)*TAU/8.0 + float(phase)*0.25
		var r: float = float(level + (i%2)*9)
		var px: int = 64 + int(round(cos(angle)*r))
		var py: int = 66 + int(round(sin(angle)*r))
		_draw_bubble(image,Vector2i(px,py),2+(i+phase)%3)
	_draw_partial_ring(image,Vector2i(64,66),24+phase*3,0,360,Color(CYAN.r,CYAN.g,CYAN.b,0.58),1)

static func _draw_bubble(image: Image, center: Vector2i, radius: int) -> void:
	_draw_partial_ring(image,center,radius,0,360,CYAN_L,0)
	_set_block(image,center.x-1,center.y-1,WHITE,0)

static func _draw_tusk(image: Image, root: Vector2i, direction: int) -> void:
	var mid := Vector2i(root.x+direction*10,root.y+9)
	var tip := Vector2i(root.x+direction*5,root.y+21)
	_line(image,root,mid,IVORY,3)
	_line(image,mid,tip,IVORY,2)
	_set_block(image,tip.x,tip.y,WHITE,1)

static func _draw_spring(image: Image, a: Vector2i, b: Vector2i) -> void:
	var steps: int = maxi(1,b.y-a.y)
	var prev:=a
	for i: int in range(1,steps+1):
		var p:=Vector2i(a.x + (2 if i%4<2 else -2), a.y+i)
		_line(image,prev,p,STEEL,0)
		prev=p

static func _rounded_blob(image: Image, rect: Rect2i, outline: Color, fill: Color) -> void:
	_ellipse_outline(image,rect,outline,fill)
	# Square central fill turns the ellipse into a soft rounded block.
	for y: int in range(rect.position.y+4,rect.end.y-4):
		for x: int in range(rect.position.x+2,rect.end.x-2):
			image.set_pixel(x,y,fill)

static func _place(base: Image, dx: int, dy: int, sx: float, sy: float, alpha: float) -> Image:
	var transformed: Image = base.duplicate()
	var width: int = maxi(1,int(round(128.0*sx)))
	var height: int = maxi(1,int(round(128.0*sy)))
	if width!=128 or height!=128:
		transformed.resize(width,height,Image.INTERPOLATE_NEAREST)
	if alpha<0.999:
		_multiply_alpha(transformed,alpha)
	var canvas:=Image.create(128,128,false,Image.FORMAT_RGBA8)
	canvas.fill(Color(0,0,0,0))
	var tx: int=int((128-width)/2)+dx
	var ty: int=128-height+dy
	_blit_clipped(canvas,transformed,tx,ty)
	return canvas

static func _blit_clipped(canvas: Image, source: Image, target_x: int, target_y: int) -> void:
	var sx: int=maxi(0,-target_x); var sy: int=maxi(0,-target_y)
	var dx: int=maxi(0,target_x); var dy: int=maxi(0,target_y)
	var w: int=mini(source.get_width()-sx,128-dx); var h: int=mini(source.get_height()-sy,128-dy)
	if w>0 and h>0:
		canvas.blit_rect(source,Rect2i(sx,sy,w,h),Vector2i(dx,dy))

static func _multiply_alpha(image: Image, alpha: float) -> void:
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			var c: Color=image.get_pixel(x,y)
			if c.a>0.0:
				c.a*=alpha; image.set_pixel(x,y,c)

static func _tint_red(image: Image, strength: float) -> void:
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			var c: Color=image.get_pixel(x,y)
			if c.a>0.0:
				c.r=lerpf(c.r,1.0,strength); c.g=lerpf(c.g,0.3,strength); c.b=lerpf(c.b,0.3,strength); image.set_pixel(x,y,c)

static func _ellipse_outline(image: Image, rect: Rect2i, outline: Color, fill: Color) -> void:
	_ellipse(image,rect,outline)
	var inner:=Rect2i(rect.position+Vector2i(2,2),rect.size-Vector2i(4,4))
	if inner.size.x>0 and inner.size.y>0:
		_ellipse(image,inner,fill)

static func _ellipse(image: Image, rect: Rect2i, color: Color) -> void:
	var rx: float=maxf(0.5,float(rect.size.x)*0.5); var ry: float=maxf(0.5,float(rect.size.y)*0.5)
	var cx: float=float(rect.position.x)+rx; var cy: float=float(rect.position.y)+ry
	for y: int in range(rect.position.y,rect.end.y):
		for x: int in range(rect.position.x,rect.end.x):
			if x<0 or x>=image.get_width() or y<0 or y>=image.get_height(): continue
			var px: float=(float(x)+0.5-cx)/rx; var py: float=(float(y)+0.5-cy)/ry
			if px*px+py*py<=1.0: image.set_pixel(x,y,color)

static func _poly(image: Image, points: Array[Vector2i], color: Color) -> void:
	if points.size()<3: return
	var min_x: int=points[0].x; var max_x: int=points[0].x; var min_y: int=points[0].y; var max_y: int=points[0].y
	for p: Vector2i in points:
		min_x=mini(min_x,p.x); max_x=maxi(max_x,p.x); min_y=mini(min_y,p.y); max_y=maxi(max_y,p.y)
	for y: int in range(min_y,max_y+1):
		for x: int in range(min_x,max_x+1):
			if x>=0 and x<image.get_width() and y>=0 and y<image.get_height() and _inside(Vector2(float(x)+0.5,float(y)+0.5),points): image.set_pixel(x,y,color)

static func _inside(point: Vector2, points: Array[Vector2i]) -> bool:
	var inside: bool=false; var j: int=points.size()-1
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
		_set_block(image,a.x,a.y,color,radius); return
	for i: int in range(steps+1):
		var t: float=float(i)/float(steps)
		_set_block(image,int(round(lerpf(float(a.x),float(b.x),t))),int(round(lerpf(float(a.y),float(b.y),t))),color,radius)

static func _set_block(image: Image, cx: int, cy: int, color: Color, radius: int) -> void:
	for y: int in range(cy-radius,cy+radius+1):
		for x: int in range(cx-radius,cx+radius+1):
			if x>=0 and x<image.get_width() and y>=0 and y<image.get_height(): image.set_pixel(x,y,color)

static func _draw_partial_ring(image: Image, center: Vector2i, radius: int, start_degree: int, end_degree: int, color: Color, thickness: int) -> void:
	for degree: int in range(start_degree,end_degree+1,6):
		var angle: float=deg_to_rad(float(degree))
		_set_block(image,center.x+int(round(cos(angle)*float(radius))),center.y+int(round(sin(angle)*float(radius))),color,thickness)
