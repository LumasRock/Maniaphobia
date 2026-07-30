extends State
class_name GhostCall

signal ChasePlayer

@export var ghost := CharacterBody2D
@export var Maw : Node

func Enter():
	ghost.velocity = Vector2.ZERO
	
	await get_tree().create_timer(1.0).timeout
	ChasePlayer.emit()
	Transitioned.emit(self, "GhostWander")
