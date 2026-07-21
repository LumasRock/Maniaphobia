extends Node
class_name State

#signal Transitioned(state: State, new_state_name: StringName)

func Enter() -> void:
	pass

func Exit() -> void:
	pass

func Update(_delta: float) -> void:
	pass

func Physics_Update(_delta: float) -> void:
	pass
