extends RefCounted

const LEGACY = preload("res://scripts/data/monster_art.gd")
const STRIP_PATH: String = "res://assets/monsters/alpha1/somaskan_001_010_strip.webp"
const NUCIK_PATH: String = "res://assets/monsters/alpha1/somaskan_015_nucik.webp"
const PORTRAIT_SIZE: Vector2i = Vector2i(128, 96)

static var _atlas: Texture2D
static var _nucik: Texture2D
static var _cache: Dictionary = {}
static var _INDEX: Dictionary = {
	"Luzik": 0,
	"Bocznik": 1,
	"Milimik": 2,
	"Pufek": 3,
	"Wahlik": 4,
	"Kompasik": 5,
	"Srubik": 6,
	"Uczek": 7,
	"Kotwiczek": 8,
	"Nasuch": 9
}

static func texture_for(monster_name: String) -> Texture2D:
	if _cache.has(monster_name):
		return _cache[monster_name] as Texture2D
	if monster_name == "Nucik":
		if _nucik == null:
			_nucik = load(NUCIK_PATH) as Texture2D
		if _nucik != null:
			_cache[monster_name] = _nucik
			return _nucik
	if _INDEX.has(monster_name):
		if _atlas == null:
			_atlas = load(STRIP_PATH) as Texture2D
		if _atlas != null:
			var index: int = int(_INDEX[monster_name])
			var region: AtlasTexture = AtlasTexture.new()
			region.atlas = _atlas
			region.region = Rect2(index * PORTRAIT_SIZE.x, 0, PORTRAIT_SIZE.x, PORTRAIT_SIZE.y)
			region.filter_clip = true
			_cache[monster_name] = region
			return region
	return LEGACY.texture_for(monster_name)

static func has_remastered(monster_name: String) -> bool:
	return monster_name == "Nucik" or _INDEX.has(monster_name)

static func remastered_names() -> Array[String]:
	var result: Array[String] = []
	for raw_name: Variant in _INDEX.keys():
		result.append(str(raw_name))
	result.append("Nucik")
	result.sort()
	return result
