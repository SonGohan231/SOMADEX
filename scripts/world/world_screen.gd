extends Control

signal menu_requested(tile: Vector2i)
signal battle_requested(tile: Vector2i)
signal station_requested(tile: Vector2i)
signal zone_change_requested(zone_id: String, spawn_tile: Vector2i)
signal dialogue_flag_requested(flag_id: String)

const ZONES = preload("res://scripts/data/zone_db.gd")
const DIALOGUE = preload("res://scripts/data/dialogue_db.gd")
const TILE_ART = preload("res://scripts/world/vela_tile_art.gd")

const TILE: int = 24
const WORLD_TOP: int = 56
const COLS: int = 15
const ROWS: int = 23

var map_rows: Array[String] = []
var font: Font
var partner_name: String = "Luzik"
var trainer_level: int = 1
var player_tile: Vector2i = Vector2i(7, 20)
var facing: Vector2i = Vector2i.UP
var player_px: Vector2 = Vector2.ZERO
var from_px: Vector2 = Vector2.ZERO
var to_px: Vector2 = Vector2.ZERO
var moving: bool = false
var move_t: float = 0.0
var steps_since_encounter: int = 0
var dialog: String = ""
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var haptics: bool = true
var elapsed: float = 0.0
var zone_id: String = "vela"
var quest_short: String = ""
var dialogue_flags: Dictionary = {}

func setup(
	active_partner: String,
	start_tile: Vector2i,
	level: int,
	use_haptics: bool,
	current_zone: String,
	current_quest: String,
	flags: Dictionary = {}
) -> void:
	partner_name = active_partner
	player_tile = start_tile
	trainer_level = maxi(1, level)
	haptics = use_haptics
	zone_id = current_zone if ZONES.has_zone(current_zone) else "vela"
	quest_short = current_quest
	dialogue_flags = flags.duplicate(true)
	map_rows = ZONES.map_rows(zone_id)
	if map_rows.size() != ROWS:
		map_rows = ZONES.map_rows("vela")

func _ready() -> void:
	font = ThemeDB.fallback_font
	rng.randomize()
	if map_rows.is_empty():
		map_rows = ZONES.map_rows(zone_id)
	player_px = _tile_to_px(player_tile)
	from_px = player_px
	to_px = player_px
	queue_redraw()

func get_player_tile() -> Vector2i:
	return player_tile

func _process(delta: float) -> void:
	elapsed += delta
	if moving:
		move_t += delta * 7.5
		var t: float = minf(move_t, 1.0)
		var smooth: float = t * t * (3.0 - 2.0 * t)
		player_px = from_px.lerp(to_px, smooth)
		if t >= 1.0:
			moving = false
			player_tile = _px_to_tile(to_px)
			player_px = to_px
			_after_step()
	queue_redraw()

func _draw() -> void:
	_draw_header()
	for y: int in range(ROWS):
		for x: int in range(COLS):
			_draw_tile(Vector2i(x, y), _tile_code(Vector2i(x, y)))
	_draw_player()
	_draw_controls()
	if not dialog.is_empty():
		_draw_dialog()

func _draw_header() -> void:
	draw_rect(Rect2(0, 0, 360, 56), Color("081820"))
	draw_rect(Rect2(0, 52, 360, 4), Color("1b746f"))
	draw_string(font, Vector2(14, 21), ZONES.zone_name(zone_id).to_upper(), HORIZONTAL_ALIGNMENT_LEFT, 210, 12, Color("e8fffb"))
	draw_string(font, Vector2(14, 40), ZONES.biome(zone_id), HORIZONTAL_ALIGNMENT_LEFT, 210, 8, Color("769fa1"))
	draw_string(font, Vector2(234, 20), "TR Lv.%d" % trainer_level, HORIZONTAL_ALIGNMENT_RIGHT, 112, 9, Color("68ddd6"))
	draw_string(font, Vector2(234, 39), partner_name, HORIZONTAL_ALIGNMENT_RIGHT, 112, 8, Color("b7d1d2"))
	if not quest_short.is_empty():
		draw_string(font, Vector2(14, 51), quest_short, HORIZONTAL_ALIGNMENT_LEFT, 320, 6, Color("8cb7b6"))

func _draw_tile(tile: Vector2i, code: String) -> void:
	var p: Vector2 = Vector2(tile.x * TILE, WORLD_TOP + tile.y * TILE)
	var r: Rect2 = Rect2(p, Vector2(TILE, TILE))
	var base_code: String = code
	if code == "N":
		base_code = "G"
	var texture: Texture2D = TILE_ART.texture_for(base_code)
	if texture != null:
		draw_texture_rect(texture, r, false)
	else:
		draw_rect(r, Color("4f9b5f"))
	if code == "N":
		_draw_npc(p)
	elif code == "F":
		var pulse: float = 0.65 + 0.25 * sin(elapsed * 2.0 + float(tile.x + tile.y))
		draw_circle(p + Vector2(18, 7), 1.0, Color(0.95, 0.84, 0.46, pulse))

