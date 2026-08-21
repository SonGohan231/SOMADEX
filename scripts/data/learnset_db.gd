extends RefCounted

const MOVES = preload("res://scripts/data/move_db.gd")
const EVOLUTION = preload("res://scripts/data/evolution_db.gd")

const LEARNSET_SIZE: int = 16
const ACTIVE_LIMIT: int = 4
const SPECIAL_UNLOCK_LEVEL: int = 20
const UNLOCK_LEVELS: Array[int] = [1,1,1,1,5,8,12,15,18,22,26,30,34,38,44,50]

static func learnset_for(creature_name: String, creature_data: Dictionary) -> Array[Dictionary]:
	var selected: Array[String] = []
	for raw_move: Variant in creature_data.get("moves", []) as Array:
		if typeof(raw_move) != TYPE_DICTIONARY:
			continue
		var legacy_name: String = str((raw_move as Dictionary).get("name", ""))
		var matched: String = _id_for_name(legacy_name)
		if not matched.is_empty() and not selected.has(matched):
			selected.append(matched)
	var preferred_types: Array[String] = []
	for raw_type: Variant in creature_data.get("types", []) as Array:
		var type_id: String = str(raw_type)
		if not type_id.is_empty() and not preferred_types.has(type_id):
			preferred_types.append(type_id)
	for fallback: String in [str(creature_data.get("type", "")), "REZONANS", "PHYSICAL", "SUPPORT"]:
		if not fallback.is_empty() and not preferred_types.has(fallback):
			preferred_types.append(fallback)
	for type_id: String in preferred_types:
		for move_id: String in MOVES.ids():
			if selected.size() >= LEARNSET_SIZE:
				break
			var data: Dictionary = MOVES.info(move_id)
			if str(data.get("move_type", "")) == type_id and not selected.has(move_id):
				selected.append(move_id)
	var all_ids: Array[String] = MOVES.ids()
	var family_id: int = maxi(1, EVOLUTION.family_id(creature_name))
	if family_id <= 0:
		family_id = maxi(1, int(creature_data.get("id", 1)))
	var start: int = posmod(family_id * 7, maxi(1, all_ids.size()))
	for offset: int in range(all_ids.size()):
		if selected.size() >= LEARNSET_SIZE:
			break
		var move_id: String = all_ids[(start + offset) % all_ids.size()]
		if not selected.has(move_id):
			selected.append(move_id)
	var result: Array[Dictionary] = []
	for index: int in range(mini(LEARNSET_SIZE, selected.size())):
		var move_id: String = selected[index]
		result.append({
			"move_id":move_id,
			"level":UNLOCK_LEVELS[index],
			"signature":index == 0,
			"special":false
		})
	return result

static func available_move_ids(creature_name: String, level: int, creature_data: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for entry: Dictionary in learnset_for(creature_name, creature_data):
		if int(entry.get("level", 1)) <= level:
			result.append(str(entry.get("move_id", "")))
	return result

static func default_loadout(creature_name: String, level: int, creature_data: Dictionary) -> Array[String]:
	var available: Array[String] = available_move_ids(creature_name, level, creature_data)
	var result: Array[String] = []
	for move_id: String in available:
		if result.size() >= ACTIVE_LIMIT:
			break
		if MOVES.has(move_id):
			result.append(move_id)
	if result.size() < ACTIVE_LIMIT:
		for move_id: String in MOVES.ids():
			if result.size() >= ACTIVE_LIMIT:
				break
			if not result.has(move_id):
				result.append(move_id)
	return result

static func normalize_loadout(creature_name: String, level: int, raw: Variant, creature_data: Dictionary) -> Array[String]:
	var available: Array[String] = available_move_ids(creature_name, level, creature_data)
	var result: Array[String] = []
	if typeof(raw) == TYPE_ARRAY:
		for value: Variant in raw as Array:
			var move_id: String = str(value)
			if available.has(move_id) and MOVES.has(move_id) and not result.has(move_id):
				result.append(move_id)
			if result.size() >= ACTIVE_LIMIT:
				break
	for move_id: String in default_loadout(creature_name, level, creature_data):
		if result.size() >= ACTIVE_LIMIT:
			break
		if not result.has(move_id):
			result.append(move_id)
	return result

static func default_special(creature_name: String, level: int, creature_data: Dictionary) -> String:
	if level < SPECIAL_UNLOCK_LEVEL:
		return ""
	var family_id: int = maxi(1, EVOLUTION.family_id(creature_name))
	var candidates: Array[String] = []
	for move_id: String in MOVES.ids():
		var tags: Array = MOVES.info(move_id).get("tags", []) as Array
		if tags.has("special") or tags.has("finisher"):
			candidates.append(move_id)
	if candidates.is_empty():
		return ""
	return candidates[posmod(family_id - 1, candidates.size())]

static func normalize_special(creature_name: String, level: int, raw: Variant, creature_data: Dictionary) -> String:
	if level < SPECIAL_UNLOCK_LEVEL:
		return ""
	var move_id: String = str(raw)
	if MOVES.has(move_id):
		var tags: Array = MOVES.info(move_id).get("tags", []) as Array
		if tags.has("special") or tags.has("finisher"):
			return move_id
	return default_special(creature_name, level, creature_data)

static func active_move_data(member: Dictionary, creature_data: Dictionary) -> Array[Dictionary]:
	var name: String = str(member.get("name", creature_data.get("name", "")))
	var level: int = maxi(1, int(member.get("level", 1)))
	var loadout: Array[String] = normalize_loadout(name, level, member.get("move_ids", []), creature_data)
	var result: Array[Dictionary] = []
	for move_id: String in loadout:
		result.append(MOVES.info(move_id))
	return result

static func cycle_slot(member: Dictionary, creature_data: Dictionary, slot_index: int) -> Dictionary:
	var result: Dictionary = member.duplicate(true)
	if slot_index < 0 or slot_index >= ACTIVE_LIMIT:
		return result
	var name: String = str(result.get("name", creature_data.get("name", "")))
	var level: int = maxi(1, int(result.get("level", 1)))
	var available: Array[String] = available_move_ids(name, level, creature_data)
	if available.is_empty():
		return result
	var loadout: Array[String] = normalize_loadout(name, level, result.get("move_ids", []), creature_data)
	var current: String = loadout[slot_index]
	var current_index: int = available.find(current)
	for offset: int in range(1, available.size() + 1):
		var candidate: String = available[(maxi(0, current_index) + offset) % available.size()]
		if not loadout.has(candidate):
			loadout[slot_index] = candidate
			break
	result["move_ids"] = loadout
	return result

static func _id_for_name(move_name: String) -> String:
	if move_name.is_empty():
		return ""
	for move_id: String in MOVES.ids():
		if str(MOVES.info(move_id).get("name", "")) == move_name:
			return move_id
	return ""
