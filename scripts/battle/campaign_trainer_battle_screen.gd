extends "res://scripts/battle/loadout_battle_screen.gd"

const TRAINERS = preload("res://scripts/data/runtime_trainer_db.gd")
const MONSTERS = preload("res://scripts/data/monster_db.gd")
const BATTLE_MODES = preload("res://scripts/data/battle_mode_db.gd")
const CAMPAIGN_BALANCE = preload("res://scripts/data/campaign_battle_balance.gd")
const BOSS_AI = preload("res://scripts/data/boss_profile_db.gd")
const BOSS_STATUS = preload("res://scripts/data/status_db.gd")
const MOVE_DB = preload("res://scripts/data/move_db.gd")
const BATTLE_MUSIC = preload("res://scripts/audio/retro_music.gd")
const SCENE_TRANSITION = preload("res://scripts/ui/scene_transition.gd")

const BOSS_SIGNATURES: Dictionary = {
	"vela_trial":"stability_crush",
	"marea_resonance":"conductive_surge",
	"ferrum_construct":"static_net",
	"nivra_guardian":"deep_freeze",
	"lumen_keeper":"weakness_scan",
	"aster_warden":"emergency_regen",
	"koral_tide":"fracture_wave",
	"zenith_final":"final_harmonic"
}

var trainer_id: String = ""
var boss_ai_id: String = ""
var trainer_name: String = "Trener"
var trainer_title: String = "Pojedynek trenerski"
var enemy_team: Array = []
var enemy_team_index: int = 0
var trainer_reward_xp: int = 0
var enemy_switched_this_turn: bool = false
var boss_profile: Dictionary = {}
var boss_turn: int = 0
var boss_phase: int = 0
var boss_observed_move_types: Dictionary = {}
var _battle_music: Node = null

func setup_trainer(
	trainer_key: String,
	party_data: Array,
	start_active_index: int,
	level: int,
	battle_inventory: Dictionary,
	talent_levels: Dictionary,
	loadout: Dictionary
) -> void:
	var data: Dictionary = TRAINERS.info(trainer_key)
	trainer_id = trainer_key
	boss_ai_id = TRAINERS.boss_profile_id(trainer_key)
	trainer_name = str(data.get("name", "Trener"))
	trainer_title = str(data.get("title", "Pojedynek trenerski"))
	trainer_reward_xp = TRAINERS.reward_xp(trainer_key)
	enemy_team = TRAINERS.party(trainer_key)
	enemy_team_index = 0
	boss_profile = BOSS_AI.info(boss_ai_id)
	boss_turn = 0
	boss_phase = 0
	boss_observed_move_types.clear()
	var first_name: String = "Wahlik"
	var first_level: int = 3
	if not enemy_team.is_empty():
		var first_entry: Dictionary = enemy_team[0] as Dictionary
		first_name = str(first_entry.get("name", first_name))
		first_level = maxi(1, int(first_entry.get("level", first_level)))
	super.setup(party_data,start_active_index,level,first_name,first_level,battle_inventory,talent_levels,loadout)
	_install_boss_signature_move()
	var enemy_base_hp: int = int(enemy_data.get("max_hp", 20))
	enemy_max_hp = CAMPAIGN_BALANCE.scaled_max_hp(enemy_base_hp, enemy_level)
	enemy_hp = enemy_max_hp
	set_battle_mode(TRAINERS.battle_mode(trainer_key))

func _ready() -> void:
	super._ready()
	log_text = "%s · %s rozpoczyna pojedynek!" % [trainer_name, trainer_title]
	if not boss_profile.is_empty():
		log_text += "\nBOSS: %s — %s" % [str(boss_profile.get("name", "MECHANIKA")), str(boss_profile.get("intro", ""))]
		if trainer_id.begins_with("rematch_"):
			log_text += "\nREMATCH+: profil reaguje na powtarzane typy ruchów."
	_battle_music = BATTLE_MUSIC.new()
	add_child(_battle_music)
	_battle_music.play_theme("boss" if not boss_profile.is_empty() else "trainer_battle")
	var transition: Control = SCENE_TRANSITION.new()
	add_child(transition)
	transition.play_in(0.22 if boss_profile.is_empty() else 0.30)
	queue_redraw()

