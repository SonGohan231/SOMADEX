extends RefCounted

# Reverse visual-production pass starts from family 015.
# These three transparent 128x128 seeds are compact pixel redraws based on the
# approved SOMADEX source cards. All five action strips are generated from the
# seed with deterministic frame poses, so battle code receives true per-frame
# textures rather than one portrait reused for every state.

const ACTIONS: Array[String] = ["idle", "attack", "hurt", "faint", "special"]
const ACTION_FRAME_COUNTS: Dictionary = {
	"idle": 4,
	"attack": 6,
	"hurt": 3,
	"faint": 5,
	"special": 6
}

const _SEEDS: Dictionary = {
	"Rezonar": "UklGRogCAABXRUJQVlA4THsCAAAvf8AfEFegKJIUhyeFAvhFG1zyrycqURLJCvX0U8/iv5IW9E9BCmaUBADaxklAAtRTnwD4ldj8BwAgMYlIH/aWs/5/tWzFs8+pGYOsSJLFRnoUjsJQEAVROAqi8CgchaWwND3T78ka3Xd1RP8Ztm0bhrGxZP1kfHliPDrPCWW+E1MRiVeJmR61mK/ChEFqScyXiQlRxAC+2xaYAMEsme8Tk79lAuYbifJr9xQ3i+wf/05GdBPcy6r27wxkergRWSXQ6SBgBtx+V05bpYnJbhZSPhUTAzoIOHazbEpp3Zs47AlsZEeojTYisbdyBxydfLqZHUBwwmGn83HyLlksSyPsCQ7bOU04z1aWglQxn+NhqzsHGWn72wCpUz7KLM2NNlAyycsyK4vNMdogbLGsshC61DaQslgA1yUUWUC0BbAtF+pjIIkC1m1AxPUxJxbktmwDNWWpgdPiKajbThvQyQtpK4C/AYcn3mwDImLJtS//Szlhwn4bkEmLbBquE47P3D8f48XE2uWTmp2lgVjVy6bIc7V04MUol2ZNLg14Nepe0CFPEyFm595BmfL6pOWEHFOpXBnA2JgWAID8pPxo5903WgACWynn5Xcom+DrB5d5i8BLeYGXSJuWAoB9tqf7ycpX7+dEfR1s8IswgACvRW+LphjbQtjf+z6MUSY44Lx+nOe4/f44Uc1w1TnslxhiDrsumW/96igSA6eBI82rHHUC/gPGi9SE6AD4tLnFqW/gRUp27ijoTGbjjncxrO7gfAcVA2UZAacNcPQnY+cFzjrAfAFCLZ5xyG1MxqQ7nYlBdwB87fMgscz8WF+/Ny1AgMXw9a0FIPI89eebAAA=",
	"Wibrospiew": "UklGRvwBAABXRUJQVlA4TO8BAAAvf8AfEFegKJIUhyeFAvhFG1zyrycqURLJCvX0U8/iv5IW9E9BCmaUBADaxklAAtRTnwD4ldj8BwAgMYlIH/aWs/5/tWzFs8+pGYOsSJLsSCoKSyEpLIWhIAqi0BSGgigMzeouzY5Ue4+vyIj+T0D8DVVTKgz1xNAK9aSBFvTEACUG9MQANKMnRtaEQD0JGMqb6EdjqwuaEVv5ZVs0s5XtL/slOlHN/sovRCPbexBd6E3KXWzvOYq6O53B/rJfRzF+/Ao6AaKGbR9rxQ2Jb6iBKAFaxVsvJ5yhBOItCnQ/wtNhWxRAbCoHh8BwWx7YtliBoiw8hZsRLg481aIoT0eyuBXh+igoJ3k58A0Jnx0k4MiiMPBa3AiIE/bA1rEWk4HL4k5AnLBHiTTwWXErgKjZUEADnxVx+nogFswne9b3WYi3Xg+EmR/L3U/7FMTbrweKXNj99P70bsEC4kevN9cx3wsOEHxDfOTlVHgunrsiKz7zPlzy5FP/F9Hj2L2w1Qpi4lL0Ix72bj/t3aYV5UOPvM/pRPBwwROIPvSYwsIGiD7kc/QiZ7JL0YZsGwIKQHzwPRC5FI3IK60guiFmXkRzdKU8ic7AREMm5srdoBIIm4YME2H3g5zJzkQ3KBWJflCJ6AjBBIieQPO47vX+pAEA",
	"Nucik": "UklGRqgBAABXRUJQVlA4TJsBAAAvf8AfEE+gpm0k5sbXA2j70+j8ET0Ss22bdO7UI1pg5Av+PwjJTAOkikhAAi4KMAL4e1rA+Q8AiMwSn2GO2Pp/eXZZgmOQVdt23VaiUAqbgiiYgiiIgimYQvD6HDltdHofX2tH9H8C2r9PlaWkK1E1VuJIrgYrceCCbEVqoIKwrcCATUl2YLkkbIS524aCdB+AA6hGwFgVUItgPBVUIhjLLxgIShmrL/gyjErEeGBsBqKmFw4pRIw3IWpTVby4MXTWhc0NUEXwgkEEqKA0AbQ9vkft2/fWfuTHiQPeorP90I9TwBsEZdgGHglaDeo3AywJaJtTz4+Qe6Jwd4iIyGbdBYCCYzmZh23YH6KbpenL8/K0K5DvdLMws2u6iu66ZPd4YfrKPL079cWjKJvy7kGvSF7sfhe0jYmDtNumGkF/mjmbO1NfJCPwGrRdISIcAhyPvDdQENNY8LQvB9B2hugALRWJZwptb6itCxL7drC/xwIS2wCtGJgWEUy3D9xDXpINRI268vqw/7hsajth7YRaThqcZCcNTir5nx4A"
}

