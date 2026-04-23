class_name Vector3L extends Object

var x: int
var y: int
var z: int

func _init(x_in, y_in, z_in) -> void:
	x = x_in
	y = y_in
	z = z_in


func subtract(to_subtract: Vector3L) -> Vector3L:
	return Vector3L.new(
		x - to_subtract.x,
		y - to_subtract.y,
		z - to_subtract.z
	)


func add(to_add: Vector3L) -> Vector3L:
	return Vector3L.new(
		x + to_add.x,
		y + to_add.y,
		z + to_add.z
	)


func to_vector3() -> Vector3:
	return Vector3(x, y, z)
