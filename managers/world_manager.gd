class_name WorldManager extends Node3D

@export var player: Player 
@export var skybox: DynamicSkybox 
@export var loader: DynamicLoader
@export var ui: UI

@export_category("debug teleport")

@export var teleport_chunk_x: int:
	set(value):
		move_skybox()
		teleport_chunk_x = value

@export var teleport_chunk_y: int:
	set(value):
		move_skybox()
		teleport_chunk_y = value

@export var teleport_chunk_z: int:
	set(value):
		move_skybox()
		teleport_chunk_z = value

var chunk := Vector3L.new(0, 0, 0)

var chunk_bounds_size = Vector3( 2000,  2000,  2000)
var chunk_bounds: AABB = AABB(
	-chunk_bounds_size / 2,
	chunk_bounds_size
)

var loading_bounds_size = Vector3( 2000,  2000,  2000)
var loading_bounds: AABB = AABB(
	-loading_bounds_size / 2,
	loading_bounds_size
)

var load_unload_distance: int = 10000


func _process(_delta: float) -> void:
	load_and_unload()
	marching_origin()
	move_skybox()
	debug_print()


func load_and_unload():
	loading_bounds.position = player.position -loading_bounds_size/2 
	var load_x: float = chunk.x + player.position.x
	var load_z: float = chunk.z + player.position.z
	loader.load_and_unload(player.position, chunk, loading_bounds)


func marching_origin():
	if not chunk_bounds.has_point(player.position):

		var offset = -player.position
		offset_all_children(offset)

		chunk.x += offset.x
		chunk.y += offset.y
		chunk.z += offset.z


func offset_all_children(offset: Vector3):
	for child in get_children():
		if not child is Node3D: continue
		var node3d := child as Node3D
		if node3d.position.distance_to(player.position) > load_unload_distance:
			node3d.queue_free()
		node3d.position += offset


func debug_print():
	var debug_string := ""
	debug_string = "x: %s, y: %s, z: %s" % [
		snapped(player.position.x, 0.01), 
		snapped(player.position.y, 0.01),
		snapped(player.position.z, 0.01),
	]
	ui.status_to_be_printed["player position"] = debug_string
	
	debug_string = "x: %s, y: %s, z: %s" % [
		snapped(skybox.position.x, 0.01), 
		snapped(skybox.position.y, 0.01),
		snapped(skybox.position.z, 0.01),
	]
	ui.status_to_be_printed["skybox position"] = debug_string
	
	debug_string = "x: %s, y: %s, z: %s" % [
		snapped(chunk.x, 0.01), 
		snapped(chunk.y, 0.01),
		snapped(chunk.z, 0.01),
	]
	ui.status_to_be_printed["chuck position"] = debug_string


func move_skybox():
	if not player: return

	var player_offset = player.camera.global_position / 100

	var chunk_offset = Vector3(
		chunk.x / 100.0,
		chunk.y / 100.0,
		chunk.z / 100.0,
	)

	skybox.position = player.camera.global_position - (player_offset - chunk_offset)
