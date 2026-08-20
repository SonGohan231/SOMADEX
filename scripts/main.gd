extends Node2D

# SOMADEX mobile vertical slice — title, intro, starter choice, exploration,
# functional pause menu, saving/loading and a simple turn-based encounter.

enum GameState { TITLE, INTRO, STARTER, WORLD, MENU, BATTLE }

const BASE_W := 360.0
const BASE_H := 800.0
const TILE := 24.0
const WORLD_TOP := 48.0
const WORLD_COLS := 15
const WORLD_ROWS := 23
const SAVE_PATH := "user://somadex_save.json"

const INK := Color("10212b")
const INK_2 := Color("173745")
const CYAN := Color("43e4dd")
const CYAN_DARK := Color("198b8c")
const CREAM := Color("f6f0d8")
const GOLD := Color("f3c969")
const GRASS := Color("5ea85e")
const GRASS_DARK := Color("3c7c4b")
const PATH := Color("c9ad72")
const PATH_DARK := Color("9a8056")
const WATER := Color("3f9bb5")
const WATER_DARK := Color("2b6f8a")
const PANEL := Color("122934")
const PANEL_2 := Color("1b3f4c")
const RED := Color("ef6b68")
const GREEN := Color("6fce7a")

var state: GameState = GameState.TITLE
var title_index := 0
var intro_page := 0
var starter_index := 0
var chosen_starter := ""

var player_tile := Vector2i(7, 20)
var player_from_px := Vector2.ZERO
var player_to_px := Vector2.ZERO
var player_px := Vector2.ZERO
var player_facing := Vector2i.UP
var moving := false
var move_progress := 0.0
var walk_frame := 0
var encounter_steps := 0

var dialog_text := ""
var toast_text := ""
var toast_until := 0
var menu_index := 0
var menu_section := "root"
var touch_haptics := true

var player_level := 5
var player_max_hp := 28
var player_hp := 28
var trainer_level := 1
var trainer_xp := 0
var discovered := 1

var battle_enemy := "Wahlik"
var battle_enemy_level := 3
var battle_enemy_max_hp := 22
var battle_enemy_hp := 22
var battle_mode := "root"
var battle_index := 0
var battle_log := "Dziki Wahlik dostraja się do pola!"
var battle_finished := false

var rng := RandomNumberGenerator.new()
var font: Font

func _ready() -> void:
    rng.randomize()
    font = ThemeDB.fallback_font
    player_px = _tile_to_px(player_tile)
    player_from_px = player_px
    player_to_px = player_px
    set_process(true)
    queue_redraw()

func _process(delta: float) -> void:
    if state == GameState.WORLD and moving:
        move_progress += delta * 7.0
        var t := min(move_progress, 1.0)
        var ease := t * t * (3.0 - 2.0 * t)
        player_px = player_from_px.lerp(player_to_px, ease)
        walk_frame = int(Time.get_ticks_msec() / 130) % 2
        if t >= 1.0:
            moving = false
            player_tile = _px_to_tile(player_to_px)
            player_px = player_to_px
            _after_step()
    queue_redraw()

func _draw() -> void:
    match state:
        GameState.TITLE:
            _draw_title()
        GameState.INTRO:
            _draw_intro()
        GameState.STARTER:
            _draw_starter_select()
        GameState.WORLD:
            _draw_world()
        GameState.MENU:
            _draw_world()
            _draw_menu_overlay()
        GameState.BATTLE:
            _draw_battle()

    if toast_text != "" and Time.get_ticks_msec() < toast_until:
        _draw_toast(toast_text)

func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        _handle_key(event.keycode)
    elif event is InputEventScreenTouch and event.pressed:
        _handle_touch(event.position)

func _handle_key(keycode: Key) -> void:
    match state:
        GameState.TITLE:
            if keycode in [KEY_UP, KEY_W]:
                title_index = max(0, title_index - 1)
            elif keycode in [KEY_DOWN, KEY_S]:
                title_index = min(2, title_index + 1)
            elif keycode in [KEY_ENTER, KEY_SPACE, KEY_Z]:
                _activate_title_choice()
        GameState.INTRO:
            if keycode in [KEY_ENTER, KEY_SPACE, KEY_Z, KEY_RIGHT]:
                _advance_intro()
            elif keycode in [KEY_ESCAPE, KEY_X]:
                _skip_intro()
        GameState.STARTER:
            if keycode in [KEY_LEFT, KEY_A]:
                starter_index = (starter_index + 2) % 3
            elif keycode in [KEY_RIGHT, KEY_D]:
                starter_index = (starter_index + 1) % 3
            elif keycode in [KEY_ENTER, KEY_SPACE, KEY_Z]:
                _choose_starter()
        GameState.WORLD:
            if dialog_text != "":
                if keycode in [KEY_ENTER, KEY_SPACE, KEY_Z, KEY_ESCAPE, KEY_X]:
                    dialog_text = ""
                return
            if keycode in [KEY_UP, KEY_W]:
                _request_move(Vector2i.UP)
            elif keycode in [KEY_DOWN, KEY_S]:
                _request_move(Vector2i.DOWN)
            elif keycode in [KEY_LEFT, KEY_A]:
                _request_move(Vector2i.LEFT)
            elif keycode in [KEY_RIGHT, KEY_D]:
                _request_move(Vector2i.RIGHT)
            elif keycode in [KEY_ENTER, KEY_SPACE, KEY_Z]:
                _interact()
            elif keycode in [KEY_ESCAPE, KEY_X, KEY_M]:
                _open_menu()
        GameState.MENU:
            _handle_menu_key(keycode)
        GameState.BATTLE:
            _handle_battle_key(keycode)

