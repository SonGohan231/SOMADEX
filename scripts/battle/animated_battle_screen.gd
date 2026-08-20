extends "res://scripts/battle/battle_screen.gd"

const SPRITES = preload("res://scripts/battle/battle_sprite_art.gd")
const VISUAL_QUEUE = preload("res://scripts/battle/battle_visual_queue.gd")

var visual_queue = VISUAL_QUEUE.new()
var animation_clock: float = 0.0

func _ready() -> void:
	super._ready()
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func _process(delta: float) -> void:
	animation_clock += delta
	visual_queue.tick(delta)
	super._process(delta)

func _unhandled_input(event: InputEvent) -> void:
	if visual_queue.blocks_input():
		return
	super._unhandled_input(event)

func _execute_pending_move(lines: Array[String]) -> void:
	var move_data: Dictionary = {}
	var moves: Array = player_data.get("moves", []) as Array
	if pending_move_index >= 0 and pending_move_index < moves.size():
		move_data = moves[pending_move_index] as Dictionary
	var before_enemy: int = enemy_hp
	super._execute_pending_move(lines)
	if move_data.is_empty():
		return
	var move_type: String = str(move_data.get("move_type", "REZONANS"))
	var kind: String = str(move_data.get("kind", "attack"))
	visual_queue.enqueue("player", _visual_state_for_move(move_data), move_type)
	if kind == "attack" and enemy_hp < before_enemy:
		visual_queue.enqueue("enemy", "hurt", move_type, float(before_enemy - enemy_hp) / float(maxi(1, enemy_max_hp)) + 0.7)
		if enemy_hp <= 0 and before_enemy > 0:
			visual_queue.enqueue("enemy", "faint", move_type)

func _enemy_turn(lines: Array[String]) -> void:
	if enemy_hp <= 0:
		return
	var predicted: Dictionary = {}
	var moves: Array = enemy_data.get("moves", []) as Array
	if not moves.is_empty():
		var probe := RandomNumberGenerator.new()
		probe.state = rng.state
		predicted = moves[probe.randi_range(0, moves.size() - 1)] as Dictionary
	var before_player: int = player_hp
	super._enemy_turn(lines)
	if predicted.is_empty():
		return
	var move_type: String = str(predicted.get("move_type", "REZONANS"))
	visual_queue.enqueue("enemy", _visual_state_for_move(predicted), move_type)
	if player_hp < before_player:
		visual_queue.enqueue("player", "hurt", move_type, float(before_player - player_hp) / float(maxi(1, player_max_hp)) + 0.7)
		if player_hp <= 0 and before_player > 0:
			visual_queue.enqueue("player", "faint", move_type)

func _end_round(lines: Array[String]) -> void:
	var before_player: int = player_hp
	var before_enemy: int = enemy_hp
	super._end_round(lines)
	if player_hp < before_player and player_hp > 0:
		visual_queue.enqueue("player", "hurt", "STATUS")
	elif player_hp > before_player:
		visual_queue.enqueue("player", "special", "SUPPORT")
	if enemy_hp < before_enemy and enemy_hp > 0:
		visual_queue.enqueue("enemy", "hurt", "STATUS")
	elif enemy_hp > before_enemy:
		visual_queue.enqueue("enemy", "special", "SUPPORT")

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
	_draw_actor_visual("enemy", str(enemy_data.get("name", "Wahlik")), art_rect, enemy_tex, true)
	var flash: bool = Time.get_ticks_msec() < flash_enemy_until
	draw_rect(art_rect, Color(1, 1, 1, 0.32) if flash else Color(0.32, 0.86, 0.80, 0.26), false, 2.0)

func _draw_player_side() -> void:
	var art_rect: Rect2 = Rect2(16, 304, 170, 128)
	draw_rect(Rect2(12, 300, 178, 136), Color("16323a"))
	_draw_actor_visual("player", _active_name(), art_rect, player_tex, false)
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

