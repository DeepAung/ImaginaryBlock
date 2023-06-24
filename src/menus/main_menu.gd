extends Control


@onready var cube_create_button: TextureButton = $CubeCreateButton

var cube_scene = preload("res://src/cube/cube.tscn")
var tutorial_menu_scene = preload("res://src/menus/tutorial_menu.tscn")


func _on_cube_create_button_button_down() -> void:
	var cube: Cube = cube_scene.instantiate()
	cube.global_position = cube_create_button.global_position
	
	var cubes_container = get_tree().get_first_node_in_group("cubes_container")
	cubes_container.add_child(cube)
	
	Game.clear_selected_cubes()
	Game.add_selected_cube(cube)
	EventBus.cube_clicked.emit()


func _on_tutorial_button_pressed() -> void:
	var tutorial_menu = tutorial_menu_scene.instantiate()
	add_child(tutorial_menu)


func _on_undo_button_pressed() -> void:
	HistoryManager.undo_history()


func _on_redo_button_pressed() -> void:
	HistoryManager.redo_history()
