extends Node


const SELECTED_MODULATE = Color(0.6, 1, 1, 1)
const UNSELECTED_MODULATE = Color(1, 1, 1, 1)

#var cube_graphs: CubeGraphs

var selected_cubes: Array[Cube] = []
var cubes_offset: Array[Vector2] = []

var cube_scene = preload("res://src/cube/cube.tscn")


func _ready() -> void:
	EventBus.dragging_started.connect(set_cubes_offset)
	EventBus.dragging_ended.connect(clear_cubes_offset)


func add_selected_cube(cube: Cube):
	if is_in_selected_cubes(cube): return
	
	cube.modulate = SELECTED_MODULATE
	selected_cubes.push_back(cube)


func remove_selected_cube(cube: Cube):
	cube.modulate = UNSELECTED_MODULATE
	selected_cubes.erase(cube)


func clear_selected_cubes():
	for cube in selected_cubes:
		cube.modulate = UNSELECTED_MODULATE
	
	selected_cubes = []


func is_in_selected_cubes(cube: Cube):
	return cube.modulate == SELECTED_MODULATE


func set_cubes_offset():
	var mouse_pos = get_viewport().get_mouse_position()
	
	cubes_offset = []
	for cube in selected_cubes:
		cubes_offset.push_back(cube.global_position - mouse_pos)


func clear_cubes_offset():
	cubes_offset = []
