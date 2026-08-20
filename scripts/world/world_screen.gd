extends Control

signal menu_requested(tile: Vector2i)
signal battle_requested(tile: Vector2i)
signal station_requested(tile: Vector2i)

const ZONES = preload("res://scripts/data/zone_db.gd")

const TILE: int = 24
const WORLD_TOP: int = 56
const COLS: int = 15
const ROWS: int = 23

var map_rows: Array[String] = [
	"TTTTTTTTTTTTTTT",
	"TGGGGGGCGGGGGGT",
	"TGGGGGPPPGGGGGT",
	"TGGGGGPPPGGGGGT",
	"TGGHHGPPPGGGGGT",
	"TGGHHNPPPGGGGGT",
	"TGGGGGPPPGGGGGT",
	"TGGGGGPPPGGGGGT",
	"TGGGGGPPPGGGGGT",
	"TGGGGGPPPGGGGGT",
	"TWWWWGPPPGGGGGT",
	"TWWWWGPPPGGGGGT",
	"TWWWWGPPPGGGGGT",
	"TGGGGGPPPGGGGGT",
	"TGGGPPPPPPPGGGT",
	"TGGGPGGGGPGGGGT",
	"TGGGPGGGGPGGGGT",
	"TGGGPPPPPPPGGGT",
	"TGGGGGPPPSGGGGT",
	"TGGGGGPPPGGGGGT",
	"TGGGGGPPPGGGGGT",
	"TGGGGGPPPGGGGGT",
	"TTTTTTTTTTTTTTT"
]

var font: Font
var starter: String = "Luzik"
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
var objective: String = "Znajdź dzikiego Somaskana"

func setup(starter_name: String, start_tile: Vector2i, level: int, use_haptics: bool, world_zone_id: String = "vela", quest_objective: String = "") -> void:
	starter = starter_name
	player_tile = start_tile
	trainer_level = level
	haptics = use_haptics
	zone_id = world_zone_id if ZONES.has_zone(world_zone_id) else "vela"
	objective = quest_objective

func _ready() -> void:
	font = ThemeDB.fallback_font
	rng.randomize()
	player_px = _tile_to_px(player_tile)
	from_px = player_px
	to_px = player_px
	set_process(true)
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
	draw_rect(Rect2(0, 0, 360, 56), Color("0a1f28"))
	draw_line(Vector2(0, 55), Vector2(360, 55), Color("3bd4cd"), 2.0)
	var zone_label: String = ZONES.zone_name(zone_id).to_upper()
	draw_string(font, Vector2(12, 21), zone_label, HORIZONTAL_ALIGNMENT_LEFT, 190, 11, Color("dff8f4"))
	var short_objective: String = "CEL: " + objective
	draw_string(font, Vector2(12, 42), short_objective, HORIZONTAL_ALIGNMENT_LEFT, 218, 8, Color("70a8aa"))
	draw_string(font, Vector2(256, 21), "TR Lv.%d" % trainer_level, HORIZONTAL_ALIGNMENT_RIGHT, 90, 10, Color("61d9d4"))
	draw_string(font, Vector2(256, 42), starter, HORIZONTAL_ALIGNMENT_RIGHT, 90, 9, Color("bcd3d4"))
	for y: int in range(ROWS):
		for x: int in range(COLS):
			_draw_tile(Vector2i(x, y), _tile_code(Vector2i(x, y)))
	_draw_player()
	_draw_controls()
	if not dialog.is_empty():
		_draw_dialog()

