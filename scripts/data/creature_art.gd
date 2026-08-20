extends RefCounted

const VELA = preload("res://scripts/data/vela_portrait_art.gd")
const LEGACY = preload("res://scripts/data/monster_art.gd")

static func texture_for(creature_name: String) -> Texture2D:
	var portrait: Texture2D = VELA.texture_for(creature_name)
	if portrait != null:
		return portrait
	return LEGACY.texture_for(creature_name)

static func has_portrait(creature_name: String) -> bool:
	return VELA.has_portrait(creature_name)

static func vela_portrait_count() -> int:
	return VELA.portrait_count()

static func vela_atlas_size() -> Vector2i:
	return VELA.atlas_size()
