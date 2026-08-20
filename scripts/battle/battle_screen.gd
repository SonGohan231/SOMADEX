extends Control

signal finished(result: Dictionary)

const DB = preload("res://scripts/data/monster_db.gd")
const ART = preload("res://scripts/data/monster_art.gd")
const PROGRESSION = preload("res://scripts/data/progression_db.gd")
const EQUIPMENT = preload("res://scripts/data/equipment_db.gd")
const ITEMS = preload("res://scripts/data/item_db.gd")
const STATUS = preload("res://scripts/data/status_db.gd")
const RULES = preload("res://scripts/battle/battle_rules.gd")
const STATE = preload("res://scripts/core/game_state.gd")

var font: Font
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var party: Array = []
var active_index: int = 0
var player_data: Dictionary = {}
var enemy_data: Dictionary = {}
var player_tex: Texture2D
var enemy_tex: Texture2D
var player_hp: int = 1
var player_max_hp: int = 1
var enemy_hp: int = 1
var enemy_max_hp: int = 1
var enemy_level: int = 1
var trainer_level: int = 1

var inventory: Dictionary = {}
var talents: Dictionary = {}
var equipment: Dictionary = {}
var talent_bonuses: Dictionary = {}
var gear_bonuses: Dictionary = {}

var trainer_focus: int = 3
var trainer_focus_max: int = 3
var pending_move_index: int = -1
var pending_damage_bonus: int = 0

var player_statuses: Dictionary = {}
var enemy_statuses: Dictionary = {}
var player_guard: bool = false
var enemy_guard: bool = false

var mode: String = "root"
var selected: int = 0
var log_text: String = ""
var battle_done: bool = false
var result_data: Dictionary = {}
var flash_enemy_until: int = 0
var flash_player_until: int = 0
var elapsed: float = 0.0

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
	party = party_data.duplicate(true)
	active_index = clampi(start_active_index, 0, maxi(0, party.size() - 1))
	trainer_level = maxi(1, level)
	enemy_data = DB.get_monster(enemy_name)
	enemy_level = maxi(1, encounter_level)
	inventory = ITEMS.normalize_inventory(battle_inventory)
	talents = PROGRESSION.default_talents()
	for path_id: String in PROGRESSION.path_ids():
		talents[path_id] = maxi(0, int(talent_levels.get(path_id, 0)))
	talent_bonuses = PROGRESSION.bonuses(talents)
	var owned_for_normalize: Array[String] = EQUIPMENT.default_owned()
	equipment = EQUIPMENT.normalize_loadout(loadout, owned_for_normalize)
	gear_bonuses = EQUIPMENT.aggregate(equipment)
	trainer_focus_max = 3 + int(gear_bonuses.get("trainer_focus_bonus", 0))
	trainer_focus = trainer_focus_max
	var enemy_base_hp: int = int(enemy_data.get("max_hp", 20))
	enemy_max_hp = enemy_base_hp + maxi(0, enemy_level - 3)
	enemy_hp = enemy_max_hp
	_load_active_member()

func _ready() -> void:
	font = ThemeDB.fallback_font
	rng.randomize()
	if party.is_empty():
		party.append(STATE.make_member("Luzik", 5, 1))
		active_index = 0
	if player_data.is_empty():
		_load_active_member()
	if enemy_data.is_empty():
		enemy_data = DB.first_zone_enemy()
		enemy_max_hp = int(enemy_data.get("max_hp", 20))
		enemy_hp = enemy_max_hp
	player_tex = ART.texture_for(_active_name())
	enemy_tex = ART.texture_for(str(enemy_data.get("name", "Wahlik")))
	log_text = "Dziki %s Lv.%d pojawia się w polu rezonansu!" % [str(enemy_data.get("name", "Somaskan")), enemy_level]
	queue_redraw()

func _process(delta: float) -> void:
	elapsed += delta
	queue_redraw()

func _active_member() -> Dictionary:
	if party.is_empty():
		return {}
	active_index = clampi(active_index, 0, party.size() - 1)
	return party[active_index] as Dictionary

func _active_name() -> String:
	return str(_active_member().get("name", "Luzik"))

func _load_active_member() -> void:
	if party.is_empty():
		return
	var member: Dictionary = _active_member()
	player_data = DB.get_monster(str(member.get("name", "Luzik")))
	player_max_hp = STATE.member_max_hp(member, talents, equipment)
	player_hp = clampi(int(member.get("hp", player_max_hp)), 0, player_max_hp)
	if is_inside_tree():
		player_tex = ART.texture_for(_active_name())