func _draw_tile(tile: Vector2i, code: String) -> void:
	var p: Vector2 = Vector2(tile.x * TILE, WORLD_TOP + tile.y * TILE)
	var r: Rect2 = Rect2(p, Vector2(TILE, TILE))
	match code:
		"P":
			draw_rect(r, Color("bda66e"))
			draw_rect(Rect2(p + Vector2(4, 5), Vector2(3, 2)), Color("9b8355"))
			draw_rect(Rect2(p + Vector2(15, 16), Vector2(4, 2)), Color("d5c486"))
		"G":
			draw_rect(r, Color("4d9459"))
			var seed: int = tile.x * 31 + tile.y * 17
			draw_line(p + Vector2(5 + seed % 5, 18), p + Vector2(8 + seed % 5, 13), Color("83c76f"), 1.0)
			draw_line(p + Vector2(15, 19), p + Vector2(13, 15), Color("347744"), 1.0)
		"W":
			draw_rect(r, Color("347f9c"))
			var drift: int = int(elapsed * 10.0 + tile.y * 3) % 8
			draw_line(p + Vector2(drift, 7), p + Vector2(mini(23, drift + 9), 7), Color("6fc1ca"), 1.0)
			draw_line(p + Vector2(9, 17), p + Vector2(20, 17), Color("286a85"), 1.0)
		"T":
			draw_rect(r, Color("315f42"))
			draw_rect(Rect2(p + Vector2(10, 15), Vector2(5, 9)), Color("655239"))
			draw_circle(p + Vector2(12, 10), 9.0, Color("2a7248"))
			draw_circle(p + Vector2(7, 11), 5.0, Color("3b8752"))
		"H":
			draw_rect(r, Color("6f5b4b"))
			draw_rect(Rect2(p + Vector2(2, 4), Vector2(20, 18)), Color("d0b778"))
			draw_rect(Rect2(p + Vector2(0, 2), Vector2(24, 5)), Color("9a5447"))
		"C":
			draw_rect(r, Color("315f42"))
			draw_rect(Rect2(p + Vector2(1, 4), Vector2(22, 19)), Color("d6e5df"))
			draw_rect(Rect2(p + Vector2(4, 0), Vector2(16, 6)), Color("45cfc7"))
			draw_rect(Rect2(p + Vector2(9, 13), Vector2(6, 10)), Color("2b6771"))
		"N":
			draw_rect(r, Color("4d9459"))
			draw_circle(p + Vector2(12, 8), 5.0, Color("e5c6a0"))
			draw_rect(Rect2(p + Vector2(7, 13), Vector2(10, 9)), Color("804f9a"))
		"S":
			draw_rect(r, Color("4d9459"))
			draw_rect(Rect2(p + Vector2(10, 11), Vector2(4, 12)), Color("6d4f31"))
			draw_rect(Rect2(p + Vector2(4, 4), Vector2(16, 10)), Color("d6bd73"))
		_:
			draw_rect(r, Color("4d9459"))

func _draw_player() -> void:
	var bob: float = 1.0 if moving and int(Time.get_ticks_msec() / 100) % 2 == 0 else 0.0
	var p: Vector2 = player_px + Vector2(3, 1 - bob)
	_draw_pixel_shadow(p + Vector2(9, 20))
	draw_rect(Rect2(p + Vector2(5, 2), Vector2(8, 7)), Color("efc09a"))
	draw_rect(Rect2(p + Vector2(4, 0), Vector2(10, 4)), Color("28c9c4"))
	draw_rect(Rect2(p + Vector2(3, 9), Vector2(12, 8)), Color("173b55"))
	draw_rect(Rect2(p + Vector2(4, 17), Vector2(4, 5)), Color("222c3a"))
	draw_rect(Rect2(p + Vector2(10, 17), Vector2(4, 5)), Color("222c3a"))
	var center: Vector2 = p + Vector2(9, 11)
	draw_circle(center + Vector2(facing) * 5.0, 1.5, Color("f5e16d"))

func _draw_pixel_shadow(center: Vector2) -> void:
	var shadow: Color = Color(0.02, 0.08, 0.09, 0.35)
	draw_rect(Rect2(center - Vector2(8, 1), Vector2(16, 2)), shadow)
	draw_rect(Rect2(center - Vector2(6, 2), Vector2(12, 4)), shadow)

