extends RefCounted

const MONSTERS = preload("res://scripts/data/monster_db.gd")
const EVOLUTION = preload("res://scripts/data/evolution_db.gd")
const ZONES = preload("res://scripts/data/campaign_zone_db.gd")
const PACK = preload("res://scripts/data/region_zone_pack.gd")

const BASE_POOL_SIZE: int = 10
const POST_GAME_POOL_SIZE: int = 18

static func zone_ids() -> Array[String]:
	return PACK.ids()

static func is_safe_zone(zone_id: String) -> bool:
	if not PACK.has_zone(zone_id):
		return false
	var style: String = str(ZONES.zone_info(zone_id).get("style", ""))
	return style == "town" or style.ends_with("_town")

static func pool(zone_id: String) -> Array[Dictionary]:
	if not PACK.has_zone(zone_id) or is_safe_zone(zone_id):
		return []
	var level: int = ZONES.recommended_level(zone_id)
	var stage_cap: int = 1
	if level >= 12:
		stage_cap = 2
	if level >= 24:
		stage_cap = 3
	var candidates: Array[String] = []
	for name: String in MONSTERS.all_names():
		if EVOLUTION.stage(name) <= stage_cap:
			candidates.append(name)
	candidates.sort()
	if candidates.is_empty():
		return []
	var zone_index: int = maxi(0, zone_ids().find(zone_id))
	var desired: int = POST_GAME_POOL_SIZE if ZONES.is_post_game(zone_id) else BASE_POOL_SIZE
	var selected: Array[String] = []
	var stride: int = 7
	var cursor: int = posmod(zone_index * 13, candidates.size())
	while selected.size() < mini(desired, candidates.size()):
		var name: String = candidates[cursor]
		if not selected.has(name):
			selected.append(name)
		cursor = posmod(cursor + stride, candidates.size())
		if cursor == posmod(zone_index * 13, candidates.size()) and selected.size() < mini(desired, candidates.size()):
			cursor = posmod(cursor + 1, candidates.size())
	var result: Array[Dictionary] = []
	for index: int in range(selected.size()):
		var name: String = selected[index]
		var weight: int = 18
		if index < 3:
			weight = 24
		elif index >= selected.size() - 2:
			weight = 10
		var spread: int = 2 if level < 30 else 3
		result.append({
			"name":name,
			"weight":weight,
			"min_level":maxi(2, level - spread),
			"max_level":level + 2
		})
	return result

static func species(zone_id: String) -> Array[String]:
	var result: Array[String] = []
	for entry: Dictionary in pool(zone_id):
		var name: String = str(entry.get("name", ""))
		if not name.is_empty():
			result.append(name)
	return result

static func all_species() -> Array[String]:
	var result: Array[String] = []
	for zone_id: String in zone_ids():
		for name: String in species(zone_id):
			if not result.has(name):
				result.append(name)
	# The three post-game ecosystems deliberately expose the complete 150-form runtime catalog.
	for name: String in MONSTERS.all_names():
		if not result.has(name):
			result.append(name)
	result.sort()
	return result

static func post_game_completion_pool() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for name: String in MONSTERS.all_names():
		result.append({"name":name,"weight":1,"min_level":46,"max_level":50})
	return result

static func roll(zone_id: String, rng: RandomNumberGenerator) -> Dictionary:
	var entries: Array[Dictionary] = pool(zone_id)
	if ZONES.is_post_game(zone_id):
		entries = post_game_completion_pool()
	if entries.is_empty():
		return {}
	var total: int = 0
	for entry: Dictionary in entries:
		total += maxi(1, int(entry.get("weight", 1)))
	var roll_value: int = rng.randi_range(1, maxi(1, total))
	var cursor: int = 0
	for entry: Dictionary in entries:
		cursor += maxi(1, int(entry.get("weight", 1)))
		if roll_value <= cursor:
			var min_level: int = maxi(1, int(entry.get("min_level", 2)))
			var max_level: int = maxi(min_level, int(entry.get("max_level", min_level)))
			return {"name":str(entry.get("name", "Wahlik")),"level":rng.randi_range(min_level, max_level)}
	return {}
