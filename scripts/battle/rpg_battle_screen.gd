extends "res://scripts/battle/animated_battle_screen.gd"

const MODES = preload("res://scripts/data/battle_mode_db.gd")
const PASSIVES = preload("res://scripts/data/passive_db.gd")
const MOVES = preload("res://scripts/data/move_db.gd")
const RPG_STATUS = preload("res://scripts/data/status_db.gd")

var battle_mode_id: String = MODES.MODE_STANDARD
var player_stability: int = 0
var player_stability_max: int = 0
var enemy_trainer_stability: int = 0
var enemy_trainer_stability_max: int = 0
var player_passive_id: String = ""
var enemy_passive_id: String = ""

func setup(
	party_data: Array,
	start_active_index: int,
	level: int,
	enemy_name: String = "Wahlik",
	encounter_level: int = 3,
	battle_inventory: Dictionary = {},
	talent_levels: Dictionary = {},
	loadout: Dictionary = {}
) -> void:
	super.setup(party_data, start_active_index, level, enemy_name, encounter_level, battle_inventory, talent_levels, loadout)
	_refresh_rpg_identity()
	set_battle_mode(MODES.MODE_STANDARD)

func _ready() -> void:
	super._ready()
	_refresh_rpg_identity()
	set_battle_mode(battle_mode_id)

func set_battle_mode(mode_id: String) -> void:
	battle_mode_id = mode_id if MODES.has(mode_id) else MODES.MODE_STANDARD
	var mode_data: Dictionary = MODES.info(battle_mode_id)
	var passive_focus: int = PASSIVES.focus_bonus(player_passive_id)
	trainer_focus_max = maxi(0, MODES.focus_base(battle_mode_id) + int(gear_bonuses.get("trainer_focus_bonus", 0)) + passive_focus)
	trainer_focus = trainer_focus_max
	player_stability_max = MODES.stability_base(battle_mode_id, false)
	player_stability = player_stability_max
	enemy_trainer_stability_max = MODES.stability_base(battle_mode_id, true)
	enemy_trainer_stability = enemy_trainer_stability_max
	if is_inside_tree():
		queue_redraw()

func _refresh_rpg_identity() -> void:
	player_data = _normalize_creature_moves(player_data)
	enemy_data = _normalize_creature_moves(enemy_data)
	player_passive_id = PASSIVES.default_for_creature(player_data)
	enemy_passive_id = PASSIVES.default_for_creature(enemy_data)

func _normalize_creature_moves(data: Dictionary) -> Dictionary:
	if data.is_empty():
		return data
	var result: Dictionary = data.duplicate(true)
	var normalized: Array = []
	for raw_move: Variant in result.get("moves", []) as Array:
		if typeof(raw_move) != TYPE_DICTIONARY:
			continue
		normalized.append(MOVES.normalize(raw_move as Dictionary))
	result["moves"] = normalized
	if not result.has("passive_id"):
		result["passive_id"] = PASSIVES.default_for_creature(result)
	return result

func _load_active_member() -> void:
	super._load_active_member()
	player_data = _normalize_creature_moves(player_data)
	player_passive_id = PASSIVES.default_for_creature(player_data)

func _draw_background() -> void:
	super._draw_background()
	var mode_name: String = MODES.name(battle_mode_id)
	draw_string(font, Vector2(205, 27), mode_name, HORIZONTAL_ALIGNMENT_RIGHT, 137, 7, Color("d5c76b"))
	if MODES.uses_stability(battle_mode_id):
		draw_string(font, Vector2(18, 58), "STABILNOŚĆ %d/%d" % [player_stability, player_stability_max], HORIZONTAL_ALIGNMENT_LEFT, 152, 7, Color("7fe0d7"))
		draw_string(font, Vector2(190, 132), "PRZECIWNIK %d/%d" % [enemy_trainer_stability, enemy_trainer_stability_max], HORIZONTAL_ALIGNMENT_RIGHT, 152, 7, Color("e0b77f"))

