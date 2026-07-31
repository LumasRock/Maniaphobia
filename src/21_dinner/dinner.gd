extends Node2D

@export var dialogue: Dialogue
@export var transition: AnimationPlayer

func _ready() -> void:
	if Transition.is_transitioning:
		await Transition.fade_out_finished
	dialogue.play("Dinner")
