extends Control

signal finished(result: Dictionary)

const DB = preload("res://scripts/data/monster_db.gd")
const ART = preload("res://scripts/data/monster_art.gd")
const PROGRESSION = preload("res://scripts/data/progression_db.gd")

var font: Font
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var starter: String = "Luzik"
var player_data: Dictionary = {}
var enemy_data: Dictionary = {}
var player_tex: Texture2D
var enemy_tex: Texture2D
var player_hp: int = 28
var player_max_hp: int = 28
var enemy_hp: int = 23
var enemy_max_hp: int = 23
var enemy_level: int = 3
var trainer_level: int = 1
var mode: String = "root"
var selected: int = 0
var log_text: String = ""
var battle_done: bool = false
var result_data: Dictionary = {}
var player_guard: bool = false
var enemy_guard: bool = false
var inventory: Dictionary = {"capture_modules": 5, "regenerators": 3, "sondas": 1}
var talents: Dictionary = {}
var bonuses: Dictionary = {}
var flash_enemy_until: int = 0
var flash_player_until: int = 0
var elapsed: float = 0.0

func setup(starter_name: String, current_hp: int, level: int, enemy_name: String = "Wahlik", encounter_level: int = 3, battle_inventory: Dictionary = {}, talent_levels: Dictionary = {}) -> void:
	starter = starter_name
	trainer_level = maxi(1, level)
	player_data = DB.get_monster(starter)
	enemy_data = DB.get_monster(enemy_name)
	talents = PROGRESSION.default_talents()
	for path_id: String in PROGRESSION.path_ids():
		talents[path_id] = maxi(0, int(talent_levels.get(path_id, 0)))
	bonuses = PROGRESSION.bonuses(talents)
	if not battle_inventory.is_empty():
		inventory = battle_inventory.duplicate(true)
	player_max_hp = int(player_data["max_hp"]) + int(bonuses.get("max_hp_bonus", 0))
	player_hp = clampi(current_hp, 1, player_max_hp)
	enemy_level = maxi(1, encounter_level)
	var enemy_base_hp: int = int(enemy_data["max_hp"])
	enemy_max_hp = enemy_base_hp + maxi(0, enemy_level - 3)
	enemy_hp = enemy_max_hp

func _ready() -> void:
	font = ThemeDB.fallback_font
	rng.randomize()
	if player_data.is_empty():
		player_data = DB.get_monster(starter)
	if enemy_data.is_empty():
		enemy_data = DB.first_zone_enemy()
	if bonuses.is_empty():
		bonuses = PROGRESSION.bonuses(PROGRESSION.default_talents())
	player_tex = ART.texture_for(starter)
	enemy_tex = ART.texture_for(str(enemy_data["name"]))
	log_text = "Dziki %s Lv.%d pojawia się w polu rezonansu!" % [str(enemy_data["name"]), enemy_level]
	queue_redraw()

func _process(delta: float) -> void:
	elapsed += delta
	queue_redraw()

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

func _draw_background() -> void:
	draw_rect(Rect2(0, 0, 360, 800), Color("09191f"))
	for y: int in range(70, 490, 28):
		var alpha: float = 0.035 + 0.02 * sin(elapsed * 1.8 + float(y))
		draw_line(Vector2(0, y), Vector2(360, y), Color(0.25, 0.85, 0.78, alpha), 1.0)
	draw_circle(Vector2(286, 236), 110.0, Color(0.08, 0.27, 0.28, 0.18))
	draw_circle(Vector2(82, 434), 118.0, Color(0.09, 0.24, 0.31, 0.18))
	draw_string(font, Vector2(18, 27), "POLE REZONANSU · DZIKIE STARCIE", HORIZONTAL_ALIGNMENT_LEFT, 320, 10, Color("5fcfc9"))