func _sync_active_member() -> void:
	if party.is_empty():
		return
	var member: Dictionary = _active_member()
	member["hp"] = clampi(player_hp, 0, player_max_hp)
	party[active_index] = member

func _draw() -> void:
	_draw_background()
	_draw_enemy_side()
	_draw_player_side()
	_draw_log()
	if battle_done:
		_draw_continue()
	elif mode == "root":
		_draw_root_menu()
	elif mode == "moves":
		_draw_move_menu()
	elif mode == "bag":
		_draw_bag_menu()
	elif mode == "party":
		_draw_party_menu()
	elif mode == "trainer":
		_draw_trainer_menu()

func _draw_background() -> void:
	draw_rect(Rect2(0, 0, 360, 800), Color("09191f"))
	for y: int in range(70, 490, 28):
		var alpha: float = 0.035 + 0.02 * sin(elapsed * 1.8 + float(y))
		draw_line(Vector2(0, y), Vector2(360, y), Color(0.25, 0.85, 0.78, alpha), 1.0)
	draw_circle(Vector2(286, 236), 110.0, Color(0.08, 0.27, 0.28, 0.18))
	draw_circle(Vector2(82, 434), 118.0, Color(0.09, 0.24, 0.31, 0.18))
	draw_string(font, Vector2(18, 27), "POLE REZONANSU · FOCUS %d/%d" % [trainer_focus, trainer_focus_max], HORIZONTAL_ALIGNMENT_LEFT, 320, 10, Color("5fcfc9"))

func _draw_enemy_side() -> void:
	var panel: Rect2 = Rect2(18, 48, 204, 80)
	draw_rect(panel, Color("102a32"))
	draw_rect(panel, Color("315761"), false, 2.0)
	draw_string(font, Vector2(30, 72), str(enemy_data.get("name", "?")), HORIZONTAL_ALIGNMENT_LEFT, 120, 16, Color("f0faf8"))
	draw_string(font, Vector2(158, 71), "Lv.%d" % enemy_level, HORIZONTAL_ALIGNMENT_RIGHT, 50, 10, Color("9db9bc"))
	_draw_hp_bar(Rect2(30, 88, 176, 12), enemy_hp, enemy_max_hp)
	draw_string(font, Vector2(136, 112), "%d/%d" % [enemy_hp, enemy_max_hp], HORIZONTAL_ALIGNMENT_RIGHT, 70, 9, Color("8ca8aa"))
	var status_text: String = STATUS.summary(enemy_statuses)
	if not status_text.is_empty():
		draw_string(font, Vector2(30, 124), status_text, HORIZONTAL_ALIGNMENT_LEFT, 180, 7, Color("e2c66d"))
	var art_rect: Rect2 = Rect2(188, 136, 156, 117)
	draw_rect(Rect2(184, 132, 164, 125), Color("16323a"))
	if enemy_tex != null:
		draw_texture_rect(enemy_tex, art_rect, false)
	var flash: bool = Time.get_ticks_msec() < flash_enemy_until
	draw_rect(art_rect, Color(1, 1, 1, 0.32) if flash else Color(0.32, 0.86, 0.80, 0.26), false, 2.0)

func _draw_player_side() -> void:
	var art_rect: Rect2 = Rect2(16, 304, 170, 128)
	draw_rect(Rect2(12, 300, 178, 136), Color("16323a"))
	if player_tex != null:
		draw_texture_rect(player_tex, art_rect, false)
	var flash: bool = Time.get_ticks_msec() < flash_player_until
	draw_rect(art_rect, Color(1, 1, 1, 0.32) if flash else Color(0.32, 0.86, 0.80, 0.26), false, 2.0)
	var panel: Rect2 = Rect2(144, 388, 200, 92)
	draw_rect(panel, Color("102a32"))
	draw_rect(panel, Color("315761"), false, 2.0)
	var member: Dictionary = _active_member()
	draw_string(font, Vector2(156, 414), _active_name(), HORIZONTAL_ALIGNMENT_LEFT, 120, 16, Color("f0faf8"))
	draw_string(font, Vector2(276, 413), "Lv.%d" % int(member.get("level", 1)), HORIZONTAL_ALIGNMENT_RIGHT, 54, 9, Color("9db9bc"))
	_draw_hp_bar(Rect2(156, 428, 174, 13), player_hp, player_max_hp)
	draw_string(font, Vector2(240, 458), "HP %d/%d" % [player_hp, player_max_hp], HORIZONTAL_ALIGNMENT_RIGHT, 90, 9, Color("9db9bc"))
	var status_text: String = STATUS.summary(player_statuses)
	if not status_text.is_empty():
		draw_string(font, Vector2(156, 475), status_text, HORIZONTAL_ALIGNMENT_LEFT, 174, 7, Color("e2c66d"))

