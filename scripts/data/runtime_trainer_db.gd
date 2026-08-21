extends RefCounted

const BASE = preload("res://scripts/data/trainer_db.gd")

static func ids() -> Array[String]:
	return BASE.ids()

static func has(trainer_id: String) -> bool:
	return BASE.has(trainer_id)

static func info(trainer_id: String) -> Dictionary:
	return BASE.info(trainer_id)

static func party(trainer_id: String) -> Array:
	return BASE.party(trainer_id)

static func can_challenge(trainer_id: String, flags: Dictionary) -> bool:
	if trainer_id == "vela_trial" and not bool(flags.get("trainer_rhea_defeated", false)):
		return false
	return BASE.can_challenge(trainer_id, flags)

static func defeated_flag(trainer_id: String) -> String:
	return BASE.defeated_flag(trainer_id)

static func is_defeated(trainer_id: String, flags: Dictionary) -> bool:
	return BASE.is_defeated(trainer_id, flags)

static func reward_xp(trainer_id: String) -> int:
	return BASE.reward_xp(trainer_id)

static func reward_items(trainer_id: String) -> Dictionary:
	return BASE.reward_items(trainer_id)

static func locked_text(trainer_id: String) -> String:
	if trainer_id == "vela_trial" and not bool_placeholder():
		return "Strażnik Eron: Najpierw ukończ próbę Rhei. Dopiero wtedy otworzę drogę do Orin."
	return BASE.locked_text(trainer_id)

static func battle_mode(trainer_id: String) -> String:
	return BASE.battle_mode(trainer_id)

static func boss_ids() -> Array[String]:
	return BASE.boss_ids()

static func trainer_count() -> int:
	return BASE.trainer_count()

static func bool_placeholder() -> bool:
	# Helper keeps locked_text signature compatible with existing trainer DB API.
	return false
