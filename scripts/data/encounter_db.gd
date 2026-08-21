extends RefCounted

const VELA = preload("res://scripts/data/alpha1_encounter_db.gd")
const CAMPAIGN = preload("res://scripts/data/campaign_encounter_db.gd")

static func pool(zone_id: String) -> Array[Dictionary]:
	var campaign_pool: Array[Dictionary] = CAMPAIGN.pool(zone_id)
	if not campaign_pool.is_empty():
		return campaign_pool
	return VELA.pool(zone_id)

static func species(zone_id: String) -> Array[String]:
	var result: Array[String] = []
	for entry: Dictionary in pool(zone_id):
		var name: String = str(entry.get("name", ""))
		if not name.is_empty() and not result.has(name):
			result.append(name)
	return result

static func all_species() -> Array[String]:
	var result: Array[String] = VELA.all_species()
	for name: String in CAMPAIGN.all_species():
		if not result.has(name):
			result.append(name)
	result.sort()
	return result

static func roll(zone_id: String, rng: RandomNumberGenerator) -> Dictionary:
	if not CAMPAIGN.pool(zone_id).is_empty():
		return CAMPAIGN.roll(zone_id, rng)
	return VELA.roll(zone_id, rng)
