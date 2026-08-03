extends Node
signal Transitioned(state: State, new_state_name: StringName)
#signal hiding
#signal not_hiding

var active_camera: Camera2D = null

func set_camera(cam: Camera2D) -> void:
	if active_camera:
		active_camera.enabled = false
	active_camera = cam
	if active_camera:
		active_camera.enabled = true


func clear_camera(cam: Camera2D) -> void:
	if active_camera == cam:
		active_camera = null
		