func _draw_hp_bar(rect: Rect2, hp: int, max_hp: int) -> void:
	draw_rect(rect, Color("08171d"))
	var ratio: float = clampf(float(hp) / float(maxi(1, max_hp)), 0.0, 1.0)
	var bar_color: Color = Color("61d975")
	if ratio < 0.5:
		bar_color = Color("e3c55a")
	if ratio < 0.22:
		bar_color = Color("e76b68")
	draw_rect(Rect2(rect.position + Vector2(2, 2), Vector2((rect.size.x - 4.0) * ratio, rect.size.y - 4.0)), bar_color)
	draw_rect(rect, Color("34545b"), false, 1.0)

func _draw_log() -> void:
	var r: Rect2 = Rect2(14, 492, 332, 116)
	draw_rect(r, Color("071b22"))
	draw_rect(r, Color("4bdcd5"), false, 2.0)
	var wrapped: Array[String] = _wrap(log_text, 44)
	for i: int in range(mini(4, wrapped.size())):
		draw_string(font, Vector2(28, 523 + i * 21), wrapped[i], HORIZONTAL_ALIGNMENT_LEFT, 304, 11, Color("e3f2f0"))

func _draw_root_menu() -> void:
	var labels: Array[String] = ["RUCHY", "DRUŻYNA", "PLECAK", "ODWRÓT"]
	for i: int in range(4):
		_draw_grid_button(i, labels[i], Color("50e0d9"))

func _draw_move_menu() -> void:
	var moves: Array = player_data.get("moves", []) as Array
	for i: int in range(4):
		var r: Rect2 = _root_rect(i)
		var move_data: Dictionary = moves[i] as Dictionary
		var active: bool = i == selected
		draw_rect(r, Color("193f49") if active else Color("0e2831"))
		draw_rect(r, Color("50e0d9") if active else Color("2d5059"), false, 2.0)
		draw_string(font, r.position + Vector2(9, 22), str(move_data.get("name", "Ruch")), HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 18, 9, Color("effffc"))
		var tag: String = "%s · PWR %d" % [str(move_data.get("move_type", "?")), int(move_data.get("power", 0))]
		if str(move_data.get("kind", "attack")) == "heal":
			tag = "REGEN +%d" % int(move_data.get("power", 0))
		elif str(move_data.get("kind", "attack")) == "guard":
			tag = "OBRONA"
		draw_string(font, r.position + Vector2(9, 42), tag, HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 18, 7, Color("7ba5a7"))

func _draw_bag_menu() -> void:
	var labels: Array[String] = [
		"MODUŁ ×%d" % ITEMS.count(inventory, "capture_modules"),
		"REGEN ×%d" % ITEMS.count(inventory, "regenerators"),
		"OGNIWO ×%d" % ITEMS.count(inventory, "resonance_cells"),
		"SONDA ×%d" % ITEMS.count(inventory, "sondas")
	]
	for i: int in range(4):
		_draw_grid_button(i, labels[i], Color("e4c965"))

func _draw_party_menu() -> void:
	for i: int in range(6):
		var r: Rect2 = _list_rect(i)
		var active: bool = i == selected
		draw_rect(r, Color("193f49") if active else Color("0e2831"))
		draw_rect(r, Color("50e0d9") if active else Color("2d5059"), false, 1.0)
		if i < party.size():
			var member: Dictionary = party[i] as Dictionary
			var name: String = str(member.get("name", "?"))
			var max_hp: int = STATE.member_max_hp(member, talents, equipment)
			var marker: String = "● " if i == active_index else ""
			draw_string(font, r.position + Vector2(8, 17), "%s%d. %s  Lv.%d  HP %d/%d" % [marker, i + 1, name, int(member.get("level", 1)), int(member.get("hp", 0)), max_hp], HORIZONTAL_ALIGNMENT_LEFT, 310, 9, Color("effffc"))
		else:
			draw_string(font, r.position + Vector2(8, 17), "%d. — pusty slot —" % (i + 1), HORIZONTAL_ALIGNMENT_LEFT, 310, 8, Color("577176"))

