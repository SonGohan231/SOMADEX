extends RefCounted

const PROGRESSION = preload("res://scripts/data/progression_db.gd")
const DB = preload("res://scripts/data/monster_db.gd")
const EVOLUTION = preload("res://scripts/data/evolution_db.gd")
const ITEMS = preload("res://scripts/data/item_db.gd")
const EQUIPMENT = preload("res://scripts/data/equipment_db.gd")
const RULES = preload("res://scripts/battle/battle_rules.gd")

const SAVE_VERSION: int = 10
const START_TILE: Vector2i = Vector2i(7, 20)
const STARTER_LEVEL: int = 5
const PARTY_LIMIT: int = 6

static func new_profile(starter_name: String = "") -> Dictionary:
	var profile: Dictionary = {
		"version": SAVE_VERSION,
		"starter": starter_name,
		"player_x": START_TILE.x,
		"player_y": START_TILE.y,
		"trainer_level": 1,
		"trainer_xp": 0,
		"talent_points": 1,
		"talents": PROGRESSION.default_talents(),
		"party": [],
		"storage": [],
		"active_party_index": 0,
		"next_member_id": 1,
		"seen": [],
		"caught": [],
		"inventory": ITEMS.default_inventory(),
		"owned_equipment": EQUIPMENT.default_owned(),
		"equipment": EQUIPMENT.default_loadout(),
		"quest_stage": 0,
		"zone_id": "vela",
		"flags": {},
		"dialogue_flags": {},
		"last_evolutions": [],
		"haptics": true
	}
	if not starter_name.is_empty():
		var member: Dictionary = make_member(starter_name, STARTER_LEVEL, 1)
		(profile["party"] as Array).append(member)
		(profile["seen"] as Array).append(starter_name)
		(profile["caught"] as Array).append(starter_name)
		profile["next_member_id"] = 2
	return profile

static func make_member(monster_name: String, level: int, serial: int, hp: int = -1) -> Dictionary:
	var safe_name: String = EVOLUTION.canonical_name(monster_name)
	if safe_name.is_empty():
		safe_name = monster_name
	var safe_level: int = maxi(1, level)
	var member: Dictionary = {
		"uid": "%s-%04d" % [safe_name.to_lower(), maxi(1, serial)],
		"name": safe_name,
		"level": safe_level,
		"xp": 0,
		"hp": 1,
		"bond": 0,
		"moves": [0, 1, 2, 3]
	}
	var max_hp: int = base_member_max_hp(member)
	member["hp"] = max_hp if hp < 0 else clampi(hp, 0, max_hp)
	return member

static func base_member_max_hp(member: Dictionary) -> int:
	var name: String = str(member.get("name", "Luzik"))
	var data: Dictionary = DB.get_monster(name)
	var level: int = maxi(1, int(member.get("level", 1)))
	return maxi(1, int(data.get("max_hp", 20)) + int((level - 1) / 2))

static func member_max_hp(member: Dictionary, talents: Dictionary, loadout: Dictionary) -> int:
	var talent_bonus: Dictionary = PROGRESSION.bonuses(talents)
	var gear_bonus: Dictionary = EQUIPMENT.aggregate(loadout)
	return base_member_max_hp(member) + int(talent_bonus.get("max_hp_bonus", 0)) + int(gear_bonus.get("max_hp_bonus", 0))

