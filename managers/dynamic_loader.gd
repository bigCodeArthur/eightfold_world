class_name DynamicLoader extends Node

@export var world_manager: WorldManager

class SceneByChunk extends Object:
	var path: String
	var x: int
	var y: int
	var z: int

	func _init(path_in: String, x_in: int = 0, y_in: int = 0, z_in: int = 0) -> void:
		path = path_in
		x = x_in
		y = y_in
		z = z_in

	func within_loading_distance(chunk: Vector3L, bounds: AABB) -> bool:
		var localized = Vector3(x - chunk.x, y - chunk.y, z - chunk.z)
		return bounds.has_point(localized)

var loaded: Array[SceneByChunk] = []
var to_load: Array[SceneByChunk] = []
var all_loaded: bool = false
var scene_database: Array[SceneByChunk] = [
	SceneByChunk.new("res://maps/CityTest.tscn"),
]


func load_and_unload(chunk: Vector3L, loading_bounds: AABB):
	for scene in scene_database:
		if scene.within_loading_distance(chunk, loading_bounds):
			if scene in to_load or scene in loaded: continue
			all_loaded = false
			to_load.append(scene)
			ResourceLoader.load_threaded_request(scene.path)
		else:
			pass


func _physics_process(_delta: float) -> void:
	if not all_loaded:
		print("NOT ALL LOADED")
		all_loaded = true
		for scene in to_load:
			if scene in loaded: continue
			if ResourceLoader.load_threaded_get_status(scene.path) == 3:
				print("loaded!")
				var resource := ResourceLoader.load_threaded_get(scene.path)
				var packed_scene := resource as PackedScene
				world_manager.add_child(packed_scene.instantiate())
				loaded.append(scene)
			else:
				all_loaded = false
