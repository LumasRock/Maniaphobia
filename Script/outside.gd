extends Node2D

@onready var dialogue: Dialogue = $Dialogue

func _ready() -> void: 
	await Transition.fade_out_finished
	@warning_ignore("return_value_discarded")
	dialogue.visibility_changed.connect(_on_dialogue_visibility_changed)
	dialogue.play("Outside")

func _on_dialogue_visibility_changed() -> void:
	if dialogue.visible:
		return

	Transition.transition_to("res://Scenes/Levels/Mansion.tscn")
