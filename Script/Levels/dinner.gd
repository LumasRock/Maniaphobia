extends Node2D

@export var Dialogue : Control
@export var transition : AnimationPlayer

func _ready() -> void:
	await Transition.fade_out_finished
	Dialogue.play("Dinner")
