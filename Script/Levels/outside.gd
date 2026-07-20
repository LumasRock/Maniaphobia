extends Node2D

@onready var Dialogue = $Dialogue

func _ready() -> void: 
	await Transition.fade_out_finished
	Dialogue.visibility_changed.connect(_on_dialogue_visibility_changed)
	Dialogue.play("Outside")

func _on_dialogue_visibility_changed() -> void:
	if Dialogue.visible:
		return

	Transition.transition_to("res://Scenes/Levels/Mansion.tscn")