func _draw_enemy_side() -> void:
	var panel: Rect2 = Rect2(18, 48, 204, 72)
	draw_rect(panel, Color("102a32"))
	draw_rect(panel, Color("315761"), false, 2.0)
	draw_string(font, Vector2(30, 72), str(enemy_data["name"]), HORIZONTAL_ALIGNMENT_LEFT, 120, 16, Color("f0faf8"))
	draw_string(font, Vector2(158, 71), "Lv.%d" % enemy_level, HORIZONTAL_ALIGNMENT_RIGHT, 50, 10, Color("9db9bc"))
	_draw_hp_bar(Rect2(30, 88, 176, 12), enemy_hp, enemy_max_hp)
	draw_string(font, Vector2(136, 112), "%d/%d" % [enemy_hp, enemy_max_hp], HORIZONTAL_ALIGNMENT_RIGHT, 70, 9, Color("8ca8aa"))
	var art_rect: Rect2 = Rect2(188, 132, 156, 117)
	draw_rect(Rect2(184, 128, 164, 125), Color("16323a"))
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
	var panel: Rect2 = Rect2(144, 392, 200, 86)
	draw_rect(panel, Color("102a32"))
	draw_rect(panel, Color("315761"), false, 2.0)
	draw_string(font, Vector2(156, 418), starter, HORIZONTAL_ALIGNMENT_LEFT, 120, 16, Color("f0faf8"))
	draw_string(font, Vector2(284, 417), "TR %d" % trainer_level, HORIZONTAL_ALIGNMENT_RIGHT, 46, 10, Color("9db9bc"))
	_draw_hp_bar(Rect2(156, 432, 174, 13), player_hp, player_max_hp)
	draw_string(font, Vector2(240, 463), "HP %d/%d" % [player_hp, player_max_hp], HORIZONTAL_ALIGNMENT_RIGHT, 90, 9, Color("9db9bc"))

func _draw_hp_bar(rect: Rect2, hp: int, max_hp: int) -> void:
	draw_rect(rect, Color("08171d"))
	var ratio: float = clampf(float(hp) / float(max_hp), 0.0, 1.0)
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
	var labels: Array[String] = ["ATAK", "SOMASKANY", "PLECAK", "UCIECZKA"]
	for i: int in range(4):
		var r: Rect2 = _root_rect(i)
		var active: bool = i == selected
		draw_rect(r, Color("18424b") if active else Color("0e2831"))
		draw_rect(r, Color("50e0d9") if active else Color("2d5059"), false, 2.0)
		draw_string(font, Vector2(r.position.x + 6, r.position.y + 34), labels[i], HORIZONTAL_ALIGNMENT_CENTER, r.size.x - 12, 12, Color("f0fffc") if active else Color("a9c2c3"))

func _draw_move_menu() -> void:
	var moves: Array = player_data["moves"]
	for i: int in range(4):
		var r: Rect2 = _root_rect(i)
		var move_data: Dictionary = moves[i]
		var active: bool = i == selected
		draw_rect(r, Color("193f49") if active else Color("0e2831"))
		draw_rect(r, player_data["accent"] if active else Color("2d5059"), false, 2.0)
		draw_string(font, Vector2(r.position.x + 9, r.position.y + 22), str(move_data["name"]), HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 18, 10, Color("effffc"))
		var tag: String = "PWR %d · %d%%" % [int(move_data["power"]), int(round(float(move_data.get("accuracy", 1.0)) * 100.0))]
		if str(move_data["kind"]) == "heal":
			tag = "REGEN · +%d" % (int(move_data["power"]) + int(bonuses.get("heal_bonus", 0)))
		if str(move_data["kind"]) == "guard":
			tag = "OBRONA · PRI %d" % int(move_data.get("priority", 0))
		draw_string(font, Vector2(r.position.x + 9, r.position.y + 41), tag, HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 18, 8, Color("7ba5a7"))

func _draw_bag_menu() -> void:
	var labels: Array[String] = [
		"MODUŁ CHWYTU ×%d" % _inventory_count("capture_modules"),
		"REGENERATOR ×%d" % _inventory_count("regenerators"),
		"WRÓĆ",
		"ANALIZA POLA"
	]
	for i: int in range(4):
		var r: Rect2 = _root_rect(i)
		var active: bool = i == selected
		draw_rect(r, Color("193f49") if active else Color("0e2831"))
		draw_rect(r, Color("e4c965") if active else Color("2d5059"), false, 2.0)
		draw_string(font, Vector2(r.position.x + 6, r.position.y + 31), labels[i], HORIZONTAL_ALIGNMENT_CENTER, r.size.x - 12, 10, Color("effffc"))

