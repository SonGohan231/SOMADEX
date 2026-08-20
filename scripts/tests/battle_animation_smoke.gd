extends SceneTree

const SPRITES = preload("res://scripts/battle/battle_sprite_art.gd")
const VISUAL_QUEUE = preload("res://scripts/battle/battle_visual_queue.gd")
const SCREEN = preload("res://scripts/battle/animated_battle_screen.gd")
const TRAINER_SCREEN = preload("res://scripts/battle/alpha1_trainer_battle_screen.gd")

func _initialize() -> void:
	var errors: Array[String] = []
	_test_sprite_catalog(errors)
	_test_frame_decode(errors)
	_test_visual_queue(errors)
	_test_screen_contract(errors)
	if errors.is_empty():
		print("BATTLE_ANIMATION_SMOKE: PASS")
		quit(0)
		return
	for text: String in errors:
		printerr("BATTLE_ANIMATION_SMOKE: " + text)
	quit(1)

func _test_sprite_catalog(errors: Array[String]) -> void:
	_expect(SPRITES.animation_count() == 30, "expected 30 generated animated forms", errors)
	_expect(SPRITES.atlas_size() == Vector2i(360, 270), "animation atlas size mismatch", errors)
	for name: String in ["Luzik", "Synkronaut", "Bocznik", "Falomamut", "Wahlik", "Kartografon", "Spiralion", "Labiryntaur", "Fundamentor", "Sensoryks"]:
		_expect(SPRITES.has_animation(name), "missing animation mapping for %s" % name, errors)
	_expect(not SPRITES.has_animation("Nucik"), "Nucik should currently exercise portrait fallback", errors)

func _test_frame_decode(errors: Array[String]) -> void:
	for action: String in SPRITES.ACTIONS:
		for frame: int in range(SPRITES.FRAME_COUNT):
			var tex: Texture2D = SPRITES.frame_texture("Luzik", action, frame)
			_expect(tex != null, "Luzik %s frame %d failed" % [action, frame], errors)
	if SPRITES.frame_texture("Luzik", "idle", 0) != null:
		_expect(SPRITES.frame_texture("Luzik", "idle", 0).get_size() == Vector2(30, 54), "frame region size mismatch", errors)

func _test_visual_queue(errors: Array[String]) -> void:
	var queue = VISUAL_QUEUE.new()
	queue.enqueue("player", "attack", "PHYSICAL")
	queue.enqueue("enemy", "hurt", "PHYSICAL")
	_expect(queue.blocks_input(), "visual queue must block battle input", errors)
	_expect(queue.state_for("player") == "attack", "first visual event is not player attack", errors)
	queue.tick(0.5)
	_expect(queue.state_for("enemy") == "hurt", "queue did not advance to enemy hurt", errors)
	queue.tick(0.5)
	_expect(not queue.blocks_input(), "visual queue did not drain", errors)

func _test_screen_contract(errors: Array[String]) -> void:
	var screen: Control = SCREEN.new()
	_expect(screen.has_method("_draw_actor_visual"), "animated battle screen lacks sprite renderer", errors)
	_expect(screen.has_method("_draw_move_fx"), "animated battle screen lacks move FX renderer", errors)
	screen.free()
	var trainer: Control = TRAINER_SCREEN.new()
	_expect(trainer.has_method("_draw_actor_visual"), "trainer battle does not inherit animated battle", errors)
	trainer.free()

func _expect(condition: bool, message: String, errors: Array[String]) -> void:
	if not condition:
		errors.append(message)
