extends RefCounted

# Adapter for the pinned CC0 production art fetched by tools/fetch_cc0_pixel_assets.sh.
# SOMADEX gameplay/data remains independent from the external atlas layout.

const PLAYER_PATH: String = "res://assets/external/ninja_adventure/character/player_base.png"
const TILESET_FLOOR_PATH: String = "res://assets/external/ninja_adventure/map/tileset_floor.png"
const TILESET_VILLAGE_PATH: String = "res://assets/external/ninja_adventure/map/tileset_village.png"
const TILESET_WALL_PATH: String = "res://assets/external/ninja_adventure/map/tileset_wall.png"
const UI_FONT_PATH: String = "res://assets/external/ninja_adventure/ui/font_normal.ttf"
const SOURCE_FRAME: int = 16

# Coordinates were visually reviewed from CI contact sheets. Variants deliberately
# stay inside coherent palette families so procedural noise no longer leaks into art.
const TILE_SPECS: Dictionary = {
	"G":{"atlas":"floor","cells":[[0,12],[1,12],[2,12],[3,12],[4,12]]},
	"F":{"atlas":"floor","cells":[[1,7],[2,7],[3,7],[1,9],[2,9]]},
	"P":{"atlas":"floor","cells":[[0,11],[1,11],[3,8],[5,8],[7,8]]},
	"A":{"atlas":"floor","cells":[[1,1],[2,1],[4,1],[5,1]]},
	"W":{"atlas":"floor","cells":[[1,22],[2,22],[3,22],[4,22],[5,22]]},
	"T":{"atlas":"village","cells":[[1,7],[2,7],[1,8],[2,8],[1,9]]},
	"O":{"atlas":"village","cells":[[6,3],[7,3],[8,3],[9,3],[10,3]]},
	"K":{"atlas":"wall","cells":[[1,7],[2,7],[3,7],[1,9],[2,9],[3,9]]},
	"H":{"atlas":"village","cells":[[14,1],[15,1],[14,2],[15,2],[14,8],[15,8]]}
}

static var _player_atlas: Texture2D = null
static var _atlas_cache: Dictionary = {}
static var _player_cache: Dictionary = {}
static var _tile_cache: Dictionary = {}
static var _font: Font = null

static func assets_ready() -> bool:
	return ResourceLoader.exists(PLAYER_PATH) and ResourceLoader.exists(TILESET_FLOOR_PATH)

static func pixel_font() -> Font:
	if _font != null:
		return _font
	if ResourceLoader.exists(UI_FONT_PATH):
		_font = load(UI_FONT_PATH) as Font
	return _font

static func tile_texture(code: String, variant: int = 0) -> Texture2D:
	if not TILE_SPECS.has(code):
		return null
	var spec: Dictionary = TILE_SPECS[code] as Dictionary
	var cells: Array = spec.get("cells", []) as Array
	if cells.is_empty():
		return null
	var cell: Array = cells[posmod(variant, cells.size())] as Array
	if cell.size() < 2:
		return null
	var atlas_id: String = str(spec.get("atlas", "floor"))
	var key: String = "%s:%s:%d:%d" % [atlas_id, code, int(cell[0]), int(cell[1])]
	if _tile_cache.has(key):
		return _tile_cache[key] as Texture2D
	var source: Texture2D = _atlas_texture(atlas_id)
	if source == null:
		return null
	var tile := AtlasTexture.new()
	tile.atlas = source
	tile.region = Rect2(int(cell[0]) * SOURCE_FRAME, int(cell[1]) * SOURCE_FRAME, SOURCE_FRAME, SOURCE_FRAME)
	_tile_cache[key] = tile
	return tile

static func player_texture(facing: Vector2i, moving: bool, frame: int) -> Texture2D:
	if not ResourceLoader.exists(PLAYER_PATH):
		return null
	if _player_atlas == null:
		_player_atlas = load(PLAYER_PATH) as Texture2D
	if _player_atlas == null:
		return null

	var direction_col: int = _direction_column(facing)
	var animation_row: int = 0 if not moving else posmod(frame, 4)
	var key: String = "%d:%d" % [direction_col, animation_row]
	if _player_cache.has(key):
		return _player_cache[key] as Texture2D

	var atlas := AtlasTexture.new()
	atlas.atlas = _player_atlas
	atlas.region = Rect2(direction_col * SOURCE_FRAME, animation_row * SOURCE_FRAME, SOURCE_FRAME, SOURCE_FRAME)
	_player_cache[key] = atlas
	return atlas

static func _atlas_texture(atlas_id: String) -> Texture2D:
	if _atlas_cache.has(atlas_id):
		return _atlas_cache[atlas_id] as Texture2D
	var path: String = TILESET_FLOOR_PATH
	match atlas_id:
		"village": path = TILESET_VILLAGE_PATH
		"wall": path = TILESET_WALL_PATH
	if not ResourceLoader.exists(path):
		return null
	var texture: Texture2D = load(path) as Texture2D
	if texture != null:
		_atlas_cache[atlas_id] = texture
	return texture

static func _direction_column(facing: Vector2i) -> int:
	# Source SpriteCharacter mapping: RIGHT=3, DOWN=0, LEFT=2, UP=1.
	if facing == Vector2i.RIGHT:
		return 3
	if facing == Vector2i.LEFT:
		return 2
	if facing == Vector2i.UP:
		return 1
	return 0
