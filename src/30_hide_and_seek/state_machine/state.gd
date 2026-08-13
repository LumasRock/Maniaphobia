extends Node
class_name State

signal transitioned(state: State, new_state_name: StringName)


func state_enter() -> void:
	pass

func state_exit() -> void:
	pass

func state_update(_delta: float) -> void:
	pass

func state_physics_update(_delta: float) -> void:
	pass