func _execute_pending_move(lines: Array[String]) -> void:
	player_data = _normalize_creature_moves(player_data)
	var moves: Array = player_data.get("moves", []) as Array
	var move_data: Dictionary = {}
	if pending_move_index >= 0 and pending_move_index < moves.size():
		move_data = moves[pending_move_index] as Dictionary
	var before_enemy_hp: int = enemy_hp
	var old_bonus: int = pending_damage_bonus
	if not move_data.is_empty() and str(move_data.get("kind", "attack")) == "attack":
		var hp_ratio: float = float(player_hp) / float(maxi(1, player_max_hp))
		var passive_bonus: int = PASSIVES.attack_flat_bonus(player_passive_id, move_data, player_statuses, enemy_statuses, hp_ratio)
		pending_damage_bonus += passive_bonus
		if passive_bonus > 0:
			lines.append("%s: %s wzmacnia ruch (+%d)." % [_active_name(), str(PASSIVES.info(player_passive_id).get("name", "PASYWKA")), passive_bonus])
	super._execute_pending_move(lines)
	pending_damage_bonus = old_bonus
	if move_data.is_empty() or enemy_hp >= before_enemy_hp:
		return
	var move_type: String = str(move_data.get("move_type", "PHYSICAL"))
	var reaction: Dictionary = RPG_STATUS.resolve_reaction(move_type, enemy_statuses)
	if not reaction.is_empty():
		var label: String = str(reaction.get("label", "REAKCJA"))
		var applied: String = str(reaction.get("applied", ""))
		var suffix: String = ""
		if not applied.is_empty():
			suffix = " → %s" % str(RPG_STATUS.info(applied).get("name", applied.to_upper()))
		lines.append("REAKCJA: %s%s" % [label, suffix])
	_damage_enemy_stability(maxi(1, before_enemy_hp - enemy_hp), move_data, lines)

func _enemy_turn(lines: Array[String]) -> void:
	if enemy_hp <= 0:
		return
	enemy_data = _normalize_creature_moves(enemy_data)
	enemy_passive_id = PASSIVES.default_for_creature(enemy_data)
	var predicted: Dictionary = _predict_enemy_move()
	var original_attack: int = int(enemy_data.get("attack", 5))
	if not predicted.is_empty() and str(predicted.get("kind", "attack")) == "attack":
		var hp_ratio: float = float(enemy_hp) / float(maxi(1, enemy_max_hp))
		var bonus: int = PASSIVES.attack_flat_bonus(enemy_passive_id, predicted, enemy_statuses, player_statuses, hp_ratio)
		enemy_data["attack"] = original_attack + bonus
	var before_player_hp: int = player_hp
	super._enemy_turn(lines)
	enemy_data["attack"] = original_attack
	if player_hp < before_player_hp:
		var move_data: Dictionary = predicted
		if not move_data.is_empty():
			var move_type: String = str(move_data.get("move_type", "PHYSICAL"))
			var reaction: Dictionary = RPG_STATUS.resolve_reaction(move_type, player_statuses)
			if not reaction.is_empty():
				lines.append("REAKCJA PRZECIWNIKA: %s" % str(reaction.get("label", "REAKCJA")))
		_damage_player_stability(maxi(1, before_player_hp - player_hp), move_data, lines)

func _predict_enemy_move() -> Dictionary:
	var moves: Array = enemy_data.get("moves", []) as Array
	if moves.is_empty():
		return {}
	var probe := RandomNumberGenerator.new()
	probe.state = rng.state
	var index: int = probe.randi_range(0, moves.size() - 1)
	return moves[index] as Dictionary