func _draw_trainer_menu() -> void:
	for i: int in range(6):
		var r: Rect2 = _list_rect(i)
		var active: bool = i == selected
		draw_rect(r, Color("1b3d46") if active else Color("0e2831"))
		draw_rect(r, Color("d6c96a") if active else Color("2d5059"), false, 1.0)
		if i < 5:
			var action: Dictionary = PROGRESSION.trainer_action_info(i, talents)
			var rank: int = int(action.get("rank", 0))
			var lock_text: String = "R%d" % rank if rank > 0 else "ZABLOK."
			draw_string(font, r.position + Vector2(8, 17), "%s · %s · F1" % [str(action.get("name", "?")), lock_text], HORIZONTAL_ALIGNMENT_LEFT, 310, 8, Color("effffc") if rank > 0 else Color("6b7d80"))
		else:
			draw_string(font, r.position + Vector2(8, 17), "POMIŃ KOMENDĘ TRENERA", HORIZONTAL_ALIGNMENT_LEFT, 310, 9, Color("effffc"))

func _draw_grid_button(index: int, label: String, accent: Color) -> void:
	var r: Rect2 = _root_rect(index)
	var active: bool = index == selected
	draw_rect(r, Color("18424b") if active else Color("0e2831"))
	draw_rect(r, accent if active else Color("2d5059"), false, 2.0)
	draw_string(font, r.position + Vector2(6, 34), label, HORIZONTAL_ALIGNMENT_CENTER, r.size.x - 12, 10, Color("f0fffc") if active else Color("a9c2c3"))

func _draw_continue() -> void:
	var r: Rect2 = Rect2(44, 654, 272, 62)
	draw_rect(r, Color("17464e"))
	draw_rect(r, Color("54e4dd"), false, 2.0)
	draw_string(font, Vector2(60, 692), "WRÓĆ DO ŚWIATA", HORIZONTAL_ALIGNMENT_CENTER, 240, 13, Color("f0fffc"))

func _root_rect(index: int) -> Rect2:
	var col: int = index % 2
	var row: int = int(index / 2)
	return Rect2(16 + col * 166, 628 + row * 68, 160, 58)

func _list_rect(index: int) -> Rect2:
	return Rect2(16, 615 + index * 29, 328, 25)

func _wrap(text: String, width: int) -> Array[String]:
	var out: Array[String] = []
	var current: String = ""
	for word: String in text.replace("\n", " ").split(" "):
		var candidate: String = word if current.is_empty() else current + " " + word
		if candidate.length() > width and not current.is_empty():
			out.append(current)
			current = word
		else:
			current = candidate
	if not current.is_empty():
		out.append(current)
	return out

func _activate_root() -> void:
	match selected:
		0:
			mode = "moves"
			selected = 0
		1:
			mode = "party"
			selected = active_index
		2:
			mode = "bag"
			selected = 0
		3:
			_try_escape()
	queue_redraw()

func _queue_move(index: int) -> void:
	var moves: Array = player_data.get("moves", []) as Array
	if index < 0 or index >= moves.size():
		return
	pending_move_index = index
	pending_damage_bonus = 0
	mode = "trainer"
	selected = 5
	var move_data: Dictionary = moves[index] as Dictionary
	log_text = "%s przygotowuje %s. Wybierz komendę trenera albo POMIŃ." % [_active_name(), str(move_data.get("name", "ruch"))]
	queue_redraw()

