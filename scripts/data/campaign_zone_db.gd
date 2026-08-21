extends RefCounted

const BASE = preload("res://scripts/data/zone_db.gd")
const PACK = preload("res://scripts/data/region_zone_pack.gd")

static func ids() -> Array[String]:
	var result: Array[String] = BASE.ids()
	for zone_id: String in PACK.ids():
		if not result.has(zone_id):
			result.append(zone_id)
	result.sort()
	return result

static func has_zone(zone_id: String) -> bool:
	return BASE.has_zone(zone_id) or PACK.has_zone(zone_id)

static func zone_info(zone_id: String) -> Dictionary:
	if PACK.has_zone(zone_id):
		return PACK.zone_info(zone_id)
	return BASE.zone_info(zone_id)

static func zone_name(zone_id: String) -> String:
	return str(zone_info(zone_id).get("name", "Vela"))

static func biome(zone_id: String) -> String:
	return str(zone_info(zone_id).get("biome", ""))

static func recommended_level(zone_id: String) -> int:
	return maxi(1, int(zone_info(zone_id).get("recommended_level", 2)))

static func map_rows(zone_id: String) -> Array[String]:
	var rows: Array[String] = []
	if PACK.has_zone(zone_id):
		rows = PACK.map_rows(zone_id)
	else:
		rows = PACK.patch_base_rows(zone_id, BASE.map_rows(zone_id))
	# In the authored Vela map the synchronization station sat directly below
	# the north exit. Stations are interactable but intentionally non-walkable,
	# so it sealed the only tile leading to Resonance Route. Keep the station
	# beside the corridor and restore the corridor tile to P.
	if zone_id == "vela" and rows.size() > 1:
		rows[1] = _replace_char(rows[1], 7, "P")
		rows[1] = _replace_char(rows[1], 6, "C")
	return rows

static func spawn_tile(zone_id: String) -> Vector2i:
	var raw_spawn: Variant = zone_info(zone_id).get("spawn", [7, 20])
	if typeof(raw_spawn) == TYPE_ARRAY:
		var arr: Array = raw_spawn as Array
		if arr.size() >= 2:
			return Vector2i(int(arr[0]), int(arr[1]))
	return Vector2i(7, 20)

static func exit_at(zone_id: String, tile: Vector2i) -> Dictionary:
	if zone_id == "north_gate":
		var extra: Dictionary = PACK.north_gate_exit(tile)
		if not extra.is_empty():
			return extra
	if PACK.has_zone(zone_id):
		return PACK.exit_at(zone_id, tile)
	return BASE.exit_at(zone_id, tile)

static func exit_spawn(exit_data: Dictionary) -> Vector2i:
	var raw_spawn: Variant = exit_data.get("spawn", [7, 20])
	if typeof(raw_spawn) == TYPE_ARRAY:
		var arr: Array = raw_spawn as Array
		if arr.size() >= 2:
			return Vector2i(int(arr[0]), int(arr[1]))
	return Vector2i(7, 20)

static func is_post_game(zone_id: String) -> bool:
	return bool(zone_info(zone_id).get("post_game", false))

static func _replace_char(text: String, index: int, value: String) -> String:
	if index < 0 or index >= text.length():
		return text
	return text.substr(0, index) + value + text.substr(index + 1)
