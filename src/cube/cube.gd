extends Area2D
class_name Cube


enum { TOP=0, TOP_RIGHT=1, BOTTOM_RIGHT=2, BOTTOM=3, BOTTOM_LEFT=4, TOP_LEFT=5, CENTER=6 }
const JOIN_ARRAY = [
	[CENTER, TOP_LEFT],  # back left
	[CENTER, TOP_RIGHT], # back right
	[TOP_RIGHT, CENTER], # front left
	[TOP_LEFT, CENTER],  # front right
	[BOTTOM, CENTER],    # above
	[CENTER, BOTTOM],    # under
]

const OFFSET_ARRAY = [
	Vector2(-54, -31),
	Vector2( 54, -31),
	Vector2(-54,  31),
	Vector2( 54,  31),
	Vector2(  0, -62),
	Vector2(  0,  62),
]

const SNAP_RANGE = 10.0

var dragging: bool = false
var click_offset: Vector2 = Vector2.ZERO
var snap_mode: bool = false


# ---------------------------------------- #


# utility functions
func get_offset(direction: int) -> Vector2:
	if direction == CENTER:
		return Vector2.ZERO
	
	return $CollisionPolygon2D.polygon[direction] * scale


func get_min_snap(other: Cube):
	var min_dist = -1
	var snap_pos = Vector2.ZERO
	var new_z_index = other.z_index
	
	for idx in range(JOIN_ARRAY.size()):
		var item = JOIN_ARRAY[idx]
		
		var my_pos = position + get_offset(item[0])
		var other_pos = other.position + other.get_offset(item[1])
		
		var cur_dist = my_pos.distance_to(other_pos)
		if min_dist == -1 or cur_dist < min_dist:
			min_dist = cur_dist
			snap_pos = other_pos - get_offset(item[0])

			if idx == 4: new_z_index += 1 # above
			elif idx == 5: new_z_index -= 1 # under
	
	return [min_dist, snap_pos, new_z_index]


# ---------------------------------------- #


func _physics_process(delta: float) -> void:
	if not dragging: return
	
	move_handler(delta)
	snap_handler(delta)


func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if not dragging and Input.is_action_just_pressed("left_click"):
		dragging = true
		click_offset = global_position - get_global_mouse_position()


func _input(event: InputEvent) -> void:
	if dragging and Input.is_action_just_released("left_click"):
		dragging = false
		click_offset = Vector2.ZERO


# ---------------------------------------- #


func move_handler(delta: float):
	var target_position = get_global_mouse_position() + click_offset
	global_position = lerp(global_position, target_position, 25*delta)


func snap_handler(delta: float):
	var areas = get_overlapping_areas()
	var dists: Array = []

	for area in areas:
		var result = get_min_snap(area)
		if result[0] == -1 or result[0] > SNAP_RANGE: continue
		dists.push_back(result)

	if dists.is_empty(): return

	dists.sort()

	var snap_position = dists[0][1]
	var new_z_index = dists[0][2]

	global_position = snap_position
	z_index = new_z_index
