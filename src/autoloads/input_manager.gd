extends Node


var cube_scene = preload("res://src/cube/cube.tscn")


func _ready() -> void:
	EventBus.is_dragged_started.connect(func():
		if Input.is_action_pressed("alt"):
			duplicate_cubes()
	)


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("delete"):
		delete_cubes()
	elif Input.is_action_just_pressed("ui_redo"):
		HistoryManager.redo_history()
	elif Input.is_action_just_pressed("ui_undo"):
		HistoryManager.undo_history()
	elif Input.is_action_just_pressed("ui_text_select_all"):
		select_all_cubes()


func delete_cubes():
	for cube in SelectManager.selected_cubes:
		cube.queue_free()
	SelectManager.clear_selected_cubes()
	HistoryManager.save_history()


func duplicate_cubes():
	var cubes_container = get_tree().get_first_node_in_group("cubes_container")
	
	for cube in SelectManager.selected_cubes:
		var new_cube = cube_scene.instantiate() as Cube
		new_cube.global_position = cube.global_position
		new_cube.z_index = cube.z_index
		cubes_container.add_child(new_cube)


func select_all_cubes():
	var all_cubes = get_tree().get_nodes_in_group("cubes")
	
	for cube in all_cubes:
		if SelectManager.is_in_selected_cubes(cube):
			continue
		
		SelectManager.add_selected_cube(cube)
