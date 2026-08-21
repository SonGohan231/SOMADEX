extends RefCounted

const SEEDS = preload("res://scripts/battle/creature_seed_atlas_db.gd")
const ACTIONS: Array[String] = ["idle", "attack", "hurt", "faint", "special"]
const FRAME_COUNTS: Dictionary = {"idle":4, "attack":6, "hurt":3, "faint":5, "special":6}
const FRAME_SIZE := Vector2i(128, 128)

const FAMILIES: Dictionary = {
	21:{"names":["Tchnik","Ruchodmuch","Autonomir"],"profile":"breath_motion"},
	23:{"names":["Iskrokol","Piezousk","Elektrokoral"],"profile":"piezo_pulse"},
	27:{"names":["Kropelka","Osemnik","Hydrainfinity"],"profile":"fluid_eight"},
	28:{"names":["Mostek","Cisnieniak","Pneumost"],"profile":"pressure_bridge"},
	29:{"names":["Echonerw","Synapsik","Neurogryf"],"profile":"neural_echo"},
	30:{"names":["Kafelek","Mozaur","Anatomorf"],"profile":"mosaic_shift"}
}

static var _cache: Dictionary = {}

static func names() -> Array[String]:
	var result: Array[String] = []
	for raw_family: Variant in FAMILIES.values():
		for raw_name: Variant in (raw_family as Dictionary).get("names", []) as Array:
			result.append(str(raw_name))
	result.sort()
	return result

static func animation_count() -> int:
	return names().size()

static func has_animation(creature_name: String) -> bool:
	return names().has(creature_name) and SEEDS.is_approved(creature_name)

static func frame_count(action: String) -> int:
	return maxi(1, int(FRAME_COUNTS.get(action, 1)))

static func profile(creature_name: String) -> String:
	for raw_family: Variant in FAMILIES.values():
		var family: Dictionary = raw_family as Dictionary
		if (family.get("names", []) as Array).has(creature_name):
			return str(family.get("profile", "default"))
	return "default"

static func frame_texture(creature_name: String, action: String, frame: int) -> Texture2D:
	if not has_animation(creature_name):
		return null
	if action not in ACTIONS:
		action = "idle"
	var safe_frame: int = clampi(frame, 0, frame_count(action) - 1)
	var key: String = "%s|%s|%d" % [creature_name, action, safe_frame]
	if _cache.has(key):
		return _cache[key] as Texture2D
	var seed: Image = SEEDS.image_for(creature_name)
	if seed == null:
		return null
	var image: Image = _make_frame(seed, action, safe_frame, profile(creature_name))
	var texture := ImageTexture.create_from_image(image)
	_cache[key] = texture
	return texture

static func _make_frame(seed: Image, action: String, frame: int, motion: String) -> Image:
	var count: int = frame_count(action)
	var t: float = 0.0 if count <= 1 else float(frame) / float(count - 1)
	var dx: int = 0
	var dy: int = 0
	var sx: float = 1.0
	var sy: float = 1.0
	var alpha: float = 1.0
	match action:
		"idle":
			dy = [0,-2,0,1][frame]
			if motion in ["fluid_eight","neural_echo"]: dx = [0,1,0,-1][frame]
		"attack":
			dx = [0,5,12,18,9,2][frame]
			dy = [0,-1,-3,-5,-2,0][frame]
			if motion == "pressure_bridge": sy = 1.0 - 0.05 * sin(t * PI)
		"hurt":
			dx = [-6,5,0][frame]
			sx = [0.97,1.02,1.0][frame]
		"faint":
			dy = [0,5,11,20,30][frame]
			sy = [1.0,0.92,0.76,0.55,0.30][frame]
			sx = [1.0,1.02,1.04,1.07,1.10][frame]
			alpha = [1.0,0.94,0.80,0.58,0.30][frame]
		"special":
			var pulse: float = sin(t * PI)
			dy = -int(round(6.0 * pulse))
			sx = 1.0 + 0.10 * pulse
			sy = 1.0 + 0.10 * pulse
			if motion == "mosaic_shift": dx = [0,-2,2,-2,2,0][frame]
	var image: Image = _place(seed, dx, dy, sx, sy, alpha)
	_draw_signature(image, motion, action, frame, t)
	return image

