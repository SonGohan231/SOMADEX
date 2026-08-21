extends RefCounted

const ART = preload("res://scripts/data/monster_art.gd")
const SEEDS = preload("res://scripts/battle/creature_battle_seed_db.gd")
const REVERSE15 = preload("res://scripts/battle/reverse_family15_sprite_db.gd")
const REVERSE10 = preload("res://scripts/battle/reverse_family10_sprite_db.gd")
const REVERSE09 = preload("res://scripts/battle/reverse_family09_sprite_db.gd")
const REVERSE08 = preload("res://scripts/battle/reverse_family08_sprite_db.gd")
const REVERSE07 = preload("res://scripts/battle/reverse_family07_sprite_db.gd")
const REVERSE06 = preload("res://scripts/battle/reverse_family06_sprite_db.gd")
const REVERSE05 = preload("res://scripts/battle/reverse_family05_sprite_db.gd")
const SEED_ATLAS = preload("res://scripts/battle/creature_seed_atlas_db.gd")
const ARCHETYPE_RUNTIME = preload("res://scripts/battle/creature_archetype_animation_db.gd")

const ACTIONS: Array[String] = ["idle", "attack", "hurt", "faint", "special"]
const ACTION_FRAME_COUNTS: Dictionary = {"idle":4, "attack":6, "hurt":3, "faint":5, "special":6}
const FRAME_COUNT: int = 6
const FRAME_W: int = 128
const FRAME_H: int = 128

static var _strip_cache: Dictionary = {}
static var _frame_cache: Dictionary = {}
static var _missing_cache: Dictionary = {}

static func animated_names() -> Array[String]:
	var names: Array[String] = []
	for creature_name: String in SEED_ATLAS.NAMES:
		var display_name: String = "Uczek" if creature_name.to_lower() == "uczek" else creature_name
		if not names.has(display_name): names.append(display_name)
	names.sort()
	return names

static func has_animation(creature_name: String) -> bool:
	return SEED_ATLAS.has_name(creature_name)

static func animation_count() -> int:
	return SEED_ATLAS.form_count()

static func authored_seed_count() -> int:
	return SEEDS.seed_count()

static func has_authored_seed(creature_name: String) -> bool:
	return SEEDS.has_seed(creature_name)

static func authored_full_animation_count() -> int:
	return REVERSE15.animation_count() + REVERSE10.animation_count() + REVERSE09.animation_count() + REVERSE08.animation_count() + REVERSE07.animation_count() + REVERSE06.animation_count() + REVERSE05.animation_count()

static func has_authored_full_animation(creature_name: String) -> bool:
	return REVERSE15.has_animation(creature_name) or REVERSE10.has_animation(creature_name) or REVERSE09.has_animation(creature_name) or REVERSE08.has_animation(creature_name) or REVERSE07.has_animation(creature_name) or REVERSE06.has_animation(creature_name) or REVERSE05.has_animation(creature_name)

static func production_atlas_approved_count() -> int:
	return ARCHETYPE_RUNTIME.animation_count()

static func production_atlas_has_name(creature_name: String) -> bool:
	return SEED_ATLAS.has_name(creature_name)

static func production_atlas_is_approved(creature_name: String) -> bool:
	return ARCHETYPE_RUNTIME.has_animation(creature_name)

static func frame_count(action: String) -> int:
	return maxi(1, int(ACTION_FRAME_COUNTS.get(action, 1)))

static func has_real_strip(creature_name: String, action: String) -> bool:
	return has_animation(creature_name) and action in ACTIONS and FileAccess.file_exists(_strip_path(creature_name, action))

static func real_strip_count(creature_name: String) -> int:
	var result: int = 0
	for action: String in ACTIONS:
		if has_real_strip(creature_name, action): result += 1
	return result

