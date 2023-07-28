extends TextureButton
class_name Cube


class SnapResult:
	var snapping_cube: Cube
	var snapped_cube: Cube
	var snap_offset: Vector2
	var new_z_index: int
	var join_dir: int
	
	func _init(snapping_cube: Cube, snapped_cube: Cube, snap_offset: Vector2, new_z_index: int, join_dir: int) -> void:
		self.snapping_cube = snapping_cube
		self.snapped_cube = snapped_cube
		self.snap_offset = snap_offset
		self.new_z_index = new_z_index
		self.join_dir = join_dir


enum DIR { TOP, TOP_RIGHT, BOTTOM_RIGHT, BOTTOM, BOTTOM_LEFT, TOP_LEFT, CENTER, }
enum JOIN_DIR { BACK_LEFT, BACK_RIGHT, FRONT_LEFT, FRONT_RIGHT, ABOVE, UNDER }

const JOIN_ARRAY = [
	[DIR.CENTER,    DIR.TOP_LEFT],  # BACK_LEFT
	[DIR.CENTER,    DIR.TOP_RIGHT], # BACK_RIGHT
	[DIR.TOP_RIGHT, DIR.CENTER],    # FRONT_LEFT
	[DIR.TOP_LEFT,  DIR.CENTER],    # FRONT_RIGHT
	[DIR.BOTTOM,    DIR.CENTER],    # ABOVE
	[DIR.CENTER,    DIR.BOTTOM],    # UNDER
]

const SNAP_RANGE = 20.0

@onready var area_2d: Area2D = $Area2D
@onready var collision_polygon_2d: CollisionPolygon2D = $Area2D/CollisionPolygon2D
@onready var line_2d: Line2D = $Area2D/Line2D
@onready var select_line_2d: Line2D = $Area2D/SelectLine2D

@onready var for_show: bool = self.is_in_group("show_cube")


func _process(delta: float) -> void:
	# wait line_2d to be ready
	if line_2d == null: return
	
	line_2d.width = Setting.cube_border
	
	if line_2d.width == 0: line_2d.hide()
	else: line_2d.show()


# ---------------------------------------- #


static func get_reversed_join_dir(join_dir: JOIN_DIR) -> JOIN_DIR:
	match join_dir:
		JOIN_DIR.BACK_LEFT: return JOIN_DIR.FRONT_RIGHT
		JOIN_DIR.BACK_RIGHT: return JOIN_DIR.FRONT_LEFT
		JOIN_DIR.FRONT_LEFT: return JOIN_DIR.BACK_RIGHT
		JOIN_DIR.FRONT_RIGHT: return JOIN_DIR.BACK_LEFT
		JOIN_DIR.ABOVE: return JOIN_DIR.UNDER
		JOIN_DIR.UNDER: return JOIN_DIR.ABOVE
		_: return -1 # impossible case


# ---------------------------------------- #


func get_snap() -> SnapResult:
	var areas: Array[Area2D] = area_2d.get_overlapping_areas()
	var dists: Array = []

	for area in areas:
		var other_cube = area.get_parent() as Cube
		
		if SelectManager.is_in_selected_cubes(other_cube): continue
		# TODO: if not has above front-left, front-right: continue
		
		var result = get_snap_to(other_cube)
		var snap_dist = result[0]

		if snap_dist == -1 or snap_dist > SNAP_RANGE: continue
		dists.push_back(result)

	if dists.is_empty(): return null

	dists.sort_custom(snap_sort_compare)
	var result = dists[0]
	
	var snap_offset = result[1]
	var new_z_index = result[2]
	var snapped_cube = result[3]
	var join_dir = result[4]
	
	return SnapResult.new(self, snapped_cube, snap_offset, new_z_index, join_dir)


func get_snap_to(other: Cube):
	var min_dist = -1
	var snap_offset = Vector2.ZERO
	var new_z_index = other.z_index
	var snapped_cube = null
	var join_dir: JOIN_DIR
	
	for idx in range(len(JOIN_ARRAY) - 1):
		var item = JOIN_ARRAY[idx]
		
		var my_pos = get_pos_offset(item[0])
		var other_pos = other.get_pos_offset(item[1])
		var cur_dist = my_pos.distance_to(other_pos)
		
		if min_dist == -1 or cur_dist < min_dist:
			min_dist = cur_dist
			snap_offset = other_pos - my_pos
			snapped_cube = other
			join_dir = idx

			if idx == 4: new_z_index += 1 # above
			elif idx == 5: new_z_index -= 1 # under
	
	return [min_dist, snap_offset, new_z_index, snapped_cube, join_dir]


func get_pos_offset(direction: DIR) -> Vector2:
	return position + get_cube_offset(direction)


func get_cube_offset(direction: DIR) -> Vector2:
	if direction == DIR.CENTER:
		return Vector2.ZERO
	
	return collision_polygon_2d.polygon[direction] * scale


static func snap_sort_compare(a, b):
	var min_dist_a = a[0]
	var z_index_a = a[2]
	var pos_a = (a[3] as Cube).global_position
	
	var min_dist_b = b[0]
	var z_index_b = b[2]
	var pos_b = (b[3] as Cube).global_position
	
	if abs(min_dist_b - min_dist_a) > 5:
		return min_dist_a < min_dist_b
	
	if z_index_a != z_index_b:
		return z_index_a > z_index_b
	
	if pos_a.y != pos_b.y:
		return pos_a.y > pos_b.y
	
	return min_dist_a < min_dist_b


# ---------------------------------------- #


func _on_button_down() -> void:
	if for_show: return
	
	if Input.is_action_pressed("ctrl"):
		if SelectManager.is_in_selected_cubes(self):
			SelectManager.remove_selected_cube(self)
		else:
			SelectManager.add_selected_cube(self)
			EventBus.cube_clicked.emit()
	else:
		if not SelectManager.is_in_selected_cubes(self):
			SelectManager.clear_selected_cubes()
			SelectManager.add_selected_cube(self)

		EventBus.cube_clicked.emit()