func _handle_touch(pos: Vector2) -> void:
    _haptic()
    match state:
        GameState.TITLE:
            for i in range(3):
                if Rect2(48, 430 + i * 62, 264, 50).has_point(pos):
                    title_index = i
                    _activate_title_choice()
                    return
        GameState.INTRO:
            if Rect2(44, 686, 272, 62).has_point(pos):
                _advance_intro()
            elif Rect2(256, 38, 76, 36).has_point(pos):
                _skip_intro()
        GameState.STARTER:
            for i in range(3):
                var r := Rect2(26 + i * 110, 278, 88, 230)
                if r.has_point(pos):
                    starter_index = i
                    return
            if Rect2(66, 650, 228, 62).has_point(pos):
                _choose_starter()
        GameState.WORLD:
            if dialog_text != "":
                if Rect2(18, 560, 324, 122).has_point(pos):
                    dialog_text = ""
                return
            if _dpad_rect("up").has_point(pos):
                _request_move(Vector2i.UP)
            elif _dpad_rect("down").has_point(pos):
                _request_move(Vector2i.DOWN)
            elif _dpad_rect("left").has_point(pos):
                _request_move(Vector2i.LEFT)
            elif _dpad_rect("right").has_point(pos):
                _request_move(Vector2i.RIGHT)
            elif _world_button_rect("a").has_point(pos):
                _interact()
            elif _world_button_rect("menu").has_point(pos):
                _open_menu()
        GameState.MENU:
            _handle_menu_touch(pos)
        GameState.BATTLE:
            _handle_battle_touch(pos)

func _activate_title_choice() -> void:
    match title_index:
        0:
            _new_game()
        1:
            if FileAccess.file_exists(SAVE_PATH):
                _load_game()
            else:
                _show_toast("Brak zapisu gry")
        2:
            intro_page = 3
            state = GameState.INTRO

func _new_game() -> void:
    chosen_starter = ""
    player_tile = Vector2i(7, 20)
    player_px = _tile_to_px(player_tile)
    player_hp = player_max_hp
    trainer_level = 1
    trainer_xp = 0
    discovered = 1
    intro_page = 0
    state = GameState.INTRO

func _advance_intro() -> void:
    if intro_page >= 2:
        state = GameState.STARTER
        starter_index = 0
    else:
        intro_page += 1

func _skip_intro() -> void:
    state = GameState.STARTER
    starter_index = 0

func _choose_starter() -> void:
    var starters := ["Luzik", "Bocznik", "Nucik"]
    chosen_starter = starters[starter_index]
    player_hp = player_max_hp
    discovered = 1
    state = GameState.WORLD
    dialog_text = "Dr Irena: %s reaguje na Twój rezonans.\nRuszaj do Stacji Somaskan na północy." % chosen_starter
    _save_game()

func _request_move(direction: Vector2i) -> void:
    if moving or dialog_text != "":
        return
    player_facing = direction
    var target := player_tile + direction
    if not _is_walkable(target):
        return
    moving = true
    move_progress = 0.0
    player_from_px = _tile_to_px(player_tile)
    player_to_px = _tile_to_px(target)

func _after_step() -> void:
    encounter_steps += 1
    if _tile_code(player_tile) == "G" and encounter_steps >= 3:
        if rng.randf() < 0.22:
            encounter_steps = 0
            _start_battle()

func _interact() -> void:
    if moving:
        return
    var target := player_tile + player_facing
    var tile := _tile_code(target)
    if tile == "N":
        dialog_text = "Mira: W wysokiej trawie pojawiają się dzikie Somaskany.\nBuduj kombinacje, nie tylko siłę ataku."
    elif tile == "S":
        dialog_text = "TABLICA: Miasteczko VELA\n↑ Stacja Somaskan   → Szlak Rezonansu"
    elif tile == "C":
        player_hp = player_max_hp
        dialog_text = "Stacja Somaskan: drużyna została w pełni zregenerowana."
    elif tile == "H":
        dialog_text = "Drzwi są zamknięte. Ktoś zostawił notatkę o zaginionym module."
    else:
        dialog_text = ""

func _open_menu() -> void:
    if moving:
        return
    menu_index = 0
    menu_section = "root"
    state = GameState.MENU

func _handle_menu_key(keycode: Key) -> void:
    if menu_section != "root":
        if keycode in [KEY_ESCAPE, KEY_X, KEY_BACKSPACE]:
            menu_section = "root"
        return
    if keycode in [KEY_UP, KEY_W]:
        menu_index = (menu_index + 6) % 7
    elif keycode in [KEY_DOWN, KEY_S]:
        menu_index = (menu_index + 1) % 7
    elif keycode in [KEY_ENTER, KEY_SPACE, KEY_Z]:
        _activate_menu_item()
    elif keycode in [KEY_ESCAPE, KEY_X, KEY_M]:
        state = GameState.WORLD

func _handle_menu_touch(pos: Vector2) -> void:
    if menu_section != "root":
        if Rect2(18, 724, 126, 48).has_point(pos):
            menu_section = "root"
        return
    for i in range(7):
        if Rect2(34, 142 + i * 65, 292, 52).has_point(pos):
            menu_index = i
            _activate_menu_item()
            return

func _activate_menu_item() -> void:
    match menu_index:
        0:
            menu_section = "party"
        1:
            menu_section = "dex"
        2:
            menu_section = "bag"
        3:
            menu_section = "trainer"
        4:
            _save_game()
            _show_toast("Gra zapisana")
        5:
            menu_section = "settings"
            touch_haptics = not touch_haptics
            _show_toast("Wibracje: %s" % ("WŁ." if touch_haptics else "WYŁ."))
        6:
            state = GameState.WORLD

func _save_game() -> void:
    if chosen_starter == "":
        return
    var data := {
        "starter": chosen_starter,
        "player_x": player_tile.x,
        "player_y": player_tile.y,
        "player_hp": player_hp,
        "trainer_level": trainer_level,
        "trainer_xp": trainer_xp,
        "discovered": discovered,
        "haptics": touch_haptics
    }
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(data))

