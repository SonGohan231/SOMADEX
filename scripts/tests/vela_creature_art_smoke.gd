extends SceneTree

const ART = preload("res://scripts/data/monster_art.gd")
const DB = preload("res://scripts/data/monster_db.gd")
const STATE = preload("res://scripts/core/game_state.gd")
const PAUSE_ART = preload("res://scripts/ui/alpha1_pause_menu_art.gd")
const GAME_ANIMATIONS = preload("res://scripts/game_animations.gd")
const MANIFEST_PATH: String = "res://data/creatures/vela_portraits_manifest.csv"

func _initialize() -> void:
	var errors: Array[String] = []
	_expect(ART.vela_portrait_count() == 33, "Vela atlas does not expose exactly 33 forms", errors)
	_expect(ART.vela_atlas_size() == Vector2i(672, 432), "Vela atlas has unexpected dimensions", errors)
	_validate_manifest_textures(errors)
	_validate_screen_controller(errors)
	_validate_dex_navigation(errors)
	if errors.is_empty():
		print("VELA_CREATURE_ART_SMOKE: PASS")
		quit(0)
		return
	for message: String in errors:
		printerr("VELA_CREATURE_ART_SMOKE: " + message)
	quit(1)

func _validate_manifest_textures(errors: Array[String]) -> void:
	var file := FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	_expect(file != null, "portrait manifest cannot be opened", errors)
	if file == null:
		return
	file.get_csv_line()
	var count: int = 0
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.size() < 4 or row[0].strip_edges().is_empty():
			continue
		var creature_name: String = row[0].strip_edges()
		count += 1
		_expect(DB.has_monster(creature_name), creature_name + " is missing from runtime DB", errors)
		var texture: Texture2D = ART.texture_for(creature_name)
		_expect(texture != null, creature_name + " has no Vela portrait texture", errors)
		if texture is AtlasTexture:
			var atlas_texture := texture as AtlasTexture
			_expect(atlas_texture.region.size == Vector2(112, 72), creature_name + " uses a wrong atlas region", errors)
	_expect(count == 33, "portrait manifest does not contain 33 rows", errors)

func _validate_screen_controller(errors: Array[String]) -> void:
	var packed: PackedScene = load("res://scenes/Main.tscn") as PackedScene
	_expect(packed != null, "Main.tscn cannot be loaded", errors)
	if packed == null:
		return
	var node: Node = packed.instantiate()
	_expect(node.get_script() == GAME_ANIMATIONS, "Main.tscn is not using the Vela art + animation controller", errors)
	node.free()

func _validate_dex_navigation(errors: Array[String]) -> void:
	var profile: Dictionary = STATE.new_profile("Luzik")
	STATE.add_seen(profile, "Warstwin")
	STATE.add_seen(profile, "Synkronaut")
	var menu: Control = PAUSE_ART.new()
	menu.setup(profile)
	menu.section = "dex"
	_expect(menu._section_count() == 3, "Somadex navigation does not follow discovered forms", errors)
	menu.section_selected = 2
	var names: Array[String] = menu._dex_names()
	_expect(names.size() == 3, "Somadex discovered form list is wrong", errors)
	_expect(names.has("Luzik") and names.has("Warstwin") and names.has("Synkronaut"), "Somadex lost an evolution form", errors)
	menu.free()

func _expect(condition: bool, message: String, errors: Array[String]) -> void:
	if not condition:
		errors.append(message)
