extends RefCounted

const SEEDS = preload("res://scripts/battle/creature_seed_atlas_db.gd")
const ACTIONS: Array[String] = ["idle", "attack", "hurt", "faint", "special"]
const FRAME_COUNTS: Dictionary = {"idle":4, "attack":6, "hurt":3, "faint":5, "special":6}

const FAMILIES: Dictionary = {
	11:{"names":["Dwumik","Synchroap","Chorogrif"],"profile":"phase_duo"},
	12:{"names":["Fazik","Kontrafal","Antyfonix"],"profile":"anti_phase"},
	13:{"names":["Tropiciel","Dalekoskok","Sieciowid"],"profile":"trace_dash"},
	14:{"names":["Przeskok","Wezowiec","Portalnik"],"profile":"portal_shift"},
	16:{"names":["Petelka","Sprzezyk","Cyberwibr"],"profile":"closed_loop"},
	17:{"names":["Dudnik","Fazodud","Interferon"],"profile":"interference"},
	18:{"names":["Wirutek","Spirydrz","Galaktylion"],"profile":"spiral"},
	19:{"names":["Hercek","Akceler","Metronotron"],"profile":"sensor_meter"},
	20:{"names":["Szewik","Blizgacz","Regenerion"],"profile":"scar_recovery"}
}

static var _frame_cache: Dictionary = {}

static func names() -> Array[String]:
	var result: Array[String] = []
	for raw_family_id: Variant in FAMILIES.keys():
		for raw_name: Variant in (FAMILIES[raw_family_id] as Dictionary).get("names", []) as Array:
			result.append(str(raw_name))
	result.sort()
	return result

static func animation_count() -> int: return names().size()
static func has_animation(creature_name: String) -> bool: return names().has(creature_name)

static func family_id(creature_name: String) -> int:
	for raw_family_id: Variant in FAMILIES.keys():
		var family: Dictionary = FAMILIES[raw_family_id] as Dictionary
		if (family.get("names", []) as Array).has(creature_name): return int(raw_family_id)
	return 0

static func profile(creature_name: String) -> String:
	var id: int = family_id(creature_name)
	var data: Dictionary = FAMILIES.get(id, {}) as Dictionary
	return str(data.get("profile", "default"))

static func frame_count(action: String) -> int: return maxi(1, int(FRAME_COUNTS.get(action, 1)))

static func frame_texture(creature_name: String, action: String, frame: int) -> Texture2D:
	if not has_animation(creature_name) or not SEEDS.is_approved(creature_name): return null
	if action not in ACTIONS: action = "idle"
	var safe_frame: int = clampi(frame, 0, frame_count(action) - 1)
	var key: String = "%s|%s|%d" % [creature_name, action, safe_frame]
	if _frame_cache.has(key): return _frame_cache[key] as Texture2D
	var seed: Image = SEEDS.image_for(creature_name)
	if seed == null: return null
	var image: Image = _make_frame(seed, action, safe_frame, profile(creature_name))
	var texture: Texture2D = ImageTexture.create_from_image(image)
	_frame_cache[key] = texture
	return texture

static func _make_frame(seed: Image, action: String, frame: int, family_profile: String) -> Image:
	var count: int = frame_count(action)
	var t: float = 0.0 if count <= 1 else float(frame) / float(count - 1)
	var dx: int = 0; var dy: int = 0; var sx: float = 1.0; var sy: float = 1.0; var alpha: float = 1.0
	match action:
		"idle":
			dy = [0,-2,1,0][frame]; dx = _idle_side(family_profile, frame)
		"attack":
			dx = [0,5,12,19,9,2][frame]; dy = _attack_y(family_profile, frame)
			if family_profile in ["phase_duo","interference","spiral"] and frame in [2,3]: sx = 1.06; sy = 0.96
		"hurt":
			dx = [-6,5,0][frame]; dy = [1,2,0][frame]; sx = [0.97,1.02,1.0][frame]
		"faint":
			dy = [0,5,11,20,30][frame]; sy = [1.0,0.92,0.76,0.55,0.30][frame]; sx = [1.0,1.02,1.04,1.07,1.10][frame]; alpha = [1.0,0.94,0.80,0.58,0.30][frame]
		"special":
			var pulse: float = sin(t * PI); dx = _special_x(family_profile, frame); dy = -int(round(6.0 * pulse)); sx = 1.0 + 0.10 * pulse; sy = 1.0 + 0.10 * pulse
	var image: Image = _place(seed, dx, dy, sx, sy, alpha)
	_draw_signature(image, family_profile, action, frame, t)
	if action == "hurt" and frame < 2: _tint(image, Color(1.0,0.32,0.32,1.0), 0.26)
	return image

