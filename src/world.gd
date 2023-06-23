extends Node


@onready var cube_create_button: TextureButton = $Control/CubeCreateButton

var cube_scene = preload("res://src/cube/cube.tscn")

func _on_cube_create_button_button_down() -> void:
	var cube: Cube = cube_scene.instantiate()
	cube.global_position = cube_create_button.global_position
	
	$Cubes.add_child(cube)
	
	Game.clear_selected_cubes()
	Game.add_selected_cube(cube)
	EventBus.cube_clicked.emit()


# ------------------------------------- #


var dragging: bool = false
var is_dragged: bool = false
var cur_mouse_pos: Vector2 = Vector2.ZERO
var pre_mouse_pos: Vector2 = Vector2.ZERO


func _ready() -> void:
	pre_mouse_pos = get_viewport().get_mouse_position()
	cur_mouse_pos = get_viewport().get_mouse_position()
	
	sort_cubes_handler()
	
	EventBus.cube_clicked.connect(_on_cube_clicked)


func _on_cube_clicked():
	if not dragging:
		Game.set_cubes_offset()
		dragging = true
		is_dragged = false


func _input(event: InputEvent) -> void:
	if dragging and Input.is_action_just_released("left_click"):
		Game.clear_cubes_offset()
		dragging = false
		is_dragged = false
	
	if Input.is_action_just_pressed("delete"):
		delete_cubes()


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("left_click"):
		Game.clear_selected_cubes()


func _physics_process(delta: float) -> void:
	pre_mouse_pos = cur_mouse_pos
	cur_mouse_pos = get_viewport().get_mouse_position()
	
	if Game.selected_cubes.is_empty(): return
	if len(Game.cubes_offset) != len(Game.selected_cubes): return
	if not dragging: return

	if cur_mouse_pos == pre_mouse_pos: return
	
	if not is_dragged:
		is_dragged = true
		if Input.is_action_pressed("alt"):
			duplicate_cubes()
	
	move_handler(delta)
	snap_handler(delta)
	sort_cubes_handler()


func delete_cubes():
	for cube in Game.selected_cubes:
		cube.queue_free()
	Game.clear_selected_cubes()


func move_handler(delta: float):
	for i in range(len(Game.selected_cubes)):
		var cube = Game.selected_cubes[i]
		var cube_offset = Game.cubes_offset[i]
		
		cube.global_position = lerp(
			cube.global_position, 
			cur_mouse_pos + cube_offset, 
			25 * delta
		)


func duplicate_cubes():
	for cube in Game.selected_cubes:
		var new_cube = cube_scene.instantiate() as Cube
		new_cube.global_position = cube.global_position
		new_cube.z_index = cube.z_index
		$Cubes.add_child(new_cube)


func snap_handler(delta: float):
	var result = get_best_snap()
	if result == null: return
	
	var snap_offset = result[1]
	var new_z_index = result[2]
	
	update_snap(snap_offset, new_z_index)


func get_best_snap():
	var best_result = []
	for cube in Game.selected_cubes:
		var result = cube.get_snap()
		if result == null: continue
		best_result.push_back(result)
	
	if best_result.is_empty(): return null
	
	best_result.sort()
	return best_result[0]


func update_snap(snap_offset: Vector2, new_z_index: int):
	# find min z-index
	var min_z_index: int = Game.selected_cubes[0].z_index
	for i in range(1, len(Game.selected_cubes)):
		var cube = Game.selected_cubes[i]
		min_z_index = min(min_z_index, cube.z_index)
	
	var delta_z_index = new_z_index - min_z_index
	
	# update pos and z-index
	for cube in Game.selected_cubes:
		cube.global_position += snap_offset
		cube.z_index += delta_z_index


func sort_cubes_handler():
	var cubes = $Cubes.get_children() as Array[Cube]
	
	cubes.sort_custom(func (a: Cube, b: Cube):
		if a.z_index != b.z_index:
			return a.z_index < b.z_index
		return a.position.y < b.position.y
	)
	
	for i in range(len(cubes)):
		$Cubes.move_child(cubes[i], i)
