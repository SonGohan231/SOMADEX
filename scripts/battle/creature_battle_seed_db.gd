extends RefCounted

# Compatibility adapter for the first authored Vela family. The canonical
# creature seed source is creature_seed_atlas_db.gd; keeping a second embedded
# Base64 copy here previously allowed the two sources to drift and caused a
# Godot decode regression. This adapter preserves the old API without storing
# duplicate artwork.

const ATLAS = preload("res://scripts/battle/creature_seed_atlas_db.gd")
const NAMES: Array[String] = ["Luzik", "Warstwin", "Synkronaut"]
const FRAME_SIZE := Vector2i(128, 128)

static var _texture_cache: Dictionary = {}

static func has_seed(creature_name: String) -> bool:
	return creature_name in NAMES and ATLAS.is_approved(creature_name)

static func seed_count() -> int:
	return NAMES.size()

static func archetype(creature_name: String) -> String:
	if not has_seed(creature_name):
		return "default"
	return ATLAS.archetype(creature_name)

static func texture_for(creature_name: String) -> Texture2D:
	if not has_seed(creature_name):
		return null
	if _texture_cache.has(creature_name):
		return _texture_cache[creature_name] as Texture2D
	var image: Image = ATLAS.image_for(creature_name)
	if image == null:
		return null
	image = image.duplicate()
	if Vector2i(image.get_size()) != FRAME_SIZE:
		image.resize(FRAME_SIZE.x, FRAME_SIZE.y, Image.INTERPOLATE_NEAREST)
	var texture: Texture2D = ImageTexture.create_from_image(image)
	_texture_cache[creature_name] = texture
	return texture