static func _draw_signature(image: Image, motion: String, action: String, frame: int, t: float) -> void:
	if action not in ["idle","attack","special"]:
		return
	var cyan := Color(0.35,0.94,0.95,0.82)
	var gold := Color(1.0,0.78,0.30,0.84)
	var violet := Color(0.74,0.44,0.96,0.82)
	var green := Color(0.43,0.95,0.64,0.82)
	var center := Vector2i(64,66)
	match motion:
		"breath_motion":
			var r: int = 15 + frame * 3
			_draw_arc(image, center + Vector2i(0,10), r, -0.2, 3.35, cyan)
		"piezo_pulse":
			for i: int in range(3):
				_draw_ring(image, center, 13 + i * 9 + frame * 2, gold if i % 2 == 0 else cyan)
		"fluid_eight":
			_draw_figure_eight(image, center, 20 + frame * 2, cyan)
		"pressure_bridge":
			var y: int = 83 - frame * 2
			_draw_line(image, Vector2i(28,y), Vector2i(100,y), gold)
			_draw_line(image, Vector2i(38,y-10), Vector2i(38,y+10), cyan)
			_draw_line(image, Vector2i(90,y-10), Vector2i(90,y+10), cyan)
		"neural_echo":
			var drift := Vector2i((frame % 3) - 1, ((frame * 2) % 3) - 1)
			for p: Vector2i in [Vector2i(37,51),Vector2i(55,39),Vector2i(76,44),Vector2i(91,61),Vector2i(72,82),Vector2i(48,78)]:
				var target: Vector2i = p + drift
				_draw_line(image, center - drift, target, violet if frame % 2 == 0 else cyan)
				_set_safe(image, target.x, target.y, gold)
		"mosaic_shift":
			for y: int in range(40,96,12):
				for x: int in range(34,100,12):
					var cell_x: int = int((x - 34) / 12)
					var cell_y: int = int((y - 40) / 12)
					if (cell_x + cell_y + frame) % 2 == 0:
						_draw_box(image, Rect2i(x,y,5,5), green if frame % 2 == 0 else violet)

static func _place(seed: Image, dx: int, dy: int, sx: float, sy: float, alpha: float) -> Image:
	var source: Image = seed.duplicate()
	var width: int = maxi(1, int(round(128.0 * sx)))
	var height: int = maxi(1, int(round(128.0 * sy)))
	if width != 128 or height != 128:
		source.resize(width, height, Image.INTERPOLATE_NEAREST)
	if alpha < 0.999:
		for y: int in range(source.get_height()):
			for x: int in range(source.get_width()):
				var c: Color = source.get_pixel(x,y)
				if c.a > 0.0:
					c.a *= alpha
					source.set_pixel(x,y,c)
	var canvas := Image.create(128,128,false,Image.FORMAT_RGBA8)
	canvas.fill(Color(0,0,0,0))
	var tx: int = int((128-width)/2) + dx
	var ty: int = 128-height + dy
	var sx0: int = maxi(0,-tx); var sy0: int = maxi(0,-ty)
	var dx0: int = maxi(0,tx); var dy0: int = maxi(0,ty)
	var w: int = mini(width-sx0,128-dx0); var h: int = mini(height-sy0,128-dy0)
	if w > 0 and h > 0:
		canvas.blit_rect(source, Rect2i(sx0,sy0,w,h), Vector2i(dx0,dy0))
	return canvas

static func _set_safe(image: Image, x: int, y: int, color: Color) -> void:
	if x >= 0 and x < 128 and y >= 0 and y < 128:
		image.set_pixel(x,y,color)

static func _draw_line(image: Image, a: Vector2i, b: Vector2i, color: Color) -> void:
	var x0: int = a.x
	var y0: int = a.y
	var x1: int = b.x
	var y1: int = b.y
	var dx: int = absi(x1 - x0)
	var sxv: int = 1 if x0 < x1 else -1
	var dy: int = -absi(y1 - y0)
	var syv: int = 1 if y0 < y1 else -1
	var err: int = dx + dy
	while true:
		_set_safe(image,x0,y0,color)
		if x0==x1 and y0==y1: break
		var e2: int = 2 * err
		if e2>=dy: err+=dy; x0+=sxv
		if e2<=dx: err+=dx; y0+=syv

static func _draw_ring(image: Image, center: Vector2i, radius: int, color: Color) -> void:
	for degree: int in range(0,360,7):
		var a:=deg_to_rad(float(degree)); _set_safe(image,center.x+int(round(cos(a)*radius)),center.y+int(round(sin(a)*radius)),color)

static func _draw_arc(image: Image, center: Vector2i, radius: int, start: float, finish: float, color: Color) -> void:
	for i: int in range(40):
		var a:=lerpf(start,finish,float(i)/39.0); _set_safe(image,center.x+int(round(cos(a)*radius)),center.y+int(round(sin(a)*radius*0.55)),color)

static func _draw_figure_eight(image: Image, center: Vector2i, radius: int, color: Color) -> void:
	for i: int in range(72):
		var a:=float(i)/71.0*TAU; var x:=int(round(sin(a)*radius)); var y:=int(round(sin(a)*cos(a)*radius)); _set_safe(image,center.x+x,center.y+y,color)

static func _draw_box(image: Image, rect: Rect2i, color: Color) -> void:
	for y: int in range(rect.position.y, rect.end.y):
		for x: int in range(rect.position.x, rect.end.x):
			_set_safe(image,x,y,color)
