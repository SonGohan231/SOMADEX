extends RefCounted

# Reverse visual-production pass: family 002 (Bocznik -> Slizgogon -> Horyzontor).
# Source identity: tangential shear. The line evolves from a low gliding
# amphibious creature into increasingly aerodynamic winged horizon-gliders.

const ACTIONS: Array[String] = ["idle","attack","hurt","faint","special"]
const ACTION_FRAME_COUNTS: Dictionary = {"idle":4,"attack":6,"hurt":3,"faint":5,"special":6}
const NAMES: Array[String] = ["Bocznik","Slizgogon","Horyzontor"]

const OUTLINE:=Color("17293a")
const LIME_D:=Color("6b8d37")
const LIME:=Color("a8d84d")
const LIME_L:=Color("d8f879")
const BLUE_D:=Color("315f8d")
const BLUE:=Color("4a8ac0")
const BLUE_L:=Color("8bc8e5")
const CYAN:=Color("6fe5e8")
const WHITE:=Color("f9fff2")
const EYE:=Color("071425")
const GOLD:=Color("e0b64e")
const GREEN:=Color("76c954")

static var _base_cache: Dictionary={}
static var _frame_cache: Dictionary={}

static func has_animation(creature_name:String)->bool: return creature_name in NAMES
static func animation_count()->int: return NAMES.size()
static func frame_count(action:String)->int: return maxi(1,int(ACTION_FRAME_COUNTS.get(action,1)))

static func frame_texture(creature_name:String,action:String,frame:int)->Texture2D:
	if not has_animation(creature_name): return null
	if action not in ACTIONS: action="idle"
	var f:int=clampi(frame,0,frame_count(action)-1)
	var key:String="%s|%s|%d"%[creature_name,action,f]
	if _frame_cache.has(key): return _frame_cache[key] as Texture2D
	var base:Image=_base_image(creature_name)
	if base==null: return null
	var image:Image=_make_frame(base,action,f)
	var texture:Texture2D=ImageTexture.create_from_image(image)
	_frame_cache[key]=texture
	return texture

static func _base_image(name:String)->Image:
	if _base_cache.has(name): return _base_cache[name] as Image
	var im:=Image.create(64,64,false,Image.FORMAT_RGBA8); im.fill(Color(0,0,0,0))
	match name:
		"Bocznik": _draw_bocznik(im)
		"Slizgogon": _draw_slizgogon(im)
		"Horyzontor": _draw_horyzontor(im)
		_: return null
	im.resize(128,128,Image.INTERPOLATE_NEAREST); _base_cache[name]=im; return im

static func _draw_bocznik(im:Image)->void:
	_ellipse_outline(im,Rect2i(14,28,35,19),OUTLINE,LIME)
	_poly(im,[Vector2i(18,33),Vector2i(9,23),Vector2i(14,39)],BLUE)
	_poly(im,[Vector2i(23,28),Vector2i(18,17),Vector2i(29,25)],GREEN)
	_poly(im,[Vector2i(32,28),Vector2i(37,16),Vector2i(41,29)],GREEN)
	_poly(im,[Vector2i(40,30),Vector2i(51,20),Vector2i(48,35)],LIME_L)
	_ellipse(im,Rect2i(17,31,8,8),WHITE); _ellipse(im,Rect2i(20,33,4,5),EYE); _plot(im,22,33,CYAN,0)
	for p:Vector2i in [Vector2i(28,34),Vector2i(36,32),Vector2i(41,38)]: _plot(im,p.x,p.y,BLUE_L,1)
	for x:int in [21,31,41]: _line(im,Vector2i(x,44),Vector2i(x-3,55),BLUE_D,1); _plot(im,x-4,56,OUTLINE,1)
	_line(im,Vector2i(47,38),Vector2i(58,42),LIME_D,2)

static func _draw_slizgogon(im:Image)->void:
	_poly(im,[Vector2i(11,34),Vector2i(23,26),Vector2i(40,24),Vector2i(54,29),Vector2i(58,35),Vector2i(46,39),Vector2i(27,40)],BLUE)
	_poly(im,[Vector2i(28,28),Vector2i(14,10),Vector2i(7,11),Vector2i(16,31)],GREEN)
	_poly(im,[Vector2i(35,27),Vector2i(46,8),Vector2i(56,10),Vector2i(47,31)],LIME)
	_line(im,Vector2i(18,13),Vector2i(28,27),LIME_L,1); _line(im,Vector2i(48,11),Vector2i(38,28),LIME_L,1)
	_poly(im,[Vector2i(44,25),Vector2i(49,15),Vector2i(57,18),Vector2i(59,27),Vector2i(52,31)],BLUE_L)
	_ellipse(im,Rect2i(53,20,6,6),WHITE); _ellipse(im,Rect2i(55,21,3,4),EYE)
	_line(im,Vector2i(13,36),Vector2i(3,44),BLUE_D,2)
	_line(im,Vector2i(3,44),Vector2i(1,55),LIME_D,1)
	_poly(im,[Vector2i(1,53),Vector2i(8,49),Vector2i(6,59)],LIME)
	for x:int in [24,38]: _line(im,Vector2i(x,39),Vector2i(x-2,52),OUTLINE,1)

