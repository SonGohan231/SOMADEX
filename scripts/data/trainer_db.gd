extends RefCounted

const VELA = preload("res://scripts/data/alpha1_trainer_db.gd")
const CAMPAIGN = preload("res://scripts/data/campaign_trainer_db.gd")
const CAMPAIGN_REWARDS = preload("res://scripts/data/campaign_reward_db.gd")

static func ids() -> Array[String]:
	var result: Array[String] = []
	for trainer_id: String in VELA.ids():
		result.append(trainer_id)
	for trainer_id: String in CAMPAIGN.ids():
		if not result.has(trainer_id):
			result.append(trainer_id)
	return result

static func has(trainer_id: String) -> bool:
	return VELA.has(trainer_id) or CAMPAIGN.has(trainer_id)

static func info(trainer_id: String) -> Dictionary:
	if VELA.has(trainer_id):
		return VELA.info(trainer_id)
	return CAMPAIGN.info(trainer_id)

static func party(trainer_id: String) -> Array:
	if VELA.has(trainer_id):
		return VELA.party(trainer_id)
	return CAMPAIGN.party(trainer_id)

static func can_challenge(trainer_id: String, flags: Dictionary) -> bool:
	if VELA.has(trainer_id):
		return VELA.can_challenge(trainer_id, flags)
	return CAMPAIGN.can_challenge(trainer_id, flags)

static func defeated_flag(trainer_id: String) -> String:
	if VELA.has(trainer_id):
		return VELA.defeated_flag(trainer_id)
	return CAMPAIGN.defeated_flag(trainer_id)

static func is_defeated(trainer_id: String, flags: Dictionary) -> bool:
	if VELA.has(trainer_id):
		return VELA.is_defeated(trainer_id, flags)
	return CAMPAIGN.is_defeated(trainer_id, flags)

static func reward_xp(trainer_id: String) -> int:
	if VELA.has(trainer_id):
		return VELA.reward_xp(trainer_id)
	return CAMPAIGN.reward_xp(trainer_id)

static func reward_items(trainer_id: String) -> Dictionary:
	if VELA.has(trainer_id):
		return VELA.reward_items(trainer_id)
	if CAMPAIGN.has(trainer_id):
		return CAMPAIGN_REWARDS.items(trainer_id, CAMPAIGN.info(trainer_id))
	return {}

static func locked_text(trainer_id: String) -> String:
	if VELA.has(trainer_id):
		return VELA.locked_text(trainer_id)
	return CAMPAIGN.locked_text(trainer_id)

static func battle_mode(trainer_id: String) -> String:
	if CAMPAIGN.has(trainer_id):
		return CAMPAIGN.battle_mode(trainer_id)
	var data: Dictionary = VELA.info(trainer_id)
	return str(data.get("battle_mode", "resonance"))

static func boss_ids() -> Array[String]:
	return CAMPAIGN.boss_ids()

static func trainer_count() -> int:
	return ids().size()
