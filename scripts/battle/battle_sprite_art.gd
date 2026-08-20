extends RefCounted

const ACTIONS: Array[String] = ["idle", "attack", "hurt", "faint", "special"]
const FRAME_COUNT: int = 4
const ATLAS_SIZE := Vector2i(360, 270)
const CELL_SIZE := Vector2i(30, 54)
const PACKAGE_CHUNKS: int = 18

const SPECIES: Dictionary = {
	"Luzik": [1, 0], "Warstwin": [1, 1], "Synkronaut": [1, 2],
	"Bocznik": [2, 0], "Slizgogon": [2, 1], "Horyzontor": [2, 2],
	"Milimik": [3, 0], "Drobnoskok": [3, 1], "Kwantomruk": [3, 2],
	"Pufek": [4, 0], "Pulsopuch": [4, 1], "Falomamut": [4, 2],
	"Wahlik": [5, 0], "Oscylot": [5, 1], "Fazoryb": [5, 2],
	"Kompasik": [6, 0], "Oktantor": [6, 1], "Kartografon": [6, 2],
	"Srubik": [7, 0], "Torsys": [7, 1], "Spiralion": [7, 2],
	"Uczek": [8, 0], "Objegnik": [8, 1], "Labiryntaur": [8, 2],
	"Kotwiczek": [9, 0], "Bramnik": [9, 1], "Fundamentor": [9, 2],
	"Nasuch": [10, 0], "Echouszek": [10, 1], "Sensoryks": [10, 2]
}

static var _atlases: Dictionary = {}
static var _frame_cache: Dictionary = {}
static var _encoded_atlases: Dictionary = {}
static var _encoded_loaded: bool = false

static func animated_names() -> Array[String]:
	var names: Array[String] = []
	for raw_name: Variant in SPECIES.keys():
		names.append(str(raw_name))
	names.sort()
	return names

static func has_animation(creature_name: String) -> bool:
	return SPECIES.has(creature_name)

static func animation_count() -> int:
	return SPECIES.size()

static func frame_texture(creature_name: String, action: String, frame: int) -> Texture2D:
	if not SPECIES.has(creature_name):
		return null
	var action_index: int = ACTIONS.find(action)
	if action_index < 0:
		action_index = 0
	var normalized_frame: int = posmod(frame, FRAME_COUNT)
	var cache_key: String = "%s|%s|%d" % [creature_name, ACTIONS[action_index], normalized_frame]
	if _frame_cache.has(cache_key):
		return _frame_cache[cache_key] as Texture2D
	var entry: Array = SPECIES[creature_name] as Array
	var family_id: int = int(entry[0])
	var slot: int = int(entry[1])
	var atlas: Texture2D = _atlas_for_family(family_id)
	if atlas == null:
		return null
	var texture := AtlasTexture.new()
	texture.atlas = atlas
	var column: int = slot * FRAME_COUNT + normalized_frame
	texture.region = Rect2(column * CELL_SIZE.x, action_index * CELL_SIZE.y, CELL_SIZE.x, CELL_SIZE.y)
	_frame_cache[cache_key] = texture
	return texture

static func atlas_size() -> Vector2i:
	return ATLAS_SIZE

static func _atlas_for_family(family_id: int) -> Texture2D:
	if _atlases.has(family_id):
		return _atlases[family_id] as Texture2D
	_load_encoded_atlases()
	var key: String = "f%02d" % family_id
	var encoded: String = str(_encoded_atlases.get(key, ""))
	if encoded.is_empty():
		_atlases[family_id] = null
		return null
	var bytes: PackedByteArray = Marshalls.base64_to_raw(encoded)
	var image := Image.new()
	var err: Error = image.load_webp_from_buffer(bytes)
	if err != OK or image.get_size() != ATLAS_SIZE:
		push_error("SOMADEX animation atlas f%02d failed to decode" % family_id)
		_atlases[family_id] = null
		return null
	var texture: Texture2D = ImageTexture.create_from_image(image)
	_atlases[family_id] = texture
	return texture

static func _load_encoded_atlases() -> void:
	if _encoded_loaded:
		return
	_encoded_loaded = true
	var raw: String = ""
	for i: int in range(PACKAGE_CHUNKS):
		var path: String = "res://assets/creatures/animations/data/atlas_%02d.b64part" % i
		if not FileAccess.file_exists(path):
			push_error("SOMADEX animation atlas package chunk %02d missing" % i)
			return
		raw += FileAccess.get_file_as_string(path)
	for line: String in raw.split("\n"):
		if line.is_empty():
			continue
		var split_at: int = line.find(":")
		if split_at <= 0:
			continue
		_encoded_atlases[line.substr(0, split_at)] = line.substr(split_at + 1)