static func _idle_side(p: String, frame: int) -> int:
	match p:
		"trace_dash": return [0,1,0,-1][frame]
		"portal_shift": return [0,-1,1,0][frame]
		"spiral": return [0,1,-1,0][frame]
		_: return 0

static func _attack_y(p: String, frame: int) -> int:
	var base: Array[int] = [0,-1,-3,-5,-2,0]
	if p in ["portal_shift","spiral"]: return base[frame] - (2 if frame in [2,3] else 0)
	if p == "scar_recovery": return [0,0,-1,-2,-1,1][frame]
	return base[frame]

static func _special_x(p: String, frame: int) -> int:
	match p:
		"anti_phase": return [0,-2,2,-2,2,0][frame]
		"spiral": return [0,2,3,0,-3,0][frame]
		"portal_shift": return [0,-3,-1,2,3,0][frame]
		_: return 0

static func _draw_signature(image: Image, p: String, action: String, frame: int, t: float) -> void:
	var cyan := Color(0.38,0.93,0.94,0.86); var violet := Color(0.74,0.46,0.96,0.82); var gold := Color(1.0,0.78,0.31,0.88); var green := Color(0.47,0.94,0.59,0.82); var center := Vector2i(64,65)
	_set_safe(image, 13 + frame * 2, 112 - _profile_family_id(p), cyan)
	match p:
		"phase_duo":
			if action in ["attack","special"]: _draw_ring(image,center,24+frame*3,cyan); _draw_ring(image,center,31+frame*2,violet)
		"anti_phase":
			if action in ["attack","special"]:
				var span: int=16+frame*4; _draw_line(image,Vector2i(64-span,48+frame),Vector2i(64+span,82-frame),cyan); _draw_line(image,Vector2i(64-span,82-frame),Vector2i(64+span,48+frame),violet)
		"trace_dash":
			if action in ["attack","special"]:
				for trail: int in range(3): _draw_line(image,Vector2i(22-trail*5,55+trail*8),Vector2i(48+frame*5,55+trail*8),Color(cyan.r,cyan.g,cyan.b,0.55-float(trail)*0.12))
		"portal_shift":
			if action in ["attack","special"]: _draw_ring(image,Vector2i(92,63),10+frame*3,violet); _draw_ring(image,Vector2i(92,63),5+frame*2,cyan)
		"closed_loop":
			if action in ["attack","special"]: _draw_ring(image,center,18+frame*4,gold); _draw_arc_points(image,center,27+frame*2,frame,cyan)
		"interference":
			if action in ["attack","special"]:
				for off: int in [-10,0,10]: _draw_wave(image,36+off,88+frame*3,54+frame,cyan if off != 0 else violet)
		"spiral":
			if action in ["attack","special"]: _draw_spiral(image,center,10+frame*4,frame,violet)
		"sensor_meter":
			if action in ["attack","special"]: _draw_line(image,center,Vector2i(64+int(cos(t*PI*1.5)*38.0),65+int(sin(t*PI*1.5)*25.0)),gold); _draw_ring(image,center,30+frame,Color(0.35,0.95,0.70,0.55))
		"scar_recovery":
			if action == "hurt": _draw_line(image,Vector2i(49,45),Vector2i(75,84),Color(1.0,0.38,0.38,0.85))
			if action == "special":
				for i: int in range(4): _draw_line(image,Vector2i(43+i*10,92-frame*3),Vector2i(43+i*10,74-frame*2),green)

