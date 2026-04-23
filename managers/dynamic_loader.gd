class_name DynamicLoader extends Node

@export var world_manager: WorldManager

class SceneByChunk extends Object:
	var path: String
	var node_path: NodePath
	var chunk: Vector3L
	var is_loaded: bool

	func _init(
		file_path_in: String,
		node_path_in: NodePath = '',
		x_in: int = 0,
		y_in: int = 0,
		z_in: int = 0
	) -> void:
		path = file_path_in
		node_path = node_path_in
		chunk = Vector3L.new(x_in, y_in, z_in)

	func within_loading_distance(chunk_in: Vector3L, bounds: AABB) -> bool:
		var localized = Vector3(chunk.x - chunk_in.x, chunk.y - chunk_in.y, chunk.z - chunk_in.z)
		return bounds.has_point(localized)

var loaded: Array[SceneByChunk] = []
var to_load: Array[SceneByChunk] = []
var all_loaded: bool = false
var world_object_database: Array[SceneByChunk] = [
	SceneByChunk.new("res://maps/CityTest.tscn"),
]


func load_and_unload(chunk: Vector3L, loading_bounds: AABB):
	for world_object in loaded:
		if not world_object.within_loading_distance(chunk, loading_bounds):
			if not world_object.node_path: continue
			var node = get_node(world_object.node_path)
			if node: node.queue_free()

	for world_object in world_object_database:
		if world_object.within_loading_distance(chunk, loading_bounds):
			if world_object in to_load or world_object in loaded: continue
			if not world_object.node_path: print("HET WERKT")
			all_loaded = false
			to_load.append(world_object)
			ResourceLoader.load_threaded_request(world_object.path)


func _physics_process(_delta: float) -> void:
	if not all_loaded:
		print("started_loading")
		all_loaded = true
		for world_object in to_load:
			if not load_world_object_when_ready(world_object): 
				all_loaded = false


func load_world_object_when_ready(world_object: SceneByChunk) -> bool:
	if ResourceLoader.load_threaded_get_status(world_object.path) != 3: 
		return false

	var resource := ResourceLoader.load_threaded_get(world_object.path)
	var packed_scene := resource as PackedScene
	var node = packed_scene.instantiate() as Node3D

	world_manager.add_child(node)
	node.position = world_object.chunk.subtract(world_manager.chunk).to_vector3()
	world_object.node_path = node.get_path()

	loaded.append(world_object)
	to_load.erase(world_object)

	print("spawned %s at %s" % [node.name, node.position])

	return true