func _use_trainer_action(index: int) -> void:
	if pending_move_index < 0:
		mode = "root"
		selected = 0
		return
	var lines: Array[String] = []
	if index < 5:
		var action: Dictionary = PROGRESSION.trainer_action_info(index, talents)
		var rank: int = int(action.get("rank", 0))
		if rank <= 0:
			log_text = "Ta komenda wymaga co najmniej 1 rangi odpowiedniej ścieżki trenera."
			return
		var focus_cost: int = maxi(0, int(action.get("focus_cost", 1)))
		if trainer_focus < focus_cost:
			log_text = "Brak Skupienia. Użyj Ogniwa Rezonansu lub pomiń komendę."
			return
		trainer_focus -= focus_cost
		var path_id: String = str(action.get("path_id", ""))
		_apply_trainer_action(path_id, rank, lines)
	else:
		lines.append("Trener nie wydaje dodatkowej komendy.")
	_execute_pending_move(lines)
	if battle_done:
		return
	_enemy_turn(lines)
	if not battle_done:
		_end_round(lines)
	if not battle_done:
		_handle_faint(lines)
	mode = "root"
	selected = 0
	pending_move_index = -1
	pending_damage_bonus = 0
	log_text = "\n".join(lines)
	queue_redraw()

func _apply_trainer_action(path_id: String, rank: int, lines: Array[String]) -> void:
	match path_id:
		PROGRESSION.PATH_TACTICIAN:
			pending_damage_bonus += rank * 2
			lines.append("Taktyk: +%d mocy do ruchu tej rundy." % (rank * 2))
		PROGRESSION.PATH_GUARDIAN:
			var before: int = player_hp
			player_hp = mini(player_max_hp, player_hp + rank * 2)
			lines.append("Opiekun: +%d HP." % (player_hp - before))
		PROGRESSION.PATH_RESEARCHER:
			STATUS.apply(enemy_statuses, "marked", 3)
			lines.append("Badacz oznacza słabość przeciwnika.")
		PROGRESSION.PATH_TECHNICIAN:
			STATUS.apply(enemy_statuses, "disrupted", 1 + int(rank / 3))
			lines.append("Technik zakłóca następną odpowiedź.")
		PROGRESSION.PATH_VANGUARD:
			player_guard = true
			lines.append("Awangardzista przechwytuje część następnego uderzenia.")

func _execute_pending_move(lines: Array[String]) -> void:
	var moves: Array = player_data.get("moves", []) as Array
	if pending_move_index < 0 or pending_move_index >= moves.size():
		return
	var move_data: Dictionary = moves[pending_move_index] as Dictionary
	var accuracy: float = clampf(float(move_data.get("accuracy", 1.0)), 0.0, 1.0)
	if rng.randf() > accuracy:
		lines.append("%s używa %s, ale ruch nie trafia." % [_active_name(), str(move_data.get("name", "ruch"))])
		return
	var kind: String = str(move_data.get("kind", "attack"))
	if kind == "attack":
		var attack_stat: int = int(player_data.get("attack", 5)) + int(gear_bonuses.get("attack_bonus", 0))
		var defense_stat: int = int(enemy_data.get("defense", 5))
		var member: Dictionary = _active_member()
		var move_type: String = str(move_data.get("move_type", "PHYSICAL"))
		var guard_mult: float = 0.55 if enemy_guard else 1.0
		var damage: int = RULES.calculate_damage(int(move_data.get("power", 1)), attack_stat, defense_stat, int(member.get("level", 1)), int(talent_bonuses.get("attack_bonus", 0)) + pending_damage_bonus + rng.randi_range(-2, 2), move_type, enemy_statuses, player_statuses, guard_mult)
		enemy_guard = false
		enemy_hp = maxi(0, enemy_hp - damage)
		flash_enemy_until = Time.get_ticks_msec() + 170
		var reaction: String = STATUS.interaction_label(move_type, enemy_statuses)
		var suffix: String = " · %s!" % reaction if not reaction.is_empty() else ""
		lines.append("%s używa %s: -%d HP%s" % [_active_name(), str(move_data.get("name", "ruch")), damage, suffix])
		_try_apply_move_status(move_data, enemy_statuses, lines, str(enemy_data.get("name", "przeciwnik")))
	elif kind == "heal":
		var heal: int = int(move_data.get("power", 0)) + 4 + int(talent_bonuses.get("heal_bonus", 0)) + int(gear_bonuses.get("heal_bonus", 0))
		var before: int = player_hp
		player_hp = mini(player_max_hp, player_hp + heal)
		var status_id: String = str(move_data.get("status", ""))
		if status_id == "stabilny":
			STATUS.cleanse_stability(player_statuses)
		elif not status_id.is_empty():
			STATUS.apply(player_statuses, status_id)
		lines.append("%s: odzyskano %d HP." % [str(move_data.get("name", "Regeneracja")), player_hp - before])
	elif kind == "guard":
		player_guard = true
		lines.append("%s przygotowuje osłonę." % _active_name())
	if enemy_hp <= 0:
		_win(lines)