static func migrate(raw: Dictionary) -> Dictionary:
	var starter_name: String = str(raw.get("starter", ""))
	var profile: Dictionary = new_profile()
	profile["starter"] = starter_name
	profile["player_x"] = int(raw.get("player_x", START_TILE.x))
	profile["player_y"] = int(raw.get("player_y", START_TILE.y))
	profile["trainer_level"] = maxi(1, int(raw.get("trainer_level", 1)))
	profile["trainer_xp"] = maxi(0, int(raw.get("trainer_xp", 0)))
	profile["haptics"] = bool(raw.get("haptics", true))
	profile["zone_id"] = str(raw.get("zone_id", "vela"))
	profile["quest_stage"] = maxi(0, int(raw.get("quest_stage", 0)))
	profile["talent_points"] = maxi(0, int(raw.get("talent_points", 1)))

	var raw_talents: Variant = raw.get("talents", {})
	var talents: Dictionary = PROGRESSION.default_talents()
	if typeof(raw_talents) == TYPE_DICTIONARY:
		var incoming_talents: Dictionary = raw_talents as Dictionary
		for path_id: String in PROGRESSION.path_ids():
			talents[path_id] = clampi(int(incoming_talents.get(path_id, 0)), 0, 5)
	profile["talents"] = talents

	profile["inventory"] = ITEMS.normalize_inventory(raw.get("inventory", {}))
	var owned: Array[String] = EQUIPMENT.normalize_owned(raw.get("owned_equipment", []))
	profile["owned_equipment"] = owned
	profile["equipment"] = EQUIPMENT.normalize_loadout(raw.get("equipment", {}), owned)

	profile["seen"] = _string_array(raw.get("seen", []))
	profile["caught"] = _string_array(raw.get("caught", []))

	var raw_flags: Variant = raw.get("flags", {})
	if typeof(raw_flags) == TYPE_DICTIONARY:
		profile["flags"] = (raw_flags as Dictionary).duplicate(true)
	var raw_dialogue: Variant = raw.get("dialogue_flags", {})
	if typeof(raw_dialogue) == TYPE_DICTIONARY:
		profile["dialogue_flags"] = (raw_dialogue as Dictionary).duplicate(true)

	var serial: int = 1
	var normalized_party: Array = []
	var raw_party: Variant = raw.get("party", [])
	if typeof(raw_party) == TYPE_ARRAY:
		for value: Variant in raw_party as Array:
			if normalized_party.size() >= PARTY_LIMIT:
				break
			var member: Dictionary = _normalize_member(value, serial)
			if member.is_empty():
				continue
			normalized_party.append(member)
			serial += 1

	if normalized_party.is_empty() and not starter_name.is_empty():
		normalized_party.append(make_member(starter_name, STARTER_LEVEL, serial))
		serial += 1

	var old_player_hp: int = int(raw.get("player_hp", -1))
	if old_player_hp >= 0 and not normalized_party.is_empty():
		var first_member: Dictionary = normalized_party[0] as Dictionary
		first_member["hp"] = clampi(old_player_hp, 0, base_member_max_hp(first_member))
		normalized_party[0] = first_member

	profile["party"] = normalized_party

	var normalized_storage: Array = []
	var raw_storage: Variant = raw.get("storage", [])
	if typeof(raw_storage) == TYPE_ARRAY:
		for value: Variant in raw_storage as Array:
			var member: Dictionary = _normalize_member(value, serial)
			if member.is_empty():
				continue
			normalized_storage.append(member)
			serial += 1
	profile["storage"] = normalized_storage
	profile["next_member_id"] = maxi(serial, int(raw.get("next_member_id", serial)))

	var active_index: int = int(raw.get("active_party_index", 0))
	profile["active_party_index"] = clampi(active_index, 0, maxi(0, normalized_party.size() - 1))

	var old_version: int = int(raw.get("version", 2))
	if old_version <= 2 and not starter_name.is_empty():
		_add_unique(profile["seen"] as Array, starter_name)
		_add_unique(profile["caught"] as Array, starter_name)
		if int(raw.get("discovered", 1)) >= 2:
			_add_unique(profile["seen"] as Array, "Wahlik")
		profile["quest_stage"] = maxi(int(profile["quest_stage"]), 1)

	for value: Variant in normalized_party:
		var member: Dictionary = value as Dictionary
		var name: String = str(member.get("name", ""))
		_add_unique(profile["seen"] as Array, name)
		_add_unique(profile["caught"] as Array, name)

	profile["last_evolutions"] = []
	if not str(profile.get("zone_id", "")).is_empty():
		profile["version"] = SAVE_VERSION
	return profile

static func player_tile(profile: Dictionary) -> Vector2i:
	return Vector2i(int(profile.get("player_x", START_TILE.x)), int(profile.get("player_y", START_TILE.y)))

static func set_player_tile(profile: Dictionary, tile: Vector2i) -> void:
	profile["player_x"] = tile.x
	profile["player_y"] = tile.y

static func active_index(profile: Dictionary) -> int:
	var party: Array = profile.get("party", []) as Array
	if party.is_empty():
		return 0
	return clampi(int(profile.get("active_party_index", 0)), 0, party.size() - 1)