func _load_game() -> void:
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if not file:
        _show_toast("Nie udało się odczytać zapisu")
        return
    var data = JSON.parse_string(file.get_as_text())
    if typeof(data) != TYPE_DICTIONARY:
        _show_toast("Uszkodzony zapis")
        return
    chosen_starter = str(data.get("starter", "Luzik"))
    player_tile = Vector2i(int(data.get("player_x", 7)), int(data.get("player_y", 20)))
    player_px = _tile_to_px(player_tile)
    player_hp = int(data.get("player_hp", player_max_hp))
    trainer_level = int(data.get("trainer_level", 1))
    trainer_xp = int(data.get("trainer_xp", 0))
    discovered = int(data.get("discovered", 1))
    touch_haptics = bool(data.get("haptics", true))
    dialog_text = "Zapis wczytany. Witaj ponownie w VELA."
    state = GameState.WORLD

func _start_battle() -> void:
    battle_enemy = ["Wahlik", "Milimik", "Dudnik"][rng.randi_range(0, 2)]
    battle_enemy_level = rng.randi_range(2, 4)
    battle_enemy_max_hp = 17 + battle_enemy_level * 2
    battle_enemy_hp = battle_enemy_max_hp
    battle_mode = "root"
    battle_index = 0
    battle_finished = false
    battle_log = "Dziki %s Lv.%d pojawia się z wysokiej trawy!" % [battle_enemy, battle_enemy_level]
    state = GameState.BATTLE

func _handle_battle_key(keycode: Key) -> void:
    if battle_finished:
        if keycode in [KEY_ENTER, KEY_SPACE, KEY_Z, KEY_ESCAPE, KEY_X]:
            state = GameState.WORLD
        return
    if battle_mode == "root":
        if keycode in [KEY_LEFT, KEY_A]:
            battle_index = max(0, battle_index - 1)
        elif keycode in [KEY_RIGHT, KEY_D]:
            battle_index = min(3, battle_index + 1)
        elif keycode in [KEY_ENTER, KEY_SPACE, KEY_Z]:
            _battle_activate_root()
    else:
        if keycode in [KEY_UP, KEY_W]:
            battle_index = (battle_index + 3) % 4
        elif keycode in [KEY_DOWN, KEY_S]:
            battle_index = (battle_index + 1) % 4
        elif keycode in [KEY_ENTER, KEY_SPACE, KEY_Z]:
            _battle_use_move(battle_index)
        elif keycode in [KEY_ESCAPE, KEY_X]:
            battle_mode = "root"
            battle_index = 0

func _handle_battle_touch(pos: Vector2) -> void:
    if battle_finished:
        if Rect2(30, 666, 300, 82).has_point(pos):
            state = GameState.WORLD
        return
    if battle_mode == "root":
        for i in range(4):
            var col := i % 2
            var row := i / 2
            var r := Rect2(24 + col * 158, 642 + row * 58, 146, 48)
            if r.has_point(pos):
                battle_index = i
                _battle_activate_root()
                return
    else:
        for i in range(4):
            if Rect2(26, 606 + i * 42, 308, 36).has_point(pos):
                battle_index = i
                _battle_use_move(i)
                return

func _battle_activate_root() -> void:
    match battle_index:
        0:
            battle_mode = "moves"
            battle_index = 0
        1:
            battle_log = "Na razie walczy tylko %s." % chosen_starter
        2:
            var heal := min(8, player_max_hp - player_hp)
            player_hp += heal
            battle_log = "Tonik przywraca %d HP." % heal
            _enemy_turn()
        3:
            if rng.randf() < 0.78:
                battle_log = "Udało się wycofać bezpiecznie."
                battle_finished = true
            else:
                battle_log = "Nie udało się uciec!"
                _enemy_turn()

func _battle_use_move(index: int) -> void:
    var moves := [
        {"name":"Impuls warstwowy", "min":6, "max":9},
        {"name":"Ślizg styczny", "min":4, "max":7},
        {"name":"Mikrofala", "min":5, "max":8},
        {"name":"Dostrojenie", "min":3, "max":5}
    ]
    var move: Dictionary = moves[index]
    var damage := rng.randi_range(int(move["min"]), int(move["max"]))
    if index == 3 and player_hp < player_max_hp / 2:
        damage += 4
    battle_enemy_hp = max(0, battle_enemy_hp - damage)
    battle_log = "%s używa: %s!  -%d HP" % [chosen_starter, move["name"], damage]
    battle_mode = "root"
    battle_index = 0
    if battle_enemy_hp <= 0:
        trainer_xp += 24
        discovered = max(discovered, 2)
        battle_log = "%s traci rezonans!  +24 EXP trenera." % battle_enemy
        battle_finished = true
        _save_game()
    else:
        _enemy_turn()

func _enemy_turn() -> void:
    if battle_finished:
        return
    var damage := rng.randi_range(3, 6)
    player_hp = max(0, player_hp - damage)
    battle_log += "\n%s odpowiada falą: -%d HP." % [battle_enemy, damage]
    if player_hp <= 0:
        player_hp = player_max_hp
        player_tile = Vector2i(7, 20)
        player_px = _tile_to_px(player_tile)
        battle_log = "%s traci rezonans. Stacja VELA przywraca drużynę." % chosen_starter
        battle_finished = true
        _save_game()

func _tile_code(p: Vector2i) -> String:
    if p.x < 0 or p.y < 0 or p.x >= WORLD_COLS or p.y >= WORLD_ROWS:
        return "T"
    if p.x == 0 or p.y == 0 or p.x == WORLD_COLS - 1 or p.y == WORLD_ROWS - 1:
        return "T"

    if p.x >= 1 and p.x <= 4 and p.y >= 2 and p.y <= 5:
        return "~"

    if (p.x >= 2 and p.x <= 4 and p.y >= 7 and p.y <= 9) or (p.x >= 10 and p.x <= 12 and p.y >= 7 and p.y <= 9):
        return "H"
    if p.x >= 9 and p.x <= 11 and p.y >= 2 and p.y <= 4:
        return "C"

    if p == Vector2i(9, 10):
        return "N"
    if p == Vector2i(6, 13):
        return "S"

    if p.x in [7, 8] or p.y in [11, 12]:
        return "="

    if (p.x >= 2 and p.x <= 5 and p.y >= 14 and p.y <= 18) or (p.x >= 10 and p.x <= 13 and p.y >= 14 and p.y <= 19):
        return "G"

    var trees := [Vector2i(5, 3), Vector2i(6, 4), Vector2i(12, 5), Vector2i(3, 12), Vector2i(12, 12), Vector2i(5, 20), Vector2i(10, 21)]
    if p in trees:
        return "T"
    return "."

