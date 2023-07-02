extends Control


@onready var cube_border_slider: HSlider = $Background/CubeBorder/CubeBorderSlider


func _ready() -> void:
	cube_border_slider.value = Setting.cube_border
	hide()


func _on_back_button_pressed() -> void:
	hide()


func _on_cube_border_slider_value_changed(value: float) -> void:
	Setting.cube_border = value


func _on_cube_border_reset_pressed() -> void:
	cube_border_slider.value = Setting.CUBE_BORDER
	Setting.cube_border = Setting.CUBE_BORDER