static func active_member(profile: Dictionary) -> Dictionary:
	var party: Array = profile.get("party", []) as Array
	if party.is_empty():
		return {}
	return (party[active_index(profile)] as Dictionary).duplicate(true)

static func active_name(profile: Dictionary) -> String:
	return str(active_member(profile).get("name", profile.get("starter", "Luzik")))

static func set_active_member(profile: Dictionary, index: int) -> bool:
	var party: Array = profile.get("party", []) as Array
	if index < 0 or index >= party.size():
		return false
	var member: Dictionary = party[index] as Dictionary
	if int(member.get("hp", 0)) <= 0:
		return false
	profile["active_party_index"] = index
	return true

static func replace_party(profile: Dictionary, party: Array, new_active_index: int) -> void:
	var normalized: Array = []
	var serial: int = maxi(1, int(profile.get("next_member_id", 1)))
	for value: Variant in party:
		if normalized.size() >= PARTY_LIMIT:
			break
		var member: Dictionary = _normalize_member(value, serial)
		if member.is_empty():
			continue
		normalized.append(member)
		serial += 1
	profile["party"] = normalized
	profile["active_party_index"] = clampi(new_active_index, 0, maxi(0, normalized.size() - 1))

static func add_seen(profile: Dictionary, monster_name: String) -> void:
	var seen: Array = profile.get("seen", []) as Array
	_add_unique(seen, EVOLUTION.canonical_name(monster_name))
	profile["seen"] = seen

static func add_caught(profile: Dictionary, monster_name: String, level: int = 1) -> Dictionary:
	var canonical: String = EVOLUTION.canonical_name(monster_name)
	add_seen(profile, canonical)
	var caught: Array = profile.get("caught", []) as Array
	_add_unique(caught, canonical)
	profile["caught"] = caught

	var serial: int = maxi(1, int(profile.get("next_member_id", 1)))
	var member: Dictionary = make_member(canonical, level, serial)
	profile["next_member_id"] = serial + 1
	var party: Array = profile.get("party", []) as Array
	if party.size() < PARTY_LIMIT:
		party.append(member)
		profile["party"] = party
		return {"destination": "party", "member": member}
	var storage: Array = profile.get("storage", []) as Array
	storage.append(member)
	profile["storage"] = storage
	return {"destination": "storage", "member": member}

static func heal_party(profile: Dictionary) -> void:
	var talents: Dictionary = profile.get("talents", PROGRESSION.default_talents()) as Dictionary
	var loadout: Dictionary = profile.get("equipment", EQUIPMENT.default_loadout()) as Dictionary
	var party: Array = profile.get("party", []) as Array
	for i: int in range(party.size()):
		var member: Dictionary = party[i] as Dictionary
		member["hp"] = member_max_hp(member, talents, loadout)
		party[i] = member
	profile["party"] = party

static func add_member_exp(profile: Dictionary, index: int, amount: int) -> int:
	var party: Array = profile.get("party", []) as Array
	profile["last_evolutions"] = []
	if index < 0 or index >= party.size() or amount <= 0:
		return 0
	var member: Dictionary = party[index] as Dictionary
	var old_name: String = str(member.get("name", "Luzik"))
	var old_level: int = maxi(1, int(member.get("level", 1)))
	var level: int = old_level
	var xp: int = maxi(0, int(member.get("xp", 0))) + amount
	var threshold: int = RULES.creature_xp_to_next(level)
	while xp >= threshold:
		xp -= threshold
		level += 1
		threshold = RULES.creature_xp_to_next(level)
	member["level"] = level
	member["xp"] = xp
	var talents: Dictionary = profile.get("talents", PROGRESSION.default_talents()) as Dictionary
	var loadout: Dictionary = profile.get("equipment", EQUIPMENT.default_loadout()) as Dictionary
	if level > old_level:
		member["hp"] = int(member.get("hp", 1)) + RULES.level_hp_growth(old_level, level)
		member["hp"] = mini(int(member["hp"]), member_max_hp(member, talents, loadout))

	var resolved_name: String = EVOLUTION.resolve_name(old_name, level)
	if not resolved_name.is_empty() and resolved_name != old_name:
		var old_max_hp: int = member_max_hp(member, talents, loadout)
		member["name"] = resolved_name
		var new_max_hp: int = member_max_hp(member, talents, loadout)
		member["hp"] = clampi(int(member.get("hp", 1)) + maxi(1, new_max_hp - old_max_hp), 0, new_max_hp)
		var seen: Array = profile.get("seen", []) as Array
		var caught: Array = profile.get("caught", []) as Array
		_add_unique(seen, resolved_name)
		_add_unique(caught, resolved_name)
		profile["seen"] = seen
		profile["caught"] = caught
		profile["last_evolutions"] = [{
			"uid": str(member.get("uid", "")),
			"from": old_name,
			"to": resolved_name,
			"level": level
		}]

	party[index] = member
	profile["party"] = party
	return level - old_level

