extends Node2D

# Visual-only layer for SOMADEX Alpha 1 / VELA.
# It deliberately leaves the frozen Foundation gameplay logic untouched.
# Source creatures come from the Google Drive SOMADEX art pack and are decoded
# from compact base64 files so the project stays portable through text-only CI.

const TILE := 24.0
const WORLD_TOP := 48.0
const WORLD_COLS := 15
const WORLD_ROWS := 23

const STATE_TITLE := 0
const STATE_INTRO := 1
const STATE_STARTER := 2
const STATE_WORLD := 3
const STATE_MENU := 4
const STATE_BATTLE := 5

const STARTERS := ["Luzik", "Bocznik", "Nucik"]
const CREATURE_PATHS := {
    "Luzik": "res://assets/embedded/luzik.b64",
    "Bocznik": "res://assets/embedded/bocznik.b64",
    "Nucik": "res://assets/embedded/nucik.b64",
    "Wahlik": "res://assets/embedded/wahlik.b64",
    "Milimik": "res://assets/embedded/milimik.b64",
    "Dudnik": "res://assets/embedded/dudnik.b64",
}

var creatures: Dictionary = {}
var tileset: Texture2D
var trainer_sheet: Texture2D
var npc_sheet: Texture2D
var load_errors: Array[String] = []

func _ready() -> void:
    z_index = 100
    process_mode = Node.PROCESS_MODE_ALWAYS
    _load_assets()
    queue_redraw()

func _process(_delta: float) -> void:
    queue_redraw()

func _load_assets() -> void:
    for creature_name in CREATURE_PATHS.keys():
        var texture := _load_b64_png(CREATURE_PATHS[creature_name])
        if texture != null:
            creatures[creature_name] = texture
    tileset = _load_b64_png("res://assets/embedded/tileset.b64")
    trainer_sheet = _load_b64_png("res://assets/embedded/trainer_walk.b64")
    npc_sheet = _load_b64_png("res://assets/embedded/npc_mira.b64")

func _load_b64_png(path: String) -> Texture2D:
    if not FileAccess.file_exists(path):
        load_errors.append("missing: %s" % path)
        return null
    var encoded := FileAccess.get_file_as_string(path).strip_edges()
    if encoded.is_empty():
        load_errors.append("empty: %s" % path)
        return null
    var raw := Marshalls.base64_to_raw(encoded)
    var image := Image.new()
    var err := image.load_png_from_buffer(raw)
    if err != OK:
        load_errors.append("decode: %s (%s)" % [path, err])
        return null
    return ImageTexture.create_from_image(image)

func _draw() -> void:
    var main := get_tree().current_scene
    if main == null:
        return
    var state_variant = main.get("state")
    if state_variant == null:
        return
    var state := int(state_variant)
    match state:
        STATE_TITLE:
            _draw_title_art(main)
        STATE_INTRO:
            _draw_intro_art(main)
        STATE_STARTER:
            _draw_starter_art(main)
        STATE_WORLD:
            _draw_world_art(main)
        STATE_MENU:
            _draw_menu_art(main)
        STATE_BATTLE:
            _draw_battle_art(main)

func _draw_title_art(_main: Node) -> void:
    draw_circle(Vector2(180, 214), 67.0, Color("153e4b"))
    _draw_creature("Luzik", Vector2(139, 219), Vector2(62, 62), Color(1, 1, 1, 0.96))
    _draw_creature("Nucik", Vector2(180, 198), Vector2(72, 72), Color.WHITE)
    _draw_creature("Bocznik", Vector2(221, 220), Vector2(60, 60), Color(1, 1, 1, 0.96))

func _draw_intro_art(main: Node) -> void:
    var page := int(main.get("intro_page"))
    if page == 2:
        draw_circle(Vector2(180, 405), 92.0, Color(0.04, 0.15, 0.18, 0.82))
        _draw_creature("Luzik", Vector2(112, 416), Vector2(68, 68))
        _draw_creature("Nucik", Vector2(180, 388), Vector2(78, 78))
        _draw_creature("Bocznik", Vector2(248, 416), Vector2(68, 68))

func _draw_starter_art(main: Node) -> void:
    var selected := int(main.get("starter_index"))
    for i in range(3):
        var card_x := 26.0 + i * 110.0
        draw_rect(Rect2(card_x + 8, 294, 72, 106), Color("102c36"), true)
        var size := Vector2(70, 70) if i == selected else Vector2(60, 60)
        var center := Vector2(card_x + 44, 348)
        _draw_creature(STARTERS[i], center, size, Color.WHITE if i == selected else Color(0.82, 0.90, 0.90, 0.92))

