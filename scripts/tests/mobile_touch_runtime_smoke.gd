extends SceneTree

const TOUCH = preload("res://scripts/ui/touch_proxy.gd")
const TITLE = preload("res://scripts/ui/title_screen.gd")
const WORLD = preload("res://scripts/world/world_screen.gd")

var failures: Array[String] = []

func _init() -> void:
	_validate_phone_coordinate_mapping()
	_validate_title_touch_targets()
	_validate_world_touch_targets()
	if failures.is_empty():
		print("MOBILE TOUCH RUNTIME: PASS · phone scaling · title · dpad · A · menu")
		quit(0)
		return
	for failure: String in failures:
		push_error("MOBILE TOUCH: " + failure)
	print("MOBILE TOUCH RUNTIME: FAIL (%d)" % failures.size())
	quit(1)

func _validate_phone_coordinate_mapping() -> void:
	var phone := Vector2(696.0, 1536.0)
	var canvas := Vector2(360.0, 800.0)
	var center := TOUCH.map_position(Vector2(348.0, 768.0), phone, canvas)
	_check(center.distance_to(Vector2(180.0, 400.0)) < 0.01, "phone center must map to logical canvas center")
	var bottom_right := TOUCH.map_position(phone, phone, canvas)
	_check(bottom_right.distance_to(canvas) < 0.01, "phone bottom-right must map to 360x800")
	var title_new_game_phone := Vector2(180.0, 465.0) * phone / canvas
	var mapped_new_game := TOUCH.map_position(title_new_game_phone, phone, canvas)
	_check(TITLE.touch_option_at(mapped_new_game, false) == 0, "scaled phone tap must hit NOWA GRA")

func _validate_title_touch_targets() -> void:
	_check(TITLE.touch_option_at(Vector2(180, 465), false) == 0, "NOWA GRA target missing")
	_check(TITLE.touch_option_at(Vector2(180, 535), false) == 1, "KONTYNUUJ target missing")
	_check(TITLE.touch_option_at(Vector2(180, 605), false) == 2, "INFORMACJE target missing")
	_check(TITLE.touch_option_at(Vector2(20, 760), false) == -1, "empty title area must not activate a menu option")

func _validate_world_touch_targets() -> void:
	var world: Control = WORLD.new()
	_check(world._dpad_rect("up").has_point(Vector2(92, 654)), "world UP touch area invalid")
	_check(world._dpad_rect("left").has_point(Vector2(52, 694)), "world LEFT touch area invalid")
	_check(world._dpad_rect("down").has_point(Vector2(92, 734)), "world DOWN touch area invalid")
	_check(world._dpad_rect("right").has_point(Vector2(132, 694)), "world RIGHT touch area invalid")
	_check(world._a_rect().has_point(Vector2(280, 686)), "world A touch area invalid")
	_check(world._menu_rect().has_point(Vector2(280, 763)), "world MENU touch area invalid")
	world.free()

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
