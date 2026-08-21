extends RefCounted

const TILE_SIZE: int = 24
const SPRITE_SIZE: int = 24

static var _tile_cache: Dictionary = {}
static var _player_cache: Dictionary = {}
static var _npc_cache: Dictionary = {}
static var _pickup_cache: Dictionary = {}

static func tile_texture(code: String, variant: int = 0) -> Texture2D:
	var key: String = "%s:%d" % [code, posmod(variant, 4)]
	if _tile_cache.has(key):
		return _tile_cache[key] as Texture2D
	var image: Image = Image.create(TILE_SIZE, TILE_SIZE, false, Image.FORMAT_RGBA8)
	_draw_tile(image, code, posmod(variant, 4))
	var texture: ImageTexture = ImageTexture.create_from_image(image)
	_tile_cache[key] = texture
	return texture

static func player_texture(facing: Vector2i, frame: int) -> Texture2D:
	var direction: String = _direction_name(facing)
	var frame_id: int = posmod(frame, 4)
	var key: String = "%s:%d" % [direction, frame_id]
	if _player_cache.has(key):
		return _player_cache[key] as Texture2D
	var image: Image = Image.create(SPRITE_SIZE, SPRITE_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	_draw_character(
		image,
		direction,
		frame_id,
		Color("173b55"),
		Color("28c9c4"),
		Color("efc09a"),
		Color("382c36"),
		"trainer"
	)
	var texture: ImageTexture = ImageTexture.create_from_image(image)
	_player_cache[key] = texture
	return texture

static func npc_texture(npc: Dictionary, facing: String = "down", frame: int = 0) -> Texture2D:
	var role: String = str(npc.get("role", npc.get("title", "npc"))).to_lower()
	var body_hex: String = str(npc.get("color", "6d7890"))
	var trainer: bool = bool(npc.get("trainer", false))
	var archetype: String = _archetype(role, trainer)
	var direction: String = facing if facing in ["down", "up", "left", "right"] else "down"
	var frame_id: int = posmod(frame, 4)
	var key: String = "%s:%s:%s:%d" % [archetype, body_hex, direction, frame_id]
	if _npc_cache.has(key):
		return _npc_cache[key] as Texture2D
	var body: Color = Color(body_hex)
	var accent: Color = _accent_for(role, trainer)
	var skin: Color = Color("e5b58f")
	var hair: Color = _hair_for(role)
	var image: Image = Image.create(SPRITE_SIZE, SPRITE_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	_draw_character(image, direction, frame_id, body, accent, skin, hair, archetype)
	var texture: ImageTexture = ImageTexture.create_from_image(image)
	_npc_cache[key] = texture
	return texture

static func pickup_texture(kind: String = "item") -> Texture2D:
	if _pickup_cache.has(kind):
		return _pickup_cache[kind] as Texture2D
	var image: Image = Image.create(12, 12, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var dark: Color = Color("4c432e")
	var gold: Color = Color("e6c85f")
	var light: Color = Color("fff0a1")
	if kind == "gear":
		dark = Color("3c3950")
		gold = Color("7ee0dc")
		light = Color("e3fffb")
	image.fill_rect(Rect2i(3, 3, 6, 6), dark)
	image.fill_rect(Rect2i(4, 2, 4, 8), gold)
	image.fill_rect(Rect2i(2, 4, 8, 4), gold)
	image.fill_rect(Rect2i(5, 3, 2, 2), light)
	image.set_pixel(8, 8, light)
	var texture: ImageTexture = ImageTexture.create_from_image(image)
	_pickup_cache[kind] = texture
	return texture

static func _draw_tile(image: Image, code: String, variant: int) -> void:
	match code:
		"P": _tile_path(image, variant)
		"G": _tile_grass(image, variant)
		"F": _tile_forest_floor(image, variant)
		"A": _tile_sand(image, variant)
		"W": _tile_water(image, variant)
		"B": _tile_bridge(image, variant)
		"D": _tile_tech_floor(image, variant)
		"V": _tile_cave_floor(image, variant)
		"O": _tile_boulder(image, variant)
		"K": _tile_wall(image, variant)
		"T": _tile_tree(image, variant)
		"H": _tile_house(image, variant)
		"C": _tile_station(image, variant)
		"N": _tile_marker(image, variant)
		"S": _tile_sign(image, variant)
		"E": _tile_exit(image, variant)
		_:
			_tile_grass(image, variant)

static func _tile_path(image: Image, variant: int) -> void:
	image.fill(Color("b9a46f"))
	var dark: Color = Color("8f7b50")
	var light: Color = Color("d7c58e")
	for i: int in range(6):
		var x: int = posmod(i * 7 + variant * 5, 22) + 1
		var y: int = posmod(i * 11 + variant * 3, 22) + 1
		image.fill_rect(Rect2i(x, y, 2, 1), dark if i % 2 == 0 else light)
	image.fill_rect(Rect2i(0, 0, 24, 1), Color("a18d60"))

static func _tile_grass(image: Image, variant: int) -> void:
	image.fill(Color("4b9359"))
	var dark: Color = Color("347443")
	var light: Color = Color("76bd68")
	for i: int in range(7):
		var x: int = posmod(i * 5 + variant * 7, 21) + 1
		var y: int = posmod(i * 9 + variant * 3, 19) + 3
		image.set_pixel(x, y, dark)
		image.set_pixel(x + 1, y - 2, light)
		image.set_pixel(x + 1, y - 1, light)

static func _tile_forest_floor(image: Image, variant: int) -> void:
	image.fill(Color("3b7b49"))
	for i: int in range(5):
		var x: int = posmod(i * 8 + variant * 3, 21) + 1
		var y: int = posmod(i * 5 + variant * 7, 21) + 1
		image.fill_rect(Rect2i(x, y, 3, 2), Color("2d633a"))
	image.set_pixel(18, 6 + variant, Color("d5c65b"))
	image.set_pixel(19, 6 + variant, Color("f0df77"))

static func _tile_sand(image: Image, variant: int) -> void:
	image.fill(Color("d2b878"))
	for i: int in range(6):
		var x: int = posmod(i * 7 + variant * 4, 22) + 1
		var y: int = posmod(i * 13 + variant * 2, 22) + 1
		image.set_pixel(x, y, Color("a98f5c"))
		if i % 2 == 0:
			image.set_pixel(mini(23, x + 1), y, Color("ead99c"))

static func _tile_water(image: Image, variant: int) -> void:
	image.fill(Color("347f9c"))
	for y: int in [5, 12, 19]:
		var offset: int = posmod(variant * 3 + y, 7)
		image.fill_rect(Rect2i(offset, y, 9, 1), Color("6fc1ca"))
		image.fill_rect(Rect2i(posmod(offset + 12, 24), y + 2, 6, 1), Color("286a85"))

static func _tile_bridge(image: Image, variant: int) -> void:
	_tile_water(image, variant)
	image.fill_rect(Rect2i(0, 3, 24, 18), Color("765e3e"))
	for y: int in range(4, 21, 4):
		image.fill_rect(Rect2i(0, y, 24, 1), Color("a98655"))
	image.fill_rect(Rect2i(0, 3, 24, 2), Color("4f432f"))
	image.fill_rect(Rect2i(0, 19, 24, 2), Color("4f432f"))

static func _tile_tech_floor(image: Image, variant: int) -> void:
	image.fill(Color("6f7b82"))
	image.fill_rect(Rect2i(0, 0, 24, 2), Color("4f5b62"))
	image.fill_rect(Rect2i(0, 11, 24, 1), Color("59676e"))
	image.fill_rect(Rect2i(11, 0, 1, 24), Color("59676e"))
	var accent_x: int = 3 + variant * 4
	image.fill_rect(Rect2i(accent_x, 5, 4, 1), Color("55cfc8"))
	image.set_pixel(accent_x + 1, 6, Color("b9fffa"))

static func _tile_cave_floor(image: Image, variant: int) -> void:
	image.fill(Color("3c4453"))
	for i: int in range(5):
		var x: int = posmod(i * 7 + variant * 5, 21) + 1
		var y: int = posmod(i * 9 + variant * 2, 21) + 1
		image.fill_rect(Rect2i(x, y, 3, 2), Color("596678"))
	image.set_pixel(4 + variant * 3, 18, Color("75658d"))

static func _tile_boulder(image: Image, variant: int) -> void:
	_tile_cave_floor(image, variant)
	image.fill_rect(Rect2i(4, 9, 16, 10), Color("4c5261"))
	image.fill_rect(Rect2i(7, 6, 10, 3), Color("616a7a"))
	image.fill_rect(Rect2i(6, 8, 12, 2), Color("596170"))
	image.fill_rect(Rect2i(8, 8, 5, 2), Color("7a8290"))
	image.fill_rect(Rect2i(5, 18, 14, 2), Color("303743"))

static func _tile_wall(image: Image, variant: int) -> void:
	image.fill(Color("292f39"))
	for y: int in range(2, 24, 6):
		image.fill_rect(Rect2i(0, y, 24, 1), Color("4a5260"))
	for y: int in range(0, 24, 6):
		var shift: int = 0 if ((y / 6) as int) % 2 == 0 else 6
		for x: int in range(shift, 24, 12):
			image.fill_rect(Rect2i(x, y, 1, 6), Color("414955"))
	image.fill_rect(Rect2i(0, 0, 24, 2), Color("5a6372"))

static func _tile_tree(image: Image, variant: int) -> void:
	image.fill(Color("315f42"))
	image.fill_rect(Rect2i(10, 13, 5, 11), Color("685139"))
	image.fill_rect(Rect2i(8, 15, 9, 3), Color("765c3c"))
	image.fill_rect(Rect2i(4, 6, 17, 10), Color("276b42"))
	image.fill_rect(Rect2i(7, 3, 11, 5), Color("337e49"))
	image.fill_rect(Rect2i(2, 9, 7, 5), Color("3c8650"))
	image.fill_rect(Rect2i(13, 8, 9, 6), Color("2d7546"))
	image.fill_rect(Rect2i(8 + variant, 5, 4, 2), Color("58a260"))

static func _tile_house(image: Image, variant: int) -> void:
	image.fill(Color("3e7650"))
	image.fill_rect(Rect2i(2, 8, 20, 16), Color("cfb477"))
	image.fill_rect(Rect2i(0, 5, 24, 5), Color("925247"))
	image.fill_rect(Rect2i(3, 3, 18, 3), Color("aa6050"))
	image.fill_rect(Rect2i(5, 12, 5, 5), Color("78b5b4"))
	image.fill_rect(Rect2i(14, 12, 5, 5), Color("78b5b4"))
	image.fill_rect(Rect2i(10, 17, 5, 7), Color("6e513d"))

static func _tile_station(image: Image, variant: int) -> void:
	image.fill(Color("426d55"))
	image.fill_rect(Rect2i(2, 5, 20, 19), Color("d6e4df"))
	image.fill_rect(Rect2i(5, 2, 14, 5), Color("45cfc7"))
	image.fill_rect(Rect2i(8, 8, 8, 2), Color("2b6771"))
	image.fill_rect(Rect2i(10, 14, 4, 10), Color("2b6771"))
	image.fill_rect(Rect2i(6, 16, 12, 3), Color("54ded7"))
	image.fill_rect(Rect2i(11, 12, 2, 11), Color("effffd"))

static func _tile_marker(image: Image, variant: int) -> void:
	_tile_grass(image, variant)
	image.fill_rect(Rect2i(10, 8, 4, 16), Color("62503a"))
	image.fill_rect(Rect2i(6, 5, 12, 9), Color("8152a0"))
	image.fill_rect(Rect2i(9, 7, 6, 2), Color("cfa8e4"))

static func _tile_sign(image: Image, variant: int) -> void:
	_tile_grass(image, variant)
	image.fill_rect(Rect2i(11, 11, 3, 13), Color("624930"))
	image.fill_rect(Rect2i(4, 5, 16, 9), Color("d0b774"))
	image.fill_rect(Rect2i(6, 7, 12, 1), Color("8f7348"))
	image.fill_rect(Rect2i(7, 10, 9, 1), Color("8f7348"))

static func _tile_exit(image: Image, variant: int) -> void:
	_tile_path(image, variant)
	image.fill_rect(Rect2i(4, 0, 16, 24), Color("1a4852"))
	image.fill_rect(Rect2i(7, 0, 10, 24), Color("35bdb8"))
	image.fill_rect(Rect2i(9, 0, 6, 24), Color("173c46"))
	image.fill_rect(Rect2i(10, 7, 4, 10), Color("7dfff5"))
	image.fill_rect(Rect2i(11, 5, 2, 14), Color("eafffc"))

static func _draw_character(
	image: Image,
	direction: String,
	frame: int,
	body: Color,
	accent: Color,
	skin: Color,
	hair: Color,
	archetype: String
) -> void:
	var shadow: Color = Color(0.05, 0.08, 0.10, 0.45)
	image.fill_rect(Rect2i(5, 21, 14, 2), shadow)
	image.fill_rect(Rect2i(7, 20, 10, 3), shadow)
	var step: int = 0
	if frame == 1:
		step = -1
	elif frame == 3:
		step = 1
	var torso_x: int = 7
	var head_x: int = 8
	if direction == "left":
		torso_x = 6
		head_x = 7
	elif direction == "right":
		torso_x = 8
		head_x = 9
	# legs + boots: actual alternating walk frames
	if frame in [1, 3]:
		image.fill_rect(Rect2i(7 + step, 17, 4, 5), Color("27313d"))
		image.fill_rect(Rect2i(13 - step, 17, 4, 5), Color("27313d"))
		image.fill_rect(Rect2i(6 + step, 21, 5, 2), Color("171d27"))
		image.fill_rect(Rect2i(13 - step, 21, 5, 2), Color("171d27"))
	else:
		image.fill_rect(Rect2i(7, 17, 4, 5), Color("27313d"))
		image.fill_rect(Rect2i(13, 17, 4, 5), Color("27313d"))
		image.fill_rect(Rect2i(6, 21, 5, 2), Color("171d27"))
		image.fill_rect(Rect2i(13, 21, 5, 2), Color("171d27"))
	# torso, arms and silhouette accents
	image.fill_rect(Rect2i(torso_x, 9, 11, 9), body)
	image.fill_rect(Rect2i(torso_x - 2, 10, 2, 7), body.darkened(0.18))
	image.fill_rect(Rect2i(torso_x + 11, 10, 2, 7), body.darkened(0.18))
	image.fill_rect(Rect2i(torso_x + 2, 10, 7, 2), accent)
	if archetype in ["researcher", "medic", "technician"]:
		image.fill_rect(Rect2i(torso_x + 1, 13, 9, 4), body.lightened(0.18))
		image.fill_rect(Rect2i(torso_x + 5, 13, 1, 5), accent)
	if archetype in ["ranger", "guard", "boss"]:
		image.fill_rect(Rect2i(torso_x - 1, 9, 13, 2), accent.darkened(0.12))
	if archetype == "boss":
		image.fill_rect(Rect2i(torso_x - 2, 12, 2, 5), accent)
		image.fill_rect(Rect2i(torso_x + 11, 12, 2, 5), accent)
	# head/face changes by facing
	image.fill_rect(Rect2i(head_x, 3, 9, 7), skin)
	image.fill_rect(Rect2i(head_x, 2, 9, 3), hair)
	image.fill_rect(Rect2i(head_x - 1, 4, 2, 4), hair.darkened(0.10))
	image.fill_rect(Rect2i(head_x + 8, 4, 2, 4), hair.darkened(0.10))
	if direction == "down":
		image.set_pixel(head_x + 2, 6, Color("28303c"))
		image.set_pixel(head_x + 6, 6, Color("28303c"))
		image.fill_rect(Rect2i(head_x + 3, 8, 3, 1), skin.darkened(0.22))
	elif direction == "left":
		image.set_pixel(head_x + 1, 6, Color("28303c"))
	elif direction == "right":
		image.set_pixel(head_x + 7, 6, Color("28303c"))
	else:
		image.fill_rect(Rect2i(head_x + 2, 4, 5, 3), hair)
	# archetype-specific equipment gives NPCs readable jobs instead of recolored placeholders
	if archetype == "trainer":
		image.fill_rect(Rect2i(head_x - 1, 1, 11, 2), accent)
		image.fill_rect(Rect2i(head_x + 5, 3, 5, 1), accent)
	elif archetype == "researcher":
		image.fill_rect(Rect2i(head_x + 1, 5, 7, 2), Color("88d8dc"))
		image.fill_rect(Rect2i(head_x + 2, 5, 2, 1), Color("eaffff"))
	elif archetype == "technician":
		image.fill_rect(Rect2i(torso_x + 9, 12, 3, 4), Color("d4b750"))
		image.set_pixel(torso_x + 10, 13, Color("fff0a1"))
	elif archetype == "medic":
		image.fill_rect(Rect2i(torso_x + 4, 12, 3, 5), Color("e9f7f3"))
		image.fill_rect(Rect2i(torso_x + 3, 13, 5, 3), Color("56c7be"))
	elif archetype == "ranger":
		image.fill_rect(Rect2i(torso_x - 2, 12, 2, 6), Color("5a4630"))
	elif archetype == "guard":
		image.fill_rect(Rect2i(head_x, 1, 9, 2), accent)
		image.fill_rect(Rect2i(head_x + 1, 0, 7, 1), accent.lightened(0.2))
	elif archetype == "boss":
		image.fill_rect(Rect2i(head_x - 1, 1, 11, 2), accent)
		image.set_pixel(head_x - 1, 0, accent.lightened(0.35))
		image.set_pixel(head_x + 9, 0, accent.lightened(0.35))

static func _direction_name(facing: Vector2i) -> String:
	if facing == Vector2i.UP:
		return "up"
	if facing == Vector2i.LEFT:
		return "left"
	if facing == Vector2i.RIGHT:
		return "right"
	return "down"

static func _archetype(role: String, trainer: bool) -> String:
	if "boss" in role or "mistrz" in role or "warden" in role or "arcy" in role:
		return "boss"
	if "med" in role or "uzdrow" in role:
		return "medic"
	if "technik" in role or "mechan" in role or "operator" in role or "inż" in role or "konstruk" in role:
		return "technician"
	if "badacz" in role or "archiw" in role or "history" in role or "kartograf" in role or "czyt" in role:
		return "researcher"
	if "straż" in role or "guard" in role or "patrol" in role:
		return "guard"
	if "tropic" in role or "ranger" in role or "wędrow" in role or "alpin" in role or "nurek" in role:
		return "ranger"
	if trainer:
		return "trainer"
	return "citizen"

static func _accent_for(role: String, trainer: bool) -> Color:
	if trainer:
		return Color("e1c65f")
	if "technik" in role or "mechan" in role or "operator" in role:
		return Color("58d9d2")
	if "badacz" in role or "archiw" in role:
		return Color("78b5d8")
	if "med" in role:
		return Color("d6f0e8")
	return Color("d6bd73")

static func _hair_for(role: String) -> Color:
	var value: int = abs(role.hash())
	var palette: Array[Color] = [Color("382c36"), Color("4b3428"), Color("6b4c35"), Color("2c3447"), Color("785844"), Color("d3c0a0")]
	return palette[posmod(value, palette.size())]
