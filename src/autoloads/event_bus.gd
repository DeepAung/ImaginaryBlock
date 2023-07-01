extends Node


signal cube_clicked

signal cube_created(cube: Cube)
signal cube_snapped(cube: Cube, snapped_cube: Cube, dir: Cube.DIR)

signal is_dragged_started
signal dragging_started
signal dragging_ended

signal cubes_moved
signal cubes_deleted