func _is_walkable(p: Vector2i) -> bool:
    return _tile_code(p) in [".", "=", "G"]

func _tile_to_px(tile: Vector2i) -> Vector2:
    return Vector2(tile.x * TILE, WORLD_TOP + tile.y * TILE)

func _px_to_tile(px: Vector2) -> Vector2i:
    return Vector2i(int(round(px.x / TILE)), int(round((px.y - WORLD_TOP) / TILE)))

func _draw_title() -> void:
    _fill_vertical_gradient(Color("071b26"), Color("123f4d"))
    var t := Time.get_ticks_msec() / 1000.0
    var pulse := 0.5 + 0.5 * sin(t * 2.2)
    var center := Vector2(180, 214)
    for r in [70.0, 98.0, 126.0]:
        draw_arc(center, r + pulse * 4.0, 0, TAU, 80, Color(0.26, 0.89, 0.87, 0.12), 2.0)
    draw_circle(center, 61, Color("153e4b"))
    draw_circle(center, 56, Color("205d67"))
    _draw_creature_icon(center + Vector2(-38, 3), 0, 1.15)
    _draw_creature_icon(center + Vector2(0, -10), 1, 1.30)
    _draw_creature_icon(center + Vector2(39, 5), 2, 1.10)

    _text(Vector2(47, 112), "SOMADEX", 45, Color("07151d"))
    _text(Vector2(44, 109), "SOMADEX", 45, CREAM)
    _text(Vector2(88, 143), "KRONIKI REZONANSU", 14, CYAN)
    _text(Vector2(74, 364), "Wybierz drogę. Zbuduj więź. Dostrój świat.", 12, Color("b9d9da"))

    var labels := ["NOWA GRA", "KONTYNUUJ", "O ŚWIECIE"]
    for i in range(3):
        var r := Rect2(48, 430 + i * 62, 264, 50)
        _draw_button(r, labels[i], i == title_index, true)
    if not FileAccess.file_exists(SAVE_PATH):
        _text(Vector2(228, 514), "brak zapisu", 10, Color("87a3a8"))
    _text(Vector2(106, 750), "SOMASKAN LAB • BUILD 0.2", 10, Color("6b9298"))

func _draw_intro() -> void:
    _fill_vertical_gradient(Color("08171e"), Color("133b43"))
    _text(Vector2(24, 54), "PROLOG", 13, CYAN)
    _draw_pill(Rect2(256, 38, 76, 36), "POMIŃ", false)

    if intro_page == 0:
        _text(Vector2(31, 126), "ŚWIAT NIE JEST CICHY.", 23, CREAM)
        _text(Vector2(31, 160), "Każda materia drga. Każda istota\nodpowiada własnym wzorem rezonansu.", 14, Color("c9dedd"))
        _draw_resonance_scene(Vector2(180, 360), 0)
    elif intro_page == 1:
        _text(Vector2(31, 126), "SOMASKANY SŁYSZĄ WIĘCEJ.", 21, CREAM)
        _text(Vector2(31, 160), "Nie są bronią. Są partnerami, które\nuczą się rytmu swojego trenera.", 14, Color("c9dedd"))
        _draw_resonance_scene(Vector2(180, 360), 1)
    elif intro_page == 2:
        _text(Vector2(31, 126), "DZIŚ ZACZYNA SIĘ TWOJA DROGA.", 20, CREAM)
        _text(Vector2(31, 160), "W laboratorium VELA czekają trzy\nstworzenia. Jedno wybierze Ciebie.", 14, Color("c9dedd"))
        _draw_resonance_scene(Vector2(180, 360), 2)
    else:
        _text(Vector2(31, 126), "O SOMADEX", 24, CREAM)
        _text(Vector2(31, 170), "Kolekcjonerskie RPG o więzi, eksploracji\ni taktycznej walce stworka oraz trenera.\n\nTa wersja zawiera działający pionowy wycinek:\nintro, wybór stworka, eksplorację, zapis, menu\noraz losowe walki w wysokiej trawie.", 13, Color("c9dedd"))
        _draw_resonance_scene(Vector2(180, 440), 1)

    _draw_button(Rect2(44, 686, 272, 62), "DALEJ  ›", true, true)
    _text(Vector2(148, 774), "%d / 3" % min(intro_page + 1, 3), 11, Color("7ea4aa"))

func _draw_starter_select() -> void:
    _fill_vertical_gradient(Color("0a2029"), Color("164551"))
    _text(Vector2(26, 62), "WYBIERZ PIERWSZY REZONANS", 18, CREAM)
    _text(Vector2(26, 90), "Każdy ma inną rolę taktyczną.", 12, Color("afd0d1"))

    var names := ["Luzik", "Bocznik", "Nucik"]
    var roles := ["wsparcie", "szybkość", "kontrola"]
    for i in range(3):
        var r := Rect2(26 + i * 110, 278, 88, 230)
        var selected := i == starter_index
        draw_rect(r, CYAN if selected else Color("2a5660"), false, 3.0)
        draw_rect(r.grow(-4), Color("102c36"), true)
        _draw_creature_icon(Vector2(r.position.x + 44, r.position.y + 72), i, 1.55)
        _text(Vector2(r.position.x + 12, r.position.y + 141), names[i], 16, CREAM)
        _text(Vector2(r.position.x + 12, r.position.y + 165), roles[i], 10, CYAN if selected else Color("90adb1"))
        _mini_stat(Vector2(r.position.x + 12, r.position.y + 187), 54 + i * 12, selected)
        _mini_stat(Vector2(r.position.x + 12, r.position.y + 205), 76 - i * 10, selected)

    var descs := [
        "Stabilny partner. Łączy statusy i wzmacnia kombinacje.",
        "Szybki zwiadowca. Dobrze kontruje i zmienia pozycję.",
        "Czuły rezonator. Kontroluje pole i zakłóca przeciwnika."
    ]
    _panel(Rect2(26, 534, 308, 88), false)
    _text(Vector2(42, 564), descs[starter_index], 12, Color("d6e4de"))
    _draw_button(Rect2(66, 650, 228, 62), "WYBIERAM %s" % names[starter_index].to_upper(), true, true)
    _text(Vector2(112, 756), "Możesz złapać pozostałe później", 10, Color("7da0a5"))

