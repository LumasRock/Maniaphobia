class_name PlayerHidingManager
extends Node


var current_hide_interactable: HideInteractable

var is_hiding: bool = false
var hiding_left: float = 10.0
var hide_timer: float = 0.0


func _input(_event):
	if Input.is_action_just_pressed(&"interact") and current_hide_interactable:
		if not is_hiding:
			current_hide_interactable.start_hiding()
		else:
			current_hide_interactable.stop_hiding()
