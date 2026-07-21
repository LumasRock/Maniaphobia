extends Node2D

@onready var Dialogue = $Dialogue

func _ready():
	if Transition.is_transitioning:
		await Transition.fade_out_finished
	Dialogue.play("Apartment")
