extends RefCounted

# Reverse visual-production pass: family 003 (Milimik -> Drobnoskok -> Kwantomruk).
# Source identity: microscopic shear/micro-movement. The line evolves from a
# fuzzy crystal mite into an armored micro-jumper and finally a crystalline
# deer that leaves discrete quantum-like afterimages and shard trails.

const ACTIONS: Array[String] = ["idle", "attack", "hurt", "faint", "special"]
const ACTION_FRAME_COUNTS: Dictionary = {"idle":4,"attack":6,"hurt":3,"faint":5,"special":6}
const NAMES: Array[String] = ["Milimik","Drobnoskok","Kwantomruk"]

const OUTLINE := Color("25213a")
const LAV_D := Color("65568c")
const LAV := Color("9180b8")
const LAV_L := Color("c9bce4")
const CRYSTAL := Color("88a8df")
const CRYSTAL_L := Color("c5dcff")
const VIOLET := Color("7955b8")
const VIOLET_L := Color("b47ce6")
const GOLD := Color("d6a84c")
const GOLD_L := Color("ffdd7b")
const WHITE := Color("fffaff")
const EYE := Color("160d2a")
const TEAL := Color("65dcd8")
const SHADOW := Color("3e345f")

static var _base_cache: Dictionary = {}
static var _frame_cache: Dictionary = {}

static func has_animation(creature_name: String) -> bool:
	return creature_name in NAMES

static func animation_count() -> int:
	return NAMES.size()

static func frame_count(action: String) -> int:
	return maxi(1,int(ACTION_FRAME_COUNTS.get(action,1)))

static func frame_texture(creature_name: String, action: String, frame: int) -> Texture2D:
	if not has_animation(creature_name): return null
	if action not in ACTIONS: action="idle"
	var safe_frame: int=clampi(frame,0,frame_count(action)-1)
	var key: String="%s|%s|%d" % [creature_name,action,safe_frame]
	if _frame_cache.has(key): return _frame_cache[key] as Texture2D
	var base: Image=_base_image(creature_name)
	if base==null: return null
	var image: Image=_make_frame(base,action,safe_frame)
	var texture: Texture2D=ImageTexture.create_from_image(image)
	_frame_cache[key]=texture
	return texture

static func _base_image(creature_name: String) -> Image:
	if _base_cache.has(creature_name): return _base_cache[creature_name] as Image
	var image:=Image.create(64,64,false,Image.FORMAT_RGBA8)
	image.fill(Color(0,0,0,0))
	match creature_name:
		"Milimik": _draw_milimik(image)
		"Drobnoskok": _draw_drobnoskok(image)
		"Kwantomruk": _draw_kwantomruk(image)
		_: return null
	image.resize(128,128,Image.INTERPOLATE_NEAREST)
	_base_cache[creature_name]=image
	return image

static func _draw_milimik(image: Image) -> void:
	# Fuzzy mite with segmented feelers and six tiny crystal legs.
	_ellipse_outline(image,Rect2i(15,22,32,28),OUTLINE,LAV_L)
	for p: Vector2i in [Vector2i(17,24),Vector2i(21,20),Vector2i(28,19),Vector2i(35,20),Vector2i(42,23),Vector2i(18,42),Vector2i(42,42)]:
		_set_block(image,p.x,p.y,WHITE,2)
	_ellipse(image,Rect2i(18,30,8,9),WHITE)
	_ellipse(image,Rect2i(20,32,5,6),EYE)
	_set_block(image,23,32,VIOLET_L,0)
	_ellipse(image,Rect2i(34,29,8,9),WHITE)
	_ellipse(image,Rect2i(36,31,5,6),EYE)
	_set_block(image,39,31,VIOLET_L,0)
	_poly(image,[Vector2i(28,39),Vector2i(31,41),Vector2i(34,39),Vector2i(31,43)],GOLD_L)
	for x: int in [19,27,36]:
		_line(image,Vector2i(x,46),Vector2i(x-4,57),VIOLET,1)
		_set_block(image,x-5,58,CRYSTAL,1)
	for x: int in [24,33,41]:
		_line(image,Vector2i(x,47),Vector2i(x+4,57),VIOLET,1)
		_set_block(image,x+5,58,CRYSTAL,1)
	_draw_segmented_antenna(image,Vector2i(21,25),Vector2i(12,8))
	_draw_segmented_antenna(image,Vector2i(38,24),Vector2i(48,7))

