extends Node2D

@onready var Dialogue = $Dialogue

func _ready():
	await Transition.fade_out_finished
	Dialogue.play("Apartment")
