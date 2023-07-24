extends Node


class CubeInfo:
	var position: Vector2
	var z_index: int
	
	func _init(_position: Vector2, _z_index: int) -> void:
		position = _position
		z_index = _z_index


var history_cubes: Array[Array] # Array[Array[CubeInfo]]
var cur_index: int = -1

var cube_scene = preload("res://src/cube/cube.tscn")


func _ready() -> void:
	save_history()
	
	EventBus.cubes_changed.connect(save_history)


func _input(event: InputEvent) -> void:
	if Setting.is_menu_open(): return
	
	if Input.is_action_just_pressed("ui_redo"):
		redo_history()
	elif Input.is_action_just_pressed("ui_undo"):
		undo_history()


func save_history():	
	var cubes = get_tree().get_nodes_in_group("cubes")
	var cubes_info = cubes.map( func (cube: Cube):
		return CubeInfo.new(cube.position, cube.z_index)
	)
	
	# while last_index > cur_index
	while history_cubes.size() - 1 > cur_index:
		history_cubes.pop_back()
	
	history_cubes.push_back(cubes_info)
	cur_index = history_cubes.size() - 1


func undo_history():
	if cur_index - 1 < 0: return
	
	SelectManager.clear_selected_cubes()
	cur_index -= 1
	_go_to_history()


func redo_history():
	if cur_index + 1 >= history_cubes.size(): return
	
	SelectManager.clear_selected_cubes()
	cur_index += 1
	_go_to_history()


func _go_to_history():
	var cubes = get_tree().get_nodes_in_group("cubes") as Array[Cube]
	var cubes_container = get_tree().get_first_node_in_group("cubes_container")
	
	for cube in cubes:
		cube.queue_free()
	
	for cube_info in history_cubes[cur_index]:
		cube_info = cube_info as CubeInfo
		
		var new_cube = cube_scene.instantiate() as Cube
		new_cube.position = cube_info.position
		new_cube.z_index = cube_info.z_index
		
		cubes_container.add_child(new_cube)
