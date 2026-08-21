extends RefCounted

const VELA = preload("res://scripts/data/alpha1_pickup_db.gd")
const CAMPAIGN = preload("res://scripts/data/campaign_pickup_db.gd")

static func ids() -> Array[String]:
	var result: Array[String] = VELA.ids()
	for pickup_id: String in CAMPAIGN.ids():
		if not result.has(pickup_id):
			result.append(pickup_id)
	return result

static func in_zone(zone_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for pickup: Dictionary in VELA.in_zone(zone_id):
		result.append(pickup)
	for pickup: Dictionary in CAMPAIGN.in_zone(zone_id):
		result.append(pickup)
	return result

static func at(zone_id: String, tile: Vector2i) -> Dictionary:
	var campaign_pickup: Dictionary = CAMPAIGN.at(zone_id, tile)
	if not campaign_pickup.is_empty():
		return campaign_pickup
	return VELA.at(zone_id, tile)

static func by_id(pickup_id: String) -> Dictionary:
	var campaign_pickup: Dictionary = CAMPAIGN.by_id(pickup_id)
	if not campaign_pickup.is_empty():
		return campaign_pickup
	return VELA.by_id(pickup_id)

static func flag_id(pickup_id: String) -> String:
	if not CAMPAIGN.by_id(pickup_id).is_empty():
		return CAMPAIGN.flag_id(pickup_id)
	return VELA.flag_id(pickup_id)

static func is_collected(pickup_id: String, flags: Dictionary) -> bool:
	return bool(flags.get(flag_id(pickup_id), false))
