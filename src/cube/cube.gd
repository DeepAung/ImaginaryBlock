extends TextureButton
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

const SNAP_RANGE = 20.0

@onready var area_2d: Area2D = $Area2D
@onready var collision_polygon_2d: CollisionPolygon2D = $Area2D/CollisionPolygon2D

# ---------------------------------------- #


# public functions
func get_snap():
	var areas: Array[Area2D] = area_2d.get_overlapping_areas()
	var dists: Array = []

	for area in areas:
		var other_cube = area.get_parent() as Cube
		if Game.selected_cubes.has(other_cube): continue
		
		var result = get_snap_to(other_cube)
		var snap_dist = result[0]

		if snap_dist == -1 or snap_dist > SNAP_RANGE: continue
		dists.push_back(result)

	if dists.is_empty(): return null

	dists.sort()
	return dists[0] # snap_dist, snap_offset, new_z_index


func get_snap_to(other: Cube):
	var min_dist = -1
	var snap_offset = Vector2.ZERO
	var new_z_index = other.z_index
	
	for idx in range(JOIN_ARRAY.size()):
		var item = JOIN_ARRAY[idx]
		
		var my_pos = get_pos_offset(item[0])
		var other_pos = other.get_pos_offset(item[1])
		var cur_dist = my_pos.distance_to(other_pos)
		
		if min_dist == -1 or cur_dist < min_dist:
			min_dist = cur_dist
			snap_offset = other_pos - my_pos

			if idx == 4: new_z_index += 1 # above
			elif idx == 5: new_z_index -= 1 # under
	
	return [min_dist, snap_offset, new_z_index]


func get_pos_offset(direction: int) -> Vector2:
	var add_offset = Vector2.ZERO
	if direction != CENTER:
		add_offset = collision_polygon_2d.polygon[direction] * scale
	
	return position + add_offset


# ---------------------------------------- #


func _on_button_down() -> void:
	if Input.is_action_pressed("ctrl"):
		if Game.selected_cubes.has(self):
			Game.remove_selected_cube(self)
		else:
			Game.add_selected_cube(self)
			EventBus.cube_clicked.emit()
	else:
		if not Game.selected_cubes.has(self):
			Game.clear_selected_cubes()
			Game.add_selected_cube(self)

		EventBus.cube_clicked.emit()