static func _draw_drobnoskok(image: Image) -> void:
	# Armored pillbug-like jumper with gold crystal plates and one large eye.
	_ellipse_outline(image,Rect2i(12,24,41,25),OUTLINE,LAV)
	for i: int in range(5):
		var x: int=16+i*7
		_poly(image,[Vector2i(x,24),Vector2i(x+5,21),Vector2i(x+9,27),Vector2i(x+6,34),Vector2i(x,34)],SHADOW if i%2==0 else LAV_D)
		_set_block(image,x+5,25,GOLD if i%2==0 else CRYSTAL,1)
	_poly(image,[Vector2i(18,27),Vector2i(25,18),Vector2i(34,18),Vector2i(38,26)],LAV_L)
	_ellipse(image,Rect2i(18,27,10,11),WHITE)
	_ellipse(image,Rect2i(21,29,6,7),EYE)
	_set_block(image,24,29,VIOLET_L,0)
	_poly(image,[Vector2i(13,34),Vector2i(5,37),Vector2i(14,40)],GOLD_L)
	for i: int in range(4):
		var x: int=20+i*8
		_line(image,Vector2i(x,46),Vector2i(x-3,57),OUTLINE,1)
		_set_block(image,x-4,58,GOLD,1)
		_line(image,Vector2i(x+3,46),Vector2i(x+7,55),OUTLINE,1)
	_draw_micro_shards(image,[Vector2i(30,16),Vector2i(40,19),Vector2i(47,24)])

static func _draw_kwantomruk(image: Image) -> void:
	# Crystalline deer with branching antenna-antlers and segmented tail.
	_poly(image,[Vector2i(18,31),Vector2i(25,21),Vector2i(39,20),Vector2i(48,28),Vector2i(47,42),Vector2i(27,43)],CRYSTAL)
	_poly(image,[Vector2i(35,23),Vector2i(39,10),Vector2i(47,7),Vector2i(54,12),Vector2i(53,22),Vector2i(46,29)],LAV_L)
	_poly(image,[Vector2i(47,8),Vector2i(46,2),Vector2i(51,6)],CRYSTAL_L)
	_poly(image,[Vector2i(52,10),Vector2i(57,4),Vector2i(56,13)],CRYSTAL_L)
	_poly(image,[Vector2i(39,10),Vector2i(36,3),Vector2i(43,7)],GOLD_L)
	_ellipse(image,Rect2i(48,12,6,6),WHITE)
	_ellipse(image,Rect2i(50,13,3,4),EYE)
	_poly(image,[Vector2i(53,18),Vector2i(62,19),Vector2i(54,23)],WHITE)
	for p: Vector2i in [Vector2i(25,27),Vector2i(33,24),Vector2i(40,30),Vector2i(29,38)]:
		_poly(image,[p+Vector2i(0,-3),p+Vector2i(3,0),p+Vector2i(0,3),p+Vector2i(-3,0)],VIOLET_L)
	for x: int in [24,34,43]:
		_line(image,Vector2i(x,41),Vector2i(x-2,58),SHADOW,2)
		_set_block(image,x-2,59,CRYSTAL_L,1)
	_line(image,Vector2i(19,33),Vector2i(7,42),CRYSTAL,2)
	_line(image,Vector2i(7,42),Vector2i(3,49),VIOLET,1)
	_draw_branch_antler(image,Vector2i(43,10),-1)
	_draw_branch_antler(image,Vector2i(50,9),1)

