extends Node2D

const TILE := 32
const MAP_W := 20
const MAP_H := 11
var player_tile := Vector2i(10, 6)
var info_label: Label

func _ready() -> void:
    _build_ui()
    queue_redraw()

func _build_ui() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)

    var title := Label.new()
    title.text = "SOMADEX"
    title.position = Vector2(18, 12)
    title.add_theme_font_size_override("font_size", 24)
    layer.add_child(title)

    info_label = Label.new()
    info_label.text = "Pierwszy build Android • użyj strzałek"
    info_label.position = Vector2(18, 43)
    info_label.add_theme_font_size_override("font_size", 13)
    layer.add_child(info_label)

    _make_button(layer, "^", Vector2(82, 246), Vector2i.UP)
    _make_button(layer, "<", Vector2(24, 298), Vector2i.LEFT)
    _make_button(layer, "v", Vector2(82, 298), Vector2i.DOWN)
    _make_button(layer, ">", Vector2(140, 298), Vector2i.RIGHT)

    var status := Label.new()
    status.text = "SOMASKAN LAB • PROTOTYP ŚWIATA"
    status.position = Vector2(380, 326)
    status.add_theme_font_size_override("font_size", 11)
    layer.add_child(status)

func _make_button(layer: CanvasLayer, text_value: String, pos: Vector2, direction: Vector2i) -> void:
    var button := Button.new()
    button.text = text_value
    button.position = pos
    button.size = Vector2(52, 46)
    button.add_theme_font_size_override("font_size", 22)
    button.pressed.connect(func(): _move_player(direction))
    layer.add_child(button)

func _move_player(direction: Vector2i) -> void:
    var target := player_tile + direction
    if target.x < 0 or target.y < 0 or target.x >= MAP_W or target.y >= MAP_H:
        return
    player_tile = target
    info_label.text = "Pozycja: %d, %d" % [player_tile.x, player_tile.y]
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        match event.keycode:
            KEY_UP, KEY_W:
                _move_player(Vector2i.UP)
            KEY_DOWN, KEY_S:
                _move_player(Vector2i.DOWN)
            KEY_LEFT, KEY_A:
                _move_player(Vector2i.LEFT)
            KEY_RIGHT, KEY_D:
                _move_player(Vector2i.RIGHT)

func _draw() -> void:
    draw_rect(Rect2(0, 0, 640, 360), Color("101a24"))

    var origin := Vector2(0, 72)
    for y in range(MAP_H):
        for x in range(MAP_W):
            var c := Color("3f8249")
            if y in [4, 5, 6] or x in [9, 10]:
                c = Color("bda56b")
            if (x + y) % 7 == 0:
                c = c.lightened(0.08)
            var rect := Rect2(origin + Vector2(x * TILE, y * TILE), Vector2(TILE, TILE))
            draw_rect(rect, c)
            draw_rect(rect, Color(0, 0, 0, 0.12), false, 1.0)

    for tree in [Vector2i(2, 1), Vector2i(3, 2), Vector2i(16, 2), Vector2i(17, 3), Vector2i(4, 8), Vector2i(15, 8)]:
        var p := origin + Vector2(tree.x * TILE + 16, tree.y * TILE + 16)
        draw_circle(p, 11, Color("1d5b35"))
        draw_rect(Rect2(p.x - 3, p.y + 8, 6, 10), Color("6b4930"))

    var px := origin.x + player_tile.x * TILE + 6
    var py := origin.y + player_tile.y * TILE + 5
    draw_rect(Rect2(px, py, 20, 23), Color("d8e3e7"))
    draw_rect(Rect2(px + 4, py + 4, 12, 8), Color("3c9aa8"))
    draw_rect(Rect2(px + 6, py + 14, 4, 8), Color("263648"))
    draw_rect(Rect2(px + 12, py + 14, 4, 8), Color("263648"))