func _draw_world() -> void:
    draw_rect(Rect2(0, 0, BASE_W, BASE_H), Color("09171d"))
    for y in range(WORLD_ROWS):
        for x in range(WORLD_COLS):
            _draw_world_tile(Vector2i(x, y), Rect2(x * TILE, WORLD_TOP + y * TILE, TILE, TILE))

    _draw_player(player_px + Vector2(TILE * 0.5, TILE * 0.58))

    draw_rect(Rect2(0, 0, BASE_W, WORLD_TOP), Color("0d2732"))
    _text(Vector2(14, 29), "VELA • SZLAK 01", 12, CREAM)
    _text(Vector2(244, 29), "%s  Lv.%d" % [chosen_starter if chosen_starter != "" else "Luzik", player_level], 11, CYAN)

    draw_rect(Rect2(0, 600, BASE_W, 200), Color("09171d"))
    draw_rect(Rect2(0, 600, BASE_W, 2), Color("24505c"))
    _draw_dpad()
    _draw_world_actions()

    if dialog_text != "":
        _panel(Rect2(18, 550, 324, 132), true)
        _text(Vector2(34, 583), dialog_text, 13, CREAM)
        _text(Vector2(284, 658), "A ›", 12, CYAN)

func _draw_world_tile(tile: Vector2i, r: Rect2) -> void:
    var code := _tile_code(tile)
    var alt := ((tile.x + tile.y) % 2) == 0
    match code:
        ".":
            draw_rect(r, GRASS.lightened(0.03) if alt else GRASS)
            draw_rect(Rect2(r.position + Vector2(4, 16), Vector2(2, 4)), GRASS_DARK)
            if (tile.x * 3 + tile.y) % 5 == 0:
                draw_rect(Rect2(r.position + Vector2(15, 5), Vector2(2, 3)), Color("8ac56f"))
        "G":
            draw_rect(r, Color("4e9854") if alt else Color("48904f"))
            for gx in [4.0, 10.0, 17.0]:
                draw_line(r.position + Vector2(gx, 20), r.position + Vector2(gx - 2, 10 + int(gx) % 4), Color("255e3f"), 2)
                draw_line(r.position + Vector2(gx, 20), r.position + Vector2(gx + 3, 12), Color("6cb660"), 1)
        "=":
            draw_rect(r, PATH if alt else PATH.lightened(0.03))
            if (tile.x + tile.y * 2) % 4 == 0:
                draw_rect(Rect2(r.position + Vector2(5, 8), Vector2(4, 2)), PATH_DARK.lightened(0.12))
            if tile.x in [7, 8] and tile.x == 7:
                draw_line(r.position + Vector2(23, 0), r.position + Vector2(23, 24), Color(0,0,0,0.05), 1)
        "~":
            draw_rect(r, WATER if alt else WATER_DARK.lightened(0.08))
            var phase := int(Time.get_ticks_msec() / 300) % 8
            draw_line(r.position + Vector2(3 + phase % 4, 8), r.position + Vector2(14 + phase % 4, 8), Color("8bd4d7"), 1)
            draw_line(r.position + Vector2(8, 17), r.position + Vector2(20, 17), Color("2c7d9a"), 1)
        "T":
            draw_rect(r, GRASS_DARK)
            _draw_tree(r.position + Vector2(12, 13), 0.75)
        "H":
            draw_rect(r, Color("ad7654"))
            draw_rect(Rect2(r.position + Vector2(2, 2), Vector2(20, 7)), Color("7f493d"))
            draw_line(r.position + Vector2(2, 9), r.position + Vector2(22, 9), Color("d49a61"), 2)
            if tile.y == 9:
                draw_rect(Rect2(r.position + Vector2(8, 10), Vector2(8, 14)), Color("5b3b37"))
        "C":
            draw_rect(r, Color("d7e0d6"))
            draw_rect(Rect2(r.position + Vector2(2, 3), Vector2(20, 18)), Color("d9ede6"))
            draw_rect(Rect2(r.position + Vector2(8, 8), Vector2(8, 4)), CYAN_DARK)
            draw_rect(Rect2(r.position + Vector2(10, 6), Vector2(4, 8)), CYAN_DARK)
        "N":
            draw_rect(r, PATH)
            _draw_npc(r.position + Vector2(12, 14))
        "S":
            draw_rect(r, PATH)
            draw_rect(Rect2(r.position + Vector2(5, 5), Vector2(14, 10)), Color("7b573a"))
            draw_rect(Rect2(r.position + Vector2(11, 14), Vector2(3, 9)), Color("5a3d2d"))

func _draw_player(center: Vector2) -> void:
    var bob := -1.0 if moving and walk_frame == 1 else 0.0
    var p := center + Vector2(0, bob)
    draw_ellipse(p + Vector2(0, 8), Vector2(7, 3), Color(0,0,0,0.22))
    draw_rect(Rect2(p.x - 6, p.y - 12, 12, 7), Color("263644"))
    draw_rect(Rect2(p.x - 5, p.y - 8, 10, 6), Color("f0c59f"))
    draw_rect(Rect2(p.x - 6, p.y - 2, 12, 9), Color("35aab4"))
    draw_rect(Rect2(p.x - 6, p.y + 6, 5, 5), Color("1e3140"))
    draw_rect(Rect2(p.x + 1, p.y + 6, 5, 5), Color("1e3140"))
    if moving and walk_frame == 1:
        draw_rect(Rect2(p.x - 7, p.y + 9, 5, 2), Color("d7e0df"))
    else:
        draw_rect(Rect2(p.x + 2, p.y + 9, 5, 2), Color("d7e0df"))

