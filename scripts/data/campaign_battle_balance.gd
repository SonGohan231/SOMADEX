extends RefCounted

const BASE_FOCUS: int = 3
const SPECIAL_FOCUS_COST: int = 2
const TRAINER_COMMAND_FOCUS_COST: int = 1
const FOCUS_ON_ENEMY_KO: int = 1
const TARGET_MIN_HITS: int = 2
const TARGET_MAX_HITS: int = 7

static func scaled_max_hp(base_hp: int, level: int) -> int:
	return maxi(1, maxi(1, base_hp) + int((maxi(1, level) - 1) / 2))

static func hits_to_ko(max_hp: int, damage: int) -> int:
	return int(ceil(float(maxi(1, max_hp)) / float(maxi(1, damage))))

static func focus_supports_special_plus_command() -> bool:
	return BASE_FOCUS >= SPECIAL_FOCUS_COST + TRAINER_COMMAND_FOCUS_COST

static func trainer_duel_focus_budget(team_size: int, gear_bonus: int = 0) -> int:
	return BASE_FOCUS + maxi(0, gear_bonus) + maxi(0, team_size - 1) * FOCUS_ON_ENEMY_KO
