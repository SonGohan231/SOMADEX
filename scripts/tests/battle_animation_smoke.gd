extends SceneTree

const SPRITES = preload("res://scripts/battle/battle_sprite_art.gd")
const VISUAL_QUEUE = preload("res://scripts/battle/battle_visual_queue.gd")
const SCREEN = preload("res://scripts/battle/animated_battle_screen.gd")
const TRAINER_SCREEN = preload("res://scripts/battle/alpha1_trainer_battle_screen.gd")

func _initialize() -> void:
	var errors: Array[String] = []
	_test_sprite_catalog(errors)
	_test_visual_states(errors)
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
	_expect(SPRITES.animation_count() == 33, "expected 33 Vela forms with battle animation states", errors)
	var authored_family: Array[String] = ["Luzik", "Warstwin", "Synkronaut"]
	var reverse_families: Array[String] = ["Wahlik", "Oscylot", "Fazoryb", "Kompasik", "Oktantor", "Kartografon", "Srubik", "Torsys", "Spiralion", "Uczek", "Obiegnik", "Labiryntaur", "Kotwiczek", "Bramnik", "Fundamentor", "Nasuch", "Echouszek", "Sensoryks", "Nucik", "Wibrospiew", "Rezonar"]
	var allowed_sources: Array[String] = ["portrait-procedural", "authored-seed-archetype", "sprite-strip-partial", "sprite-strip", "sprite-strip-authored-runtime"]
	for name: String in ["Luzik", "Synkronaut", "Bocznik", "Falomamut", "Wahlik", "Oscylot", "Fazoryb", "Kompasik", "Oktantor", "Kartografon", "Srubik", "Torsys", "Spiralion", "Uczek", "Obiegnik", "Labiryntaur", "Kotwiczek", "Bramnik", "Fundamentor", "Nasuch", "Echouszek", "Sensoryks", "Nucik", "Wibrospiew", "Rezonar"]:
		_expect(SPRITES.has_animation(name), "missing battle animation mapping for %s" % name, errors)
		_expect(SPRITES.source_kind(name) in allowed_sources, "wrong animation source for %s" % name, errors)
	for name: String in authored_family:
		_expect(SPRITES.has_authored_seed(name), "%s must use an authored transparent seed" % name, errors)
		_expect(SPRITES.source_kind(name) != "portrait-procedural", "%s regressed to portrait placeholder" % name, errors)
	for name: String in reverse_families:
		_expect(SPRITES.has_authored_full_animation(name), "%s reverse-pass animation missing" % name, errors)
		_expect(SPRITES.source_kind(name) == "sprite-strip-authored-runtime", "%s is not using full authored frame routing" % name, errors)

func _test_visual_states(errors: Array[String]) -> void:
	for action: String in SPRITES.ACTIONS:
		var count: int = SPRITES.frame_count(action)
		for frame: int in range(count):
			var tex: Texture2D = SPRITES.frame_texture("Luzik", action, frame)
			_expect(tex != null, "Luzik %s frame state %d failed" % [action, frame], errors)
			var final_voice: Texture2D = SPRITES.frame_texture("Rezonar", action, frame)
			_expect(final_voice != null, "Rezonar %s authored frame %d failed" % [action, frame], errors)
			var final_sensor: Texture2D = SPRITES.frame_texture("Sensoryks", action, frame)
			_expect(final_sensor != null, "Sensoryks %s authored frame %d failed" % [action, frame], errors)
			var final_anchor: Texture2D = SPRITES.frame_texture("Fundamentor", action, frame)
			_expect(final_anchor != null, "Fundamentor %s authored frame %d failed" % [action, frame], errors)
			var final_maze: Texture2D = SPRITES.frame_texture("Labiryntaur", action, frame)
			_expect(final_maze != null, "Labiryntaur %s authored frame %d failed" % [action, frame], errors)
			var final_torsion: Texture2D = SPRITES.frame_texture("Spiralion", action, frame)
			_expect(final_torsion != null, "Spiralion %s authored frame %d failed" % [action, frame], errors)
			var final_direction: Texture2D = SPRITES.frame_texture("Kartografon", action, frame)
			_expect(final_direction != null, "Kartografon %s authored frame %d failed" % [action, frame], errors)
			var final_phase: Texture2D = SPRITES.frame_texture("Fazoryb", action, frame)
			_expect(final_phase != null, "Fazoryb %s authored frame %d failed" % [action, frame], errors)

func _test_visual_queue(errors: Array[String]) -> void:
	var queue = VISUAL_QUEUE.new()
	queue.enqueue("player", "attack", "PHYSICAL")
	queue.enqueue("enemy", "hurt", "PHYSICAL")
	queue.enqueue("enemy", "faint", "PHYSICAL")
	_expect(queue.blocks_input(), "visual queue must block battle input", errors)
	_expect(queue.state_for("player") == "attack", "first visual event is not player attack", errors)
	queue.tick(0.5)
	_expect(queue.state_for("enemy") == "hurt", "queue did not advance to enemy hurt", errors)
	queue.tick(0.5)
	_expect(queue.state_for("enemy") == "faint", "queue did not advance to enemy faint", errors)
	queue.tick(0.8)
	_expect(not queue.blocks_input(), "visual queue did not drain", errors)

func _test_screen_contract(errors: Array[String]) -> void:
	var screen: Control = SCREEN.new()
	_expect(screen.has_method("_draw_actor_visual"), "animated battle screen lacks state renderer", errors)
	_expect(screen.has_method("_draw_move_fx"), "animated battle screen lacks move FX renderer", errors)
	_expect(screen.has_method("_visual_state_for_move"), "animated battle screen lacks move-state routing", errors)
	screen.free()
	var trainer: Control = TRAINER_SCREEN.new()
	_expect(trainer.has_method("_draw_actor_visual"), "trainer battle does not inherit animated battle", errors)
	trainer.free()

func _expect(condition: bool, message: String, errors: Array[String]) -> void:
	if not condition:
		errors.append(message)
