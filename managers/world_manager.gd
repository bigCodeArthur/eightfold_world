class_name WorldManager extends Node3D

@export var player: Player 
@export var skybox: DynamicSkybox 
@export var loader: DynamicLoader
@export var ui: UI

@export_category("debug teleport")

@export var teleport_chunk_x: int:
	set(value):
		offset_all_children(Vector3(teleport_chunk_x - value, 0, 0), true)
		move_skybox()
		chunk.x = value
		teleport_chunk_x = value

@export var teleport_chunk_y: int: 
	set(value):
		offset_all_children(Vector3(0, teleport_chunk_y - value, 0), true)
		move_skybox()
		chunk.y = value
		teleport_chunk_y = value

@export var teleport_chunk_z: int:
	set(value):
		offset_all_children(Vector3(0, 0, teleport_chunk_z - value), true)
		move_skybox()
		chunk.z = value
		teleport_chunk_z = value

var chunk := Vector3L.new(teleport_chunk_x, teleport_chunk_y, teleport_chunk_z)

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


func _process(_delta: float) -> void:
	load_and_unload()
	marching_origin()
	move_skybox()
	debug_print()


func load_and_unload():
	loading_bounds.position = player.position - loading_bounds_size/2 
	loader.load_and_unload(chunk, loading_bounds)


func marching_origin():
	if not chunk_bounds.has_point(player.position):
		var offset: Vector3 = -player.position
		offset_all_children(offset)

		chunk.x += int(offset.x)
		chunk.y += int(offset.y)
		chunk.z += int(offset.z)


func offset_all_children(offset: Vector3, exclude_player: bool = false):
	for child in get_children():
		if child == player and exclude_player: continue
		if not child is Node3D: continue
		var node3d := child as Node3D
		node3d.position += offset
		print("now position: ", node3d.position)


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