func _draw_npc(p: Vector2) -> void:
	draw_rect(Rect2(p + Vector2(8, 4), Vector2(8, 7)), Color("e5bc97"))
	draw_rect(Rect2(p + Vector2(6, 11), Vector2(12, 9)), Color("824f98"))
	draw_rect(Rect2(p + Vector2(7, 2), Vector2(10, 4)), Color("4e345e"))
	draw_rect(Rect2(p + Vector2(7, 20), Vector2(4, 4)), Color("28313e"))
	draw_rect(Rect2(p + Vector2(13, 20), Vector2(4, 4)), Color("28313e"))

func _draw_player() -> void:
	var bob: float = 1.0 if moving and int(Time.get_ticks_msec() / 100) % 2 == 0 else 0.0
	var p: Vector2 = player_px + Vector2(3, 1 - bob)
	_draw_pixel_shadow(p + Vector2(9, 20))
	draw_rect(Rect2(p + Vector2(5, 3), Vector2(8, 6)), Color("efc09a"))
	draw_rect(Rect2(p + Vector2(4, 0), Vector2(10, 4)), Color("31c9c2"))
	draw_rect(Rect2(p + Vector2(3, 9), Vector2(12, 8)), Color("173b55"))
	draw_rect(Rect2(p + Vector2(4, 17), Vector2(4, 5)), Color("202b38"))
	draw_rect(Rect2(p + Vector2(10, 17), Vector2(4, 5)), Color("202b38"))
	if moving:
		if int(Time.get_ticks_msec() / 90) % 2 == 0:
			draw_rect(Rect2(p + Vector2(3, 19), Vector2(4, 3)), Color("121922"))
		else:
			draw_rect(Rect2(p + Vector2(11, 19), Vector2(4, 3)), Color("121922"))
	var eye: Vector2 = p + Vector2(9, 7) + Vector2(facing) * 2.0
	draw_rect(Rect2(eye, Vector2(1, 1)), Color("1c2934"))

func _draw_pixel_shadow(center: Vector2) -> void:
	var c: Color = Color(0.02, 0.08, 0.09, 0.35)
	draw_rect(Rect2(center - Vector2(8, 1), Vector2(16, 2)), c)
	draw_rect(Rect2(center - Vector2(6, 2), Vector2(12, 4)), c)

func _draw_controls() -> void:
	draw_rect(Rect2(0, 608, 360, 192), Color("06151c"))
	draw_line(Vector2(0, 608), Vector2(360, 608), Color("1d555d"), 2.0)
	var keys: Array[String] = ["up", "left", "down", "right"]
	var arrows: Dictionary = {"up": "▲", "left": "◀", "down": "▼", "right": "▶"}
	for key: String in keys:
		var rr: Rect2 = _dpad_rect(key)
		draw_rect(rr, Color("132d36"))
		draw_rect(rr, Color("2b5b64"), false, 2.0)
		draw_string(font, rr.position + Vector2(7, 26), str(arrows[key]), HORIZONTAL_ALIGNMENT_CENTER, 26, 15, Color("a6cece"))
	var a: Rect2 = _a_rect()
	draw_circle(a.get_center(), 34.0, Color("174b50"))
	draw_circle(a.get_center(), 34.0, Color("51ddd6"), false, 2.0)
	draw_string(font, a.get_center() + Vector2(-26, 6), "A", HORIZONTAL_ALIGNMENT_CENTER, 52, 20, Color("eafffc"))
	draw_string(font, Vector2(242, 758), "AKCJA", HORIZONTAL_ALIGNMENT_CENTER, 80, 9, Color("6c9699"))
	var m: Rect2 = _menu_rect()
	draw_rect(m, Color("152f39"))
	draw_rect(m, Color("315d67"), false, 2.0)
	draw_string(font, m.position + Vector2(4, 27), "MENU", HORIZONTAL_ALIGNMENT_CENTER, m.size.x - 8, 11, Color("d5e9e8"))

func _draw_dialog() -> void:
	var r: Rect2 = Rect2(16, 494, 328, 110)
	draw_rect(r, Color("081c24"))
	draw_rect(r, Color("5be3dc"), false, 2.0)
	var lines: Array[String] = _wrap(dialog, 43)
	for i: int in range(mini(4, lines.size())):
		draw_string(font, Vector2(30, 523 + i * 19), lines[i], HORIZONTAL_ALIGNMENT_LEFT, 300, 10, Color("e4f4f1"))
	draw_string(font, Vector2(310, 590), "▼", HORIZONTAL_ALIGNMENT_CENTER, 20, 10, Color("6ddbd5"))