func _draw() -> void:
	super._draw()
	draw_rect(Rect2(12, 745, 336, 20), Color(0.02,0.08,0.10,0.74))
	draw_rect(Rect2(12, 745, 336, 20), Color(0.55,0.42,0.68,0.34) if not boss_profile.is_empty() else Color(0.25,0.68,0.66,0.30), false, 1.0)
	var hint: String = "BOSS · CZYTAJ FAZĘ · RUCH · DRUŻYNA · TORBA" if not boss_profile.is_empty() else "TRENER · RUCH · DRUŻYNA · TORBA"
	draw_string(font, Vector2(18,759), hint, HORIZONTAL_ALIGNMENT_CENTER, 324, 7, Color("eadcf0") if not boss_profile.is_empty() else Color("c8e4e1"))

func _draw_background() -> void:
	super._draw_background()
	draw_string(font, Vector2(18, 44), "%s · %d/%d" % [trainer_name.to_upper(), enemy_team_index + 1, maxi(1, enemy_team.size())], HORIZONTAL_ALIGNMENT_LEFT, 220, 8, Color("d9c96c"))
	if not boss_profile.is_empty():
		var phase_label: String = _boss_phase_name()
		draw_string(font, Vector2(185, 44), "FAZA %d · %s" % [boss_phase + 1, phase_label], HORIZONTAL_ALIGNMENT_RIGHT, 158, 7, Color("f0a6d8"))

func _execute_pending_move(lines: Array[String]) -> void:
	if not boss_profile.is_empty():
		var moves: Array = player_data.get("moves", []) as Array
		if pending_move_index >= 0 and pending_move_index < moves.size():
			var used_move: Dictionary = moves[pending_move_index] as Dictionary
			var move_type: String = TYPE_BALANCE.normalize_type(str(used_move.get("move_type", "PHYSICAL")))
			if move_type != "SUPPORT":
				boss_observed_move_types[move_type] = int(boss_observed_move_types.get(move_type, 0)) + 1
	super._execute_pending_move(lines)

func _use_bag(index: int) -> void:
	if index == 0:
		log_text = "Moduł Chwytu jest zablokowany w pojedynku trenerskim."
		queue_redraw()
		return
	super._use_bag(index)

func _try_escape() -> void:
	log_text = "Nie można wycofać się z rozpoczętego pojedynku trenerskiego."
	queue_redraw()

func _enemy_turn(lines: Array[String]) -> void:
	if enemy_switched_this_turn:
		enemy_switched_this_turn = false
		return
	if boss_profile.is_empty():
		super._enemy_turn(lines)
		return
	boss_turn += 1
	_update_boss_phase(lines)
	_apply_periodic_boss_status(lines)
	_apply_boss_pre_turn(lines)
	var original_moves: Array = (enemy_data.get("moves", []) as Array).duplicate(true)
	var chosen: Dictionary = _select_boss_move(original_moves)
	if not chosen.is_empty(): enemy_data["moves"] = [chosen]
	var original_attack: int = int(enemy_data.get("attack", 5))
	var attack_bonus: int = _boss_attack_bonus()
	if attack_bonus > 0: enemy_data["attack"] = original_attack + attack_bonus
	super._enemy_turn(lines)
	enemy_data["attack"] = original_attack
	enemy_data["moves"] = original_moves
	_apply_boss_post_turn(lines)

func _select_boss_move(moves: Array) -> Dictionary:
	if moves.is_empty(): return {}
	var desired_pattern: String = BOSS_AI.cycle_pattern(boss_ai_id, boss_turn - 1, _boss_virtual_hp(), _boss_virtual_max_hp())
	var preferred: Array[String] = BOSS_AI.preferred_types(boss_ai_id)
	var signature_id: String = str(BOSS_SIGNATURES.get(boss_ai_id, ""))
	var player_types: Array = TYPE_BALANCE.target_types(player_data)
	var best_score: int = -9999
	var best: Dictionary = moves[0] as Dictionary
	for index: int in range(moves.size()):
		var move: Dictionary = moves[index] as Dictionary
		var score: int = index
		var pattern: String = str(move.get("pattern", "direct")); var kind: String = str(move.get("kind", "attack")); var move_type: String = TYPE_BALANCE.normalize_type(str(move.get("move_type", "PHYSICAL"))); var status_id: String = str(move.get("status", ""))
		if pattern == desired_pattern: score += 14
		if preferred.has(move_type): score += 6
		if kind == "attack":
			score += 3 + int(move.get("power", 0))
			if BOSS_STATUS.damage_multiplier(move_type, player_statuses) > 1.05: score += 9
			var type_mult: float = TYPE_BALANCE.multiplier(move_type, player_types)
			if type_mult >= 1.15: score += 8
			elif type_mult <= 0.90: score -= 4
			score += _adaptation_score(move_type)
		if kind == "heal" and enemy_hp <= int(round(float(enemy_max_hp) * 0.45)): score += 14
		if kind == "guard" and enemy_hp <= int(round(float(enemy_max_hp) * 0.32)): score += 8
		if not status_id.is_empty() and not BOSS_STATUS.has_status(player_statuses, status_id): score += 4
		if desired_pattern in ["control", "setup"] and pattern in ["control", "setup", "prepared"]: score += 5
		if desired_pattern == "counter" and pattern in ["counter", "guard"]: score += 8
		if not signature_id.is_empty() and str(move.get("id", "")) == signature_id:
			if boss_turn % (3 if trainer_id.begins_with("rematch_") else 4) == 0: score += 24
			else: score += 3
		if trainer_id.begins_with("rematch_") and pattern == desired_pattern: score += 4
		if score > best_score: best_score = score; best = move
	return best.duplicate(true)

