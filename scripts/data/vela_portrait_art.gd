extends RefCounted

const MANIFEST_PATH: String = "res://data/creatures/vela_portraits_manifest.csv"
const B64_PARTS: Array[String] = [
	"res://data/creatures/vela_atlas_b64/part_00.txt",
	"res://data/creatures/vela_atlas_b64/part_01.txt",
	"res://data/creatures/vela_atlas_b64/part_02.txt",
	"res://data/creatures/vela_atlas_b64/part_03.txt",
	"res://data/creatures/vela_atlas_b64/part_04.txt",
	"res://data/creatures/vela_atlas_b64/part_05.txt"
]
const COLS: int = 6
const TILE_W: int = 112
const TILE_H: int = 72
const EXPECTED_ATLAS_SIZE: Vector2i = Vector2i(672, 432)
const EXPECTED_BYTES: int = 28508

static var _loaded: bool = false
static var _atlas: Texture2D
static var _regions: Dictionary = {}
static var _cache: Dictionary = {}

static func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	var encoded: String = ""
	for path: String in B64_PARTS:
		var part := FileAccess.open(path, FileAccess.READ)
		if part == null:
			push_error("SOMADEX Vela atlas part missing: %s" % path)
			return
		encoded += part.get_as_text().strip_edges()
	var bytes: PackedByteArray = Marshalls.base64_to_raw(encoded)
	if bytes.size() != EXPECTED_BYTES:
		push_error("SOMADEX Vela atlas byte count mismatch: %d" % bytes.size())
		return
	var image := Image.new()
	var load_error: Error = image.load_webp_from_buffer(bytes)
	if load_error != OK:
		push_error("SOMADEX Vela atlas WebP decode failed: %s" % error_string(load_error))
		return
	if Vector2i(image.get_size()) != EXPECTED_ATLAS_SIZE:
		push_error("SOMADEX Vela atlas dimensions mismatch: %s" % [image.get_size()])
		return
	_atlas = ImageTexture.create_from_image(image)
	_load_manifest()

static func _load_manifest() -> void:
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
	return Vector2i(_atlas.get_size())
