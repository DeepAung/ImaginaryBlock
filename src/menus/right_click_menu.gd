extends Control


@onready var tutorial_menu: Control = $"../TutorialMenu"


func _ready() -> void:
	hide()


func _input(event: InputEvent) -> void:
	if Input.is_action_just_released("right_click") and (not tutorial_menu.visible):
		show()
		assign_position()
	if Input.is_action_just_released("left_click"):
		hide()


func assign_position():
	var start = Vector2.ZERO
	var window_size = get_global_rect().size
	var rect_size = $ColorRect.size
	
	global_position = get_global_mouse_position()
	
	if global_position.x + rect_size.x > window_size.x:
		global_position.x = window_size.x - rect_size.x
	if global_position.y + rect_size.y > window_size.y:
		global_position.y = window_size.y - rect_size.y


func _on_rotate_top_pressed() -> void:
	RotateManager.rotate_cubes(RotateManager.AXIS.TOP, RotateManager.ROTATE_DIR.CLOCKWISE)


func _on_rotate_top_anti_pressed() -> void:
	RotateManager.rotate_cubes(RotateManager.AXIS.TOP, RotateManager.ROTATE_DIR.ANTICLOCKWISE)


func _on_rotate_front_pressed() -> void:
	RotateManager.rotate_cubes(RotateManager.AXIS.FRONT, RotateManager.ROTATE_DIR.CLOCKWISE)


func _on_rotate_front_anti_pressed() -> void:
	RotateManager.rotate_cubes(RotateManager.AXIS.FRONT, RotateManager.ROTATE_DIR.ANTICLOCKWISE)


func _on_rotate_side_pressed() -> void:
	RotateManager.rotate_cubes(RotateManager.AXIS.SIDE, RotateManager.ROTATE_DIR.CLOCKWISE)


func _on_rotate_side_anti_pressed() -> void:
	RotateManager.rotate_cubes(RotateManager.AXIS.SIDE, RotateManager.ROTATE_DIR.ANTICLOCKWISE)


func _on_delete_pressed() -> void:
	SelectManager.delete_selected_cubes()