func _adaptation_score(move_type: String) -> int:
	var score: int = 0
	for raw_observed: Variant in boss_observed_move_types.keys():
		var observed: String = str(raw_observed)
		var repetitions: int = mini(3, int(boss_observed_move_types[raw_observed]))
		var counter_mult: float = TYPE_BALANCE.multiplier(move_type, [observed])
		if counter_mult >= 1.15:
			score += repetitions * 2
	return score

func _install_boss_signature_move() -> void:
	if boss_profile.is_empty(): return
	var signature_id: String = str(BOSS_SIGNATURES.get(boss_ai_id, ""))
	if signature_id.is_empty() or not MOVE_DB.has(signature_id): return
	var moves: Array = enemy_data.get("moves", []) as Array
	for raw_move: Variant in moves:
		if typeof(raw_move) == TYPE_DICTIONARY and str((raw_move as Dictionary).get("id", "")) == signature_id:
			return
	moves.append(MOVE_DB.info(signature_id))
	enemy_data["moves"] = moves

func _update_boss_phase(lines: Array[String]) -> void:
	var new_phase: int = BOSS_AI.phase_index(boss_ai_id, _boss_virtual_hp(), _boss_virtual_max_hp())
	if new_phase <= boss_phase: return
	boss_phase = new_phase
	var text: String = BOSS_AI.phase_text(boss_ai_id, boss_phase)
	if not text.is_empty(): lines.append(text)
	match BOSS_AI.mechanic(boss_ai_id):
		"overclock":
			BOSS_STATUS.apply(enemy_statuses, "unstable", 2); lines.append("AX-7 przeciąża własną osłonę: NIESTABILNY.")
		"three_phase_finale":
			if boss_phase >= 2:
				BOSS_STATUS.apply(enemy_statuses, "vulnerable", 2); BOSS_STATUS.apply(enemy_statuses, "unstable", 2); lines.append("Rdzeń Veyra otwiera się: PODATNY + NIESTABILNY.")
		"spore_regen": BOSS_STATUS.apply(enemy_statuses, "regen", 2)

func _apply_periodic_boss_status(lines: Array[String]) -> void:
	var periodic: Dictionary = BOSS_AI.periodic_status(boss_ai_id, boss_turn)
	if periodic.is_empty(): return
	var status_id: String = str(periodic.get("status", ""))
	if status_id.is_empty(): return
	BOSS_STATUS.apply(player_statuses, status_id, int(periodic.get("turns", 1)))
	lines.append("MECHANIKA BOSSA: %s → %s." % [str(boss_profile.get("name", trainer_title)), str(BOSS_STATUS.info(status_id).get("name", status_id.to_upper()))])

func _apply_boss_pre_turn(lines: Array[String]) -> void:
	match BOSS_AI.mechanic(boss_ai_id):
		"stability_break":
			if boss_turn % 4 == 0 and player_stability > 0:
				player_stability = maxi(0, player_stability - 1); lines.append("Eron ścina rytm koncentracji: Stabilność -1.")
		"freeze_lock":
			if boss_phase >= 1 and BOSS_STATUS.has_status(player_statuses, "chilled") and boss_turn % 2 == 0:
				BOSS_STATUS.apply(player_statuses, "frozen", 1); lines.append("BIAŁA BLOKADA: WYCHŁODZONY przechodzi w ZAMROŻONY.")
		"prediction":
			if BOSS_STATUS.has_status(player_statuses, "marked"): BOSS_STATUS.apply(enemy_statuses, "focused", 1)
		"current_combo":
			if boss_phase >= 2 and BOSS_STATUS.has_status(player_statuses, "soaked"):
				BOSS_STATUS.apply(player_statuses, "paralyzed", 1); lines.append("SZTORM: mokre pole przewodzi impuls Veyi.")

