extends RefCounted

const SHEET_PATH: String = "res://assets/world/alpha1_characters_24.png"
const CELL_SIZE: Vector2i = Vector2i(24, 24)

static var _atlas: Texture2D
static var _cache: Dictionary = {}

static func player_texture(facing: Vector2i, moving: bool, phase: int) -> Texture2D:
	var direction_index: int = 0
	if facing == Vector2i.LEFT:
		direction_index = 1
	elif facing == Vector2i.RIGHT:
		direction_index = 2
	elif facing == Vector2i.UP:
		direction_index = 3
	var frame: int = 1 if moving and phase % 2 == 1 else 0
	var column: int = direction_index * 2 + frame
	return _region(column, 0, "player_%d_%d" % [direction_index, frame])

static func npc_texture(npc_id: String) -> Texture2D:
	var checksum: int = 0
	for i: int in range(npc_id.length()):
		checksum += npc_id.unicode_at(i)
	var column: int = checksum % 8
	return _region(column, 1, "npc_%d" % column)

static func _region(column: int, row: int, cache_key: String) -> Texture2D:
	if _cache.has(cache_key):
		return _cache[cache_key] as Texture2D
	if _atlas == null:
		_atlas = load(SHEET_PATH) as Texture2D
	if _atlas == null:
		return null
	var region: AtlasTexture = AtlasTexture.new()
	region.atlas = _atlas
	region.region = Rect2(column * CELL_SIZE.x, row * CELL_SIZE.y, CELL_SIZE.x, CELL_SIZE.y)
	region.filter_clip = true
	_cache[cache_key] = region
	return region