func _try_apply_move_status(move_data: Dictionary, target_statuses: Dictionary, lines: Array[String], target_name: String) -> void:
	var status_id: String = str(move_data.get("status", ""))
	if status_id.is_empty() or status_id in ["guard", "stabilny"]:
		return
	var chance: float = float(move_data.get("status_chance", 0.0))
	if RULES.status_roll(chance, rng):
		STATUS.apply(target_statuses, status_id)
		var data: Dictionary = STATUS.info(status_id)
		lines.append("%s otrzymuje status %s." % [target_name, str(data.get("name", status_id.to_upper()))])

func _enemy_turn(lines: Array[String]) -> void:
	if enemy_hp <= 0:
		return
	var moves: Array = enemy_data.get("moves", []) as Array
	if moves.is_empty():
		return
	var move_data: Dictionary = moves[rng.randi_range(0, moves.size() - 1)] as Dictionary
	var kind: String = str(move_data.get("kind", "attack"))
	if kind == "guard":
		enemy_guard = true
		lines.append("%s używa %s i wzmacnia osłonę." % [str(enemy_data.get("name", "?")), str(move_data.get("name", "ruch"))])
		return
	if kind == "heal":
		var before_enemy: int = enemy_hp
		enemy_hp = mini(enemy_max_hp, enemy_hp + int(move_data.get("power", 0)) + 2)
		lines.append("%s odzyskuje %d HP." % [str(enemy_data.get("name", "?")), enemy_hp - before_enemy])
		return
	var accuracy: float = clampf(float(move_data.get("accuracy", 1.0)), 0.0, 1.0)
	if rng.randf() > accuracy:
		lines.append("%s używa %s, ale pudłuje." % [str(enemy_data.get("name", "?")), str(move_data.get("name", "ruch"))])
		return
	var defense_stat: int = int(player_data.get("defense", 5)) + int(gear_bonuses.get("defense_bonus", 0))
	var attack_stat: int = int(enemy_data.get("attack", 5))
	var guard_mult: float = 0.45 if player_guard else 1.0
	var move_type: String = str(move_data.get("move_type", "PHYSICAL"))
	var damage: int = RULES.calculate_damage(int(move_data.get("power", 1)), attack_stat, defense_stat, enemy_level, rng.randi_range(-1, 2), move_type, player_statuses, enemy_statuses, guard_mult)
	player_guard = false
	player_hp = maxi(0, player_hp - damage)
	flash_player_until = Time.get_ticks_msec() + 170
	var reaction: String = STATUS.interaction_label(move_type, player_statuses)
	var suffix: String = " · %s!" % reaction if not reaction.is_empty() else ""
	lines.append("%s odpowiada %s: -%d HP%s" % [str(enemy_data.get("name", "?")), str(move_data.get("name", "ruch")), damage, suffix])
	_try_apply_move_status(move_data, player_statuses, lines, _active_name())
	_handle_faint(lines)

func _end_round(lines: Array[String]) -> void:
	var player_dot: int = STATUS.tick_damage(player_statuses)
	var player_hot: int = STATUS.tick_heal(player_statuses)
	var enemy_dot: int = STATUS.tick_damage(enemy_statuses)
	var enemy_hot: int = STATUS.tick_heal(enemy_statuses)
	if player_dot > 0:
		player_hp = maxi(0, player_hp - player_dot)
		lines.append("%s traci %d HP od statusów." % [_active_name(), player_dot])
	if player_hot > 0 and player_hp > 0:
		var before_player: int = player_hp
		player_hp = mini(player_max_hp, player_hp + player_hot)
		lines.append("%s regeneruje %d HP." % [_active_name(), player_hp - before_player])
	if enemy_dot > 0:
		enemy_hp = maxi(0, enemy_hp - enemy_dot)
		lines.append("%s traci %d HP od statusów." % [str(enemy_data.get("name", "?")), enemy_dot])
	if enemy_hot > 0 and enemy_hp > 0:
		var before_enemy: int = enemy_hp
		enemy_hp = mini(enemy_max_hp, enemy_hp + enemy_hot)
		lines.append("%s regeneruje %d HP." % [str(enemy_data.get("name", "?")), enemy_hp - before_enemy])
	player_statuses = STATUS.tick(player_statuses)
	enemy_statuses = STATUS.tick(enemy_statuses)
	if enemy_hp <= 0 and not battle_done:
		_win(lines)