static func _make_frame(base: Image, action: String, frame: int) -> Image:
	match action:
		"idle":
			var dx: Array[int]=[0,1,0,-1]
			var dy: Array[int]=[0,-1,0,1]
			return _place(base,dx[frame],dy[frame],1.0,1.0,1.0)
		"attack":
			var dx: Array[int]=[0,8,19,28,13,2]
			var dy: Array[int]=[0,-2,-5,-3,-1,0]
			var result: Image=_place(base,dx[frame],dy[frame],1.0,0.96 if frame==3 else 1.0,1.0)
			if frame in [1,2,3,4]: _draw_micro_afterimages(result,frame)
			if frame in [2,3,4]: _draw_shard_cut(result,frame)
			return result
		"hurt":
			var hx: Array[int]=[-7,6,0]
			var hurt: Image=_place(base,hx[frame],1 if frame<2 else 0,0.98,0.98,1.0)
			_tint_red(hurt,0.5 if frame<2 else 0.17)
			return hurt
		"faint":
			var t: float=float(frame)/float(maxi(1,frame_count("faint")-1))
			return _place(base,int(round(-5.0*t)),int(round(24.0*t)),1.0+0.06*t,1.0-0.58*t,1.0-0.8*t)
		"special":
			var p: float=float(frame)/float(maxi(1,frame_count("special")-1))
			var special: Image=_place(base,0,-int(round(2.0*sin(p*PI))),1.0+0.05*sin(p*PI),1.0+0.05*sin(p*PI),1.0)
			_draw_quantum_grid(special,frame)
			return special
	return base.duplicate()

static func _draw_micro_afterimages(image: Image, phase: int) -> void:
	for i: int in range(3):
		var x: int=17+i*8+phase*3
		var alpha: float=0.2+0.12*float(i)
		_line(image,Vector2i(x,40),Vector2i(x+10,40-i*4),Color(CRYSTAL.r,CRYSTAL.g,CRYSTAL.b,alpha),1)

static func _draw_shard_cut(image: Image, phase: int) -> void:
	var center:=Vector2i(99,62)
	for i: int in range(6):
		var angle: float=deg_to_rad(-60.0+float(i)*24.0)
		var r: float=13.0+float(phase*4+i)
		var p:=Vector2i(center.x+int(round(cos(angle)*r)),center.y+int(round(sin(angle)*r)))
		_poly(image,[p+Vector2i(0,-3),p+Vector2i(2,0),p+Vector2i(0,3),p+Vector2i(-2,0)],CRYSTAL_L if i%2==0 else VIOLET_L)

static func _draw_quantum_grid(image: Image, phase: int) -> void:
	for i: int in range(5):
		var offset: int=(phase*3+i*11)%54
		_line(image,Vector2i(20+offset,26),Vector2i(20+offset,102),Color(TEAL.r,TEAL.g,TEAL.b,0.28),0)
		_line(image,Vector2i(18,30+offset),Vector2i(110,30+offset),Color(VIOLET_L.r,VIOLET_L.g,VIOLET_L.b,0.24),0)
	for i: int in range(8):
		var angle: float=float(i)*TAU/8.0+float(phase)*0.3
		var r: float=24.0+float((i+phase)%3)*7.0
		_set_block(image,64+int(round(cos(angle)*r)),64+int(round(sin(angle)*r)),WHITE,1)

static func _draw_segmented_antenna(image: Image, root: Vector2i, tip: Vector2i) -> void:
	var prev:=root
	for i: int in range(1,6):
		var t: float=float(i)/5.0
		var p:=Vector2i(int(round(lerpf(float(root.x),float(tip.x),t))),int(round(lerpf(float(root.y),float(tip.y),t))))
		_line(image,prev,p,SHADOW,1)
		_set_block(image,p.x,p.y,CRYSTAL if i%2==0 else VIOLET,1)
		prev=p

static func _draw_branch_antler(image: Image, root: Vector2i, direction: int) -> void:
	_line(image,root,root+Vector2i(direction*5,-10),CRYSTAL_L,1)
	_line(image,root+Vector2i(direction*3,-5),root+Vector2i(direction*10,-8),VIOLET_L,1)
	_line(image,root+Vector2i(direction*4,-8),root+Vector2i(direction*7,-14),GOLD_L,1)

static func _draw_micro_shards(image: Image, points: Array[Vector2i]) -> void:
	for p: Vector2i in points:
		_poly(image,[p+Vector2i(0,-2),p+Vector2i(2,0),p+Vector2i(0,2),p+Vector2i(-2,0)],CRYSTAL_L)

static func _place(base: Image, dx: int, dy: int, sx: float, sy: float, alpha: float) -> Image:
	var transformed: Image=base.duplicate()
	var width: int=maxi(1,int(round(128.0*sx))); var height: int=maxi(1,int(round(128.0*sy)))
	if width!=128 or height!=128: transformed.resize(width,height,Image.INTERPOLATE_NEAREST)
	if alpha<0.999: _multiply_alpha(transformed,alpha)
	var canvas:=Image.create(128,128,false,Image.FORMAT_RGBA8); canvas.fill(Color(0,0,0,0))
	_blit_clipped(canvas,transformed,int((128-width)/2)+dx,128-height+dy)
	return canvas

