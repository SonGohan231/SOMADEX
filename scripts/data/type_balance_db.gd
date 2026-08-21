extends RefCounted

const FAMILY_TYPES = preload("res://scripts/data/family_type_db.gd")
const CATALOG = preload("res://scripts/data/creature_catalog.gd")

const STRONG: float = 1.20
const RESIST: float = 0.85
const MIN_MULT: float = 0.75
const MAX_MULT: float = 1.35

# SOMADEX uses a mild mechanical matchup layer. Status reactions remain the
# larger tactical multiplier; types guide team composition without hard walls.
const MATCHUPS: Dictionary = {
	"REZONANS": {"OSC":STRONG, "STABIL":RESIST},
	"ŚLIZG": {"NAPIĘCIE":STRONG, "STABIL":RESIST},
	"NAPIĘCIE": {"STABIL":STRONG, "ŚLIZG":RESIST},
	"OSC": {"KIERUNEK":STRONG, "REZONANS":RESIST},
	"KIERUNEK": {"ŚLIZG":STRONG, "OSC":RESIST},
	"TORSJA": {"STABIL":STRONG, "ŚLIZG":RESIST},
	"STABIL": {"OSC":STRONG, "TORSJA":RESIST},
	"CZUCIE": {"KIERUNEK":STRONG, "REZONANS":RESIST},
	"WAVE": {"REZONANS":STRONG, "STABIL":RESIST},
	"ELECTRIC": {"WAVE":STRONG, "STABIL":RESIST},
	"ICE": {"WAVE":STRONG, "FIRE":RESIST},
	"FIRE": {"ICE":STRONG, "WAVE":RESIST},
	"PHYSICAL": {"CZUCIE":STRONG, "NAPIĘCIE":RESIST}
}

static func normalize_type(type_id: String) -> String:
	var value: String = type_id.strip_edges().to_upper()
	match value:
		"FALA": return "WAVE"
		"OBEJŚCIE": return "KIERUNEK"
		"SUPPORT": return "SUPPORT"
		_: return value

static func multiplier(move_type: String, target_types: Array) -> float:
	var move: String = normalize_type(move_type)
	if move == "SUPPORT" or not MATCHUPS.has(move):
		return 1.0
	var total: float = 1.0
	var row: Dictionary = MATCHUPS[move] as Dictionary
	for raw_target: Variant in target_types:
		var target: String = normalize_type(str(raw_target))
		if target.is_empty():
			continue
		total *= float(row.get(target, 1.0))
	return clampf(total, MIN_MULT, MAX_MULT)

static func label(move_type: String, target_types: Array) -> String:
	var mult: float = multiplier(move_type, target_types)
	if mult >= 1.15:
		return "PRZEWAGA TYPU"
	if mult <= 0.90:
		return "OPÓR TYPU"
	return ""

static func target_types(creature_data: Dictionary) -> Array:
	var result: Array = []
	var creature_name: String = str(creature_data.get("name", ""))
	if not creature_name.is_empty() and CATALOG.has_form(creature_name):
		var catalog_info: Dictionary = CATALOG.form(creature_name)
		var family_id: int = int(catalog_info.get("family_id", 0))
		if FAMILY_TYPES.has_family(family_id):
			result.append(FAMILY_TYPES.type_for_family(family_id))
	var raw_types: Variant = creature_data.get("types", [])
	if typeof(raw_types) == TYPE_ARRAY:
		for raw_type: Variant in raw_types as Array:
			var normalized: String = normalize_type(str(raw_type))
			if not normalized.is_empty() and normalized != "SUPPORT" and not result.has(normalized):
				result.append(normalized)
	if result.is_empty():
		var fallback: String = normalize_type(str(creature_data.get("type", "REZONANS")))
		if not fallback.is_empty():
			result.append(fallback)
	return result

static func primary_type(creature_data: Dictionary) -> String:
	var types: Array = target_types(creature_data)
	return str(types[0]) if not types.is_empty() else "REZONANS"

static func family_type(family_id: int) -> String:
	return FAMILY_TYPES.type_for_family(family_id)

static func validate() -> Array[String]:
	var errors: Array[String] = []
	for raw_move: Variant in MATCHUPS.keys():
		var move: String = str(raw_move)
		if move not in FAMILY_TYPES.CORE_TYPES:
			errors.append("unknown attacking type %s" % move)
		var row: Dictionary = MATCHUPS[raw_move] as Dictionary
		for raw_target: Variant in row.keys():
			var target: String = str(raw_target)
			if target not in FAMILY_TYPES.CORE_TYPES:
				errors.append("unknown target type %s" % target)
			var value: float = float(row[raw_target])
			if value < MIN_MULT or value > MAX_MULT:
				errors.append("out-of-band matchup %s>%s" % [move, target])
	return errors