func _handle_faint(lines: Array[String]) -> void:
	if player_hp > 0 or battle_done:
		return
	_sync_active_member()
	var next_index: int = _next_living_member()
	if next_index >= 0:
		active_index = next_index
		player_statuses.clear()
		player_guard = false
		_load_active_member()
		lines.append("%s przejmuje pole rezonansu!" % _active_name())
		return
	battle_done = true
	result_data = _make_result("loss", 0)
	lines.append("Cała drużyna utraciła synchronizację. Powrót awaryjny do Vela.")

func _next_living_member() -> int:
	for i: int in range(party.size()):
		if i == active_index:
			continue
		var member: Dictionary = party[i] as Dictionary
		if int(member.get("hp", 0)) > 0:
			return i
	return -1

func _switch_party(index: int) -> void:
	if index < 0 or index >= party.size():
		return
	if index == active_index:
		log_text = "%s już jest aktywnym partnerem." % _active_name()
		return
	var target: Dictionary = party[index] as Dictionary
	if int(target.get("hp", 0)) <= 0:
		log_text = "Ten Somaskan nie może teraz wejść do walki."
		return
	_sync_active_member()
	active_index = index
	player_statuses.clear()
	player_guard = false
	_load_active_member()
	var lines: Array[String] = ["Zmiana partnera: %s wchodzi do pola." % _active_name()]
	_enemy_turn(lines)
	if not battle_done:
		_end_round(lines)
	if not battle_done:
		_handle_faint(lines)
	mode = "root"
	selected = 0
	log_text = "\n".join(lines)
	queue_redraw()

func _use_bag(index: int) -> void:
	if index == 0:
		if not ITEMS.consume(inventory, "capture_modules"):
			log_text = "Brak Modułów Chwytu."
			return
		var chance: float = RULES.capture_chance(float(enemy_data.get("capture_rate", 0.30)), enemy_hp, enemy_max_hp, float(talent_bonuses.get("capture_bonus", 0.0)), float(gear_bonuses.get("capture_bonus", 0.0)), enemy_statuses)
		if rng.randf() < chance:
			battle_done = true
			result_data = _make_result("capture", int(enemy_data.get("exp_yield", 12)) + 4, str(enemy_data.get("name", "")))
			result_data["captured_level"] = enemy_level
			log_text = "Synchronizacja udana. %s trafia do drużyny lub magazynu!" % str(enemy_data.get("name", "Somaskan"))
		else:
			var lines: Array[String] = ["Moduł nie utrzymał synchronizacji (%d%%)." % int(round(chance * 100.0))]
			_enemy_turn(lines)
			if not battle_done:
				_end_round(lines)
			log_text = "\n".join(lines)
	elif index == 1:
		if not ITEMS.consume(inventory, "regenerators"):
			log_text = "Brak Regeneratorów."
			return
		var before: int = player_hp
		var heal: int = 10 + int(talent_bonuses.get("item_heal_bonus", 0)) + int(gear_bonuses.get("heal_bonus", 0))
		player_hp = mini(player_max_hp, player_hp + heal)
		var lines: Array[String] = ["Regenerator: +%d HP." % (player_hp - before)]
		_enemy_turn(lines)
		if not battle_done:
			_end_round(lines)
		log_text = "\n".join(lines)
	elif index == 2:
		if not ITEMS.consume(inventory, "resonance_cells"):
			log_text = "Brak Ogniw Rezonansu."
			return
		var before_focus: int = trainer_focus
		trainer_focus = mini(trainer_focus_max, trainer_focus + 2)
		var lines: Array[String] = ["Ogniwo: +%d Skupienia." % (trainer_focus - before_focus)]
		_enemy_turn(lines)
		if not battle_done:
			_end_round(lines)
		log_text = "\n".join(lines)
	elif index == 3:
		if not ITEMS.consume(inventory, "sondas"):
			log_text = "Brak Sond Vela."
			return
		STATUS.apply(enemy_statuses, "marked", 3)
		var rarity: String = str(enemy_data.get("rarity", "nieznana"))
		var lines: Array[String] = ["Sonda: %s · %s · rzadkość %s. Cel OZNACZONY." % [str(enemy_data.get("name", "?")), str(enemy_data.get("type", "?")), rarity]]
		_enemy_turn(lines)
		if not battle_done:
			_end_round(lines)
		log_text = "\n".join(lines)
	if not battle_done:
		var faint_lines: Array[String] = []
		_handle_faint(faint_lines)
		if not faint_lines.is_empty():
			log_text += " " + " ".join(faint_lines)
	mode = "root"
	selected = 0
	queue_redraw()

