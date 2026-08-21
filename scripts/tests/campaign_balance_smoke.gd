extends SceneTree

const CAMPAIGN_TRAINERS = preload("res://scripts/data/campaign_trainer_db.gd")
const TRAINERS = preload("res://scripts/data/runtime_trainer_db.gd")
const REWARDS = preload("res://scripts/data/campaign_reward_db.gd")
const PROGRESS = preload("res://scripts/data/campaign_progression_db.gd")
const PROGRESSION = preload("res://scripts/data/progression_db.gd")
const ENCOUNTERS = preload("res://scripts/data/campaign_encounter_db.gd")
const ZONES = preload("res://scripts/data/campaign_zone_db.gd")
const SIDEQUESTS = preload("res://scripts/data/campaign_sidequest_db.gd")
const ITEMS = preload("res://scripts/data/item_db.gd")

var failures: Array[String] = []

func _init() -> void:
	_validate_boss_curve()
	_validate_trainer_progression_band()
	_validate_reward_economy()
	_validate_encounter_bands()
	_validate_sidequest_rewards()
	if failures.is_empty():
		print("CAMPAIGN BALANCE: PASS · boss curve · XP bands · reward economy · encounters")
		quit(0)
		return
	for failure: String in failures:
		push_error("BALANCE: " + failure)
	print("CAMPAIGN BALANCE: FAIL (%d)" % failures.size())
	quit(1)

func _validate_boss_curve() -> void:
	var previous_level: int = 0
	for boss_id: String in PROGRESS.BOSS_ORDER:
		var data: Dictionary = CAMPAIGN_TRAINERS.info(boss_id)
		var level: int = int(data.get("level", 0))
		_check(level > previous_level, "boss levels must strictly increase at %s" % boss_id)
		if previous_level > 0:
			var gap: int = level - previous_level
			_check(gap >= 4 and gap <= 7, "boss gap before %s must stay in 4-7 range, got %d" % [boss_id, gap])
		previous_level = level
	_check(previous_level == 45, "Region 1 finale should remain anchored at level 45")

func _validate_trainer_progression_band() -> void:
	var all_xp: int = 0
	var boss_xp: int = 0
	for spec: Dictionary in CAMPAIGN_TRAINERS.specs():
		var trainer_id: String = str(spec.get("id", ""))
		var reward: int = TRAINERS.reward_xp(trainer_id)
		_check(reward > 0, "trainer %s must award positive XP" % trainer_id)
		all_xp += reward
		if bool(spec.get("boss", false)):
			boss_xp += reward
	var completionist_level: int = _trainer_level_after(all_xp)
	var boss_only_level: int = _trainer_level_after(boss_xp)
	_check(completionist_level >= 32 and completionist_level <= 40, "all trainer content should land trainer level in 32-40 band, got %d" % completionist_level)
	_check(boss_only_level >= 15 and boss_only_level <= 22, "boss-only baseline drifted outside 15-22 band, got %d" % boss_only_level)
	_check(completionist_level < PROGRESSION.TRAINER_LEVEL_CAP, "Region 1 must not exhaust the trainer level cap")

func _validate_reward_economy() -> void:
	var nonboss_count: int = 0
	var regen_trainers: int = 0
	var material_trainers: int = 0
	for spec: Dictionary in CAMPAIGN_TRAINERS.specs():
		var trainer_id: String = str(spec.get("id", ""))
		var reward: Dictionary = TRAINERS.reward_items(trainer_id)
		_check(REWARDS.valid_reward(reward), "trainer %s has invalid reward payload" % trainer_id)
		if bool(spec.get("boss", false)):
			_check(int(reward.get("regenerators", 0)) >= 1, "boss %s must keep a recovery reward" % trainer_id)
			_check(int(reward.get("resonance_cells", 0)) >= 1, "boss %s must keep a Focus reward" % trainer_id)
			continue
		nonboss_count += 1
		if int(reward.get("regenerators", 0)) > 0:
			regen_trainers += 1
		for material_id: String in ITEMS.material_ids():
			if int(reward.get(material_id, 0)) > 0:
				material_trainers += 1
				break
	_check(regen_trainers * 3 <= nonboss_count, "too many normal trainers still guarantee healing: %d/%d" % [regen_trainers, nonboss_count])
	_check(material_trainers > regen_trainers, "trainer economy should favor crafting materials over guaranteed healing")

func _validate_encounter_bands() -> void:
	for zone_id: String in ENCOUNTERS.zone_ids():
		if ENCOUNTERS.is_safe_zone(zone_id):
			_check(ENCOUNTERS.pool(zone_id).is_empty(), "%s is safe but exposes wild encounters" % zone_id)
			continue
		var recommended: int = ZONES.recommended_level(zone_id)
		var entries: Array[Dictionary] = ENCOUNTERS.pool(zone_id)
		var common_weight: int = 0
		var rare_weight: int = 0
		for entry: Dictionary in entries:
			var min_level: int = int(entry.get("min_level", 0))
			var max_level: int = int(entry.get("max_level", 0))
			_check(min_level >= recommended - 3, "%s encounter under-runs level band" % zone_id)
			_check(max_level <= recommended + 3, "%s encounter over-runs level band" % zone_id)
			_check(max_level >= min_level, "%s encounter has inverted level range" % zone_id)
			var weight: int = maxi(1, int(entry.get("weight", 1)))
			if bool(entry.get("rare", false)):
				rare_weight += weight
			else:
				common_weight += weight
		_check(ENCOUNTERS.rare_species(zone_id).size() == ENCOUNTERS.RARE_PER_FIELD_ZONE, "%s must retain two rare species" % zone_id)
		_check(rare_weight > 0 and rare_weight * 20 < common_weight, "%s rare encounters are not rare enough" % zone_id)

func _validate_sidequest_rewards() -> void:
	var known: Array[String] = ITEMS.all_ids()
	for quest_id: String in SIDEQUESTS.ids():
		var reward: Dictionary = SIDEQUESTS.reward(quest_id)
		_check(not reward.is_empty(), "sidequest %s has no reward" % quest_id)
		for raw_item: Variant in reward.keys():
			var item_id: String = str(raw_item)
			_check(known.has(item_id), "sidequest %s rewards unknown item %s" % [quest_id, item_id])
			_check(int(reward[raw_item]) > 0, "sidequest %s rewards non-positive amount" % quest_id)

func _trainer_level_after(total_xp: int) -> int:
	var level: int = 1
	var xp: int = maxi(0, total_xp)
	while level < PROGRESSION.TRAINER_LEVEL_CAP:
		var threshold: int = PROGRESSION.xp_to_next_level(level)
		if xp < threshold:
			break
		xp -= threshold
		level += 1
	return level

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