func _draw_controls() -> void:
	draw_rect(Rect2(0, 608, 360, 192), Color("07171e"))
	draw_line(Vector2(0, 608), Vector2(360, 608), Color("1c4c56"), 2.0)
	for p: Vector2 in [Vector2(72, 634), Vector2(32, 674), Vector2(72, 714), Vector2(112, 674)]:
		var r: Rect2 = Rect2(p, Vector2(40, 40))
		draw_rect(r, Color("16313b"))
		draw_rect(r, Color("2a5660"), false, 2.0)
	var arrows: Dictionary = {"up": "▲", "left": "◀", "down": "▼", "right": "▶"}
	for key: Variant in arrows.keys():
		var rr: Rect2 = _dpad_rect(str(key))
		draw_string(font, rr.position + Vector2(7, 26), str(arrows[key]), HORIZONTAL_ALIGNMENT_CENTER, 26, 15, Color("9ac6c7"))
	var action_rect: Rect2 = _a_rect()
	draw_circle(action_rect.get_center(), 34, Color("174b50"))
	draw_circle(action_rect.get_center(), 34, Color("51ddd6"), false, 2.0)
	draw_string(font, action_rect.get_center() + Vector2(-26, 6), "A", HORIZONTAL_ALIGNMENT_CENTER, 52, 20, Color("eafffc"))
	draw_string(font, Vector2(242, 758), "AKCJA", HORIZONTAL_ALIGNMENT_CENTER, 80, 9, Color("6c9699"))
	var menu_rect: Rect2 = _menu_rect()
	draw_rect(menu_rect, Color("152f39"))
	draw_rect(menu_rect, Color("315d67"), false, 2.0)
	draw_string(font, Vector2(menu_rect.position.x + 4, menu_rect.position.y + 27), "MENU", HORIZONTAL_ALIGNMENT_CENTER, menu_rect.size.x - 8, 11, Color("d5e9e8"))

func _draw_dialog() -> void:
	var r: Rect2 = Rect2(16, 498, 328, 104)
	draw_rect(r, Color("081c24"))
	draw_rect(r, Color("5be3dc"), false, 2.0)
	var lines: PackedStringArray = dialog.split("\n")
	for i: int in range(mini(3, lines.size())):
		draw_string(font, Vector2(30, 530 + i * 22), str(lines[i]), HORIZONTAL_ALIGNMENT_LEFT, 300, 12, Color("e4f4f1"))
	draw_string(font, Vector2(310, 588), "▼", HORIZONTAL_ALIGNMENT_CENTER, 20, 10, Color("6ddbd5"))

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
	return _tile_code(tile) in ["P", "G"]

func _request_move(direction: Vector2i) -> void:
	if moving or not dialog.is_empty():
		return
	facing = direction
	var target: Vector2i = player_tile + direction
	if not _walkable(target):
		return
	from_px = _tile_to_px(player_tile)
	to_px = _tile_to_px(target)
	move_t = 0.0
	moving = true
	_haptic(8)

func _after_step() -> void:
	steps_since_encounter += 1
	if _tile_code(player_tile) == "G" and steps_since_encounter >= 4 and rng.randf() < 0.18:
		steps_since_encounter = 0
		battle_requested.emit(player_tile)

func _interact() -> void:
	if moving:
		return
	var target: Vector2i = player_tile + facing
	match _tile_code(target):
		"N": dialog = "Mira: W trawie pojawiają się dzikie Somaskany.\nOsłab je, a potem użyj Modułu Chwytu."
		"S": dialog = "TABLICA: VELA\n↑ Stacja Somaskan     ← Staw Odbić\n→ Szlak Rezonansu"
		"C":
			dialog = "STACJA VELA\nRezonans partnera został w pełni odnowiony.\nBaza SOMADEX zsynchronizowana."
			station_requested.emit(player_tile)
		"H": dialog = "Dom jest zamknięty. Na drzwiach widnieje znak\nGildii Techników i symbol nieaktywnego modułu."
		_: dialog = ""
	queue_redraw()

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
