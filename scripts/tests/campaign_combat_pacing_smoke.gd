extends SceneTree

const TRAINERS = preload("res://scripts/data/campaign_trainer_db.gd")
const MONSTERS = preload("res://scripts/data/monster_db.gd")
const LEARNSETS = preload("res://scripts/data/learnset_db.gd")
const MOVES = preload("res://scripts/data/move_db.gd")
const RULES = preload("res://scripts/battle/battle_rules.gd")
const BALANCE = preload("res://scripts/data/campaign_battle_balance.gd")

var failures: Array[String] = []

func _init() -> void:
	_validate_focus_budget()
	_validate_trainer_party_pacing()
	if failures.is_empty():
		print("CAMPAIGN COMBAT PACING: PASS · normalized HP · 2-7 hit mirror band · multi-opponent Focus")
		quit(0)
		return
	for failure: String in failures:
		push_error("COMBAT PACING: " + failure)
	print("CAMPAIGN COMBAT PACING: FAIL (%d)" % failures.size())
	quit(1)

func _validate_focus_budget() -> void:
	_check(BALANCE.focus_supports_special_plus_command(), "baseline Focus must support one special + one trainer command")
	_check(BALANCE.BASE_FOCUS == 3, "baseline Focus contract drifted from 3")
	_check(BALANCE.SPECIAL_FOCUS_COST == 2, "special move baseline cost must remain 2")
	_check(BALANCE.TRAINER_COMMAND_FOCUS_COST == 1, "trainer command baseline cost must remain 1")
	for spec: Dictionary in TRAINERS.specs():
		var trainer_id: String = str(spec.get("id", "trainer"))
		var team_size: int = TRAINERS.party(trainer_id).size()
		var budget: int = BALANCE.trainer_duel_focus_budget(team_size)
		_check(budget >= BALANCE.BASE_FOCUS, "%s loses Focus budget in a duel" % trainer_id)
		if bool(spec.get("boss", false)):
			_check(budget >= 5, "boss %s must expose enough Focus across its multi-creature fight" % trainer_id)

func _validate_trainer_party_pacing() -> void:
	var total_hits: int = 0
	var samples: int = 0
	var min_hits: int = 999
	var max_hits: int = 0
	for spec: Dictionary in TRAINERS.specs():
		var trainer_id: String = str(spec.get("id", "trainer"))
		for raw_member: Variant in TRAINERS.party(trainer_id):
			var member: Dictionary = raw_member as Dictionary
			var name: String = str(member.get("name", ""))
			var level: int = maxi(1, int(member.get("level", 1)))
			var data: Dictionary = MONSTERS.get_monster(name)
			var hp: int = BALANCE.scaled_max_hp(int(data.get("max_hp", 20)), level)
			var best_damage: int = _best_mirror_damage(name, level, data)
			_check(best_damage > 0, "%s Lv.%d has no usable attack in its available learnset" % [name, level])
			if best_damage <= 0:
				continue
			var hits: int = BALANCE.hits_to_ko(hp, best_damage)
			min_hits = mini(min_hits, hits)
			max_hits = maxi(max_hits, hits)
			total_hits += hits
			samples += 1
			_check(hits >= BALANCE.TARGET_MIN_HITS, "%s Lv.%d can mirror one-shot at %d hit" % [name, level, hits])
			_check(hits <= BALANCE.TARGET_MAX_HITS, "%s Lv.%d mirror pacing is too spongy at %d hits" % [name, level, hits])
	_check(samples >= 100, "combat pacing needs at least 100 trainer-party samples")
	if samples > 0:
		var average: float = float(total_hits) / float(samples)
		_check(average >= 2.0 and average <= 5.0, "average mirror pacing must stay between 2.0 and 5.0 hits, got %.2f" % average)
		print("COMBAT PACING METRICS: samples=%d avg=%.2f min=%d max=%d" % [samples, average, min_hits, max_hits])

func _best_mirror_damage(name: String, level: int, data: Dictionary) -> int:
	var best: int = 0
	var attack: int = maxi(0, int(data.get("attack", 1)))
	var defense: int = maxi(0, int(data.get("defense", 1)))
	for move_id: String in LEARNSETS.available_move_ids(name, level, data):
		var move: Dictionary = MOVES.info(move_id)
		if str(move.get("kind", "")) != "attack":
			continue
		var damage: int = RULES.calculate_damage(
			int(move.get("power", 1)),
			attack,
			defense,
			level,
			0,
			str(move.get("move_type", "PHYSICAL")),
			{},
			{}
		)
		best = maxi(best, damage)
	return best

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
