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

	func within_loading_distance(chunk: Vector3L, load_distance: int) -> bool:
		var in_x = chunk.x
		var in_y = chunk.z
		
		if not x > in_x - load_distance: return false
		if not x < in_x + load_distance: return false
		if not y > in_y - load_distance: return false
		if not y < in_y + load_distance: return false
		return true

var loaded: Array[SceneByChunk] = []
var to_load: Array[SceneByChunk] = []
var all_loaded: bool = false
var scene_database: Array[SceneByChunk] = [
	SceneByChunk.new("res://maps/CityTest.tscn"),
]


func load_and_unload(chunk: Vector3L, player_position: Vector3, loading_bounds: AABB):
	for scene in scene_database:
		if scene.within_loading_distance(chunk, player_position, loading_bounds):
			if scene in to_load or scene in loaded: continue
			all_loaded = false
			to_load.append(scene)
			ResourceLoader.load_threaded_request(scene.path)


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
