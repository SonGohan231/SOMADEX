extends RefCounted

# Compatibility facade. Existing screens keep their stable ART API while the
# implementation prefers the compact Vela atlas and falls back to legacy art.
const ART = preload("res://scripts/data/creature_art.gd")

static func texture_for(creature_name: String) -> Texture2D:
	return ART.texture_for(creature_name)

static func has_portrait(creature_name: String) -> bool:
	return ART.has_portrait(creature_name)

static func vela_portrait_count() -> int:
	return ART.vela_portrait_count()

static func vela_atlas_size() -> Vector2i:
	return ART.vela_atlas_size()