func _draw_actor_visual(actor: String, creature_name: String, base_rect: Rect2, fallback: Texture2D, mirror_x: bool) -> void:
	var state: String = visual_queue.state_for(actor)
	var progress: float = visual_queue.progress_for(actor)
	var frame: int = _animation_frame(state, progress)
	var texture: Texture2D = SPRITES.frame_texture(creature_name, state, frame)
	if texture == null:
		texture = fallback
	if texture == null:
		return
	var rect: Rect2 = _animated_rect(actor, base_rect, state, progress)
	var modulate := Color.WHITE
	if state == "faint":
		modulate.a = 1.0 - progress
	elif state == "hurt":
		modulate = Color(1.0, 0.72, 0.72, 1.0)
	if mirror_x:
		var center_x: float = rect.position.x + rect.size.x * 0.5
		draw_set_transform(Vector2(center_x * 2.0, 0.0), 0.0, Vector2(-1.0, 1.0))
		draw_texture_rect(texture, rect, false, modulate)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	else:
		draw_texture_rect(texture, rect, false, modulate)
	_draw_move_fx(actor, base_rect)

func _animation_frame(state: String, progress: float) -> int:
	if state == "idle":
		return int(floor(animation_clock * 6.0)) % SPRITES.FRAME_COUNT
	return clampi(int(floor(progress * float(SPRITES.FRAME_COUNT))), 0, SPRITES.FRAME_COUNT - 1)

func _animated_rect(actor: String, base_rect: Rect2, state: String, progress: float) -> Rect2:
	var rect: Rect2 = base_rect
	if state == "idle":
		rect.position.y += sin(animation_clock * 3.4 + (0.0 if actor == "player" else 1.7)) * 2.5
	elif state == "attack":
		var thrust: float = sin(progress * PI) * 14.0
		rect.position.x += thrust if actor == "player" else -thrust
		rect.position.y -= thrust * 0.25
	elif state == "special":
		var pulse: float = 1.0 + sin(progress * PI) * 0.08
		var old_center: Vector2 = rect.get_center()
		rect.size *= pulse
		rect.position = old_center - rect.size * 0.5
	elif state == "hurt":
		rect.position.x += sin(progress * PI * 8.0) * 5.0 * visual_queue.magnitude_for(actor)
	elif state == "faint":
		rect.position.y += progress * 24.0
		rect.size.y *= 1.0 - progress * 0.28
	return rect

func _draw_move_fx(actor: String, rect: Rect2) -> void:
	var state: String = visual_queue.state_for(actor)
	if state not in ["attack", "special"]:
		return
	var progress: float = visual_queue.progress_for(actor)
	var move_type: String = visual_queue.move_type_for(actor)
	var center: Vector2 = rect.get_center()
	var accent: Color = _fx_color(move_type)
	var radius: float = 14.0 + 38.0 * sin(progress * PI)
	for ring: int in range(3):
		var alpha: float = (0.34 - ring * 0.08) * (1.0 - progress * 0.45)
		draw_arc(center, radius + ring * 9.0, 0.0, TAU, 28, Color(accent.r, accent.g, accent.b, alpha), 2.0)
	var direction: float = 1.0 if actor == "player" else -1.0
	var lead: Vector2 = center + Vector2(direction * (28.0 + progress * 38.0), -14.0 * sin(progress * PI))
	draw_circle(lead, 5.0 + 5.0 * sin(progress * PI), Color(accent.r, accent.g, accent.b, 0.75))
	for i: int in range(4):
		var angle: float = progress * TAU + float(i) * TAU / 4.0
		var p: Vector2 = lead + Vector2(cos(angle), sin(angle)) * (10.0 + i * 3.0)
		draw_circle(p, 2.0, Color(accent.r, accent.g, accent.b, 0.58))

func _fx_color(move_type: String) -> Color:
	match move_type:
		"PHYSICAL": return Color("f0c36c")
		"REZONANS": return Color("59e7df")
		"OSC": return Color("9c7cff")
		"WAVE", "FALA": return Color("5ea9ff")
		"TORSJA": return Color("ca7cf0")
		"KIERUNEK": return Color("8fd0ff")
		"NAPIĘCIE": return Color("ff8f74")
		"ŚLIZG": return Color("71d8a7")
		"STABIL": return Color("c6b47a")
		"CZUCIE": return Color("e6c96f")
		"SUPPORT": return Color("7be6a0")
		"STATUS": return Color("d187ff")
		_: return Color("69d7e8")

func _visual_state_for_move(move_data: Dictionary) -> String:
	var kind: String = str(move_data.get("kind", "attack"))
	if kind != "attack":
		return "special"
	var move_type: String = str(move_data.get("move_type", "PHYSICAL"))
	if move_type == "PHYSICAL":
		return "attack"
	return "special"