func _dpad_rect(which: String) -> Rect2:
	match which:
		"up": return Rect2(72, 634, 40, 40)
		"left": return Rect2(32, 674, 40, 40)
		"down": return Rect2(72, 714, 40, 40)
		_: return Rect2(112, 674, 40, 40)

func _a_rect() -> Rect2:
	return Rect2(244, 650, 72, 72)

func _menu_rect() -> Rect2:
	return Rect2(226, 744, 108, 38)

func _tile_to_px(tile: Vector2i) -> Vector2:
	return Vector2(tile.x * TILE, WORLD_TOP + tile.y * TILE)

func _px_to_tile(px: Vector2) -> Vector2i:
	return Vector2i(int(round(px.x / TILE)), int(round((px.y - WORLD_TOP) / TILE)))

func _tile_code(tile: Vector2i) -> String:
	if tile.x < 0 or tile.x >= COLS or tile.y < 0 or tile.y >= ROWS:
		return "T"
	return map_rows[tile.y].substr(tile.x, 1)

func _walkable(tile: Vector2i) -> bool:
	return _tile_code(tile) in ["P", "G", "F", "D", "E", "B", "A"]

func _request_move(dir: Vector2i) -> void:
	if moving or not dialog.is_empty():
		return
	facing = dir
	var target: Vector2i = player_tile + dir
	if not _walkable(target):
		return
	from_px = _tile_to_px(player_tile)
	to_px = _tile_to_px(target)
	move_t = 0.0
	moving = true
	_haptic(8)

func _after_step() -> void:
	var exit_data: Dictionary = ZONES.exit_at(zone_id, player_tile)
	if not exit_data.is_empty():
		zone_change_requested.emit(str(exit_data.get("zone_id", "vela")), ZONES.exit_spawn(exit_data))
		return
	steps_since_encounter += 1
	var code: String = _tile_code(player_tile)
	if code in ["G", "F"] and steps_since_encounter >= 4 and rng.randf() < 0.18:
		steps_since_encounter = 0
		battle_requested.emit(player_tile)

func _interact() -> void:
	if moving:
		return
	var target: Vector2i = player_tile + facing
	var code: String = _tile_code(target)
	if code == "C":
		station_requested.emit(player_tile)
	var text: String = DIALOGUE.text(zone_id, code, dialogue_flags)
	if not text.is_empty():
		dialog = text
		var flag_id: String = DIALOGUE.flag_for(zone_id, code)
		if not flag_id.is_empty():
			dialogue_flags[flag_id] = true
			dialogue_flag_requested.emit(flag_id)
	queue_redraw()

func _wrap(text: String, width: int) -> Array[String]:
	var out: Array[String] = []
	for paragraph: String in text.split("\n"):
		var current: String = ""
		for word: String in paragraph.split(" "):
			var candidate: String = word if current.is_empty() else current + " " + word
			if candidate.length() > width and not current.is_empty():
				out.append(current)
				current = word
			else:
				current = candidate
		if not current.is_empty():
			out.append(current)
	return out

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if not key_event.pressed or key_event.echo:
			return
		if not dialog.is_empty():
			if key_event.keycode in [KEY_ENTER, KEY_SPACE, KEY_Z, KEY_ESCAPE, KEY_X]:
				dialog = ""
			return
		if key_event.keycode in [KEY_UP, KEY_W]: _request_move(Vector2i.UP)
		elif key_event.keycode in [KEY_DOWN, KEY_S]: _request_move(Vector2i.DOWN)
		elif key_event.keycode in [KEY_LEFT, KEY_A]: _request_move(Vector2i.LEFT)
		elif key_event.keycode in [KEY_RIGHT, KEY_D]: _request_move(Vector2i.RIGHT)
		elif key_event.keycode in [KEY_ENTER, KEY_SPACE, KEY_Z]: _interact()
		elif key_event.keycode in [KEY_ESCAPE, KEY_X, KEY_M]: menu_requested.emit(player_tile)
	elif event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event as InputEventScreenTouch
		if not touch.pressed:
			return
		_haptic(6)
		if not dialog.is_empty():
			dialog = ""
			return
		var pos: Vector2 = touch.position
		if _dpad_rect("up").has_point(pos): _request_move(Vector2i.UP)
		elif _dpad_rect("down").has_point(pos): _request_move(Vector2i.DOWN)
		elif _dpad_rect("left").has_point(pos): _request_move(Vector2i.LEFT)
		elif _dpad_rect("right").has_point(pos): _request_move(Vector2i.RIGHT)
		elif _a_rect().has_point(pos): _interact()
		elif _menu_rect().has_point(pos): menu_requested.emit(player_tile)

func _haptic(duration: int) -> void:
	if haptics:
		Input.vibrate_handheld(duration)
