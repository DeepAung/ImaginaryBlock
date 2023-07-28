extends Node


enum AXIS { TOP, FRONT, SIDE }
enum ROTATE_DIR { CLOCKWISE, ANTICLOCKWISE }

var cubes: Array[Cube]
var graph: Array[Array]
var visited: Array[bool]
var shifting_join_dirs: Array[int]


# used in right click menu
func rotate_cubes(axis: AXIS, rotate_dir: ROTATE_DIR):
	shifting_join_dirs = _get_shifting_join_dirs(axis, rotate_dir)
	cubes = SelectManager.selected_cubes
	
	if cubes.is_empty(): return
	
	var past_center_pos = _get_center_pos()
	
	_create_graph_handler()
	_rotate_handler()
	_reposition_handler(past_center_pos)
	
	EventBus.cubes_changed.emit()


func _create_graph_handler():
	# set default value
	graph.resize(len(cubes))
	for i in range(len(graph)):
		graph[i].resize(len(Cube.JOIN_DIR))
		graph[i].fill(-1)
	
	var cubes_pos = []
	for i in range(len(cubes)):
		cubes_pos.push_back([cubes[i].position, i])
	
	cubes_pos.sort()
	
	for u in range(0, len(cubes)):
		for u_join_dir in range(len(Cube.JOIN_ARRAY)):
			var v_join_dir = Cube.get_reversed_join_dir(u_join_dir)
			var dirs = Cube.JOIN_ARRAY[u_join_dir]

			# from: pos_a + offset_a == pos_b + offset_b
			# to:   pos_a + offset_a - offset_b == pos_b
			var target_pos = cubes[u].get_pos_offset(dirs[0]) - cubes[u].get_cube_offset(dirs[1])
			
			var start = lower_bound(cubes_pos, target_pos.x - 0.1)
			var end = upper_bound(cubes_pos, target_pos.x + 0.1)
			
			for idx in range(start, end):
				var v = cubes_pos[idx][1]
				
				if u == v: continue
				if not _is_snap(u, dirs[0], v, dirs[1]): continue
				
				graph[u][u_join_dir] = v
				graph[v][v_join_dir] = u
				break

	# Old algo
#	for i in range(0, len(cubes)):
#		for j in range(i+1, len(cubes)):
#			for k in range(len(Cube.JOIN_ARRAY)):
#				var reversed_k = Cube.get_reversed_join_dir(k)
#				var dirs = Cube.JOIN_ARRAY[k]
#				if reversed_k == -1: printerr("reversed_k: ", reversed_k)
#
#				if _is_snap(i, dirs[0], j, dirs[1]):
#					graph[i][k] = j
#					graph[j][reversed_k] = i


func _rotate_handler():
	visited.resize(len(cubes))
	visited.fill(false)
	
	for u in range(len(cubes)):
		if visited[u]: continue
		_dfs(u)


func _reposition_handler(past_center_pos: Vector2):
	var cur_center_pos = _get_center_pos()
	var delta_pos = past_center_pos - cur_center_pos
	
	for cube in cubes:
		cube.position += delta_pos


# ----- helper functions ---------------------------- #


# find result that >= value
func lower_bound(array: Array, value):
	var l = 0; var r = len(array) - 1
	
	while l < r:
		var mid = int((l + r) / 2)
		if array[mid][0].x < value:
			l = mid + 1
		else:
			r = mid
	
	return l


# find result that > value
func upper_bound(array: Array, value):
	var l = 0; var r = len(array) - 1
	
	while l < r:
		var mid = int((l + r) / 2)
		if array[mid][0].x > value:
			r = mid
		else:
			l = mid + 1
	
	return l


func _get_center_pos() -> Vector2:
	var minX: float = cubes[0].position.x
	var maxX: float = cubes[0].position.x
	var minY: float = cubes[0].position.y
	var maxY: float = cubes[0].position.y
	
	for i in range(1, len(cubes)):
		minX = min(minX, cubes[i].position.x)
		maxX = max(maxX, cubes[i].position.x)
		minY = min(minY, cubes[i].position.y)
		maxY = max(maxY, cubes[i].position.y)
	
	return Vector2(
		(minX + maxX) / 2,
		(minY + maxY) / 2
	)


func _dfs(u: int):
	visited[u] = true
	
	_shift_join_dirs_to_right(u, shifting_join_dirs)
	
	for k in len(graph[u]):
		var v: int = graph[u][k]
		var dirs = Cube.JOIN_ARRAY[k]
		
		if v == -1: continue
		if visited[v]: continue
		
		# from cube[v].pos + cube[v].offset == cube[u].pos + cube[u].offset
		# and solve the equation
		cubes[v].position = cubes[u].get_pos_offset(dirs[0]) - cubes[v].get_cube_offset(dirs[1])
		
		if k == Enum.ABOVE:
			cubes[v].z_index = cubes[u].z_index - 1
		elif k == Enum.UNDER:
			cubes[v].z_index = cubes[u].z_index + 1
		else:
			cubes[v].z_index = cubes[u].z_index
		
		_dfs(v)


func _get_shifting_join_dirs(axis: AXIS, rotate_dir: ROTATE_DIR) -> Array[int]:
	var result: Array[int] = []
	match axis:
		AXIS.TOP:
			result = [Enum.BACK_LEFT, Enum.BACK_RIGHT, Enum.FRONT_RIGHT, Enum.FRONT_LEFT]
		AXIS.FRONT:
			result = [Enum.ABOVE, Enum.FRONT_RIGHT, Enum.UNDER, Enum.BACK_LEFT]
		AXIS.SIDE:
			result = [Enum.ABOVE, Enum.BACK_RIGHT, Enum.UNDER, Enum.FRONT_LEFT]
	
	if rotate_dir == ROTATE_DIR.ANTICLOCKWISE:
		result.reverse()
	
	return result


func _is_snap(u: int, u_dir: int, v: int, v_dir: int) -> bool:
	var u_pos = cubes[u].get_pos_offset(u_dir)
	var v_pos = cubes[v].get_pos_offset(v_dir)
	
	return u_pos.distance_to(v_pos) < 0.01


func _shift_join_dirs_to_right(u: int, join_dirs: Array) -> void:
	var tmp = graph[u][join_dirs[-1]]
	
	for i in range(len(join_dirs)-1, 0, -1):
		graph[u][join_dirs[i]] = graph[u][join_dirs[i-1]]
	
	graph[u][join_dirs[0]] = tmp


func print_graph() -> void:
	for u in range(len(cubes)):
		for k in range(len(Cube.JOIN_ARRAY)):
			if graph[u][k] == -1: continue
			print("graph[", u, "][", k, "] = ", graph[u][k])
	
	print("----------------------------")
