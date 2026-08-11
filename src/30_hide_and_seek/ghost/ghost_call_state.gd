extends State
class_name GhostCall

signal ChasePlayer

@export var ghost: Ghost


func state_enter():
	ghost.velocity = Vector2.ZERO
	
	await get_tree().create_timer(1.0).timeout
	ChasePlayer.emit()
	transitioned.emit(self, "GhostWander")
