extends Node2D

@onready var dialogue: Dialogue = $Dialogue

func _ready() -> void:
	if Transition.is_transitioning:
		await Transition.fade_out_finished
	print("play")
	dialogue.play("Apartment")
