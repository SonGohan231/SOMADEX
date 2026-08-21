extends RefCounted

const BASE = preload("res://scripts/data/trainer_db.gd")
const ELITES = preload("res://scripts/data/postgame_elite_db.gd")

static func ids() -> Array[String]:
	var result: Array[String] = BASE.ids()
	for trainer_id: String in ELITES.ids():
		if not result.has(trainer_id):
			result.append(trainer_id)
	return result

static func has(trainer_id: String) -> bool:
	return BASE.has(trainer_id) or ELITES.has(trainer_id)

static func info(trainer_id: String) -> Dictionary:
	if ELITES.has(trainer_id):
		return ELITES.info(trainer_id)
	return BASE.info(trainer_id)

static func party(trainer_id: String) -> Array:
	if ELITES.has(trainer_id):
		return ELITES.party(trainer_id)
	return BASE.party(trainer_id)

static func can_challenge(trainer_id: String, flags: Dictionary) -> bool:
	if ELITES.has(trainer_id):
		return ELITES.can_challenge(trainer_id, flags)
	if trainer_id == "vela_trial" and not bool(flags.get("trainer_rhea_defeated", false)):
		return false
	return BASE.can_challenge(trainer_id, flags)

static func defeated_flag(trainer_id: String) -> String:
	if ELITES.has(trainer_id):
		return ELITES.defeated_flag(trainer_id)
	return BASE.defeated_flag(trainer_id)

static func is_defeated(trainer_id: String, flags: Dictionary) -> bool:
	if ELITES.has(trainer_id):
		return ELITES.is_defeated(trainer_id, flags)
	return BASE.is_defeated(trainer_id, flags)

static func reward_xp(trainer_id: String) -> int:
	if ELITES.has(trainer_id):
		return ELITES.reward_xp(trainer_id)
	return BASE.reward_xp(trainer_id)

static func reward_items(trainer_id: String) -> Dictionary:
	if ELITES.has(trainer_id):
		return ELITES.reward_items(trainer_id)
	return BASE.reward_items(trainer_id)

static func locked_text(trainer_id: String) -> String:
	if ELITES.has(trainer_id):
		return ELITES.locked_text(trainer_id)
	if trainer_id == "vela_trial" and not bool_placeholder():
		return "Strażnik Eron: Najpierw ukończ próbę Rhei. Dopiero wtedy otworzę drogę do Orin."
	return BASE.locked_text(trainer_id)

static func battle_mode(trainer_id: String) -> String:
	if ELITES.has(trainer_id):
		return ELITES.battle_mode(trainer_id)
	return BASE.battle_mode(trainer_id)

static func boss_ids() -> Array[String]:
	return BASE.boss_ids()

static func rematch_ids() -> Array[String]:
	return ELITES.ids()

static func boss_profile_id(trainer_id: String) -> String:
	if ELITES.has(trainer_id):
		return ELITES.boss_profile_id(trainer_id)
	return trainer_id

static func trainer_count() -> int:
	return ids().size()

static func bool_placeholder() -> bool:
	# Helper keeps locked_text signature compatible with existing trainer DB API.
	return false
