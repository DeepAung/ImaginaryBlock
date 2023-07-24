extends Control


@onready var tutorial_menu: Control = $"../TutorialMenu"


func _ready() -> void:
	hide()


func _input(event: InputEvent) -> void:
	if Setting.is_menu_open(): return
	
	if Input.is_action_just_released("right_click") and (not tutorial_menu.visible):
		show_tween()
		assign_position()
	if Input.is_action_just_released("left_click"):
		hide_tween()


func assign_position():
	var start = Vector2.ZERO
	var window_size = get_global_rect().size
	var rect_size = $ColorRect.size
	
	global_position = get_global_mouse_position()
	
	if global_position.x + rect_size.x > window_size.x:
		global_position.x = window_size.x - rect_size.x
	if global_position.y + rect_size.y > window_size.y:
		global_position.y = window_size.y - rect_size.y


func show_tween():
	if visible: return
	
	show()
	modulate = Color.TRANSPARENT
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.075)
	tween.play()


func hide_tween():
	if not visible: return
	
	modulate = Color.WHITE
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.075)
	tween.tween_callback(hide)
	tween.play()


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
