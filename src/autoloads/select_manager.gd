extends Node


const SELECTED_MODULATE = Color(0.6, 1, 1, 1)
const UNSELECTED_MODULATE = Color(1, 1, 1, 1)

var selected_cubes: Array[Cube] = []
var cubes_offset: Array[Vector2] = []

var cube_scene = preload("res://src/cube/cube.tscn")


func _ready() -> void:
	EventBus.dragging_started.connect(_set_cubes_offset)
	EventBus.dragging_ended.connect(_clear_cubes_offset)
	
	EventBus.is_dragged_started.connect(func():
		if Input.is_action_pressed("alt"):
			duplicate_selected_cubes()
	)


func _input(event: InputEvent) -> void:
	if Setting.is_menu_open(): return
	
	if Input.is_action_just_pressed("ctrl_a"):
		add_all_selected_cubes()
	if Input.is_action_just_pressed("delete"):
		delete_selected_cubes()


func _unhandled_input(event: InputEvent) -> void:
	if Setting.is_menu_open(): return
	
	if Input.is_action_just_pressed("left_click") and not Input.is_action_pressed("alt"):
		clear_selected_cubes()


func add_selected_cube(cube: Cube):
	if is_in_selected_cubes(cube): return
	
	cube.modulate = SELECTED_MODULATE
	cube.select_line_2d.show()
	selected_cubes.push_back(cube)


func remove_selected_cube(cube: Cube):
	cube.modulate = UNSELECTED_MODULATE
	cube.select_line_2d.hide()
	selected_cubes.erase(cube)


func add_all_selected_cubes():
	var all_cubes = get_tree().get_nodes_in_group("cubes")
	
	for cube in all_cubes:
		if is_in_selected_cubes(cube): continue
		
		add_selected_cube(cube)


func clear_selected_cubes():
	for cube in selected_cubes:
		cube.modulate = UNSELECTED_MODULATE
		cube.select_line_2d.hide()
	
	selected_cubes = []


func is_in_selected_cubes(cube: Cube):
	return cube.modulate == SELECTED_MODULATE


func _set_cubes_offset():
	var mouse_pos = get_viewport().get_mouse_position()
	
	cubes_offset = []
	for cube in selected_cubes:
		cubes_offset.push_back(cube.global_position - mouse_pos)


func _clear_cubes_offset():
	cubes_offset = []


func delete_selected_cubes():
	for cube in SelectManager.selected_cubes:
		cube.queue_free()
	SelectManager.clear_selected_cubes()
	EventBus.cubes_changed.emit()


func duplicate_selected_cubes():
	var cubes_container = get_tree().get_first_node_in_group("cubes_container")
	
	for cube in SelectManager.selected_cubes:
		var new_cube = cube_scene.instantiate() as Cube
		new_cube.global_position = cube.global_position
		new_cube.z_index = cube.z_index
		cubes_container.add_child(new_cube)