func _draw_menu_overlay() -> void:
    draw_rect(Rect2(0, 0, BASE_W, BASE_H), Color(0.02, 0.07, 0.09, 0.86))
    _text(Vector2(28, 66), "MENU TRENERA", 22, CREAM)
    _text(Vector2(264, 64), "Lv.%d" % trainer_level, 13, CYAN)

    if menu_section != "root":
        _draw_menu_section(menu_section)
        return

    var items := ["DRUŻYNA", "SOMADEX", "PLECAK", "TRENER", "ZAPISZ GRĘ", "USTAWIENIA", "WRÓĆ DO GRY"]
    var icons := ["◈", "◇", "▣", "◆", "▤", "⚙", "×"]
    for i in range(7):
        var r := Rect2(34, 142 + i * 65, 292, 52)
        var selected := i == menu_index
        draw_rect(r, Color("1a4651") if selected else Color("102a33"), true)
        draw_rect(r, CYAN if selected else Color("2a5963"), false, 2)
        _text(Vector2(r.position.x + 18, r.position.y + 33), icons[i], 17, CYAN if selected else Color("729ba2"))
        _text(Vector2(r.position.x + 55, r.position.y + 33), items[i], 13, CREAM)
        if i < 4:
            _text(Vector2(r.end.x - 28, r.position.y + 33), "›", 17, CYAN if selected else Color("729ba2"))

func _draw_menu_section(section: String) -> void:
    _panel(Rect2(22, 108, 316, 588), false)
    var title := ""
    match section:
        "party":
            title = "DRUŻYNA"
        "dex":
            title = "SOMADEX"
        "bag":
            title = "PLECAK"
        "trainer":
            title = "TRENER"
        "settings":
            title = "USTAWIENIA"
    _text(Vector2(42, 150), title, 21, CYAN)

    match section:
        "party":
            _draw_creature_icon(Vector2(92, 244), starter_index, 1.45)
            _text(Vector2(150, 208), chosen_starter, 19, CREAM)
            _text(Vector2(150, 235), "Lv.%d   HP %d/%d" % [player_level, player_hp, player_max_hp], 12, Color("d2e4df"))
            _draw_hp_bar(Rect2(150, 250, 132, 10), player_hp, player_max_hp)
            _text(Vector2(48, 326), "Rola: partner rezonansowy", 12, Color("afc9c8"))
            _text(Vector2(48, 355), "Aktywne ruchy:", 12, CYAN)
            _text(Vector2(62, 388), "• Impuls warstwowy\n• Ślizg styczny\n• Mikrofala\n• Dostrojenie", 12, CREAM)
        "dex":
            _text(Vector2(48, 205), "ODKRYTO", 11, Color("8fb2b5"))
            _text(Vector2(48, 257), "%d / 150" % discovered, 33, CREAM)
            _text(Vector2(48, 304), "Pierwszy region został przygotowany na\n150 form stworzeń (50 linii ewolucyjnych).", 12, Color("b8cfcd"))
            _text(Vector2(48, 390), "001  %s     ● poznany" % chosen_starter, 12, CYAN)
            _text(Vector2(48, 424), "002  ???            ○ nieznany", 12, Color("768f93"))
            _text(Vector2(48, 458), "003  ???            ○ nieznany", 12, Color("768f93"))
        "bag":
            _text(Vector2(48, 202), "PRZEDMIOTY", 12, Color("8fb2b5"))
            _bag_row(Vector2(48, 244), "Tonik rezonansowy", "×3", "HP +8")
            _bag_row(Vector2(48, 314), "Kapsuła pomiarowa", "×5", "analiza")
            _bag_row(Vector2(48, 384), "Mapa VELA", "×1", "fabularny")
        "trainer":
            _text(Vector2(48, 204), "TRENER", 11, Color("8fb2b5"))
            _text(Vector2(48, 252), "Poziom %d" % trainer_level, 28, CREAM)
            _text(Vector2(48, 286), "EXP: %d / 100" % trainer_xp, 12, CYAN)
            _text(Vector2(48, 352), "Ścieżki rozwoju", 13, CYAN)
            _text(Vector2(48, 388), "TAKTYK      0\nOPIEKUN     0\nBADACZ      0\nTECHNIK     0\nAWANGARDZISTA  0", 12, CREAM)
            _text(Vector2(48, 548), "Specjalizacja odblokuje się na Lv.10.", 11, Color("94b1b3"))
        "settings":
            _text(Vector2(48, 210), "Wibracje dotykowe", 13, CREAM)
            _text(Vector2(250, 210), "WŁ." if touch_haptics else "WYŁ.", 13, CYAN)
            _text(Vector2(48, 258), "Tryb obrazu", 13, CREAM)
            _text(Vector2(250, 258), "PIXEL", 13, CYAN)
            _text(Vector2(48, 336), "Dotknięcie USTAWIENIA w menu głównym\nprzełącza wibracje.", 11, Color("91afb1"))

    _draw_button(Rect2(18, 724, 126, 48), "‹ WSTECZ", false, false)