static var _base_cache: Dictionary = {}
static var _frame_cache: Dictionary = {}

static func has_animation(creature_name: String) -> bool:
	return _SEEDS.has(creature_name)

static func animation_count() -> int:
	return _SEEDS.size()

static func frame_count(action: String) -> int:
	return maxi(1, int(ACTION_FRAME_COUNTS.get(action, 1)))

static func frame_texture(creature_name: String, action: String, frame: int) -> Texture2D:
	if not has_animation(creature_name):
		return null
	if action not in ACTIONS:
		action = "idle"
	var safe_frame: int = clampi(frame, 0, frame_count(action) - 1)
	var key: String = "%s|%s|%d" % [creature_name, action, safe_frame]
	if _frame_cache.has(key):
		return _frame_cache[key] as Texture2D
	var base: Image = _base_image(creature_name)
	if base == null:
		return null
	var image: Image = _make_frame(base, action, safe_frame)
	var texture: Texture2D = ImageTexture.create_from_image(image)
	_frame_cache[key] = texture
	return texture

static func _base_image(creature_name: String) -> Image:
	if _base_cache.has(creature_name):
		return _base_cache[creature_name] as Image
	var bytes: PackedByteArray = Marshalls.base64_to_raw(str(_SEEDS.get(creature_name, "")))
	if bytes.is_empty():
		return null
	var image := Image.new()
	if image.load_webp_from_buffer(bytes) != OK:
		return null
	if image.get_size() != Vector2i(128, 128):
		image.resize(128, 128, Image.INTERPOLATE_NEAREST)
	_base_cache[creature_name] = image
	return image

static func _make_frame(base: Image, action: String, frame: int) -> Image:
	match action:
		"idle":
			var idle_y: Array[int] = [0, -2, 0, 1]
			return _place(base, 0, idle_y[frame], 1.0, 1.0, 1.0)
		"attack":
			var dx: Array[int] = [0, 4, 10, 18, 9, 0]
			var dy: Array[int] = [0, -1, -3, -5, -2, 0]
			var result: Image = _place(base, dx[frame], dy[frame], 1.04 if frame in [2, 3] else 1.0, 0.97 if frame == 3 else 1.0, 1.0)
			if frame in [2, 3, 4]:
				_draw_wave(result, 88 + int(dx[frame] / 2), frame)
			return result
		"hurt":
			var hurt_dx: Array[int] = [-5, 5, 0]
			var hurt: Image = _place(base, hurt_dx[frame], 2 if frame < 2 else 0, 0.98, 0.98, 1.0)
			_tint_red(hurt, 0.45 if frame < 2 else 0.18)
			return hurt
		"faint":
			var t: float = float(frame) / float(maxi(1, frame_count("faint") - 1))
			return _place(base, 0, int(round(22.0 * t)), 1.0 + 0.08 * t, 1.0 - 0.55 * t, 1.0 - 0.75 * t)
		"special":
			var p: float = float(frame) / float(maxi(1, frame_count("special") - 1))
			var pulse: float = 1.0 + 0.08 * sin(p * PI)
			var special: Image = _place(base, 0, -int(round(3.0 * sin(p * PI))), pulse, pulse, 1.0)
			_draw_ring(special, 26 + int(round(16.0 * sin(p * PI))), Color(0.70, 0.39, 1.0, 0.72))
			_draw_ring(special, 38 + int(round(18.0 * p)), Color(0.33, 0.84, 1.0, 0.48))
			_draw_notes(special, frame)
			return special
	return base.duplicate()

