extends RefCounted

const MONSTERS = preload("res://scripts/data/monster_db.gd")
const EVOLUTION = preload("res://scripts/data/evolution_db.gd")

const ZONE_LEVELS: Dictionary = {
	"orin_watchtower":10,
	"reed_islet":12,
	"ferrum_scrapyard":17,
	"nivra_observatory":23,
	"lumen_vault":28,
	"aster_grove":32,
	"echo_sanctum":52,
	"resonance_annex":52,
	"outer_trench":52
}

const ZONE_SEEDS: Dictionary = {
	"orin_watchtower":7, "reed_islet":19, "ferrum_scrapyard":31,
	"nivra_observatory":47, "lumen_vault":61, "aster_grove":79,
	"echo_sanctum":101, "resonance_annex":127, "outer_trench":149
}

static func zone_ids() -> Array[String]:
	var result: Array[String] = []
	for raw_id: Variant in ZONE_LEVELS.keys():
		result.append(str(raw_id))
	result.sort()
	return result

static func pool(zone_id: String) -> Array[Dictionary]:
	if not ZONE_LEVELS.has(zone_id):
		return []
	var level: int = int(ZONE_LEVELS[zone_id])
	var seed: int = int(ZONE_SEEDS.get(zone_id, 1))
	var candidates: Array[String] = _candidates(level)
	if candidates.is_empty():
		candidates = MONSTERS.all_names()
	var count: int = 8 if level >= 48 else 6
	var result: Array[Dictionary] = []
	var used: Dictionary = {}
	var cursor: int = 0
	while result.size() < mini(count, candidates.size()) and cursor < candidates.size() * 3:
		var index: int = posmod(seed + cursor * 11, candidates.size())
		var creature_name: String = candidates[index]
		cursor += 1
		if used.has(creature_name):
			continue
		used[creature_name] = true
		var rarity_slot: int = result.size()
		var weight: int = 22 - rarity_slot * 3
		if rarity_slot >= count - 2:
			weight = 3 if rarity_slot == count - 2 else 1
		result.append({
			"name":creature_name,
			"level":maxi(2, level - 1 + int(rarity_slot / 3)),
			"weight":maxi(1, weight),
			"rare":rarity_slot >= count - 2
		})
	return result

static func roll(zone_id: String, rng: RandomNumberGenerator) -> Dictionary:
	var entries: Array[Dictionary] = pool(zone_id)
	if entries.is_empty():
		return {}
	var total: int = 0
	for entry: Dictionary in entries:
		total += maxi(1, int(entry.get("weight", 1)))
	var ticket: int = rng.randi_range(1, total)
	for entry: Dictionary in entries:
		ticket -= maxi(1, int(entry.get("weight", 1)))
		if ticket <= 0:
			return entry.duplicate(true)
	return entries.back().duplicate(true)

static func rare_species(zone_id: String) -> Array[String]:
	var result: Array[String] = []
	for entry: Dictionary in pool(zone_id):
		if bool(entry.get("rare", false)):
			result.append(str(entry.get("name", "")))
	return result

static func _candidates(level: int) -> Array[String]:
	var max_stage: int = 1
	if level >= 12: max_stage = 2
	if level >= 24: max_stage = 3
	var result: Array[String] = []
	for creature_name: String in MONSTERS.all_names():
		if maxi(1, EVOLUTION.stage(creature_name)) <= max_stage:
			result.append(creature_name)
	return result
