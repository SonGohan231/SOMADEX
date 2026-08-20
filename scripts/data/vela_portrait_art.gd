extends RefCounted

const MANIFEST_PATH: String = "res://data/creatures/vela_portraits_manifest.csv"
const ATLAS_PATH: String = "res://assets/creatures/vela_portraits_atlas.webp"
const COLS: int = 6
const TILE_W: int = 112
const TILE_H: int = 72

static var _loaded: bool = false
static var _atlas: Texture2D
static var _regions: Dictionary = {}
static var _cache: Dictionary = {}

static func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	_atlas = ResourceLoader.load(ATLAS_PATH) as Texture2D
	if _atlas == null:
		push_error("SOMADEX Vela portrait atlas missing: %s" % ATLAS_PATH)
		return
	var file := FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	if file == null:
		push_error("SOMADEX Vela portrait manifest missing: %s" % MANIFEST_PATH)
		return
	if not file.eof_reached():
		file.get_csv_line()
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.size() < 4:
			continue
		var creature_name: String = row[0].strip_edges()
		if creature_name.is_empty():
			continue
		var index: int = int(row[1])
		var col: int = index % COLS
		var atlas_row: int = int(index / COLS)
		_regions[creature_name] = Rect2(col * TILE_W, atlas_row * TILE_H, TILE_W, TILE_H)

static func has_portrait(creature_name: String) -> bool:
	_ensure_loaded()
	return _atlas != null and _regions.has(creature_name)

static func texture_for(creature_name: String) -> Texture2D:
	_ensure_loaded()
	if _atlas == null or not _regions.has(creature_name):
		return null
	if _cache.has(creature_name):
		return _cache[creature_name] as Texture2D
	var texture := AtlasTexture.new()
	texture.atlas = _atlas
	texture.region = _regions[creature_name] as Rect2
	texture.filter_clip = true
	_cache[creature_name] = texture
	return texture

static func portrait_count() -> int:
	_ensure_loaded()
	return _regions.size()

static func atlas_size() -> Vector2i:
	_ensure_loaded()
	if _atlas == null:
		return Vector2i.ZERO
	return _atlas.get_size()
