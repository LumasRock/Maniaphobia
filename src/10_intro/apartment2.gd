class_name Apartment
extends Node2D

enum Area {
	NONE,
	COFFEE_MACHINE,
	EXIT,
	JACOBS_ROOM,
}

@onready var initialDialogue : Dialogue = $Dialogues/InitialDialogue
@onready var coffeeDialogue : Dialogue = $Dialogues/FixCoffeeMachine
@onready var jacobs_room: Dialogue = $Dialogues/JacobsRoom
@onready var leave_early: Dialogue = $Dialogues/LeaveEarly


@onready var player : Player = $Entities/Player

# (Future) scenes like this one, should extend from a `BaseScene` class that handles common functionality like dialogue management, area tracking, and scene transitions. This would reduce code duplication and improve maintainability.
@export_file("*.tscn", "*.scn") var exit_scene: String

# this variable is only for logging purposes
var _dialogue_id : String

# (Future) this could be an AreaOfInterest system that tracks the player's current area and triggers events based on their location.
var _current_area : Area = Area.NONE

# (FUTURE) this should be handled by a 'Checkpoint' system that can track progress within a scene or across multiple scenes.
var _coffee_machine_fixed : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialDialogue.show()
	coffeeDialogue.hide()
	jacobs_room.hide()
	leave_early.hide()
	if Transition.is_transitioning:
		await Transition.fade_out_finished

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"): 
		match _current_area: 
			Area.NONE:
				pass
			Area.COFFEE_MACHINE:
				player.show_interact_prompt(false)
				_start_dialogue(coffeeDialogue)
			Area.EXIT:
				if _coffee_machine_fixed:
					Transition.transition_to(exit_scene)
				else:
					_log("Coffee machine not fixed yet. Cannot exit.")
					_start_dialogue(leave_early)
			Area.JACOBS_ROOM:
				player.show_interact_prompt(false)
				_start_dialogue(jacobs_room)
				pass


#region DIALOGUE MANAGEMENT

func start_dialogue_jacobs_room() -> void:
	_start_dialogue(jacobs_room)

func start_dialogue_exit_early() -> void:
	_start_dialogue(leave_early)

# common function to start a dialogue and set camera to dialogue camera
func _start_dialogue(dialogue: Dialogue) -> void:
	dialogue.show()
	EventBus.set_camera(dialogue.dialogue_camera)
	dialogue.start()
	_dialogue_id = dialogue.get_dialogue_id()

# common function to hide a dialogue and set camera to player
func _finish_dialogue(dialogue: Dialogue) -> void:
	_log("Dialogue Finished")
	dialogue.finish()
	dialogue.hide()
	EventBus.set_camera(player.camera)
	_dialogue_id = ""
#endregion

#region INITIAL DIALOGUE

func _on_dialogue_dialogue_started(dialogue_id: String) -> void:
	_dialogue_id = dialogue_id
	_log("Started")

func _on_dialogue_node_entered(node: DialogueNode) -> void:
	_log("Enter Node " + node.id)

func _on_dialogue_node_exited(node: DialogueNode) -> void:
	_log("Exit Node " + node.id)

func _on_initial_dialogue_finished(__dialogue_id: String) -> void:
	_finish_dialogue(initialDialogue)

func _on_dialogue_speaker_changed(previous_speaker: String, new_speaker: String) -> void:
	_log("Speaker changed " + previous_speaker + " -> " + new_speaker)

func _on_dialogue_portrait_changed(previous_portrait: String, previous_emotion: String, new_portrait: String, new_emotion: String) -> void:
	if previous_portrait != new_portrait:
		_log("Portrait changed " + previous_portrait + " -> " + new_portrait)
	if previous_emotion != new_emotion:
		_log("Emotion changed " + previous_emotion + " -> " + new_emotion)

func _on_dialogue_dialogue_paused() -> void:
	_log("Paused")

func _on_dialogue_dialogue_resumed() -> void:
	_log("Resumed")

func _on_dialogue_choice_selected(option: DialogueOption) -> void:
	_log("Choice selected: " + option.text + " (next node: " + option.next_node_id + ")")

#endregion

#region COFFEE MACHINE AREA

func _on_coffee_machine_body_entered(body: Node2D) -> void:
	if body is Player:
		_log("Player entered coffee machine area")
		(body as Player).show_interact_prompt(true)
		_current_area = Area.COFFEE_MACHINE

func _on_coffee_machine_body_exited(body: Node2D) -> void:
	if body is Player:
		_log("Player exited coffee machine area")
		(body as Player).show_interact_prompt(false)
		_current_area = Area.NONE

func _on_fix_coffee_machine_dialogue_finished(__dialogue_id: String) -> void:
	_finish_dialogue(coffeeDialogue)
	_coffee_machine_fixed = true

#endregion

#region EXIT AREA
func _on_player_entered_exit_area(body: Node2D) -> void:
	if body is Player:
		_log("Player entered exit area")
		(body as Player).show_interact_prompt(true)
		_current_area = Area.EXIT

func _on_player_exited_exit_area(body: Node2D) -> void:
	if body is Player:
		_log("Player exited exit area")
		(body as Player).show_interact_prompt(false)
		_current_area = Area.NONE

func _on_exit_area_dialogue_finished(__dialogue_id: String) -> void:
	_finish_dialogue(leave_early)

#endregion


#region Jacobs Room

func _on_jacobs_room_body_entered(body: Node2D) -> void:
	if body is Player:
		_log("Player entered coffee machine area")
		(body as Player).show_interact_prompt(true)
		_current_area = Area.COFFEE_MACHINE

func _on_jacobs_room_body_exited(body: Node2D) -> void:
	if body is Player:
		_log("Player exited coffee machine area")
		(body as Player).show_interact_prompt(false)
		_current_area = Area.NONE

func _on_jacobs_room_dialogue_finished(__dialogue_id: String) -> void:
	_finish_dialogue(jacobs_room)

#endregion

#region LOGGING

# Helper function to log messages with the current dialogue ID
func _log(message: String) -> void:
	print("Dialogue " + _dialogue_id + " " + message)
#endregion