func _draw_world_art(main: Node) -> void:
    if tileset == null:
        return
    var dialog := str(main.get("dialog_text"))
    var max_rows := WORLD_ROWS if dialog.is_empty() else 21
    for y in range(max_rows):
        for x in range(WORLD_COLS):
            var tile := Vector2i(x, y)
            var code := str(main.call("_tile_code", tile))
            var rect := Rect2(x * TILE, WORLD_TOP + y * TILE, TILE, TILE)
            match code:
                ".":
                    _draw_tile(rect, 0)
                "G":
                    _draw_tile(rect, 1)
                "=":
                    _draw_tile(rect, 2)
                "~":
                    _draw_tile(rect, 3)
                "T":
                    _draw_tile(rect, 4)
                "S":
                    _draw_tile(rect, 7)
                "N":
                    _draw_tile(rect, 2)
                    _draw_npc(rect)
                _:
                    pass
    _draw_large_tile(Rect2(2 * TILE, WORLD_TOP + 7 * TILE, 3 * TILE, 3 * TILE), 5)
    _draw_large_tile(Rect2(10 * TILE, WORLD_TOP + 7 * TILE, 3 * TILE, 3 * TILE), 5)
    _draw_large_tile(Rect2(9 * TILE, WORLD_TOP + 2 * TILE, 3 * TILE, 3 * TILE), 6)
    _draw_trainer(main)

func _draw_menu_art(main: Node) -> void:
    var section := str(main.get("menu_section"))
    if section == "party":
        var starter := _safe_starter(main)
        draw_circle(Vector2(92, 244), 50.0, Color("102c36"))
        _draw_creature(starter, Vector2(92, 244), Vector2(84, 84))
    elif section == "dex":
        var starter := _safe_starter(main)
        draw_rect(Rect2(44, 340, 270, 66), Color("0d2630"), true)
        _draw_creature(starter, Vector2(78, 373), Vector2(54, 54))
        _draw_creature("Wahlik", Vector2(139, 373), Vector2(48, 48), Color(1, 1, 1, 0.72))
        _draw_creature("Milimik", Vector2(200, 373), Vector2(48, 48), Color(1, 1, 1, 0.72))
        _draw_creature("Dudnik", Vector2(261, 373), Vector2(48, 48), Color(1, 1, 1, 0.72))

func _draw_battle_art(main: Node) -> void:
    var starter := _safe_starter(main)
    var enemy := str(main.get("battle_enemy"))
    if not creatures.has(enemy):
        enemy = "Wahlik"
    draw_circle(Vector2(258, 300), 58.0, Color(0.12, 0.28, 0.28, 0.92))
    draw_circle(Vector2(104, 450), 70.0, Color(0.10, 0.24, 0.24, 0.92))
    draw_arc(Vector2(258, 300), 51.0, 0, TAU, 48, Color(0.27, 0.88, 0.86, 0.38), 2.0)
    draw_arc(Vector2(104, 450), 62.0, 0, TAU, 48, Color(0.95, 0.79, 0.41, 0.28), 2.0)
    _draw_creature(enemy, Vector2(258, 294), Vector2(86, 86))
    _draw_creature(starter, Vector2(104, 444), Vector2(108, 108))

func _safe_starter(main: Node) -> String:
    var starter := str(main.get("chosen_starter"))
    if not creatures.has(starter):
        var index := clampi(int(main.get("starter_index")), 0, 2)
        starter = STARTERS[index]
    return starter

func _draw_creature(name: String, center: Vector2, size: Vector2, modulate: Color = Color.WHITE) -> void:
    var tex = creatures.get(name)
    if tex == null:
        return
    var rect := Rect2(center - size * 0.5, size)
    draw_texture_rect(tex, rect, false, modulate)

func _draw_tile(rect: Rect2, tile_index: int) -> void:
    if tileset == null:
        return
    draw_texture_rect_region(tileset, rect, Rect2(tile_index * 24, 0, 24, 24))

func _draw_large_tile(rect: Rect2, tile_index: int) -> void:
    if tileset == null:
        return
    draw_texture_rect_region(tileset, rect, Rect2(tile_index * 24, 0, 24, 24))

func _draw_npc(tile_rect: Rect2) -> void:
    if npc_sheet == null:
        return
    var frame := int(Time.get_ticks_msec() / 520) % 2
    var src := Rect2(frame * 24, 0, 24, 24)
    draw_texture_rect_region(npc_sheet, tile_rect, src)

func _draw_trainer(main: Node) -> void:
    if trainer_sheet == null:
        return
    var player_px: Vector2 = main.get("player_px")
    var facing: Vector2i = main.get("player_facing")
    var walk_frame := int(main.get("walk_frame"))
    var moving := bool(main.get("moving"))
    var phase := walk_frame if moving else 0
    var dir_base := 0
    if facing == Vector2i.LEFT:
        dir_base = 2
    elif facing == Vector2i.RIGHT:
        dir_base = 4
    elif facing == Vector2i.UP:
        dir_base = 6
    var frame := dir_base + phase
    var src := Rect2(frame * 24, 0, 24, 24)
    var dst := Rect2(player_px.x, player_px.y - 3, 24, 24)
    draw_rect(Rect2(player_px.x + 2, player_px.y, 20, 22), Color(0, 0, 0, 0.04), true)
    draw_texture_rect_region(trainer_sheet, dst, src)
