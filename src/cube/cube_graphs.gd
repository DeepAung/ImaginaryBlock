class_name CubeGraphs


var graphs = [] # Array of Array 3d


func add_cube(cube: Cube):
	var result = cube.get_snap()
	if result == null: return
	
	var snap_dist: float    = result[0]
	var snap_cube: Cube     = result[3]
	var JOIN_ARRAY_idx: int = result[4]
	
	if snap_dist > 0: return
	
	result = find_cube_in_graphs(snap_cube)
	if result == null: return
	
	var x = result[0]
	var i = result[1]
	var j = result[2]
	var k = result[3]
	
	result = Cube.JOIN_ARRAY_DELTA[JOIN_ARRAY_idx]
	var di = result[0]
	var dj = result[1]
	var dk = result[2]
	
	if i + di < 0:
		graphs[x].push_front([[cube]])
	elif j + dj < 0:
		graphs[x][i+di].push_front([cube])
	elif k + dk < 0:
		graphs[x][i+di][j+dj].push_front(cube)
	else:
		graphs[x][i+di][j+dj][k+dk] = cube


func find_cube_in_graphs(target_cube: Cube):
	for x in range(len(graphs)):
		for i in range(len(graphs[x])): for j in range(len(graphs[x][i])): for k in range(len(graphs[x][i][j])):
			var cube = graphs[x][i][j][k]
			
			if cube == target_cube:
				return [x, i, j, k]
	
	return null