func _draw_continue() -> void:
	var r: Rect2 = Rect2(44, 654, 272, 62)
	draw_rect(r, Color("17464e"))
	draw_rect(r, Color("54e4dd"), false, 2.0)
	draw_string(font, Vector2(60, 692), "WRÓĆ DO ŚWIATA", HORIZONTAL_ALIGNMENT_CENTER, 240, 13, Color("f0fffc"))

func _root_rect(index: int) -> Rect2:
	var col: int = index % 2
	var row: int = int(index / 2)
	return Rect2(16 + col * 166, 628 + row * 68, 160, 58)

func _wrap(text: String, width: int) -> Array[String]:
	var out: Array[String] = []
	var current: String = ""
	for word: String in text.split(" "):
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
			log_text = "Zmiana aktywnego partnera będzie obsługiwana przez warstwę drużyny. Aktualnie walczy %s." % starter
		2:
			mode = "bag"
			selected = 0
		3:
			_try_escape()
	queue_redraw()

func _use_move(index: int) -> void:
	var moves: Array = player_data["moves"]
	var move_data: Dictionary = moves[index]
	var kind: String = str(move_data["kind"])
	var lines: Array[String] = []
	var accuracy: float = clampf(float(move_data.get("accuracy", 1.0)), 0.0, 1.0)
	if rng.randf() > accuracy:
		lines.append("%s używa %s, ale ruch nie trafia." % [starter, str(move_data["name"])])
		_enemy_turn(lines)
		mode = "root"
		selected = 0
		log_text = "\n".join(lines)
		queue_redraw()
		return
	if kind == "attack":
		var damage: int = maxi(1, int(move_data["power"]) + int(bonuses.get("attack_bonus", 0)) + rng.randi_range(-2, 2))
		if enemy_guard:
			damage = maxi(1, int(ceil(float(damage) * 0.55)))
			enemy_guard = false
		enemy_hp = maxi(0, enemy_hp - damage)
		flash_enemy_until = Time.get_ticks_msec() + 170
		lines.append("%s używa %s: -%d HP." % [starter, str(move_data["name"]), damage])
	elif kind == "heal":
		var heal: int = int(move_data["power"]) + 4 + int(bonuses.get("heal_bonus", 0))
		var before: int = player_hp
		player_hp = mini(player_max_hp, player_hp + heal)
		lines.append("%s: odzyskano %d HP." % [str(move_data["name"]), player_hp - before])
	elif kind == "guard":
		player_guard = true
		lines.append("%s przygotowuje osłonę na następne trafienie." % starter)
	if enemy_hp <= 0:
		_win(lines)
		return
	_enemy_turn(lines)
	mode = "root"
	selected = 0
	log_text = "\n".join(lines)
	queue_redraw()

func _enemy_turn(lines: Array[String]) -> void:
	var moves: Array = enemy_data["moves"]
	var move_data: Dictionary = moves[rng.randi_range(0, moves.size() - 1)]
	var kind: String = str(move_data.get("kind", "attack"))
	if kind == "guard":
		enemy_guard = true
		lines.append("%s używa %s i wzmacnia osłonę." % [str(enemy_data["name"]), str(move_data["name"])])
		return
	var accuracy: float = clampf(float(move_data.get("accuracy", 1.0)), 0.0, 1.0)
	if rng.randf() > accuracy:
		lines.append("%s używa %s, ale pudłuje." % [str(enemy_data["name"]), str(move_data["name"])])
		return
	var level_bonus: int = maxi(0, int(enemy_level / 4))
	var damage: int = maxi(1, int(move_data["power"]) + level_bonus + rng.randi_range(-1, 2))
	if player_guard:
		damage = maxi(1, int(ceil(float(damage) * 0.45)))
		player_guard = false
	player_hp = maxi(0, player_hp - damage)
	flash_player_until = Time.get_ticks_msec() + 170
	lines.append("%s odpowiada %s: -%d HP." % [str(enemy_data["name"]), str(move_data["name"]), damage])
	if player_hp <= 0:
		battle_done = true
		result_data = _make_result("loss", 0)
		result_data["player_hp"] = 1
		lines.append("Rezonans partnera załamał się. Powrót awaryjny do Vela.")

func _try_escape() -> void:
	var chance: float = clampf(0.70 + float(bonuses.get("escape_bonus", 0.0)), 0.10, 0.95)
	if rng.randf() < chance:
		battle_done = true
		result_data = _make_result("escape", 0)
		log_text = "Udało się bezpiecznie wycofać z pola rezonansu."
	else:
		var lines: Array[String] = ["%s blokuje drogę ucieczki!" % str(enemy_data["name"])]
		_enemy_turn(lines)
		log_text = "\n".join(lines)
	queue_redraw()

