class_name ApartmentLevel
extends Node2D
## Main script for the Apartment Level scene. This script manages the player's interactions with the environment, including dialogues, area tracking (see [enum Area]), and scene transitions.

## Area enum defines the different areas of interest in the apartment level. 
## The player's current area is tracked using the [_current_area] variable, 
## and is updated everytime the player enters or exits the boundaries of [Area2D] nodes in the scene (doors, rooms).

enum Area {
	NONE,
	COFFEE_MACHINE,
	EXIT,
	BEDROOM,
	LOUNGE,
	JACOB_ROOM
}

enum LevelStates {
	INITIAL_DIALOGUE,
	BEFORE_COFFEE_MACHINE_FIX,
	AFTER_COFFEE_MACHINE_FIX,
}

@export_file("*.tscn", "*.scn") var exit_scene : String

@onready var initialDialogue : Dialogue    = $Dialogues/InitialDialogue
@onready var coffeeDialogue  : Dialogue    = $Dialogues/FixCoffeeMachine
@onready var jacobDialogue   : Dialogue    = $Dialogues/JacobRoomDialogue
@onready var leaveDialogue   : Dialogue    = $Dialogues/LeaveEarlyDialogue
@onready var player          : Player      = $Entities/Player
@onready var doors           : Array[Node] = [$Interactables/BedroomDoor, $Interactables/LoungeDoor, $Interactables/JacobRoomDoor]
@onready var exit_door       : Node        = $Interactables/ExitDoor

var _dialogue_id             : String           ## this variable is only for logging purposes
var _current_area            : Area = Area.NONE ## FUTURE this could be an AreaOfInterest system that tracks the player's current area and triggers events based on their location.
var _current_state           : LevelStates = LevelStates.INITIAL_DIALOGUE 
var _coffee_machine_fixed    : bool             ## FUTURE this should be handled by a 'Checkpoint' system that can track progress within a scene or across multiple scenes.

#region BUILT-IN
func _ready() -> void:
	if Transition.is_transitioning:
		await Transition.fade_out_finished
	initialDialogue.show()
	player.show_interact_prompt(false)
	EventBus.set_camera(player.camera)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"): 
		match _current_area: 
			Area.NONE:
				pass
			Area.COFFEE_MACHINE:
				if _current_state == LevelStates.AFTER_COFFEE_MACHINE_FIX :
					return
				player.show_interact_prompt(false)
				_show_and_start_dialogue(coffeeDialogue)
			Area.EXIT:
				if _current_state == LevelStates.AFTER_COFFEE_MACHINE_FIX :
					Transition.transition_to(exit_scene)
				else : 
					_show_and_start_dialogue(leaveDialogue)
			Area.BEDROOM:
				pass
			Area.LOUNGE:
				pass
			Area.JACOB_ROOM:
				if jacobDialogue.visible : # dialogue is already running
					return
				if _current_state == LevelStates.INITIAL_DIALOGUE :
					return
				player.show_interact_prompt(false)
				_show_and_start_dialogue(jacobDialogue)
#endregion


#region DIALOGUE METHODS

## common function to start a dialogue and set camera to dialogue camera
func _show_and_start_dialogue(dialogue: Dialogue) -> void:
	print("Starting dialogue %s" % dialogue.get_dialogue_id())
	dialogue.show()
	# Align the dialogue camera to the current screen center shown by the active player camera.
	var screen_center: Vector2 = player.camera.get_screen_center_position()
	dialogue.global_position += screen_center - dialogue.dialogue_camera.global_position
	EventBus.set_camera(dialogue.dialogue_camera)
	dialogue.start()

## common function to hide a dialogue and set camera to player
func _finish_and_hide_dialogue(dialogue: Dialogue) -> void:
	print("Dialogue %s Finished" % dialogue.get_dialogue_id())
	dialogue.finish()
	dialogue.hide()
	EventBus.set_camera(player.camera)
#endregion

#region SIGNAL METHODS

## initialDialogue finishes
func _on_initial_dialogue_finished(dialogue_id: String) -> void:
	_finish_and_hide_dialogue(initialDialogue)
	_current_state = LevelStates.BEFORE_COFFEE_MACHINE_FIX

## player enters coffee machine Area2D
func _on_coffee_machine_body_entered(body: Node2D) -> void:
	if _current_state != LevelStates.INITIAL_DIALOGUE:
		_set_player_area(Area.COFFEE_MACHINE)

## player exits coffee machine Area2D
func _on_coffee_machine_body_exited(body: Node2D) -> void:
	if _current_state != LevelStates.INITIAL_DIALOGUE:
		_set_player_area(Area.NONE, false)

## coffeeDialogue finishes
func _on_fix_coffee_machine_dialogue_finished(dialogue_id: String) -> void:
	_finish_and_hide_dialogue(coffeeDialogue)
	_coffee_machine_fixed = true
	_current_state = LevelStates.AFTER_COFFEE_MACHINE_FIX

## player enters exit door Area2D
func _on_player_entered_exit_area(body: Node2D) -> void:
	if _current_state != LevelStates.INITIAL_DIALOGUE:
		_set_player_area(Area.EXIT)

## player exits exit door Area2D
func _on_player_exited_exit_area(body: Node2D) -> void:
	_set_player_area(Area.NONE, false)

func _on_player_enter_jacobroom_area(body:Node2D) -> void:
	if _current_state != LevelStates.INITIAL_DIALOGUE:
		_set_player_area(Area.JACOB_ROOM)

func _on_player_exit_jacobroom_area(body:Node2D) -> void:
	_set_player_area(Area.NONE, false)

func _on_jacobroom_dialogue_finished(dialogue_id: String) -> void:
	_finish_and_hide_dialogue(jacobDialogue)

## Sets the player area 
func _set_player_area(area: Area, show_prompt: bool = true) -> void :
	player.show_interact_prompt(show_prompt)
	_current_area = area

#endregion

## These methods are here for demo purposes, should be removed for prod build
#region DIALOGUE SIGNAL EXAMPLES

func _on_dialogue_dialogue_started(dialogue_id: String) -> void:
	_dialogue_id = dialogue_id

func _on_dialogue_node_entered(node: DialogueNode) -> void:
	_log("Enter Node %s" % [_dialogue_id, node.id])

func _on_dialogue_node_exited(node: DialogueNode) -> void:
	_log("Exit Node %s" % [_dialogue_id, node.id])

func _on_dialogue_speaker_changed(previous_speaker: String, new_speaker: String) -> void:
	_log("Speaker changed %s -> %s" % [_dialogue_id, previous_speaker, new_speaker])

func _on_dialogue_portrait_changed(previous_portrait: String, previous_emotion: String, new_portrait: String, new_emotion: String) -> void:
	if previous_portrait != new_portrait:
		_log("Portrait changed %s -> %s" % [previous_portrait, new_portrait])
	if previous_emotion != new_emotion:
		_log("Emotion changed %s -> %s" % [previous_emotion, new_emotion])

func _on_dialogue_dialogue_paused(dialogue_id: String) -> void:
	_log("Paused" % dialogue_id)

func _on_dialogue_dialogue_resumed(dialogue_id: String) -> void:
	_log("Resumed" % dialogue_id)

func _on_dialogue_choice_selected(option: DialogueOption) -> void:
	_log("Choice selected: %s (next node: %s)" % [option.text, option.next_node_id])

func _log(message: String) -> void:
	print("Dialogue " + _dialogue_id + " " + message)
#endregion
