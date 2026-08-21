extends RefCounted

# Reverse visual-production pass: family 001 (Luzik -> Warstwin -> Synkronaut).
# Uses the three approved transparent production-atlas seeds and authors a complete
# five-state battle set around the family's layer-coupling / synchronization
# identity. Frames remain 128x128 nearest-neighbour pixel art.

const SEEDS = preload("res://scripts/battle/creature_seed_atlas_db.gd")
const ACTIONS: Array[String] = ["idle", "attack", "hurt", "faint", "special"]
const ACTION_FRAME_COUNTS: Dictionary = {"idle":4, "attack":6, "hurt":3, "faint":5, "special":6}
const NAMES: Array[String] = ["Luzik", "Warstwin", "Synkronaut"]
const FRAME_SIZE := Vector2i(128, 128)

const EDGE := Color("18202c")
const CYAN := Color("50d7e8")
const BLUE := Color("5178d9")
const VIOLET := Color("9b71de")
const WHITE := Color("edf7f6")
const HURT := Color("f06464")

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
	var image: Image = _make_frame(base, creature_name, action, safe_frame)
	var texture: Texture2D = ImageTexture.create_from_image(image)
	_frame_cache[key] = texture
	return texture

static func _base_image(creature_name: String) -> Image:
	if _base_cache.has(creature_name): return _base_cache[creature_name] as Image
	if not SEEDS.is_approved(creature_name): return null
	var image: Image = SEEDS.image_for(creature_name)
	if image == null: return null
	image = image.duplicate()
	if Vector2i(image.get_size()) != FRAME_SIZE: image.resize(FRAME_SIZE.x, FRAME_SIZE.y, Image.INTERPOLATE_NEAREST)
	_base_cache[creature_name] = image
	return image

static func _make_frame(base: Image, creature_name: String, action: String, frame: int) -> Image:
	var stage: int = NAMES.find(creature_name)
	match action:
		"idle":
			var y_offsets: Array[int] = [0, -2-stage, 0, 2+stage]
			var idle: Image = _place(base, 0, y_offsets[frame], 1.0, 1.0, 1.0)
			_draw_phase_marks(idle, frame, stage, 0.30)
			return idle
		"attack":
			var x_offsets: Array[int] = [0, 5+stage, 12+stage*2, 20+stage*2, 10+stage, 2]
			var y_offsets: Array[int] = [0, -1, -3-stage, -5-stage, -2, 0]
			var sx: float = 1.0 + (0.05 + 0.02*stage if frame in [2,3] else 0.0)
			var sy: float = 0.96 if frame == 3 else 1.0
			var attack: Image = _place(base, x_offsets[frame], y_offsets[frame], sx, sy, 1.0)
			if frame in [1,2,3,4]:
				_draw_sync_arc(attack, Vector2i(72+x_offsets[frame], 64+y_offsets[frame]), 18+frame*5+stage*2, CYAN if stage < 2 else WHITE)
			return attack
		"hurt":
			var x_offsets: Array[int] = [-6-stage, 5+stage, 0]
			var hurt: Image = _place(base, x_offsets[frame], 2 if frame < 2 else 0, 0.98, 1.02, 1.0)
			_tint(hurt, HURT, 0.40 if frame < 2 else 0.16)
			_draw_phase_split(hurt, frame, stage)
			return hurt
		"faint":
			var t: float = float(frame) / float(maxi(1, frame_count("faint")-1))
			var faint: Image = _place(base, -int(round(3.0*t)), int(round(27.0*t)), 1.0+0.08*t, 1.0-0.60*t, 1.0-0.78*t)
			_draw_dissolve(faint, frame, stage)
			return faint
		"special":
			var t: float = float(frame) / float(maxi(1, frame_count("special")-1))
			var pulse: float = sin(t * PI)
			var special: Image = _place(base, 0, -int(round((4.0+stage)*pulse)), 1.0+(0.08+0.02*stage)*pulse, 1.0+(0.08+0.02*stage)*pulse, 1.0)
			_draw_sync_ring(special, Vector2i(64,66), 21+frame*4+stage*2, Color(CYAN.r,CYAN.g,CYAN.b,0.72))
			_draw_sync_ring(special, Vector2i(64,66), 38+int(round(pulse*9.0)), Color(VIOLET.r,VIOLET.g,VIOLET.b,0.50))
			_draw_layer_glyph(special, frame, stage)
			return special
	return base.duplicate()

static func _place(base: Image, dx: int, dy: int, sx: float, sy: float, alpha: float) -> Image:
	var source: Image = base.duplicate()
	var width: int = maxi(1, int(round(float(FRAME_SIZE.x)*sx)))
	var height: int = maxi(1, int(round(float(FRAME_SIZE.y)*sy)))
	if width != FRAME_SIZE.x or height != FRAME_SIZE.y: source.resize(width, height, Image.INTERPOLATE_NEAREST)
	if alpha < 0.999: _multiply_alpha(source, alpha)
	var canvas := Image.create(FRAME_SIZE.x, FRAME_SIZE.y, false, Image.FORMAT_RGBA8)
	canvas.fill(Color(0,0,0,0))
	_blit_clipped(canvas, source, int((FRAME_SIZE.x-width)/2)+dx, FRAME_SIZE.y-height+dy)
	return canvas

