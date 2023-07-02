extends Control


@onready var cube_border_slider: HSlider = $CubeBorder/CubeBorderSlider
@onready var cube_color_picker: ColorPicker = $CubeColor/Panel/CenterContainer/CubeColorPicker
@onready var background_color_picker: ColorPicker = $BackgroundColor/Panel/CenterContainer/BackgroundColorPicker
@onready var background_color_rect: ColorRect = $Show/BackgroundColorRect


func _ready() -> void:
	cube_border_slider.value = Setting.cube_border
	cube_color_picker.color = Setting.cube_color
	background_color_picker.color = Setting.background_color
	
	cube_border_slider.value_changed.connect(update_cube_border)
	cube_color_picker.color_changed.connect(update_cube_color)
	background_color_picker.color_changed.connect(update_background_color)
	
	hide()


func update_cube_border(value: float):
	Setting.cube_border = value


func update_cube_color(color: Color):
	Setting.cube_color = color


func update_background_color(color: Color):
	Setting.background_color = color
	background_color_rect.color = color


func _on_back_button_pressed() -> void:
	hide()


func _on_cube_border_reset_pressed() -> void:
	cube_border_slider.value = Setting.CUBE_BORDER
	update_cube_border(cube_border_slider.value)


func _on_cube_color_reset_pressed() -> void:
	cube_color_picker.color = Setting.CUBE_COLOR
	update_cube_color(cube_color_picker.color)


func _on_background_color_reset_pressed() -> void:
	background_color_picker.color = Setting.BACKGROUND_COLOR
	update_background_color(background_color_picker.color)