static func _reverse_frame(creature_name: String, action: String, frame: int) -> Texture2D:
	if REVERSE15.has_animation(creature_name): return REVERSE15.frame_texture(creature_name, action, frame)
	if REVERSE10.has_animation(creature_name): return REVERSE10.frame_texture(creature_name, action, frame)
	if REVERSE09.has_animation(creature_name): return REVERSE09.frame_texture(creature_name, action, frame)
	if REVERSE08.has_animation(creature_name): return REVERSE08.frame_texture(creature_name, action, frame)
	if REVERSE07.has_animation(creature_name): return REVERSE07.frame_texture(creature_name, action, frame)
	if REVERSE06.has_animation(creature_name): return REVERSE06.frame_texture(creature_name, action, frame)
	if REVERSE05.has_animation(creature_name): return REVERSE05.frame_texture(creature_name, action, frame)
	return null

static func frame_texture(creature_name: String, action: String, frame: int) -> Texture2D:
	if not has_animation(creature_name): return null
	if action not in ACTIONS: action = "idle"
	var reverse: Texture2D = _reverse_frame(creature_name, action, frame)
	if reverse != null: return reverse
	var real_frame: Texture2D = _real_frame_texture(creature_name, action, frame)
	if real_frame != null: return real_frame
	var atlas_frame: Texture2D = ARCHETYPE_RUNTIME.frame_texture(creature_name, action, frame)
	if atlas_frame != null: return atlas_frame
	var authored_seed: Texture2D = SEEDS.texture_for(creature_name)
	if authored_seed != null: return authored_seed
	return ART.texture_for(creature_name)

static func source_kind(creature_name: String) -> String:
	if not has_animation(creature_name): return "fallback"
	if has_authored_full_animation(creature_name): return "sprite-strip-authored-runtime"
	var count: int = real_strip_count(creature_name)
	if count >= ACTIONS.size(): return "sprite-strip"
	if count > 0: return "sprite-strip-partial"
	if ARCHETYPE_RUNTIME.has_animation(creature_name): return "sprite-archetype-generated"
	if SEEDS.has_seed(creature_name): return "authored-seed-archetype"
	return "portrait-procedural"

static func archetype(creature_name: String) -> String:
	if SEED_ATLAS.has_name(creature_name): return SEED_ATLAS.archetype(creature_name)
	return SEEDS.archetype(creature_name)

static func _real_frame_texture(creature_name: String, action: String, frame: int) -> Texture2D:
	var strip: Texture2D = _load_strip(creature_name, action)
	if strip == null: return null
	var safe_frame: int = clampi(frame, 0, frame_count(action) - 1)
	var key: String = "%s|%s|%d" % [creature_name, action, safe_frame]
	if _frame_cache.has(key): return _frame_cache[key] as Texture2D
	var texture := AtlasTexture.new()
	texture.atlas = strip
	texture.region = Rect2(safe_frame * FRAME_W, 0, FRAME_W, FRAME_H)
	texture.filter_clip = true
	_frame_cache[key] = texture
	return texture

static func _load_strip(creature_name: String, action: String) -> Texture2D:
	var key: String = "%s|%s" % [creature_name, action]
	if _strip_cache.has(key): return _strip_cache[key] as Texture2D
	if bool(_missing_cache.get(key, false)): return null
	var path: String = _strip_path(creature_name, action)
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_missing_cache[key] = true
		return null
	var bytes: PackedByteArray = Marshalls.base64_to_raw(file.get_as_text().strip_edges())
	if bytes.is_empty():
		_missing_cache[key] = true
		return null
	var image := Image.new()
	var load_error: Error = image.load_webp_from_buffer(bytes)
	if load_error != OK: load_error = image.load_png_from_buffer(bytes)
	var expected: Vector2i = Vector2i(FRAME_W * frame_count(action), FRAME_H)
	if load_error != OK or Vector2i(image.get_size()) != expected:
		push_error("SOMADEX sprite strip invalid: %s" % path)
		_missing_cache[key] = true
		return null
	var texture: Texture2D = ImageTexture.create_from_image(image)
	_strip_cache[key] = texture
	return texture

static func _strip_path(creature_name: String, action: String) -> String:
	return "res://data/creatures/battle_sprites/%s/%s.b64.txt" % [_slug(creature_name), action]

static func _slug(value: String) -> String:
	return value.strip_edges().to_lower().replace(" ", "_")