func _draw_battle() -> void:
    _fill_vertical_gradient(Color("16394a"), Color("6ba98a"))
    draw_polygon(PackedVector2Array([Vector2(0,240), Vector2(70,175), Vector2(133,234), Vector2(205,160), Vector2(290,231), Vector2(360,178), Vector2(360,390), Vector2(0,390)]), PackedColorArray([Color("325c59")]))
    draw_rect(Rect2(0, 350, 360, 210), Color("82b66f"))
    draw_ellipse(Vector2(260, 320), Vector2(78, 20), Color(0.13,0.22,0.19,0.20))
    draw_ellipse(Vector2(105, 478), Vector2(92, 24), Color(0.13,0.22,0.19,0.20))

    _draw_battle_creature(Vector2(258, 285), 3, 1.55, false)
    _draw_battle_creature(Vector2(102, 450), starter_index, 1.9, true)

    _panel(Rect2(22, 54, 202, 92), false)
    _text(Vector2(38, 85), "%s  Lv.%d" % [battle_enemy, battle_enemy_level], 16, CREAM)
    _text(Vector2(38, 112), "REZ", 9, Color("8fb5b4"))
    _draw_hp_bar(Rect2(73, 103, 126, 10), battle_enemy_hp, battle_enemy_max_hp)

    _panel(Rect2(136, 458, 202, 104), false)
    _text(Vector2(152, 490), "%s  Lv.%d" % [chosen_starter, player_level], 16, CREAM)
    _text(Vector2(152, 516), "HP", 9, Color("8fb5b4"))
    _draw_hp_bar(Rect2(184, 507, 130, 10), player_hp, player_max_hp)
    _text(Vector2(248, 544), "%d / %d" % [player_hp, player_max_hp], 10, Color("c7d7d3"))

    draw_rect(Rect2(0, 584, 360, 216), Color("07181f"))
    _text(Vector2(24, 615), battle_log, 11, Color("d7e5df"))

    if battle_finished:
        _draw_button(Rect2(30, 690, 300, 62), "A  KONTYNUUJ", true, true)
    elif battle_mode == "root":
        var labels := ["ATAK", "STWORKI", "PLECAK", "UCIECZKA"]
        for i in range(4):
            var col := i % 2
            var row := i / 2
            var r := Rect2(24 + col * 158, 650 + row * 58, 146, 48)
            _draw_button(r, labels[i], i == battle_index, false)
    else:
        var moves := ["Impuls warstwowy   7", "Ślizg styczny      5", "Mikrofala          6", "Dostrojenie        4"]
        for i in range(4):
            var r := Rect2(26, 630 + i * 40, 308, 34)
            draw_rect(r, Color("173540") if i == battle_index else Color("0e252e"))
            draw_rect(r, CYAN if i == battle_index else Color("2a5058"), false, 1.5)
            _text(Vector2(r.position.x + 12, r.position.y + 23), moves[i], 11, CREAM)

func _draw_resonance_scene(center: Vector2, variant: int) -> void:
    var t := Time.get_ticks_msec() / 1000.0
    for i in range(5):
        var radius := 36.0 + i * 22.0 + sin(t * 2.0 + i) * 3.0
        draw_arc(center, radius, -2.4, 0.4, 48, Color(0.27, 0.9, 0.86, 0.08 + i * 0.025), 2)
    _draw_creature_icon(center + Vector2(-54, 20), variant, 1.8)
    draw_circle(center + Vector2(54, 10), 16, Color("f0c49c"))
    draw_rect(Rect2(center.x + 44, center.y + 26, 20, 45), Color("2c5967"))
    draw_line(center + Vector2(42, 40), center + Vector2(8, 26), CYAN, 2)
    draw_circle(center + Vector2(8, 26), 5, CYAN)

func _draw_creature_icon(center: Vector2, variant: int, scale: float) -> void:
    var body := [Color("77d8d3"), Color("f0a65f"), Color("b89be7"), Color("7ecb70")][variant % 4]
    var dark := body.darkened(0.35)
    draw_circle(center, 21 * scale, dark)
    draw_circle(center + Vector2(0, -2 * scale), 18 * scale, body)
    if variant % 3 == 0:
        for a in [-1, 1]:
            draw_polygon(PackedVector2Array([center + Vector2(a*11,-14)*scale, center + Vector2(a*25,-27)*scale, center + Vector2(a*18,-3)*scale]), PackedColorArray([body.lightened(0.18)]))
    elif variant % 3 == 1:
        draw_circle(center + Vector2(-18,-8)*scale, 8*scale, body.lightened(0.2))
        draw_circle(center + Vector2(18,-8)*scale, 8*scale, body.lightened(0.2))
    else:
        draw_polygon(PackedVector2Array([center + Vector2(-12,-14)*scale, center + Vector2(-2,-34)*scale, center + Vector2(2,-11)*scale]), PackedColorArray([body.lightened(0.2)]))
        draw_polygon(PackedVector2Array([center + Vector2(12,-14)*scale, center + Vector2(2,-34)*scale, center + Vector2(-2,-11)*scale]), PackedColorArray([body.lightened(0.2)]))
    draw_circle(center + Vector2(-6,-5)*scale, 4*scale, Color("0b1a24"))
    draw_circle(center + Vector2(6,-5)*scale, 4*scale, Color("0b1a24"))
    draw_circle(center + Vector2(-5.2,-6)*scale, 1.2*scale, Color.WHITE)
    draw_circle(center + Vector2(6.8,-6)*scale, 1.2*scale, Color.WHITE)
    draw_line(center + Vector2(-4,6)*scale, center + Vector2(4,6)*scale, dark, max(1.0, scale))

func _draw_battle_creature(center: Vector2, variant: int, scale: float, back: bool) -> void:
    var body := [Color("77d8d3"), Color("f0a65f"), Color("b89be7"), Color("7ecb70")][variant % 4]
    draw_circle(center, 30 * scale, body.darkened(0.30))
    draw_circle(center + Vector2(0,-4)*scale, 28 * scale, body)
    if back:
        draw_rect(Rect2(center.x-20*scale, center.y-10*scale, 40*scale, 6*scale), body.lightened(0.18))
        draw_polygon(PackedVector2Array([center+Vector2(-18,-18)*scale, center+Vector2(-28,-40)*scale, center+Vector2(-5,-22)*scale]), PackedColorArray([body.lightened(0.14)]))
        draw_polygon(PackedVector2Array([center+Vector2(18,-18)*scale, center+Vector2(28,-40)*scale, center+Vector2(5,-22)*scale]), PackedColorArray([body.lightened(0.14)]))
    else:
        draw_circle(center+Vector2(-10,-8)*scale, 5*scale, INK)
        draw_circle(center+Vector2(10,-8)*scale, 5*scale, INK)
        draw_line(center+Vector2(-7,9)*scale, center+Vector2(7,9)*scale, INK, 2*scale)

