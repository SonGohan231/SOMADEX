extends RefCounted

const BASE = preload("res://scripts/data/npc_db.gd")

static func in_zone(zone_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for npc: Dictionary in BASE.in_zone(zone_id):
		var copy: Dictionary = npc.duplicate(true)
		if str(copy.get("id", "")) == "vela_trial":
			copy["tile"] = [7, 4]
		result.append(copy)
	return result

static func at(zone_id: String, tile: Vector2i) -> Dictionary:
	for npc: Dictionary in in_zone(zone_id):
		if tile_of(npc) == tile:
			return npc
	return {}

static func tile_of(npc: Dictionary) -> Vector2i:
	var raw_tile: Array = npc.get("tile", []) as Array
	if raw_tile.size() >= 2:
		return Vector2i(int(raw_tile[0]), int(raw_tile[1]))
	return Vector2i(-1, -1)

static func dialogue(npc: Dictionary, flags: Dictionary) -> String:
	return BASE.dialogue(npc, flags)

static func count() -> int:
	return BASE.count()

static func trainer_ids() -> Array[String]:
	return BASE.trainer_ids()
