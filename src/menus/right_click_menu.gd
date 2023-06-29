extends Control


@onready var tutorial_menu: Control = $"../TutorialMenu"


func _ready() -> void:
	hide()


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("right_click") and (not tutorial_menu.visible):
		global_position = get_global_mouse_position()
		show()


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("left_click"):
		hide()


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
