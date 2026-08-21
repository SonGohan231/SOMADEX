extends RefCounted

const VELA = preload("res://scripts/data/alpha1_npc_db.gd")
const CAMPAIGN = preload("res://scripts/data/campaign_npc_db.gd")

static func in_zone(zone_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for npc: Dictionary in CAMPAIGN.in_zone(zone_id):
		result.append(npc)
	for npc: Dictionary in VELA.in_zone(zone_id):
		var duplicate_tile: bool = false
		for existing: Dictionary in result:
			if tile_of(existing) == VELA.tile_of(npc):
				duplicate_tile = true
				break
		if not duplicate_tile:
			result.append(npc)
	return result

static func at(zone_id: String, tile: Vector2i) -> Dictionary:
	var campaign_npc: Dictionary = CAMPAIGN.at(zone_id, tile)
	if not campaign_npc.is_empty():
		return campaign_npc
	return VELA.at(zone_id, tile)

static func tile_of(npc: Dictionary) -> Vector2i:
	var raw_tile: Array = npc.get("tile", []) as Array
	if raw_tile.size() >= 2:
		return Vector2i(int(raw_tile[0]), int(raw_tile[1]))
	return Vector2i(-1, -1)

static func dialogue(npc: Dictionary, flags: Dictionary) -> String:
	if bool(npc.get("campaign", false)):
		return CAMPAIGN.dialogue(npc, flags)
	return VELA.dialogue(npc, flags)

static func count() -> int:
	return VELA.count() + CAMPAIGN.count()

static func trainer_ids() -> Array[String]:
	var result: Array[String] = VELA.trainer_ids()
	for trainer_id: String in CAMPAIGN.trainer_ids():
		if not result.has(trainer_id):
			result.append(trainer_id)
	return result
