extends RefCounted

const ITEMS = preload("res://scripts/data/item_db.gd")
const MODES = preload("res://scripts/data/battle_mode_db.gd")

static func items(trainer_id: String, spec: Dictionary) -> Dictionary:
	if spec.is_empty():
		return {}
	if bool(spec.get("boss", false)):
		return {"resonance_cells":2,"regenerators":2,"capture_modules":2}
	if str(spec.get("mode", MODES.MODE_STANDARD)) == MODES.MODE_TRAINER_DUEL:
		return {"resonance_cells":1}
	var seed: int = int(spec.get("seed", trainer_id.hash()))
	var level: int = maxi(1, int(spec.get("level", 1)))
	var bucket: int = posmod(seed, 5)
	match bucket:
		0:
			return {"regenerators":1}
		1:
			return {"resonance_dust":2 if level < 30 else 3}
		2:
			return {"alloy_scrap":2 if level < 24 else 3}
		3:
			return {"copper_coil":2 if level < 30 else 3}
		_:
			return {"glass_fiber":2 if level < 30 else 3}

static func valid_reward(reward: Dictionary) -> bool:
	if reward.is_empty():
		return false
	var known: Array[String] = ITEMS.all_ids()
	for raw_id: Variant in reward.keys():
		var item_id: String = str(raw_id)
		if not known.has(item_id) or int(reward[raw_id]) <= 0:
			return false
	return true
