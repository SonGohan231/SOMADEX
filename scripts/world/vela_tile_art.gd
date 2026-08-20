extends RefCounted

const TILE_SIZE: int = 24
const TILESET_PATH: String = "res://assets/world/vela_tiles_24.png"

static var _atlas: Texture2D
static var _cache: Dictionary = {}

static var _CODE_TO_INDEX: Dictionary = {
	"G": 0,
	"F": 1,
	"P": 2,
	"D": 3,
	"W": 4,
	"T": 5,
	"K": 6,
	"H": 7,
	"R": 8,
	"C": 9,
	"S": 10,
	"E": 11,
	"B": 12,
	"A": 13,
	"O": 14,
	"V": 15
}

static func texture_for(code: String) -> Texture2D:
	var safe_code: String = code if _CODE_TO_INDEX.has(code) else "G"
	if _cache.has(safe_code):
		return _cache[safe_code] as Texture2D
	if _atlas == null:
		_atlas = load(TILESET_PATH) as Texture2D
	if _atlas == null:
		return null
	var index: int = int(_CODE_TO_INDEX[safe_code])
	var region: AtlasTexture = AtlasTexture.new()
	region.atlas = _atlas
	region.region = Rect2((index % 8) * TILE_SIZE, int(index / 8) * TILE_SIZE, TILE_SIZE, TILE_SIZE)
	region.filter_clip = true
	_cache[safe_code] = region
	return region

static func supported_codes() -> Array[String]:
	var result: Array[String] = []
	for key: Variant in _CODE_TO_INDEX.keys():
		result.append(str(key))
	result.sort()
	return result
