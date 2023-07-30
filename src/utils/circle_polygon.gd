@tool
extends Polygon2D
class_name CirclePolygon


const MIN_NUM_SIDES = 10

@export var polygon_radius: float = 10 :
	get: return polygon_radius
	set(value):
		polygon_radius = value
		update_polygon()

@export var multiplier: float = 1 :
	get: return multiplier
	set(value):
		multiplier = value
		update_polygon()


func update_polygon():
	if polygon_radius == 0:
		polygon = []
	
	var num_sides: int = max(polygon_radius * multiplier, MIN_NUM_SIDES)
	var angle_delta: float = (PI * 2) / num_sides
	
	var offset_vector: Vector2 = Vector2(polygon_radius, 0)
	var new_polygon: PackedVector2Array
	
	for i in num_sides:
		new_polygon.push_back(offset_vector)
		offset_vector = offset_vector.rotated(angle_delta)
	
	polygon = new_polygon
