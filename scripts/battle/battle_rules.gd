extends RefCounted

const STATUS = preload("res://scripts/data/status_db.gd")
const TYPE_BALANCE = preload("res://scripts/data/type_balance_db.gd")

static func calculate_damage(power: int, attack: int, defense: int, level: int, flat_bonus: int, move_type: String, target_statuses: Dictionary, attacker_statuses: Dictionary, guard_multiplier: float = 1.0) -> int:
	var base: float = float(maxi(1, power))
	base += float(maxi(0, attack)) * 0.55
	base += float(maxi(1, level)) * 0.35
	base += float(flat_bonus)
	base -= float(maxi(0, defense)) * 0.28
	base = maxf(1.0, base)
	base *= STATUS.damage_multiplier(move_type, target_statuses)
	var target_type: String = str(target_statuses.get("__type", ""))
	if not target_type.is_empty():
		base *= TYPE_BALANCE.multiplier(move_type, [target_type])
	base *= STATUS.outgoing_multiplier(attacker_statuses)
	base *= clampf(guard_multiplier, 0.15, 1.0)
	return maxi(1, int(round(base)))

static func type_label(move_type: String, target_statuses: Dictionary) -> String:
	var target_type: String = str(target_statuses.get("__type", ""))
	if target_type.is_empty():
		return ""
	return TYPE_BALANCE.label(move_type, [target_type])

static func type_multiplier(move_type: String, target_statuses: Dictionary) -> float:
	var target_type: String = str(target_statuses.get("__type", ""))
	if target_type.is_empty():
		return 1.0
	return TYPE_BALANCE.multiplier(move_type, [target_type])

static func capture_chance(base_rate: float, current_hp: int, max_hp: int, talent_bonus: float, equipment_bonus: float, target_statuses: Dictionary) -> float:
	var safe_max: int = maxi(1, max_hp)
	var hp_ratio: float = clampf(float(maxi(0, current_hp)) / float(safe_max), 0.0, 1.0)
	var missing: float = 1.0 - hp_ratio
	var chance: float = base_rate + missing * 0.50 + talent_bonus + equipment_bonus + STATUS.capture_modifier(target_statuses)
	return clampf(chance, 0.05, 0.95)

static func escape_chance(base_rate: float, talent_bonus: float, equipment_bonus: float, player_statuses: Dictionary) -> float:
	var chance: float = base_rate + talent_bonus + equipment_bonus + STATUS.escape_modifier(player_statuses)
	return clampf(chance, 0.10, 0.95)

static func status_roll(chance: float, rng: RandomNumberGenerator) -> bool:
	return rng.randf() <= clampf(chance, 0.0, 1.0)

static func creature_xp_to_next(level: int) -> int:
	return 12 + maxi(1, level) * 6

static func level_hp_growth(old_level: int, new_level: int) -> int:
	return maxi(0, new_level - old_level)
