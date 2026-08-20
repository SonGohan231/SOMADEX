extends RefCounted

const ART = preload("res://scripts/data/monster_art.gd")
const ACTIONS: Array[String] = ["idle", "attack", "hurt", "faint", "special"]
const FRAME_COUNT: int = 4

const SPECIES: Array[String] = [
	"Luzik", "Warstwin", "Synkronaut",
	"Bocznik", "Slizgogon", "Horyzontor",
	"Milimik", "Drobnoskok", "Kwantomruk",
	"Pufek", "Pulsopuch", "Falomamut",
	"Wahlik", "Oscylot", "Fazoryb",
	"Kompasik", "Oktantor", "Kartografon",
	"Srubik", "Torsys", "Spiralion",
	"Uczek", "Objegnik", "Labiryntaur",
	"Kotwiczek", "Bramnik", "Fundamentor",
	"Nasuch", "Echouszek", "Sensoryks",
	"Nucik", "Wibrospiew", "Rezonar"
]

static func animated_names() -> Array[String]:
	var names: Array[String] = SPECIES.duplicate()
	names.sort()
	return names

static func has_animation(creature_name: String) -> bool:
	return creature_name in SPECIES

static func animation_count() -> int:
	return SPECIES.size()

static func frame_texture(creature_name: String, _action: String, _frame: int) -> Texture2D:
	if not has_animation(creature_name):
		return null
	return ART.texture_for(creature_name)

static func source_kind(creature_name: String) -> String:
	return "portrait-procedural" if has_animation(creature_name) else "fallback"
