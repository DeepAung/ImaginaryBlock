extends Node


var cube_scene = preload("res://src/cube/cube.tscn")


func _ready() -> void:
	EventBus.is_dragged_started.connect(func():
		if Input.is_action_pressed("alt"):
			_duplicate_cubes()
	)


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("delete"):
		_delete_cubes()


func _delete_cubes():
	for cube in SelectManager.selected_cubes:
		cube.queue_free()
	SelectManager.clear_selected_cubes()
	HistoryManager.save_history()


func _duplicate_cubes():
	var cubes_container = get_tree().get_first_node_in_group("cubes_container")
	
	for cube in SelectManager.selected_cubes:
		var new_cube = cube_scene.instantiate() as Cube
		new_cube.global_position = cube.global_position
		new_cube.z_index = cube.z_index
		cubes_container.add_child(new_cube)