static func _draw_horyzontor(im:Image)->void:
	_poly(im,[Vector2i(3,32),Vector2i(15,25),Vector2i(35,24),Vector2i(53,28),Vector2i(62,33),Vector2i(53,38),Vector2i(32,39),Vector2i(14,37)],BLUE)
	_poly(im,[Vector2i(24,27),Vector2i(10,8),Vector2i(2,12),Vector2i(15,32)],LIME)
	_poly(im,[Vector2i(38,27),Vector2i(51,7),Vector2i(62,12),Vector2i(49,32)],GREEN)
	_line(im,Vector2i(12,12),Vector2i(25,28),LIME_L,1); _line(im,Vector2i(53,11),Vector2i(40,29),LIME_L,1)
	_poly(im,[Vector2i(43,27),Vector2i(49,19),Vector2i(58,22),Vector2i(62,29),Vector2i(55,33)],BLUE_L)
	_ellipse(im,Rect2i(54,23,6,6),WHITE); _ellipse(im,Rect2i(56,24,3,4),EYE)
	_line(im,Vector2i(5,34),Vector2i(0,43),BLUE_D,2)
	_poly(im,[Vector2i(4,39),Vector2i(0,52),Vector2i(11,45)],LIME)
	for p:Vector2i in [Vector2i(20,29),Vector2i(31,27),Vector2i(42,30)]: _plot(im,p.x,p.y,CYAN,1)

static func _make_frame(base:Image,action:String,frame:int)->Image:
	match action:
		"idle":
			var y:Array[int]=[0,-1,0,1]; return _place(base,0,y[frame],1.0,1.0,1.0)
		"attack":
			var dx:Array[int]=[0,6,15,25,13,2]; var dy:Array[int]=[0,-1,-3,-4,-2,0]
			var r:Image=_place(base,dx[frame],dy[frame],1.03 if frame==3 else 1.0,0.98,1.0)
			if frame in [2,3,4]: _draw_tangent_cut(r,frame)
			return r
		"hurt":
			var hx:Array[int]=[-6,5,0]; var h:Image=_place(base,hx[frame],1,0.98,0.98,1.0); _tint_red(h,0.45 if frame<2 else 0.17); return h
		"faint":
			var t:float=float(frame)/float(maxi(1,frame_count("faint")-1)); return _place(base,-int(round(6.0*t)),int(round(23.0*t)),1.0+0.1*t,1.0-0.6*t,1.0-0.8*t)
		"special":
			var p:float=float(frame)/float(maxi(1,frame_count("special")-1)); var s:Image=_place(base,0,-int(round(3.0*sin(p*PI))),1.0+0.04*sin(p*PI),1.0,1.0); _draw_stream_field(s,frame); return s
	return base.duplicate()

static func _draw_tangent_cut(im:Image,phase:int)->void:
	for layer:int in range(3):
		var y:int=50+layer*13
		_line(im,Vector2i(78+phase*3,y),Vector2i(124,y-5+phase),Color(CYAN.r,CYAN.g,CYAN.b,0.72),1)
		_line(im,Vector2i(86+phase*2,y+4),Vector2i(120,y+8),Color(LIME_L.r,LIME_L.g,LIME_L.b,0.55),0)

static func _draw_stream_field(im:Image,phase:int)->void:
	for lane:int in range(6):
		var y:int=30+lane*14
		var shift:int=(phase*7+lane*5)%20
		_line(im,Vector2i(9+shift,y),Vector2i(113,y-5+lane%3),Color(BLUE_L.r,BLUE_L.g,BLUE_L.b,0.40),0)
		for x:int in range(18+shift,112,24): _plot(im,x,y,CYAN,1)
	_draw_partial_ring(im,Vector2i(64,65),22+phase*4,160,380,Color(LIME_L.r,LIME_L.g,LIME_L.b,0.55),1)

static func _place(base:Image,dx:int,dy:int,sx:float,sy:float,alpha:float)->Image:
	var tr:Image=base.duplicate(); var w:int=maxi(1,int(round(128.0*sx))); var h:int=maxi(1,int(round(128.0*sy)))
	if w!=128 or h!=128: tr.resize(w,h,Image.INTERPOLATE_NEAREST)
	if alpha<0.999: _alpha(tr,alpha)
	var c:=Image.create(128,128,false,Image.FORMAT_RGBA8); c.fill(Color(0,0,0,0)); _blit(c,tr,int((128-w)/2)+dx,128-h+dy); return c

