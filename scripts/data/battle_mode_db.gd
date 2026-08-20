extends RefCounted

const MODE_STANDARD: String = "standard"
const MODE_RESONANCE: String = "resonance"
const MODE_TRAINER_DUEL: String = "trainer_duel"

static var _MODES: Dictionary = {
	MODE_STANDARD: {
		"name": "STANDARDOWA WALKA",
		"description": "Stworki walczą, trener ma ograniczoną pulę komend.",
		"trainer_focus_base": 2,
		"stability_enabled": false,
		"trainer_stability": 0,
		"enemy_trainer_stability": 0,
		"capture_allowed": true,
		"escape_allowed": true,
		"trainer_actions": true,
		"trainer_action_focus_scale": 1.0
	},
	MODE_RESONANCE: {
		"name": "WALKA REZONANSOWA",
		"description": "Pełne użycie talentów, sprzętu, Focus i stabilności trenerów.",
		"trainer_focus_base": 4,
		"stability_enabled": true,
		"trainer_stability": 100,
		"enemy_trainer_stability": 100,
		"capture_allowed": false,
		"escape_allowed": false,
		"trainer_actions": true,
		"trainer_action_focus_scale": 1.0
	},
	MODE_TRAINER_DUEL: {
		"name": "POJEDYNEK TRENERÓW",
		"description": "Sprzęt i gadżety trenerów są główną osią starcia; stworki zapewniają ograniczone wsparcie.",
		"trainer_focus_base": 5,
		"stability_enabled": true,
		"trainer_stability": 120,
		"enemy_trainer_stability": 120,
		"capture_allowed": false,
		"escape_allowed": false,
		"trainer_actions": true,
		"trainer_action_focus_scale": 0.8
	}
}

static func ids() -> Array[String]:
	return [MODE_STANDARD, MODE_RESONANCE, MODE_TRAINER_DUEL]

static func has(mode_id: String) -> bool:
	return _MODES.has(mode_id)

static func info(mode_id: String) -> Dictionary:
	if not _MODES.has(mode_id):
		mode_id = MODE_STANDARD
	return (_MODES[mode_id] as Dictionary).duplicate(true)

static func name(mode_id: String) -> String:
	return str(info(mode_id).get("name", mode_id.to_upper()))

static func uses_stability(mode_id: String) -> bool:
	return bool(info(mode_id).get("stability_enabled", false))

static func focus_base(mode_id: String) -> int:
	return maxi(0, int(info(mode_id).get("trainer_focus_base", 2)))

static func stability_base(mode_id: String, enemy: bool = false) -> int:
	var key: String = "enemy_trainer_stability" if enemy else "trainer_stability"
	return maxi(0, int(info(mode_id).get(key, 0)))

static func capture_allowed(mode_id: String) -> bool:
	return bool(info(mode_id).get("capture_allowed", true))

static func escape_allowed(mode_id: String) -> bool:
	return bool(info(mode_id).get("escape_allowed", true))
