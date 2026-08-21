extends SceneTree

const ART = preload("res://scripts/art/world_pixel_art.gd")
const WORLD = preload("res://scripts/world/sprite_campaign_world_screen.gd")
const NPCS = preload("res://scripts/data/runtime_npc_db.gd")

var failures: Array[String] = []

func _init() -> void:
	_validate_tiles()
	_validate_player_frames()
	_validate_npc_archetypes()
	_validate_world_renderer()
	if failures.is_empty():
		print("WORLD SPRITE ART SMOKE: PASS · pixel tiles · 4-dir trainer · runtime NPC sprites")
		quit(0)
	else:
		for failure: String in failures:
			push_error("WORLD SPRITE ART: " + failure)
		quit(1)

func _validate_tiles() -> void:
	for code: String in ["P","G","F","A","W","B","D","V","O","K","T","H","C","N","S","E"]:
		for variant: int in range(4):
			var texture: Texture2D = ART.tile_texture(code, variant)
			_check(texture != null, "tile %s/%d missing" % [code, variant])
			if texture != null:
				_check(texture.get_size() == Vector2(24, 24), "tile %s has wrong size" % code)

func _validate_player_frames() -> void:
	for facing: Vector2i in [Vector2i.DOWN, Vector2i.UP, Vector2i.LEFT, Vector2i.RIGHT]:
		for frame: int in range(4):
			var texture: Texture2D = ART.player_texture(facing, frame)
			_check(texture != null, "player sprite missing")
			if texture != null:
				_check(texture.get_size() == Vector2(24, 24), "player frame must be 24x24")

func _validate_npc_archetypes() -> void:
	var probes: Array[Dictionary] = [
		{"id":"trainer","role":"trener","trainer":true,"color":"a85a55"},
		{"id":"researcher","role":"badacz archiwum","color":"5e78aa"},
		{"id":"technician","role":"technik operator","color":"5a91a1"},
		{"id":"medic","role":"medyk","color":"7aa88a"},
		{"id":"ranger","role":"tropiciel wędrowiec","color":"638253"},
		{"id":"guard","role":"strażnik","color":"765e94"},
		{"id":"boss","role":"boss warden","trainer":true,"color":"8a4f62"}
	]
	for npc: Dictionary in probes:
		var texture: Texture2D = ART.npc_texture(npc, "down", 0)
		_check(texture != null, "%s NPC sprite missing" % str(npc.get("id", "npc")))
		if texture != null:
			_check(texture.get_size() == Vector2(24, 24), "NPC sprite must be 24x24")
	_check(NPCS.count() >= 70, "runtime sprite layer must cover the full regional NPC registry")

func _validate_world_renderer() -> void:
	var world: Control = WORLD.new()
	world.setup("Luzik", Vector2i(7, 20), 12, false, "marea", "Sprite smoke", {})
	_check(str(world.get("zone_id")) == "marea", "sprite world lost campaign zone support")
	_check(world.has_method("_draw_sprite_npc"), "sprite world renderer missing NPC sprite path")
	world.free()

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
