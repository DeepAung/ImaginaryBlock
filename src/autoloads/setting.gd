extends Node


const CUBE_BORDER: float = 2
const SNAP_RANGE: float = 20.0

var cube_border: float = CUBE_BORDER
var snap_range: float = SNAP_RANGE
var menu_visible: bool = false

@onready var tutorial_menu: Control = get_tree().get_first_node_in_group("tutorial_menu")
@onready var setting_menu: Control = get_tree().get_first_node_in_group("setting_menu")


func is_menu_open() -> bool:
	return tutorial_menu.visible or setting_menu.visible