func _apply_boss_post_turn(lines: Array[String]) -> void:
	match BOSS_AI.mechanic(boss_ai_id):
		"spore_regen":
			if enemy_hp > 0 and enemy_hp < enemy_max_hp:
				var heal: int = 3 + boss_phase * 2; var before: int = enemy_hp; enemy_hp = mini(enemy_max_hp, enemy_hp + heal); lines.append("Korona Aster odnawia %d HP." % (enemy_hp - before))
		"overclock":
			if boss_phase >= 1 and enemy_hp > 1 and boss_turn % 3 == 0:
				enemy_hp = maxi(1, enemy_hp - 2); lines.append("Przeciążenie AX-7 kosztuje 2 HP.")
		"three_phase_finale":
			if boss_phase >= 2 and enemy_trainer_stability > 0:
				enemy_trainer_stability = maxi(0, enemy_trainer_stability - 1); lines.append("Otwarty rdzeń traci 1 Stabilności po własnym impulsie.")

func _boss_attack_bonus() -> int:
	match BOSS_AI.mechanic(boss_ai_id):
		"overclock": return 3 if boss_phase >= 1 else 0
		"current_combo": return boss_phase * 2
		"three_phase_finale": return boss_phase * 2
		"freeze_lock": return 1 if boss_phase >= 1 else 0
		_: return boss_phase

func _boss_virtual_max_hp() -> int: return maxi(1, enemy_team.size() * 100)

func _boss_virtual_hp() -> int:
	var remaining_after_current: int = maxi(0, enemy_team.size() - enemy_team_index - 1)
	var current_ratio: float = float(maxi(0, enemy_hp)) / float(maxi(1, enemy_max_hp))
	return remaining_after_current * 100 + int(round(current_ratio * 100.0))

func _boss_phase_name() -> String:
	if boss_profile.is_empty(): return ""
	var names: Array = boss_profile.get("phase_names", []) as Array
	if names.is_empty(): return ""
	return str(names[clampi(boss_phase, 0, names.size() - 1)])

func _win(lines: Array[String]) -> void:
	if battle_done: return
	if enemy_team_index + 1 < enemy_team.size():
		_sync_active_member(); enemy_team_index += 1
		var entry: Dictionary = enemy_team[enemy_team_index] as Dictionary; var next_name: String = str(entry.get("name", "Wahlik")); enemy_data = MONSTERS.get_monster(next_name); enemy_level = maxi(1, int(entry.get("level", 3)))
		var enemy_base_hp: int = int(enemy_data.get("max_hp", 20)); enemy_max_hp = CAMPAIGN_BALANCE.scaled_max_hp(enemy_base_hp, enemy_level); enemy_hp = enemy_max_hp; enemy_statuses.clear(); enemy_guard = false; enemy_tex = ART.texture_for(next_name); enemy_data = _normalize_creature_moves(enemy_data); enemy_passive_id = PASSIVES.default_for_creature(enemy_data); _install_boss_signature_move(); enemy_switched_this_turn = true
		var focus_before: int = trainer_focus; trainer_focus = mini(trainer_focus_max, trainer_focus + CAMPAIGN_BALANCE.FOCUS_ON_ENEMY_KO); var focus_gain: int = trainer_focus - focus_before
		if focus_gain > 0: lines.append("Pokonanie partnera rywala: +%d Focus." % focus_gain)
		lines.append("%s wysyła %s Lv.%d!" % [trainer_name, next_name, enemy_level])
		if not boss_profile.is_empty(): _update_boss_phase(lines)
		queue_redraw(); return
	super._win(lines)

func _make_result(outcome: String, xp: int, captured_name: String = "") -> Dictionary:
	var result: Dictionary = super._make_result(outcome, xp, captured_name)
	result["battle_kind"] = "trainer"; result["trainer_id"] = trainer_id; result["trainer_name"] = trainer_name
	if not boss_profile.is_empty(): result["boss_mechanic"] = BOSS_AI.mechanic(boss_ai_id); result["boss_phase_reached"] = boss_phase; result["boss_profile_id"] = boss_ai_id
	if outcome == "win": result["xp"] = trainer_reward_xp; result["captured_name"] = ""
	return result