func _use_bag(index: int) -> void:
	if index == 0:
		if _inventory_count("capture_modules") <= 0:
			log_text = "Brak modułów chwytu."
			return
		_set_inventory_count("capture_modules", _inventory_count("capture_modules") - 1)
		var missing: float = 1.0 - float(enemy_hp) / float(enemy_max_hp)
		var base_rate: float = float(enemy_data.get("capture_rate", 0.30))
		var chance: float = clampf(base_rate + missing * 0.52 + float(bonuses.get("capture_bonus", 0.0)), 0.05, 0.95)
		if rng.randf() < chance:
			battle_done = true
			result_data = _make_result("capture", int(enemy_data.get("exp_yield", 12)) + 4, str(enemy_data["name"]))
			log_text = "Moduł zsynchronizował sygnał. %s dołącza do kolekcji SOMADEX!" % str(enemy_data["name"])
		else:
			var lines: Array[String] = ["Moduł nie utrzymał synchronizacji (%d%% szansy)." % int(round(chance * 100.0))]
			_enemy_turn(lines)
			log_text = "\n".join(lines)
	elif index == 1:
		if _inventory_count("regenerators") <= 0:
			log_text = "Brak Regeneratorów."
			return
		_set_inventory_count("regenerators", _inventory_count("regenerators") - 1)
		var before: int = player_hp
		var heal: int = 10 + int(bonuses.get("item_heal_bonus", 0))
		player_hp = mini(player_max_hp, player_hp + heal)
		var lines: Array[String] = ["Regenerator: +%d HP." % (player_hp - before)]
		_enemy_turn(lines)
		log_text = "\n".join(lines)
	elif index == 2:
		mode = "root"
		selected = 0
	elif index == 3:
		var ratio: int = int(round(100.0 * float(enemy_hp) / float(enemy_max_hp)))
		var rarity: String = str(enemy_data.get("rarity", "nieznana"))
		log_text = "Analiza: %s · %s · rzadkość %s · kondycja %d%%. Osłabienie zwiększa szansę chwytu." % [str(enemy_data["name"]), str(enemy_data["type"]), rarity, ratio]
	queue_redraw()

func _win(lines: Array[String]) -> void:
	battle_done = true
	var xp: int = int(enemy_data.get("exp_yield", 12)) + maxi(0, enemy_level - 2)
	result_data = _make_result("win", xp)
	lines.append("%s traci synchronizację. Zwycięstwo! +%d EXP trenera." % [str(enemy_data["name"]), xp])
	log_text = "\n".join(lines)

func _make_result(outcome: String, xp: int, captured_name: String = "") -> Dictionary:
	return {
		"outcome": outcome,
		"player_hp": player_hp,
		"xp": maxi(0, xp),
		"seen_name": str(enemy_data.get("name", "")),
		"captured_name": captured_name,
		"inventory": inventory.duplicate(true)
	}

func _inventory_count(key: String) -> int:
	return maxi(0, int(inventory.get(key, 0)))

func _set_inventory_count(key: String, value: int) -> void:
	inventory[key] = maxi(0, value)

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
		if key_event.keycode in [KEY_LEFT, KEY_A]: selected = maxi(0, selected - 1)
		elif key_event.keycode in [KEY_RIGHT, KEY_D]: selected = mini(3, selected + 1)
		elif key_event.keycode in [KEY_UP, KEY_W]: selected = maxi(0, selected - 2)
		elif key_event.keycode in [KEY_DOWN, KEY_S]: selected = mini(3, selected + 2)
		elif key_event.keycode in [KEY_ESCAPE, KEY_X] and mode != "root":
			mode = "root"
			selected = 0
		elif key_event.keycode in [KEY_ENTER, KEY_SPACE, KEY_Z]:
			if mode == "root": _activate_root()
			elif mode == "moves": _use_move(selected)
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
		for i: int in range(4):
			if _root_rect(i).has_point(pos):
				selected = i
				if mode == "root": _activate_root()
				elif mode == "moves": _use_move(i)
				elif mode == "bag": _use_bag(i)
				return