func _end_round(lines: Array[String]) -> void:
	super._end_round(lines)
	if battle_done:
		return
	var passive_heal: int = PASSIVES.round_heal(player_passive_id, player_max_hp, player_statuses)
	if passive_heal > 0 and player_hp > 0 and player_hp < player_max_hp:
		var before: int = player_hp
		player_hp = mini(player_max_hp, player_hp + passive_heal)
		lines.append("%s: %s odnawia %d HP." % [_active_name(), str(PASSIVES.info(player_passive_id).get("name", "PASYWKA")), player_hp - before])
	var enemy_heal: int = PASSIVES.round_heal(enemy_passive_id, enemy_max_hp, enemy_statuses)
	if enemy_heal > 0 and enemy_hp > 0 and enemy_hp < enemy_max_hp:
		enemy_hp = mini(enemy_max_hp, enemy_hp + enemy_heal)

func _use_bag(index: int) -> void:
	if index == 0 and not MODES.capture_allowed(battle_mode_id):
		log_text = "Moduł Chwytu jest zablokowany w trybie %s." % MODES.name(battle_mode_id)
		queue_redraw()
		return
	var old_capture_bonus: float = float(talent_bonuses.get("capture_bonus", 0.0))
	if index == 0:
		talent_bonuses["capture_bonus"] = old_capture_bonus + PASSIVES.capture_bonus(player_passive_id, enemy_statuses)
	super._use_bag(index)
	talent_bonuses["capture_bonus"] = old_capture_bonus

func _try_escape() -> void:
	if not MODES.escape_allowed(battle_mode_id):
		log_text = "Odwrót jest zablokowany w trybie %s." % MODES.name(battle_mode_id)
		queue_redraw()
		return
	super._try_escape()

func _damage_enemy_stability(damage: int, move_data: Dictionary, lines: Array[String]) -> void:
	if not MODES.uses_stability(battle_mode_id) or enemy_trainer_stability <= 0:
		return
	var pressure: int = _stability_pressure(damage, move_data)
	var before: int = enemy_trainer_stability
	enemy_trainer_stability = maxi(0, enemy_trainer_stability - pressure)
	if enemy_trainer_stability < before:
		lines.append("Stabilność przeciwnika -%d." % (before - enemy_trainer_stability))
	if before > 0 and enemy_trainer_stability == 0:
		RPG_STATUS.apply(enemy_statuses, "disrupted", 2)
		lines.append("REZONANS PRZEŁAMANY: przeciwnik zostaje ZAKŁÓCONY.")

func _damage_player_stability(damage: int, move_data: Dictionary, lines: Array[String]) -> void:
	if not MODES.uses_stability(battle_mode_id) or player_stability <= 0:
		return
	var pressure: int = _stability_pressure(damage, move_data)
	var resistance: float = PASSIVES.stability_resist(player_passive_id) + float(talent_bonuses.get("stability_resist", 0.0))
	pressure = maxi(1, int(round(float(pressure) * (1.0 - clampf(resistance, 0.0, 0.75)))))
	var before: int = player_stability
	player_stability = maxi(0, player_stability - pressure)
	if player_stability < before:
		lines.append("Stabilność trenera -%d." % (before - player_stability))
	if before > 0 and player_stability == 0:
		trainer_focus = maxi(0, trainer_focus - 1)
		RPG_STATUS.apply(player_statuses, "silence", 1)
		lines.append("KONCENTRACJA PRZEŁAMANA: -1 Focus i CISZA.")

func _stability_pressure(damage: int, move_data: Dictionary) -> int:
	var pressure: int = maxi(1, int(ceil(float(damage) * 0.65)))
	var move_type: String = str(move_data.get("move_type", ""))
	if move_type in ["REZONANS", "OSC", "WAVE", "FALA", "TORSJA", "CZUCIE"]:
		pressure += 2
	if str(move_data.get("pattern", "")) in ["control", "prepared", "counter"]:
		pressure += 1
	return pressure

func _make_result(outcome: String, xp: int, captured_name: String = "") -> Dictionary:
	var result: Dictionary = super._make_result(outcome, xp, captured_name)
	result["battle_mode"] = battle_mode_id
	result["player_stability"] = player_stability
	result["enemy_trainer_stability"] = enemy_trainer_stability
	return result
