extends Control


@onready var cube_border_slider: HSlider = $Background/CubeBorder/CubeBorderSlider
@onready var snap_strength_slider: HSlider = $Background/SnapStrength/SnapStrengthSlider


func _ready() -> void:
	cube_border_slider.value = Setting.cube_border
	snap_strength_slider.value = Setting.snap_range
	
	cube_border_slider.value_changed.connect( func(value: float):
		Setting.cube_border = value
	)
	
	snap_strength_slider.value_changed.connect( func(value: float):
		Setting.snap_range = value
	)
	
	hide()


func _on_back_button_pressed() -> void:
	hide()


func _on_cube_border_reset_pressed() -> void:
	cube_border_slider.value = Setting.CUBE_BORDER
	Setting.cube_border = Setting.CUBE_BORDER


func _on_snap_strength_reset_pressed() -> void:
	snap_strength_slider.value = Setting.SNAP_RANGE
	Setting.snap_range = Setting.SNAP_RANGE
