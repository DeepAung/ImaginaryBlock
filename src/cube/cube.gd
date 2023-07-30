extends Area2D
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


@onready var show_cube: bool = self.is_in_group("show_cube")

@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D
@onready var line_2d: Line2D = $Line2D
@onready var select_line_2d: Line2D = $SelectLine2D


# only exist in show_cube
var show_center: CirclePolygon = null
var show_top_left: CirclePolygon = null
var show_top_right: CirclePolygon = null
var show_bottom: CirclePolygon = null

# only exist in non show_cube
var collision_shape: CollisionShape2D = null
var JOIN_AREA = []
var EXACT_JOIN_AREA = []


func _ready() -> void:
	if show_cube:
		show_center = $ShowAreaDetectors/Center
		show_top_left = $ShowAreaDetectors/TopLeft
		show_top_right = $ShowAreaDetectors/TopRight
		show_bottom = $ShowAreaDetectors/Bottom
	else:
		# collision_shape is shared amongs AreaDetectors
		collision_shape = $AreaDetectors/BackLeft/CollisionShape2D
		
		JOIN_AREA = [
			[%BackLeft,   %TopLeft],
			[%BackRight,  %TopRight],
			[%FrontLeft,  %Center],
			[%FrontRight, %Center],
			[%Above,      %Center],
			[%Under,      %Bottom],
		]
		
		EXACT_JOIN_AREA = [
			[%ExactBackLeft,   %TopLeft],
			[%ExactBackRight,  %TopRight],
			[%ExactFrontLeft,  %Center],
			[%ExactFrontRight, %Center],
			[%ExactAbove,      %Center],
			[%ExactUnder,      %Bottom],
		]


func _process(delta: float) -> void:
	
	if line_2d != null:
		line_2d.width = Setting.cube_border
		
		if line_2d.width == 0: line_2d.hide()
		else: line_2d.show()
	
	
	# only for show_cube
	if not show_cube and collision_shape != null:
		collision_shape.shape.radius = Setting.snap_range
	
	
	if not show_cube: return
	
	# only for non show_cube
	if show_center != null:
		show_center.polygon_radius = Setting.snap_range
	if show_top_left != null:
		show_top_left.polygon_radius = Setting.snap_range
	if show_top_right != null:
		show_top_right.polygon_radius = Setting.snap_range
	if show_bottom != null:
		show_bottom.polygon_radius = Setting.snap_range


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
	var best_snap_array = []
	
	for join_dir in range(len(JOIN_AREA)):
		var detector = JOIN_AREA[join_dir][0] as Area2D
		var detected_areas = detector.get_overlapping_areas() as Array[Cube]
		
		if detected_areas.is_empty(): continue
		
		var min_snap = _get_min_snap_of(detector, detected_areas, join_dir)
		if min_snap == null: continue
		
		best_snap_array.push_back(min_snap)
	
	if best_snap_array.is_empty(): return null
	
	var best_snap = best_snap_array.min()
	var snapped_cube: Cube = best_snap[1]
	var join_dir: JOIN_DIR = best_snap[2]
	
	var snap_offset: Vector2 = _get_snap_offset(snapped_cube, join_dir)
	var new_z_index: int = _get_new_z_index(snapped_cube, join_dir)
	
	if snap_offset.length() > SNAP_RANGE: return null
	
	return SnapResult.new(
		self, snapped_cube, snap_offset, new_z_index, join_dir
	)


func _get_min_snap_of(detector: Area2D, detected_areas: Array[Area2D], join_dir: JOIN_DIR):
	var snap_array = []
	for detected_area in detected_areas:
		var snapped_cube = detected_area.get_parent().get_parent() as Cube
		
		if SelectManager.is_in_selected_cubes(snapped_cube):
			continue
		
		if _already_has_snap(snapped_cube, join_dir):
			continue
		
		snap_array.push_back([
			detector.position.distance_to(detected_area.position), 
			snapped_cube, 
			join_dir
		])
	
	if snap_array.is_empty(): return null
	return snap_array.min()


func _get_snap_offset(snapped_cube: Cube, join_dir: JOIN_DIR) -> Vector2:
	var dirs = JOIN_ARRAY[join_dir]
	
	var my_pos = get_pos_offset(dirs[0])
	var other_pos = snapped_cube.get_pos_offset(dirs[1])
	
	var snap_offset = other_pos - my_pos
	return snap_offset


func _get_new_z_index(snapped_cube: Cube, join_dir: JOIN_DIR) -> int:
	var new_z_index = snapped_cube.z_index
	if join_dir == JOIN_DIR.ABOVE: new_z_index += 1
	elif join_dir == JOIN_DIR.UNDER: new_z_index -= 1
	
	return new_z_index


func _already_has_snap(snapped_cube: Cube, join_dir: JOIN_DIR) -> bool:
	var reversed_join_dir = get_reversed_join_dir(join_dir)
	var exact_detector = \
		snapped_cube.EXACT_JOIN_AREA[reversed_join_dir][0] as Area2D
	
	var areas = exact_detector.get_overlapping_areas()
	areas = areas.filter(func(area: Area2D):
		return area.get_parent().get_parent() != self
	)
	
	return not areas.is_empty()


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


func _on_texture_button_button_down() -> void:
	if show_cube: return
	
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
