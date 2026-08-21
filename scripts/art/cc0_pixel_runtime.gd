extends RefCounted

# Adapter for the pinned CC0 production art fetched by tools/fetch_cc0_pixel_assets.sh.
# We keep SOMADEX gameplay/data independent from the external atlas layout.

const PLAYER_PATH: String = "res://assets/external/ninja_adventure/character/player_base.png"
const TILESET_FLOOR_PATH: String = "res://assets/external/ninja_adventure/map/tileset_floor.png"
const UI_FONT_PATH: String = "res://assets/external/ninja_adventure/ui/font_normal.ttf"
const SOURCE_FRAME: int = 16

static var _player_atlas: Texture2D = null
static var _player_cache: Dictionary = {}
static var _font: Font = null

static func assets_ready() -> bool:
	return ResourceLoader.exists(PLAYER_PATH) and ResourceLoader.exists(TILESET_FLOOR_PATH)

static func pixel_font() -> Font:
	if _font != null:
		return _font
	if ResourceLoader.exists(UI_FONT_PATH):
		_font = load(UI_FONT_PATH) as Font
	return _font

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
	atlas.region = Rect2(
		direction_col * SOURCE_FRAME,
		animation_row * SOURCE_FRAME,
		SOURCE_FRAME,
		SOURCE_FRAME
	)
	_player_cache[key] = atlas
	return atlas

static func _direction_column(facing: Vector2i) -> int:
	# Source SpriteCharacter mapping: RIGHT=3, DOWN=0, LEFT=2, UP=1.
	if facing == Vector2i.RIGHT:
		return 3
	if facing == Vector2i.LEFT:
		return 2
	if facing == Vector2i.UP:
		return 1
	return 0
