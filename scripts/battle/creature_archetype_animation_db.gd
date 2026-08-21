extends RefCounted

const SEEDS = preload("res://scripts/battle/creature_seed_atlas_db.gd")
const ACTIONS: Array[String] = ["idle", "attack", "hurt", "faint", "special"]
const FRAME_COUNTS: Dictionary = {"idle":4, "attack":6, "hurt":3, "faint":5, "special":6}
const FRAME_SIZE: Vector2i = Vector2i(128, 128)

static var _frame_cache: Dictionary = {}

static func has_animation(creature_name: String) -> bool:
	return SEEDS.is_approved(creature_name)

static func animation_count() -> int:
	return SEEDS.approved_count()

static func frame_count(action: String) -> int:
	return maxi(1, int(FRAME_COUNTS.get(action, 1)))

static func archetype(creature_name: String) -> String:
	return SEEDS.archetype(creature_name)

static func frame_texture(creature_name: String, action: String, frame: int) -> Texture2D:
	if not has_animation(creature_name):
		return null
	if action not in ACTIONS:
		action = "idle"
	var safe_frame: int = clampi(frame, 0, frame_count(action) - 1)
	var key: String = "%s|%s|%d" % [creature_name.to_lower(), action, safe_frame]
	if _frame_cache.has(key):
		return _frame_cache[key] as Texture2D
	var seed: Image = SEEDS.image_for(creature_name)
	if seed == null or Vector2i(seed.get_size()) != FRAME_SIZE:
		return null
	var image: Image = _make_frame(seed, action, safe_frame, archetype(creature_name))
	var texture: Texture2D = ImageTexture.create_from_image(image)
	_frame_cache[key] = texture
	return texture

static func _make_frame(seed: Image, action: String, frame: int, body: String) -> Image:
	var count: int = frame_count(action)
	var t: float = 0.0 if count <= 1 else float(frame) / float(count - 1)
	var scale_x: float = 1.0
	var scale_y: float = 1.0
	var offset := Vector2i.ZERO
	var alpha: float = 1.0
	match action:
		"idle":
			var phase: float = sin(t * TAU)
			offset.y = int(round(-2.0 * phase))
			if body == "hover" or body == "wing-glide":
				offset.y = int(round(-4.0 * phase))
			elif body == "heavy":
				offset.y = int(round(-1.0 * phase))
		"attack":
			var thrust: float = sin(t * PI)
			offset.x = int(round(_attack_distance(body) * thrust))
			if body in ["wing-glide", "hover", "glide"]:
				offset.y = int(round(-7.0 * thrust))
			if body == "serpent":
				offset.y = int(round(sin(t * TAU) * 4.0))
			if body == "heavy":
				scale_x = 1.0 + 0.08 * thrust
				scale_y = 1.0 - 0.06 * thrust
		"hurt":
			offset.x = int(round(sin(t * PI * 4.0) * _hurt_distance(body)))
			scale_x = 1.0 - 0.05 * sin(t * PI)
			scale_y = 1.0 + 0.04 * sin(t * PI)
		"faint":
			offset.y = int(round(26.0 * t))
			scale_y = maxf(0.18, 1.0 - 0.72 * t)
			scale_x = 1.0 + 0.10 * t
			alpha = 1.0 - 0.78 * t
		"special":
			var pulse: float = sin(t * PI)
			var strength: float = 0.10 if body != "pulse" else 0.16
			scale_x = 1.0 + strength * pulse
			scale_y = 1.0 + strength * pulse
			offset.y = int(round(-5.0 * pulse))
			if body == "serpent":
				offset.x = int(round(sin(t * TAU) * 3.0))
	return _transform_seed(seed, scale_x, scale_y, offset, alpha)

static func _attack_distance(body: String) -> float:
	match body:
		"heavy": return 7.0
		"pulse": return 5.0
		"hover": return 10.0
		"wing-glide": return 12.0
		"serpent": return 13.0
		"glide": return 14.0
		_: return 11.0

static func _hurt_distance(body: String) -> float:
	return 3.0 if body == "heavy" else 5.0

static func _transform_seed(seed: Image, scale_x: float, scale_y: float, offset: Vector2i, alpha: float) -> Image:
	var source: Image = seed.duplicate()
	var width: int = maxi(1, int(round(float(FRAME_SIZE.x) * scale_x)))
	var height: int = maxi(1, int(round(float(FRAME_SIZE.y) * scale_y)))
	if width != FRAME_SIZE.x or height != FRAME_SIZE.y:
		source.resize(width, height, Image.INTERPOLATE_NEAREST)
	if alpha < 0.999:
		for y: int in range(source.get_height()):
			for x: int in range(source.get_width()):
				var color: Color = source.get_pixel(x, y)
				if color.a > 0.0:
					color.a *= alpha
					source.set_pixel(x, y, color)
	var canvas := Image.create(FRAME_SIZE.x, FRAME_SIZE.y, false, Image.FORMAT_RGBA8)
	canvas.fill(Color(0, 0, 0, 0))
	var dst := Vector2i((FRAME_SIZE.x - width) / 2 + offset.x, FRAME_SIZE.y - height + offset.y)
	canvas.blit_rect(source, Rect2i(Vector2i.ZERO, source.get_size()), dst)
	return canvas
