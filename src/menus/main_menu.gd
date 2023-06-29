extends Control


@onready var cube_create_button: TextureButton = $CubeCreateButton
@onready var cubes_container: Node2D = $"../CubeLayer/CubesContainer"
@onready var tutorial_menu: Control = $"../TopLayer/TutorialMenu"


var cube_scene = preload("res://src/cube/cube.tscn")

func _on_cube_create_button_button_down() -> void:
	var cube: Cube = cube_scene.instantiate()
	cube.global_position = cube_create_button.global_position
	
	cubes_container.add_child(cube)
	
	SelectManager.clear_selected_cubes()
	SelectManager.add_selected_cube(cube)
	EventBus.cube_clicked.emit()


func _on_tutorial_button_pressed() -> void:
	tutorial_menu.show()


func _on_undo_button_pressed() -> void:
	HistoryManager.undo_history()


func _on_redo_button_pressed() -> void:
	HistoryManager.redo_history()
