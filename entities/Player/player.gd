class_name Player extends CharacterBody3D


@export var SPEED: float = 10.0
@export var JUMP_VELOCITY: float = 5.0

@export var disable_gavity: bool = false
@export var auto_walk: bool = false

@onready var camera: PlayerCamera = $head/Camera3D


func _physics_process(delta: float) -> void:
	if not is_on_floor(): velocity += get_gravity() * delta
	if disable_gavity: velocity *= Vector3(1, 0, 1)

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	if auto_walk: input_dir = Vector2.UP
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
