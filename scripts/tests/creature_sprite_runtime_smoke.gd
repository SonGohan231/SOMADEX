extends SceneTree

const SPRITES = preload("res://scripts/battle/battle_sprite_art.gd")
const MONSTERS = preload("res://scripts/data/monster_db.gd")

func _initialize() -> void:
	var errors: Array[String] = []
	var expected_counts: Dictionary = {
		"idle": 4,
		"attack": 6,
		"hurt": 3,
		"faint": 5,
		"special": 6
	}
	_expect(SPRITES.FRAME_W == 128 and SPRITES.FRAME_H == 128, "battle sprite frame must be 128x128", errors)
	for action: String in SPRITES.ACTIONS:
		_expect(SPRITES.frame_count(action) == int(expected_counts[action]), "wrong frame count for %s" % action, errors)
	for creature_name: String in SPRITES.animated_names():
		_expect(MONSTERS.has_monster(creature_name), "sprite catalog references missing creature: %s" % creature_name, errors)
		for action: String in SPRITES.ACTIONS:
			var last_frame: int = SPRITES.frame_count(action) - 1
			_expect(SPRITES.frame_texture(creature_name, action, 0) != null, "%s %s frame 0 is blank" % [creature_name, action], errors)
			_expect(SPRITES.frame_texture(creature_name, action, last_frame) != null, "%s %s final frame is blank" % [creature_name, action], errors)

	# First production family must no longer depend on rectangular card art.
	_expect(SPRITES.authored_seed_count() >= 3, "expected at least three authored transparent seeds", errors)
	for creature_name: String in ["Luzik", "Warstwin", "Synkronaut"]:
		_expect(SPRITES.has_authored_seed(creature_name), "%s authored seed missing" % creature_name, errors)
		_expect(SPRITES.source_kind(creature_name) in ["authored-seed-archetype", "sprite-strip-partial", "sprite-strip"], "%s still uses portrait placeholder" % creature_name, errors)
		_expect(SPRITES.archetype(creature_name) == "glide", "%s family archetype mismatch" % creature_name, errors)

	if errors.is_empty():
		print("CREATURE_SPRITE_RUNTIME_SMOKE: PASS · idle4 attack6 hurt3 faint5 special6 · family001 authored transparent seeds · staged fallback safe")
		quit(0)
		return
	for text: String in errors:
		printerr("CREATURE_SPRITE_RUNTIME_SMOKE: " + text)
	quit(1)

func _expect(condition: bool, message: String, errors: Array[String]) -> void:
	if not condition:
		errors.append(message)