static func _blit(c:Image,s:Image,tx:int,ty:int)->void:
	var sx:int=maxi(0,-tx); var sy:int=maxi(0,-ty); var dx:int=maxi(0,tx); var dy:int=maxi(0,ty); var w:int=mini(s.get_width()-sx,128-dx); var h:int=mini(s.get_height()-sy,128-dy)
	if w>0 and h>0: c.blit_rect(s,Rect2i(sx,sy,w,h),Vector2i(dx,dy))

static func _alpha(im:Image,a:float)->void:
	for y:int in range(im.get_height()):
		for x:int in range(im.get_width()):
			var c:=im.get_pixel(x,y); c.a*=a; im.set_pixel(x,y,c)

static func _tint_red(im:Image,a:float)->void:
	for y:int in range(im.get_height()):
		for x:int in range(im.get_width()):
			var c:=im.get_pixel(x,y)
			if c.a>0.0: c.r=lerpf(c.r,1.0,a); c.g=lerpf(c.g,0.3,a); c.b=lerpf(c.b,0.3,a); im.set_pixel(x,y,c)

static func _ellipse_outline(im:Image,r:Rect2i,o:Color,f:Color)->void:
	_ellipse(im,r,o); var inner:=Rect2i(r.position+Vector2i(2,2),r.size-Vector2i(4,4)); if inner.size.x>0 and inner.size.y>0: _ellipse(im,inner,f)

static func _ellipse(im:Image,r:Rect2i,c:Color)->void:
	var rx:float=maxf(0.5,float(r.size.x)*0.5); var ry:float=maxf(0.5,float(r.size.y)*0.5); var cx:float=float(r.position.x)+rx; var cy:float=float(r.position.y)+ry
	for y:int in range(r.position.y,r.end.y):
		for x:int in range(r.position.x,r.end.x):
			if x>=0 and x<im.get_width() and y>=0 and y<im.get_height():
				var px:float=(float(x)+0.5-cx)/rx; var py:float=(float(y)+0.5-cy)/ry; if px*px+py*py<=1.0: im.set_pixel(x,y,c)

static func _poly(im:Image,pts:Array[Vector2i],c:Color)->void:
	if pts.size()<3:return
	var minx:int=pts[0].x;var maxx:int=pts[0].x;var miny:int=pts[0].y;var maxy:int=pts[0].y
	for p:Vector2i in pts:minx=mini(minx,p.x);maxx=maxi(maxx,p.x);miny=mini(miny,p.y);maxy=maxi(maxy,p.y)
	for y:int in range(miny,maxy+1):
		for x:int in range(minx,maxx+1):
			if x>=0 and x<im.get_width() and y>=0 and y<im.get_height() and _inside(Vector2(x+0.5,y+0.5),pts): im.set_pixel(x,y,c)

static func _inside(p:Vector2,pts:Array[Vector2i])->bool:
	var inside:bool=false;var j:int=pts.size()-1
	for i:int in range(pts.size()):
		var a:=pts[i];var b:=pts[j]
		if (a.y>p.y)!=(b.y>p.y):
			var cross:float=float(b.x-a.x)*(p.y-float(a.y))/float(b.y-a.y)+float(a.x);if p.x<cross:inside=not inside
		j=i
	return inside

static func _line(im:Image,a:Vector2i,b:Vector2i,c:Color,r:int)->void:
	var steps:int=maxi(abs(b.x-a.x),abs(b.y-a.y));if steps<=0:_plot(im,a.x,a.y,c,r);return
	for i:int in range(steps+1):
		var t:float=float(i)/float(steps);_plot(im,int(round(lerpf(a.x,b.x,t))),int(round(lerpf(a.y,b.y,t))),c,r)

static func _plot(im:Image,x:int,y:int,c:Color,r:int)->void:
	for yy:int in range(y-r,y+r+1):
		for xx:int in range(x-r,x+r+1):
			if xx>=0 and xx<im.get_width() and yy>=0 and yy<im.get_height():im.set_pixel(xx,yy,c)

static func _draw_partial_ring(im:Image,center:Vector2i,radius:int,start_degree:int,end_degree:int,c:Color,thickness:int)->void:
	for degree:int in range(start_degree,end_degree+1,6):
		var a:float=deg_to_rad(float(degree));_plot(im,center.x+int(round(cos(a)*radius)),center.y+int(round(sin(a)*radius)),c,thickness)
