extends State
class_name GhostCall

signal ChasePlayer

@export var ghost := CharacterBody2D
@export var maw : Node

func enter() -> void:
	ghost.velocity = Vector2.ZERO
	
	await get_tree().create_timer(1.0).timeout
	ChasePlayer.emit()
	Transitioned.emit(self, "GhostWander")