static func _profile_family_id(p: String) -> int:
	for raw_id: Variant in FAMILIES.keys():
		if str((FAMILIES[raw_id] as Dictionary).get("profile", "")) == p: return int(raw_id)
	return 0

static func _place(seed: Image, dx: int, dy: int, sx: float, sy: float, alpha: float) -> Image:
	var source: Image=seed.duplicate(); var w: int=maxi(1,int(round(128.0*sx))); var h: int=maxi(1,int(round(128.0*sy)))
	if w != 128 or h != 128: source.resize(w,h,Image.INTERPOLATE_NEAREST)
	if alpha < 0.999:
		for y: int in range(source.get_height()):
			for x: int in range(source.get_width()):
				var c: Color=source.get_pixel(x,y)
				if c.a>0.0: c.a*=alpha; source.set_pixel(x,y,c)
	var canvas:=Image.create(128,128,false,Image.FORMAT_RGBA8); canvas.fill(Color(0,0,0,0)); var tx: int=int((128-w)/2)+dx; var ty: int=128-h+dy
	var sx0: int=maxi(0,-tx); var sy0: int=maxi(0,-ty); var dx0: int=maxi(0,tx); var dy0: int=maxi(0,ty); var bw: int=mini(w-sx0,128-dx0); var bh: int=mini(h-sy0,128-dy0)
	if bw>0 and bh>0: canvas.blit_rect(source,Rect2i(sx0,sy0,bw,bh),Vector2i(dx0,dy0))
	return canvas

static func _tint(image: Image, target: Color, strength: float) -> void:
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			var c: Color=image.get_pixel(x,y)
			if c.a<=0.0: continue
			c.r=lerpf(c.r,target.r,strength); c.g=lerpf(c.g,target.g,strength); c.b=lerpf(c.b,target.b,strength); image.set_pixel(x,y,c)

static func _set_safe(image: Image, x: int, y: int, color: Color) -> void:
	if x>=0 and x<128 and y>=0 and y<128: image.set_pixel(x,y,color)

static func _draw_line(image: Image, a: Vector2i, b: Vector2i, color: Color) -> void:
	var x0: int=a.x; var y0: int=a.y; var x1: int=b.x; var y1: int=b.y; var dx: int=abs(x1-x0); var sx: int=1 if x0<x1 else -1; var dy: int=-abs(y1-y0); var sy: int=1 if y0<y1 else -1; var err: int=dx+dy
	while true:
		_set_safe(image,x0,y0,color)
		if x0==x1 and y0==y1: break
		var e2: int=2*err
		if e2>=dy: err+=dy; x0+=sx
		if e2<=dx: err+=dx; y0+=sy

static func _draw_ring(image: Image, center: Vector2i, radius: int, color: Color) -> void:
	for degree: int in range(0,360,6):
		var r: float=deg_to_rad(float(degree)); _set_safe(image,center.x+int(round(cos(r)*radius)),center.y+int(round(sin(r)*radius)),color)

static func _draw_arc_points(image: Image, center: Vector2i, radius: int, frame: int, color: Color) -> void:
	for i: int in range(8):
		var r: float=(float(i)/8.0)*TAU+float(frame)*0.33; _set_safe(image,center.x+int(round(cos(r)*radius)),center.y+int(round(sin(r)*radius)),color)

static func _draw_wave(image: Image, x0: int, x1: int, y: int, color: Color) -> void:
	for x: int in range(x0,x1): _set_safe(image,x,y+int(round(sin(float(x-x0)*0.33)*4.0)),color)

static func _draw_spiral(image: Image, center: Vector2i, radius: int, frame: int, color: Color) -> void:
	for i: int in range(48):
		var t: float=float(i)/47.0; var r: float=t*float(radius); var a: float=t*TAU*2.2+float(frame)*0.45; _set_safe(image,center.x+int(round(cos(a)*r)),center.y+int(round(sin(a)*r)),color)
