extends Node2D

const WORLD := Vector2(1600, 1000)
var camera_offset := Vector2(80, 80)
var zoom_level := 1.0
var selected := -1
var units: Array[Dictionary] = []
var message := "Tap a blue tank, then tap the battlefield to move it."
var ui_font: Font

func _ready() -> void:
    ui_font = ThemeDB.fallback_font
    units = [
        {"pos": Vector2(350, 360), "target": Vector2(350, 360), "team": 0},
        {"pos": Vector2(420, 400), "target": Vector2(420, 400), "team": 0},
        {"pos": Vector2(1180, 700), "target": Vector2(1180, 700), "team": 1},
        {"pos": Vector2(1260, 760), "target": Vector2(1260, 760), "team": 1}
    ]

func _process(delta: float) -> void:
    for unit in units:
        unit["pos"] = (unit["pos"] as Vector2).move_toward(unit["target"], 110.0 * delta)
    queue_redraw()

func _draw() -> void:
    var view := get_viewport_rect().size
    draw_rect(Rect2(Vector2.ZERO, view), Color("#17211f"), true)
    draw_set_transform(-camera_offset * zoom_level, 0.0, Vector2.ONE * zoom_level)
    draw_rect(Rect2(Vector2.ZERO, WORLD), Color("#263a31"), true)
    for x in range(0, 1600, 80):
        draw_line(Vector2(x, 0), Vector2(x, 1000), Color("#314a3e"), 1.0)
    for y in range(0, 1000, 80):
        draw_line(Vector2(0, y), Vector2(1600, y), Color("#314a3e"), 1.0)
    _building(Vector2(230, 220), Vector2(130, 95), Color("#43a5ff"), "COMMAND BASE")
    _building(Vector2(420, 250), Vector2(90, 68), Color("#43a5ff"), "FACTORY")
    _building(Vector2(1270, 720), Vector2(130, 95), Color("#e65b55"), "ENEMY HQ")
    for i in range(units.size()):
        var u := units[i]
        var p: Vector2 = u["pos"]
        var c := Color("#43a5ff") if u["team"] == 0 else Color("#e65b55")
        if i == selected:
            draw_arc(p, 30, 0, TAU, 32, Color("#ffe66d"), 4.0)
            draw_line(p, u["target"], Color("#ffe66d"), 2.0)
        draw_colored_polygon(PackedVector2Array([p+Vector2(-23,-12), p+Vector2(13,-12), p+Vector2(25,0), p+Vector2(13,12), p+Vector2(-23,12)]), c)
        draw_rect(Rect2(p + Vector2(-5,-5), Vector2(25,10)), c.lightened(0.2), true)
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
    draw_rect(Rect2(0, 0, view.x, 62), Color("#11191f"), true)
    draw_string(ui_font, Vector2(18, 27), "YOUSEF GENERAL", HORIZONTAL_ALIGNMENT_LEFT, -1, 23, Color.WHITE)
    draw_string(ui_font, Vector2(18, 49), "COMMAND BASE  |  RESOURCES: 500", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#8ed0ff"))
    draw_rect(Rect2(0, view.y - 58, view.x, 58), Color("#11191f"), true)
    draw_string(ui_font, Vector2(18, view.y - 25), message, HORIZONTAL_ALIGNMENT_LEFT, view.x - 36, 15, Color.WHITE)

func _building(pos: Vector2, size: Vector2, c: Color, label: String) -> void:
    var rect := Rect2(pos - size / 2, size)
    draw_rect(rect, Color("#182329"), true)
    draw_rect(rect, c, false, 5.0)
    draw_rect(Rect2(rect.position + Vector2(12, 12), rect.size - Vector2(24, 24)), c.darkened(0.5), true)
    draw_string(ui_font, rect.position + Vector2(0, -8), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch and event.pressed:
        _tap(event.position)
    elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        _tap(event.position)
    elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
        zoom_level = min(1.4, zoom_level + 0.1)
    elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
        zoom_level = max(0.55, zoom_level - 0.1)

func _tap(screen: Vector2) -> void:
    var view := get_viewport_rect().size
    if screen.y < 62 or screen.y > view.y - 58:
        return
    var world_pos := screen / zoom_level + camera_offset
    for i in range(units.size()):
        if units[i]["team"] == 0 and (units[i]["pos"] as Vector2).distance_to(world_pos) < 40:
            selected = i
            message = "Tank selected. Tap the battlefield to move."
            return
    if selected >= 0:
        units[selected]["target"] = world_pos.clamp(Vector2(20, 20), WORLD - Vector2(20, 20))
        message = "Move order issued!"
    else:
        message = "Select a blue tank first."
