class_name UI extends Control

@onready var debug_status: Label = %DebugStatus
var status_to_be_printed: Dictionary[String, String] = {}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	status_to_be_printed["FPS"] = str(Engine.get_frames_per_second())

	var status_string := ""
	for status in status_to_be_printed:
		status_string += status + ": "
		status_string += status_to_be_printed[status] + "\n"

	debug_status.text = status_string