static func _blit_clipped(canvas: Image, source: Image, target_x: int, target_y: int) -> void:
	var sx: int=maxi(0,-target_x); var sy: int=maxi(0,-target_y); var dx: int=maxi(0,target_x); var dy: int=maxi(0,target_y)
	var w: int=mini(source.get_width()-sx,128-dx); var h: int=mini(source.get_height()-sy,128-dy)
	if w>0 and h>0: canvas.blit_rect(source,Rect2i(sx,sy,w,h),Vector2i(dx,dy))

static func _multiply_alpha(image: Image, alpha: float) -> void:
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			var c:=image.get_pixel(x,y)
			if c.a>0.0: c.a*=alpha; image.set_pixel(x,y,c)

static func _tint_red(image: Image, strength: float) -> void:
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			var c:=image.get_pixel(x,y)
			if c.a>0.0: c.r=lerpf(c.r,1.0,strength); c.g=lerpf(c.g,0.28,strength); c.b=lerpf(c.b,0.34,strength); image.set_pixel(x,y,c)

static func _ellipse_outline(image: Image, rect: Rect2i, outline: Color, fill: Color) -> void:
	_ellipse(image,rect,outline)
	var inner:=Rect2i(rect.position+Vector2i(2,2),rect.size-Vector2i(4,4))
	if inner.size.x>0 and inner.size.y>0: _ellipse(image,inner,fill)

static func _ellipse(image: Image, rect: Rect2i, color: Color) -> void:
	var rx: float=maxf(0.5,float(rect.size.x)*0.5); var ry: float=maxf(0.5,float(rect.size.y)*0.5); var cx: float=float(rect.position.x)+rx; var cy: float=float(rect.position.y)+ry
	for y: int in range(rect.position.y,rect.end.y):
		for x: int in range(rect.position.x,rect.end.x):
			if x<0 or x>=image.get_width() or y<0 or y>=image.get_height(): continue
			var px: float=(float(x)+0.5-cx)/rx; var py: float=(float(y)+0.5-cy)/ry
			if px*px+py*py<=1.0: image.set_pixel(x,y,color)

static func _poly(image: Image, points: Array[Vector2i], color: Color) -> void:
	if points.size()<3: return
	var min_x: int=points[0].x; var max_x: int=points[0].x; var min_y: int=points[0].y; var max_y: int=points[0].y
	for p: Vector2i in points: min_x=mini(min_x,p.x); max_x=maxi(max_x,p.x); min_y=mini(min_y,p.y); max_y=maxi(max_y,p.y)
	for y: int in range(min_y,max_y+1):
		for x: int in range(min_x,max_x+1):
			if x>=0 and x<image.get_width() and y>=0 and y<image.get_height() and _inside(Vector2(float(x)+0.5,float(y)+0.5),points): image.set_pixel(x,y,color)

static func _inside(point: Vector2, points: Array[Vector2i]) -> bool:
	var inside: bool=false; var j: int=points.size()-1
	for i: int in range(points.size()):
		var pi:=points[i]; var pj:=points[j]
		if (pi.y>point.y)!=(pj.y>point.y):
			var cross_x: float=float(pj.x-pi.x)*(point.y-float(pi.y))/float(pj.y-pi.y)+float(pi.x)
			if point.x<cross_x: inside=not inside
		j=i
	return inside

static func _line(image: Image, a: Vector2i, b: Vector2i, color: Color, radius: int) -> void:
	var steps: int=maxi(abs(b.x-a.x),abs(b.y-a.y))
	if steps<=0: _set_block(image,a.x,a.y,color,radius); return
	for i: int in range(steps+1):
		var t: float=float(i)/float(steps)
		_set_block(image,int(round(lerpf(float(a.x),float(b.x),t))),int(round(lerpf(float(a.y),float(b.y),t))),color,radius)

static func _set_block(image: Image, cx: int, cy: int, color: Color, radius: int) -> void:
	for y: int in range(cy-radius,cy+radius+1):
		for x: int in range(cx-radius,cx+radius+1):
			if x>=0 and x<image.get_width() and y>=0 and y<image.get_height(): image.set_pixel(x,y,color)
