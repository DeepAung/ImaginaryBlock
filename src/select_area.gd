extends Area2D


var dragging: bool = false
var drag_start: Vector2 = Vector2.ZERO


func _ready() -> void:
	EventBus.cube_clicked.connect(clear_select_area)


func _unhandled_input(event: InputEvent) -> void:
	if Setting.is_menu_open(): return
	if Input.is_action_pressed("alt"): return
	
	if Input.is_action_just_pressed("left_click"):
		dragging = true
		drag_start = get_global_mouse_position()
	elif dragging and Input.is_action_just_released("left_click"):
		dragging = false
		queue_redraw()
		select_intersect_cubes()
	elif event is InputEventMouseMotion:
		queue_redraw()


func _draw() -> void:
	if not dragging: return
	
	draw_rect(
		Rect2(drag_start, get_global_mouse_position() - drag_start),
		Color(.5, .5, .5),
		false
	)


func select_intersect_cubes():
	var drag_end = get_global_mouse_position()
	
	var select_rect = RectangleShape2D.new()
	select_rect.size = (drag_end - drag_start).abs()
	
	$CollisionShape2D.shape = select_rect
	$CollisionShape2D.position = (drag_start + drag_end) / 2


func clear_select_area():
	$CollisionShape2D.shape = null
	$CollisionShape2D.position = Vector2.ZERO


func _on_area_entered(area: Area2D) -> void:
	var cube = area.get_parent() as Cube
	SelectManager.add_selected_cube(cube)
