extends Node


@onready var cube_create_button: TextureButton = $Control/CubeCreateButton

var cube_scene = preload("res://src/block/cube.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_cube_create_button_button_down() -> void:
	var cube: Cube = cube_scene.instantiate()
	cube.global_position = cube_create_button.global_position
	cube.dragging = true
	$Blocks.add_child(cube)
