extends RefCounted

const MAIN_STORY_HOURS_MIN: int = 18
const MAIN_STORY_HOURS_MAX: int = 25
const RELAXED_PLAY_HOURS_MIN: int = 25
const RELAXED_PLAY_HOURS_MAX: int = 35
const COMPLETION_HOURS_MIN: int = 35
const COMPLETION_HOURS_MAX: int = 50

const FIRST_REGION_TOWNS_MIN: int = 8
const FIRST_REGION_TOWNS_MAX: int = 10
const FIRST_REGION_FIELD_AREAS_MIN: int = 12
const FIRST_REGION_FIELD_AREAS_MAX: int = 18
const MAIN_BOSSES_MIN: int = 8
const STORY_NPCS_MIN: int = 30
const STORY_NPCS_MAX: int = 50

const FAMILY_TARGET_FIRST_VERSION: int = 50
const FORM_TARGET_FIRST_VERSION: int = 150
const MOVE_TARGET_MIN: int = 180
const MOVE_TARGET_MAX: int = 220
const PASSIVE_TARGET_MIN: int = 50
const STATUS_TARGET_MIN: int = 15
const STATUS_TARGET_MAX: int = 20
const COMBO_TARGET_MIN: int = 20
const COMBO_TARGET_MAX: int = 30
const TRAINER_TALENT_TARGET: int = 100
const TRAINER_LEVEL_CAP: int = 50
const EQUIPMENT_TARGET_MIN: int = 80
const EQUIPMENT_TARGET_MAX: int = 120
const ITEM_TARGET_MIN: int = 100
const COMBAT_GADGET_TARGET_MIN: int = 25
const COMBAT_GADGET_TARGET_MAX: int = 40
const PARTY_LIMIT: int = 6
const ACTIVE_MOVE_LIMIT: int = 4
const SPECIAL_MOVE_LIMIT: int = 1

const BATTLE_MODES: Array[String] = ["standard", "resonance", "trainer_duel"]
const TRAINER_PATHS: Array[String] = ["tactician", "guardian", "researcher", "technician", "vanguard"]
const CREATURE_DATA_FIELDS: Array[String] = [
	"id", "name", "types", "max_hp", "attack", "defense", "speed",
	"moves", "capture_rate", "exp_yield", "habitat", "rarity"
]
const MOVE_DATA_FIELDS: Array[String] = [
	"id", "name", "kind", "move_type", "power", "accuracy", "cost",
	"priority", "status", "status_chance", "animation", "pattern", "tags"
]

static func first_region_contract() -> Dictionary:
	return {
		"story_hours": Vector2i(MAIN_STORY_HOURS_MIN, MAIN_STORY_HOURS_MAX),
		"completion_hours": Vector2i(COMPLETION_HOURS_MIN, COMPLETION_HOURS_MAX),
		"towns": Vector2i(FIRST_REGION_TOWNS_MIN, FIRST_REGION_TOWNS_MAX),
		"field_areas": Vector2i(FIRST_REGION_FIELD_AREAS_MIN, FIRST_REGION_FIELD_AREAS_MAX),
		"main_bosses_min": MAIN_BOSSES_MIN,
		"npc_range": Vector2i(STORY_NPCS_MIN, STORY_NPCS_MAX)
	}

static func content_contract() -> Dictionary:
	return {
		"families": FAMILY_TARGET_FIRST_VERSION,
		"forms": FORM_TARGET_FIRST_VERSION,
		"moves": Vector2i(MOVE_TARGET_MIN, MOVE_TARGET_MAX),
		"passives_min": PASSIVE_TARGET_MIN,
		"statuses": Vector2i(STATUS_TARGET_MIN, STATUS_TARGET_MAX),
		"combos": Vector2i(COMBO_TARGET_MIN, COMBO_TARGET_MAX),
		"trainer_talents": TRAINER_TALENT_TARGET,
		"equipment": Vector2i(EQUIPMENT_TARGET_MIN, EQUIPMENT_TARGET_MAX),
		"items_min": ITEM_TARGET_MIN,
		"combat_gadgets": Vector2i(COMBAT_GADGET_TARGET_MIN, COMBAT_GADGET_TARGET_MAX)
	}