static func _place(base: Image, dx: int, dy: int, sx: float, sy: float, alpha: float) -> Image:
	var transformed: Image = base.duplicate()
	var width: int = maxi(1, int(round(128.0 * sx)))
	var height: int = maxi(1, int(round(128.0 * sy)))
	if width != 128 or height != 128:
		transformed.resize(width, height, Image.INTERPOLATE_NEAREST)
	if alpha < 0.999:
		_multiply_alpha(transformed, alpha)
	var canvas := Image.create(128, 128, false, Image.FORMAT_RGBA8)
	canvas.fill(Color(0, 0, 0, 0))
	var target_x: int = int((128 - width) / 2) + dx
	var target_y: int = 128 - height + dy
	_blit_clipped(canvas, transformed, target_x, target_y)
	return canvas

static func _blit_clipped(canvas: Image, source: Image, target_x: int, target_y: int) -> void:
	var source_x: int = maxi(0, -target_x)
	var source_y: int = maxi(0, -target_y)
	var dest_x: int = maxi(0, target_x)
	var dest_y: int = maxi(0, target_y)
	var width: int = mini(source.get_width() - source_x, 128 - dest_x)
	var height: int = mini(source.get_height() - source_y, 128 - dest_y)
	if width <= 0 or height <= 0:
		return
	canvas.blit_rect(source, Rect2i(source_x, source_y, width, height), Vector2i(dest_x, dest_y))

static func _multiply_alpha(image: Image, alpha: float) -> void:
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			var color: Color = image.get_pixel(x, y)
			if color.a <= 0.0:
				continue
			color.a *= alpha
			image.set_pixel(x, y, color)

static func _tint_red(image: Image, strength: float) -> void:
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			var color: Color = image.get_pixel(x, y)
			if color.a <= 0.0:
				continue
			color.r = lerpf(color.r, 1.0, strength)
			color.g = lerpf(color.g, 0.28, strength)
			color.b = lerpf(color.b, 0.28, strength)
			image.set_pixel(x, y, color)

static func _draw_wave(image: Image, center_x: int, phase: int) -> void:
	for radius: int in [18, 25, 32]:
		for degree: int in range(-65, 66, 10):
			var angle: float = deg_to_rad(float(degree))
			var x: int = center_x + int(round(cos(angle) * float(radius)))
			var y: int = 63 + int(round(sin(angle) * float(radius))) + (phase - 3) * 2
			_set_block(image, x, y, Color(0.40, 0.88, 1.0, 0.72), 1)

static func _draw_ring(image: Image, radius: int, color: Color) -> void:
	for degree: int in range(0, 360, 12):
		var angle: float = deg_to_rad(float(degree))
		var x: int = 64 + int(round(cos(angle) * float(radius)))
		var y: int = 64 + int(round(sin(angle) * float(radius)))
		_set_block(image, x, y, color, 1)

static func _draw_notes(image: Image, phase: int) -> void:
	var positions: Array[Vector2i] = [Vector2i(17, 40), Vector2i(104, 31), Vector2i(19, 88), Vector2i(108, 83)]
	for i: int in range(positions.size()):
		if (i + phase) % 2 != 0:
			continue
		var p: Vector2i = positions[i]
		p.y += int(round(sin(float(phase + i) * 1.5) * 5.0))
		var note: Color = Color(1.0, 0.84, 0.47, 0.88)
		_set_block(image, p.x, p.y + 3, note, 1)
		_set_block(image, p.x, p.y + 6, note, 2)
		_set_block(image, p.x + 3, p.y, note, 1)

static func _set_block(image: Image, cx: int, cy: int, color: Color, radius: int) -> void:
	for y: int in range(cy - radius, cy + radius + 1):
		for x: int in range(cx - radius, cx + radius + 1):
			if x >= 0 and x < 128 and y >= 0 and y < 128:
				image.set_pixel(x, y, color)