func _try_escape() -> void:
	var chance: float = RULES.escape_chance(0.68, float(talent_bonuses.get("escape_bonus", 0.0)), float(gear_bonuses.get("escape_bonus", 0.0)), player_statuses)
	if rng.randf() < chance:
		battle_done = true
		result_data = _make_result("escape", 0)
		log_text = "Drużyna bezpiecznie wycofuje się z pola rezonansu."
	else:
		var lines: Array[String] = ["Odwrót nieudany (%d%% szansy)." % int(round(chance * 100.0))]
		_enemy_turn(lines)
		if not battle_done:
			_end_round(lines)
		_handle_faint(lines)
		log_text = "\n".join(lines)
	queue_redraw()

func _win(lines: Array[String]) -> void:
	if battle_done:
		return
	battle_done = true
	_sync_active_member()
	var xp: int = int(enemy_data.get("exp_yield", 12)) + maxi(0, enemy_level - 2)
	result_data = _make_result("win", xp)
	lines.append("%s traci synchronizację. +%d EXP partnera i trenera." % [str(enemy_data.get("name", "?")), xp])

func _make_result(outcome: String, xp: int, captured_name: String = "") -> Dictionary:
	_sync_active_member()
	return {
		"outcome": outcome,
		"party": party.duplicate(true),
		"active_party_index": active_index,
		"xp": maxi(0, xp),
		"seen_name": str(enemy_data.get("name", "")),
		"captured_name": captured_name,
		"captured_level": enemy_level,
		"inventory": inventory.duplicate(true)
	}

func _finish_battle() -> void:
	if result_data.is_empty():
		result_data = _make_result("escape", 0)
	finished.emit(result_data)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if not key_event.pressed or key_event.echo:
			return
		if battle_done:
			if key_event.keycode in [KEY_ENTER, KEY_SPACE, KEY_Z, KEY_ESCAPE, KEY_X]:
				_finish_battle()
			return
		if key_event.keycode in [KEY_ESCAPE, KEY_X] and mode != "root":
			mode = "root"
			selected = 0
			pending_move_index = -1
			queue_redraw()
			return
		if mode in ["party", "trainer"]:
			var max_index: int = 5
			if key_event.keycode in [KEY_UP, KEY_W]: selected = (selected + max_index) % (max_index + 1)
			elif key_event.keycode in [KEY_DOWN, KEY_S]: selected = (selected + 1) % (max_index + 1)
			elif key_event.keycode in [KEY_ENTER, KEY_SPACE, KEY_Z]:
				if mode == "party": _switch_party(selected)
				else: _use_trainer_action(selected)
			queue_redraw()
			return
		if key_event.keycode in [KEY_LEFT, KEY_A]: selected = maxi(0, selected - 1)
		elif key_event.keycode in [KEY_RIGHT, KEY_D]: selected = mini(3, selected + 1)
		elif key_event.keycode in [KEY_UP, KEY_W]: selected = maxi(0, selected - 2)
		elif key_event.keycode in [KEY_DOWN, KEY_S]: selected = mini(3, selected + 2)
		elif key_event.keycode in [KEY_ENTER, KEY_SPACE, KEY_Z]:
			if mode == "root": _activate_root()
			elif mode == "moves": _queue_move(selected)
			elif mode == "bag": _use_bag(selected)
		queue_redraw()
	elif event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event as InputEventScreenTouch
		if not touch.pressed:
			return
		var pos: Vector2 = touch.position
		if battle_done:
			if Rect2(44, 654, 272, 62).has_point(pos):
				_finish_battle()
			return
		if mode in ["party", "trainer"]:
			for i: int in range(6):
				if _list_rect(i).has_point(pos):
					selected = i
					if mode == "party": _switch_party(i)
					else: _use_trainer_action(i)
					return
		for i: int in range(4):
			if _root_rect(i).has_point(pos):
				selected = i
				if mode == "root": _activate_root()
				elif mode == "moves": _queue_move(i)
				elif mode == "bag": _use_bag(i)
				return