func _draw_tree(center: Vector2, scale: float) -> void:
    draw_rect(Rect2(center.x - 3*scale, center.y + 2*scale, 6*scale, 10*scale), Color("6c4932"))
    draw_circle(center + Vector2(0,-4)*scale, 11*scale, Color("235c3c"))
    draw_circle(center + Vector2(-6,-2)*scale, 7*scale, Color("2f7448"))
    draw_circle(center + Vector2(6,-2)*scale, 7*scale, Color("2b6943"))

func _draw_npc(center: Vector2) -> void:
    draw_circle(center + Vector2(0,-6), 5, Color("e8b98f"))
    draw_rect(Rect2(center.x-5, center.y-1, 10, 9), Color("8d6ac4"))
    draw_rect(Rect2(center.x-5, center.y+7, 4, 4), Color("283b48"))
    draw_rect(Rect2(center.x+1, center.y+7, 4, 4), Color("283b48"))

func _draw_dpad() -> void:
    for dir in ["up", "down", "left", "right"]:
        var r := _dpad_rect(dir)
        draw_rect(r, Color("18363f"))
        draw_rect(r, Color("2d5f68"), false, 2)
    _text(Vector2(84, 664), "▲", 20, CREAM)
    _text(Vector2(84, 758), "▼", 20, CREAM)
    _text(Vector2(37, 711), "◀", 20, CREAM)
    _text(Vector2(132, 711), "▶", 20, CREAM)

func _draw_world_actions() -> void:
    var a := _world_button_rect("a")
    draw_circle(a.get_center(), 35, Color("1d7a78"))
    draw_circle(a.get_center(), 35, CYAN_DARK, false, 2)
    _text(a.get_center() + Vector2(-8, 7), "A", 20, CREAM)
    var m := _world_button_rect("menu")
    _draw_pill(m, "MENU", false)

func _dpad_rect(dir: String) -> Rect2:
    match dir:
        "up":
            return Rect2(68, 620, 50, 50)
        "down":
            return Rect2(68, 714, 50, 50)
        "left":
            return Rect2(21, 667, 50, 50)
        _:
            return Rect2(115, 667, 50, 50)

func _world_button_rect(name: String) -> Rect2:
    if name == "a":
        return Rect2(252, 650, 70, 70)
    return Rect2(223, 735, 108, 38)

func _draw_button(r: Rect2, label: String, selected: bool, strong: bool) -> void:
    var fill := Color("1d555d") if selected else Color("102b34")
    if strong and selected:
        fill = Color("176d6e")
    draw_rect(r, Color(0,0,0,0.18))
    draw_rect(r.grow(-2), fill)
    draw_rect(r.grow(-2), CYAN if selected else Color("2c5b63"), false, 2)
    var size := 14 if len(label) < 18 else 12
    var text_size := font.get_string_size(label, HORIZONTAL_ALIGNMENT_CENTER, -1, size)
    _text(r.get_center() + Vector2(-text_size.x / 2.0, size * 0.35), label, size, CREAM)

func _draw_pill(r: Rect2, label: String, selected: bool) -> void:
    draw_rect(r, Color("173741"))
    draw_rect(r, CYAN if selected else Color("315c64"), false, 1.5)
    var size := 10
    var s := font.get_string_size(label, HORIZONTAL_ALIGNMENT_CENTER, -1, size)
    _text(r.get_center() + Vector2(-s.x/2, 4), label, size, CREAM)

func _panel(r: Rect2, bright: bool) -> void:
    draw_rect(r, Color(0,0,0,0.28))
    draw_rect(r.grow(-3), Color("153743") if bright else PANEL)
    draw_rect(r.grow(-3), CYAN_DARK if bright else Color("2a5660"), false, 2)

func _draw_hp_bar(r: Rect2, value: int, max_value: int) -> void:
    draw_rect(r, Color("0a171c"))
    var ratio := clamp(float(value) / max(1.0, float(max_value)), 0.0, 1.0)
    var c := RED
    if ratio > 0.5:
        c = GREEN
    elif ratio > 0.25:
        c = GOLD
    draw_rect(Rect2(r.position + Vector2(2,2), Vector2((r.size.x-4)*ratio, r.size.y-4)), c)

func _mini_stat(pos: Vector2, value: int, selected: bool) -> void:
    draw_rect(Rect2(pos, Vector2(64, 5)), Color("07181e"))
    draw_rect(Rect2(pos + Vector2(1,1), Vector2(62.0 * value / 100.0, 3)), CYAN if selected else Color("567b80"))

func _bag_row(pos: Vector2, name: String, count: String, note: String) -> void:
    draw_rect(Rect2(pos, Vector2(260, 52)), Color("173640"))
    _text(pos + Vector2(12, 21), name, 12, CREAM)
    _text(pos + Vector2(212, 21), count, 12, CYAN)
    _text(pos + Vector2(12, 42), note, 9, Color("84a5a8"))

func _draw_toast(message: String) -> void:
    var r := Rect2(54, 94, 252, 46)
    draw_rect(r, Color("06151b"))
    draw_rect(r, CYAN_DARK, false, 2)
    var s := font.get_string_size(message, HORIZONTAL_ALIGNMENT_CENTER, -1, 11)
    _text(r.get_center() + Vector2(-s.x/2, 5), message, 11, CREAM)

func _show_toast(message: String) -> void:
    toast_text = message
    toast_until = Time.get_ticks_msec() + 1800

func _haptic() -> void:
    if touch_haptics:
        Input.vibrate_handheld(18)

func _fill_vertical_gradient(top: Color, bottom: Color) -> void:
    for i in range(20):
        var t := float(i) / 19.0
        draw_rect(Rect2(0, i * BASE_H / 20.0, BASE_W, BASE_H / 20.0 + 1), top.lerp(bottom, t))

func _text(pos: Vector2, value: String, size: int, color: Color) -> void:
    var lines := value.split("\n")
    for i in range(lines.size()):
        draw_string(font, pos + Vector2(0, i * (size + 7)), lines[i], HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func draw_ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
    var pts := PackedVector2Array()
    for i in range(32):
        var a := TAU * float(i) / 32.0
        pts.append(center + Vector2(cos(a) * radii.x, sin(a) * radii.y))
    draw_colored_polygon(pts, color)
