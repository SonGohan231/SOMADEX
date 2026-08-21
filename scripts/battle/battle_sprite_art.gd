extends RefCounted

const ART = preload("res://scripts/data/monster_art.gd")
const SEEDS = preload("res://scripts/battle/creature_battle_seed_db.gd")
const REVERSE15 = preload("res://scripts/battle/reverse_family15_sprite_db.gd")

const ACTIONS: Array[String] = ["idle", "attack", "hurt", "faint", "special"]
const ACTION_FRAME_COUNTS: Dictionary = {
	"idle": 4,
	"attack": 6,
	"hurt": 3,
	"faint": 5,
	"special": 6
}
# AnimatedBattleScreen advances a shared maximum frame clock. Full authored
# strips are clamped per action. Authored transparent seeds are animated by the
# battle actor transform/effect archetype until a strip override is shipped.
const FRAME_COUNT: int = 6
const FRAME_W: int = 128
const FRAME_H: int = 128

const SPECIES: Array[String] = [
	"Luzik", "Warstwin", "Synkronaut",
	"Bocznik", "Slizgogon", "Horyzontor",
	"Milimik", "Drobnoskok", "Kwantomruk",
	"Pufek", "Pulsopuch", "Falomamut",
	"Wahlik", "Oscylot", "Fazoryb",
	"Kompasik", "Oktantor", "Kartografon",
	"Srubik", "Torsys", "Spiralion",
	"Uczek", "Obiegnik", "Labiryntaur",
	"Kotwiczek", "Bramnik", "Fundamentor",
	"Nasuch", "Echouszek", "Sensoryks",
	"Nucik", "Wibrospiew", "Rezonar"
]

static var _strip_cache: Dictionary = {}
static var _frame_cache: Dictionary = {}
static var _missing_cache: Dictionary = {}

static func animated_names() -> Array[String]:
	var names: Array[String] = SPECIES.duplicate()
	names.sort()
	return names

static func has_animation(creature_name: String) -> bool:
	return creature_name in SPECIES

static func animation_count() -> int:
	return SPECIES.size()

static func authored_seed_count() -> int:
	return SEEDS.seed_count()

static func has_authored_seed(creature_name: String) -> bool:
	return SEEDS.has_seed(creature_name)

static func authored_full_animation_count() -> int:
	return REVERSE15.animation_count()

static func has_authored_full_animation(creature_name: String) -> bool:
	return REVERSE15.has_animation(creature_name)

static func frame_count(action: String) -> int:
	return maxi(1, int(ACTION_FRAME_COUNTS.get(action, 1)))

static func has_real_strip(creature_name: String, action: String) -> bool:
	if not has_animation(creature_name) or action not in ACTIONS:
		return false
	return FileAccess.file_exists(_strip_path(creature_name, action))

static func real_strip_count(creature_name: String) -> int:
	var result: int = 0
	for action: String in ACTIONS:
		if has_real_strip(creature_name, action):
			result += 1
	return result

static func frame_texture(creature_name: String, action: String, frame: int) -> Texture2D:
	if not has_animation(creature_name):
		return null
	if action not in ACTIONS:
		action = "idle"
	# Reverse production pass: family 015 already owns true transparent per-frame
	# idle/attack/hurt/faint/special art, generated deterministically from the
	# approved pixel seed rather than reusing a single portrait.
	if REVERSE15.has_animation(creature_name):
		var authored: Texture2D = REVERSE15.frame_texture(creature_name, action, frame)
		if authored != null:
			return authored
	# Highest-quality disk strip wins for families migrated through external art.
	var real_frame: Texture2D = _real_frame_texture(creature_name, action, frame)
	if real_frame != null:
		return real_frame
	# Production seed keeps the creature silhouette/palette unique while the
	# existing actor animation layer provides idle/attack/hurt/faint/special
	# movement and FX. This replaces rectangular portrait placeholders.
	var seed: Texture2D = SEEDS.texture_for(creature_name)
	if seed != null:
		return seed
	# Final safety fallback while the remaining families are migrated.
	return ART.texture_for(creature_name)

static func source_kind(creature_name: String) -> String:
	if not has_animation(creature_name):
		return "fallback"
	if REVERSE15.has_animation(creature_name):
		return "sprite-strip-authored-runtime"
	var count: int = real_strip_count(creature_name)
	if count >= ACTIONS.size():
		return "sprite-strip"
	if count > 0:
		return "sprite-strip-partial"
	if SEEDS.has_seed(creature_name):
		return "authored-seed-archetype"
	return "portrait-procedural"

static func archetype(creature_name: String) -> String:
	return SEEDS.archetype(creature_name)

static func _real_frame_texture(creature_name: String, action: String, frame: int) -> Texture2D:
	var strip: Texture2D = _load_strip(creature_name, action)
	if strip == null:
		return null
	var count: int = frame_count(action)
	var safe_frame: int = clampi(frame, 0, count - 1)
	var cache_key: String = "%s|%s|%d" % [creature_name, action, safe_frame]
	if _frame_cache.has(cache_key):
		return _frame_cache[cache_key] as Texture2D
	var texture := AtlasTexture.new()
	texture.atlas = strip
	texture.region = Rect2(safe_frame * FRAME_W, 0, FRAME_W, FRAME_H)
	texture.filter_clip = true
	_frame_cache[cache_key] = texture
	return texture

static func _load_strip(creature_name: String, action: String) -> Texture2D:
	var cache_key: String = "%s|%s" % [creature_name, action]
	if _strip_cache.has(cache_key):
		return _strip_cache[cache_key] as Texture2D
	if bool(_missing_cache.get(cache_key, false)):
		return null
	var path: String = _strip_path(creature_name, action)
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_missing_cache[cache_key] = true
		return null
	var encoded: String = file.get_as_text().strip_edges()
	var bytes: PackedByteArray = Marshalls.base64_to_raw(encoded)
	if bytes.is_empty():
		push_error("SOMADEX sprite strip is empty: %s" % path)
		_missing_cache[cache_key] = true
		return null
	var image := Image.new()
	var load_error: Error = image.load_webp_from_buffer(bytes)
	if load_error != OK:
		load_error = image.load_png_from_buffer(bytes)
	if load_error != OK:
		push_error("SOMADEX sprite strip decode failed: %s" % path)
		_missing_cache[cache_key] = true
		return null
	var expected: Vector2i = Vector2i(FRAME_W * frame_count(action), FRAME_H)
	if Vector2i(image.get_size()) != expected:
		push_error("SOMADEX sprite strip dimensions mismatch: %s got %s expected %s" % [path, image.get_size(), expected])
		_missing_cache[cache_key] = true
		return null
	var texture: Texture2D = ImageTexture.create_from_image(image)
	_strip_cache[cache_key] = texture
	return texture

static func _strip_path(creature_name: String, action: String) -> String:
	return "res://data/creatures/battle_sprites/%s/%s.b64.txt" % [_slug(creature_name), action]

static func _slug(value: String) -> String:
	return value.strip_edges().to_lower().replace(" ", "_")