static func cycle_equipment(profile: Dictionary, slot_id: String) -> String:
	if not EQUIPMENT.slot_ids().has(slot_id):
		return ""
	var owned: Array[String] = EQUIPMENT.normalize_owned(profile.get("owned_equipment", []))
	var loadout: Dictionary = EQUIPMENT.normalize_loadout(profile.get("equipment", {}), owned)
	var current_id: String = str(loadout.get(slot_id, ""))
	var next_id: String = EQUIPMENT.next_owned_for_slot(owned, slot_id, current_id)
	if next_id.is_empty():
		return ""
	loadout[slot_id] = next_id
	profile["equipment"] = loadout
	_clamp_party_hp(profile)
	return next_id

static func set_dialogue_flag(profile: Dictionary, flag_id: String) -> void:
	if flag_id.is_empty():
		return
	var flags: Dictionary = profile.get("dialogue_flags", {}) as Dictionary
	flags[flag_id] = true
	profile["dialogue_flags"] = flags

static func _clamp_party_hp(profile: Dictionary) -> void:
	var talents: Dictionary = profile.get("talents", PROGRESSION.default_talents()) as Dictionary
	var loadout: Dictionary = profile.get("equipment", EQUIPMENT.default_loadout()) as Dictionary
	var party: Array = profile.get("party", []) as Array
	for i: int in range(party.size()):
		var member: Dictionary = party[i] as Dictionary
		member["hp"] = clampi(int(member.get("hp", 0)), 0, member_max_hp(member, talents, loadout))
		party[i] = member
	profile["party"] = party

static func _normalize_member(value: Variant, serial: int) -> Dictionary:
	if typeof(value) == TYPE_STRING:
		var name_from_string: String = EVOLUTION.canonical_name(str(value))
		if name_from_string.is_empty() or not DB.has_monster(name_from_string):
			return {}
		return make_member(name_from_string, STARTER_LEVEL, serial)
	if typeof(value) != TYPE_DICTIONARY:
		return {}
	var incoming: Dictionary = value as Dictionary
	var name: String = EVOLUTION.canonical_name(str(incoming.get("name", incoming.get("monster", ""))))
	if name.is_empty() or not DB.has_monster(name):
		return {}
	var level: int = maxi(1, int(incoming.get("level", STARTER_LEVEL)))
	var member: Dictionary = make_member(name, level, serial, int(incoming.get("hp", -1)))
	member["uid"] = str(incoming.get("uid", member["uid"]))
	member["xp"] = maxi(0, int(incoming.get("xp", 0)))
	member["bond"] = maxi(0, int(incoming.get("bond", 0)))
	var raw_moves: Variant = incoming.get("moves", [0, 1, 2, 3])
	var moves: Array[int] = []
	if typeof(raw_moves) == TYPE_ARRAY:
		for move_value: Variant in raw_moves as Array:
			var move_index: int = int(move_value)
			if move_index >= 0 and move_index < 4 and not moves.has(move_index):
				moves.append(move_index)
	while moves.size() < 4:
		for move_index: int in range(4):
			if not moves.has(move_index):
				moves.append(move_index)
			if moves.size() >= 4:
				break
	member["moves"] = moves
	return member

static func _string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if typeof(value) != TYPE_ARRAY:
		return result
	for item: Variant in value as Array:
		var text: String = str(item)
		if not text.is_empty() and not result.has(text):
			result.append(text)
	return result

static func _add_unique(target: Array, value: String) -> void:
	if not value.is_empty() and not target.has(value):
		target.append(value)
