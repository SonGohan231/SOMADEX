extends RefCounted

const MIN_BASE_RATE: float = 0.08
const MAX_BASE_RATE: float = 0.55

const _RARITY_MULTIPLIER: Dictionary = {
	"starter": 1.00,
	"pospolity": 1.00,
	"common": 1.00,
	"niepospolity": 0.88,
	"uncommon": 0.88,
	"rzadki": 0.72,
	"rare": 0.72,
	"bardzo rzadki": 0.58,
	"very_rare": 0.58,
	"epicki": 0.48,
	"epic": 0.48,
	"legendarny": 0.36,
	"legendary": 0.36
}

static func rarity_multiplier(rarity: String) -> float:
	return float(_RARITY_MULTIPLIER.get(rarity.strip_edges().to_lower(), 0.80))

static func adjusted_base_rate(monster: Dictionary) -> float:
	var base_rate: float = clampf(float(monster.get("capture_rate", 0.30)), 0.01, 0.95)
	var rarity: String = str(monster.get("rarity", "niepospolity"))
	return clampf(base_rate * rarity_multiplier(rarity), MIN_BASE_RATE, MAX_BASE_RATE)

static func apply(monster: Dictionary) -> Dictionary:
	var result: Dictionary = monster.duplicate(true)
	result["capture_rate"] = adjusted_base_rate(result)
	result["capture_profile"] = tier_label(str(result.get("rarity", "")))
	return result

static func tier_label(rarity: String) -> String:
	var mult: float = rarity_multiplier(rarity)
	if mult >= 0.95:
		return "STABILNY"
	if mult >= 0.80:
		return "CZUJNY"
	if mult >= 0.65:
		return "TRUDNY"
	if mult >= 0.50:
		return "BARDZO TRUDNY"
	return "EKSTREMALNY"

static func known_rarities() -> Array[String]:
	var result: Array[String] = []
	for key: Variant in _RARITY_MULTIPLIER.keys():
		result.append(str(key))
	result.sort()
	return result
