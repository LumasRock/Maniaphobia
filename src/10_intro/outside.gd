extends Node2D

@onready var dialogue: Dialogue = $Dialogue
@export_file("*.tscn", "*.scn") var mansion: String

func _ready() -> void: 
	if Transition.is_transitioning:
		await Transition.fade_out_finished
	@warning_ignore("return_value_discarded")
	dialogue.visibility_changed.connect(_on_dialogue_visibility_changed)
	dialogue.play("Outside")

func _on_dialogue_visibility_changed() -> void:
	if dialogue.visible:
		return

	# TODO transition on dialogue.completed signal
	Transition.transition_to(mansion)
