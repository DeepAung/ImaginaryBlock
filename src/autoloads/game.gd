extends Node


const SELECTED_MODULATE = Color(0.6, 1, 1, 1)
const UNSELECTED_MODULATE = Color(1, 1, 1, 1)

var selected_cubes: Array[Cube] = []
var cubes_offset: Array[Vector2] = []

var cube_scene = preload("res://src/cube/cube.tscn")


func add_selected_cube(cube: Cube):
	cube.modulate = SELECTED_MODULATE
	selected_cubes.push_back(cube)


func add_selected_cubes(cubes: Array[Cube]):
	for cube in cubes:
		if cube.modulate == SELECTED_MODULATE: continue
		
		cube.modulate = SELECTED_MODULATE
		selected_cubes.push_back(cube)


func remove_selected_cube(cube: Cube):
	cube.modulate = UNSELECTED_MODULATE
	
	selected_cubes.erase(cube)


func clear_selected_cubes():
	for cube in selected_cubes:
		cube.modulate = UNSELECTED_MODULATE
	
	selected_cubes = []


func set_cubes_offset():
	var mouse_pos = get_viewport().get_mouse_position()
	
	cubes_offset = []
	for cube in selected_cubes:
		cubes_offset.push_back(cube.global_position - mouse_pos)


func clear_cubes_offset():
	cubes_offset = []
