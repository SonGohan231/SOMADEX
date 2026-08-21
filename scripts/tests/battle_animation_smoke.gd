extends SceneTree

const SPRITES = preload("res://scripts/battle/battle_sprite_art.gd")
const VISUAL_QUEUE = preload("res://scripts/battle/battle_visual_queue.gd")
const SCREEN = preload("res://scripts/battle/animated_battle_screen.gd")
const TRAINER_SCREEN = preload("res://scripts/battle/alpha1_trainer_battle_screen.gd")

func _initialize() -> void:
	var errors: Array[String]=[]
	_test_sprite_catalog(errors)
	_test_visual_states(errors)
	_test_visual_queue(errors)
	_test_screen_contract(errors)
	if errors.is_empty(): print("BATTLE_ANIMATION_SMOKE: PASS · 150 logical forms · 33 authored Vela forms"); quit(0); return
	for text: String in errors: printerr("BATTLE_ANIMATION_SMOKE: "+text)
	quit(1)

func _test_sprite_catalog(errors: Array[String]) -> void:
	_expect(SPRITES.animation_count()==150,"expected 150 forms with logical battle animation states",errors)
	_expect(SPRITES.animated_names().size()==150,"animated name catalog must contain 150 unique forms",errors)
	var expected_counts: Dictionary={"idle":4,"attack":6,"hurt":3,"faint":5,"special":6}
	for action: String in SPRITES.ACTIONS:
		_expect(SPRITES.frame_count(action)==int(expected_counts[action]),"wrong frame count for %s" % action,errors)
	var reverse_families: Array[String]=["Luzik","Warstwin","Synkronaut","Bocznik","Slizgogon","Horyzontor","Milimik","Drobnoskok","Kwantomruk","Pufek","Pulsopuch","Falomamut","Wahlik","Oscylot","Fazoryb","Kompasik","Oktantor","Kartografon","Srubik","Torsys","Spiralion","Uczek","Obiegnik","Labiryntaur","Kotwiczek","Bramnik","Fundamentor","Nasuch","Echouszek","Sensoryks","Nucik","Wibrospiew","Rezonar"]
	_expect(SPRITES.authored_full_animation_count()>=33,"expected all 33 Vela reverse-pass forms to be fully authored",errors)
	for name: String in reverse_families:
		_expect(SPRITES.has_authored_full_animation(name),"%s reverse-pass animation missing" % name,errors)
		_expect(SPRITES.source_kind(name)=="sprite-strip-authored-runtime","%s is not using full authored frame routing" % name,errors)

func _test_visual_states(errors: Array[String]) -> void:
	var representatives: Array[String]=["Synkronaut","Rezonar","Sensoryks","Fundamentor","Labiryntaur","Spiralion","Kartografon","Fazoryb","Falomamut","Kwantomruk","Horyzontor"]
	for action: String in SPRITES.ACTIONS:
		for frame: int in range(SPRITES.frame_count(action)):
			for name: String in representatives:
				_expect(SPRITES.frame_texture(name,action,frame)!=null,"%s %s authored frame %d failed" % [name,action,frame],errors)

func _test_visual_queue(errors: Array[String]) -> void:
	var queue=VISUAL_QUEUE.new()
	queue.enqueue("player","attack","PHYSICAL")
	queue.enqueue("enemy","hurt","PHYSICAL")
	queue.enqueue("enemy","faint","PHYSICAL")
	_expect(queue.blocks_input(),"visual queue must block battle input",errors)
	queue.tick(0.5); _expect(queue.state_for("enemy")=="hurt","queue did not advance to enemy hurt",errors)
	queue.tick(0.5); _expect(queue.state_for("enemy")=="faint","queue did not advance to enemy faint",errors)
	queue.tick(0.8); _expect(not queue.blocks_input(),"visual queue did not drain",errors)

func _test_screen_contract(errors: Array[String]) -> void:
	var screen: Control=SCREEN.new()
	_expect(screen.has_method("_draw_actor_visual"),"animated battle screen lacks state renderer",errors)
	_expect(screen.has_method("_draw_move_fx"),"animated battle screen lacks move FX renderer",errors)
	screen.free()
	var trainer: Control=TRAINER_SCREEN.new()
	_expect(trainer.has_method("_draw_actor_visual"),"trainer battle does not inherit animated battle",errors)
	trainer.free()

func _expect(condition: bool, message: String, errors: Array[String]) -> void:
	if not condition: errors.append(message)