static func _blit_clipped(canvas: Image, source: Image, target_x: int, target_y: int) -> void:
	var source_x: int = maxi(0, -target_x)
	var source_y: int = maxi(0, -target_y)
	var dest_x: int = maxi(0, target_x)
	var dest_y: int = maxi(0, target_y)
	var width: int = mini(source.get_width()-source_x, FRAME_SIZE.x-dest_x)
	var height: int = mini(source.get_height()-source_y, FRAME_SIZE.y-dest_y)
	if width > 0 and height > 0: canvas.blit_rect(source, Rect2i(source_x, source_y, width, height), Vector2i(dest_x,dest_y))

static func _multiply_alpha(image: Image, alpha: float) -> void:
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			var c: Color = image.get_pixel(x,y)
			if c.a > 0.0: c.a *= alpha; image.set_pixel(x,y,c)

static func _tint(image: Image, target: Color, strength: float) -> void:
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			var c: Color = image.get_pixel(x,y)
			if c.a <= 0.0: continue
			c.r = lerpf(c.r,target.r,strength); c.g = lerpf(c.g,target.g,strength); c.b = lerpf(c.b,target.b,strength)
			image.set_pixel(x,y,c)

static func _draw_phase_marks(image: Image, frame: int, stage: int, alpha: float) -> void:
	var radius: int = 24+stage*4+frame*2
	for degree: int in range(205, 336, 22):
		var angle: float = deg_to_rad(float(degree))
		_set_block(image, 64+int(round(cos(angle)*radius)), 76+int(round(sin(angle)*radius)), Color(CYAN.r,CYAN.g,CYAN.b,alpha), 1)

static func _draw_sync_arc(image: Image, center: Vector2i, radius: int, color: Color) -> void:
	for degree: int in range(-115, 76, 10):
		var angle: float = deg_to_rad(float(degree))
		_set_block(image, center.x+int(round(cos(angle)*radius)), center.y+int(round(sin(angle)*radius)), color, 1)

static func _draw_phase_split(image: Image, frame: int, stage: int) -> void:
	var x: int = 42 + frame*18
	for y: int in range(28+stage*3, 102, 9):
		_set_block(image, x, y, Color(VIOLET.r,VIOLET.g,VIOLET.b,0.58), 1)

static func _draw_dissolve(image: Image, frame: int, stage: int) -> void:
	if frame <= 0: return
	for i: int in range(5+frame*3+stage):
		var x: int = 31 + ((i*17 + frame*11 + stage*7) % 68)
		var y: int = 70 + ((i*13 + frame*5) % 42) - frame*4
		_set_block(image, x, y, Color(WHITE.r,WHITE.g,WHITE.b,0.55), 1)

static func _draw_sync_ring(image: Image, center: Vector2i, radius: int, color: Color) -> void:
	for degree: int in range(0,360,12):
		var angle: float = deg_to_rad(float(degree))
		_set_block(image, center.x+int(round(cos(angle)*radius)), center.y+int(round(sin(angle)*radius)), color, 1)

static func _draw_layer_glyph(image: Image, frame: int, stage: int) -> void:
	var c: Color = WHITE if stage == 2 else CYAN
	var half: int = 8+stage*3+frame
	for layer: int in range(2+stage):
		var y: int = 55 + layer*7 - stage*3
		_line(image, Vector2i(64-half,y), Vector2i(64+half,y), Color(c.r,c.g,c.b,0.68), 1)
	if stage >= 1:
		_line(image, Vector2i(64,45-frame), Vector2i(64,82+frame), Color(VIOLET.r,VIOLET.g,VIOLET.b,0.58), 0)

static func _set_block(image: Image, cx: int, cy: int, color: Color, radius: int) -> void:
	for y: int in range(cy-radius,cy+radius+1):
		for x: int in range(cx-radius,cx+radius+1):
			if x>=0 and x<image.get_width() and y>=0 and y<image.get_height(): image.set_pixel(x,y,color)

static func _line(image: Image, a: Vector2i, b: Vector2i, color: Color, radius: int) -> void:
	var steps: int = maxi(abs(b.x-a.x),abs(b.y-a.y))
	if steps <= 0: _set_block(image,a.x,a.y,color,radius); return
	for i: int in range(steps+1):
		var t: float = float(i)/float(steps)
		_set_block(image, int(round(lerpf(float(a.x),float(b.x),t))), int(round(lerpf(float(a.y),float(b.y),t))), color, radius)
