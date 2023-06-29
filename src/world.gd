extends Node


var cube_scene = preload("res://src/cube/cube.tscn")
@onready var cubes_container: Node2D = $CubeLayer/CubesContainer


var dragging: bool = false
var is_dragged: bool = false
var cur_mouse_pos: Vector2 = Vector2.ZERO
var pre_mouse_pos: Vector2 = Vector2.ZERO


func _ready() -> void:
	pre_mouse_pos = get_viewport().get_mouse_position()
	cur_mouse_pos = get_viewport().get_mouse_position()
	
	_sort_cubes_handler()
	
	EventBus.cube_clicked.connect(_on_cube_clicked)


func _on_cube_clicked():
	if not dragging:
		EventBus.dragging_started.emit()
		dragging = true
		is_dragged = false


func _input(event: InputEvent) -> void:
	if dragging and Input.is_action_just_released("left_click"):
		EventBus.dragging_ended.emit(is_dragged)
		dragging = false
		is_dragged = false


func _physics_process(delta: float) -> void:
	pre_mouse_pos = cur_mouse_pos
	cur_mouse_pos = get_viewport().get_mouse_position()
	
	if SelectManager.selected_cubes.is_empty(): return
	if SelectManager.cubes_offset.is_empty(): return
	if not dragging: return

	if cur_mouse_pos == pre_mouse_pos: return
	
	if not is_dragged:
		is_dragged = true
		EventBus.is_dragged_started.emit()
	
	_move_handler(delta)
	_snap_handler(delta)
	_sort_cubes_handler()


func _move_handler(delta: float):
	for i in range(len(SelectManager.selected_cubes)):
		var cube = SelectManager.selected_cubes[i]
		var cube_offset = SelectManager.cubes_offset[i]
		
		cube.global_position = lerp(
			cube.global_position, 
			cur_mouse_pos + cube_offset, 
			25 * delta
		)


func _snap_handler(delta: float):
	var result = _get_best_snap()
	if result == null: return
	
	_update_snap(result.snap_offset, result.new_z_index)


func _sort_cubes_handler():
	var cubes = cubes_container.get_children() as Array[Cube]
	
	cubes.sort_custom(func (a: Cube, b: Cube):
		if a.z_index != b.z_index:
			return a.z_index < b.z_index
		return a.position.y < b.position.y
	)
	
	for i in range(len(cubes)):
		cubes_container.move_child(cubes[i], i)


# ----- helper functions ---------------------------- #


func _get_best_snap() -> Cube.SnapResult:
	var best_result: Array[Cube.SnapResult] = []
	for cube in SelectManager.selected_cubes:
		var result = cube.get_snap()
		if result == null: continue
		best_result.push_back(result)
	
	if best_result.is_empty(): return null
	
	best_result.sort()
	return best_result[0]


func _update_snap(snap_offset: Vector2, new_z_index: int):
	# find min z-index
	var min_z_index: int = SelectManager.selected_cubes[0].z_index
	for i in range(1, len(SelectManager.selected_cubes)):
		var cube = SelectManager.selected_cubes[i]
		min_z_index = min(min_z_index, cube.z_index)
	
	var delta_z_index = new_z_index - min_z_index
	
	# update pos and z-index
	for cube in SelectManager.selected_cubes:
		cube.global_position += snap_offset
		cube.z_index += delta_z_index
