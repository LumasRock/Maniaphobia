class_name Apartment
extends Node2D

@export_file("*.tscn", "*.scn") var exit_scene: String

@onready var initial_dialogue     : Dialogue = $Dialogues/InitialDialogue
@onready var leave_early_dialogue : Dialogue = $Dialogues/LeaveEarly
@onready var player               : Player   = $Entities/Player
@onready var exitArea             : Area2D   = $Interactives/ExitArea

var _coffee_machine_fixed         : bool
var _is_player_in_exit_area       : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_dialogue.show()
	leave_early_dialogue.hide()
	if Transition.is_transitioning:
		await Transition.fade_out_finished

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and _is_player_in_exit_area:
		player.show_interact_prompt(false)
		if _coffee_machine_fixed :
			Transition.transition_to(exit_scene)
		else:
			_start_dialogue(leave_early_dialogue)

## common function to start a dialogue and set camera to dialogue camera
func _start_dialogue(dialogue: Dialogue) -> void:
	dialogue.start()

## common function to hide a dialogue and set camera to player
func _finish_dialogue(dialogue: Dialogue) -> void:
	print("Dialogue %s Finished" % dialogue.name)
	dialogue.finish()
	dialogue.hide()

func _on_fix_coffee_machine_option_selected(node:DialogueNode, option:DialogueOption) -> void:
	print("option selected %s '%s' on node text: %s." % [option.id, option.text, node.text] )
	if option.id == "1" :
		_coffee_machine_fixed = true
	if option.id == "2" :
		_coffee_machine_fixed = false

func _on_player_entered_exit_area(body: Node2D) -> void : _set_player_in_exit_area(body, true)

func _on_player_exited_exit_area(body: Node2D) -> void : _set_player_in_exit_area(body, false)

func _set_player_in_exit_area(body : Node2D, value : bool) -> void :
	print("player in exit area : %s" % value)
	if body is Player :
		body.show_interact_prompt(value)
		_is_player_in_exit_area = value