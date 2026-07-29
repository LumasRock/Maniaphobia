extends Node2D

@onready var initialDialogue : Dialogue = $InitialDialogue
@onready var coffeeDialogue : Dialogue = $FixCoffeeMachine
@onready var player : Player = $Player

@onready var doors : Array[Door] = [$Door1, $Door2, $Door3]
@onready var exit_door : Area2D = $ExitDoor

var _dialogue_id : String
var _in_coffee_machine_area : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await Transition.fade_out_finished
	initialDialogue.show()
	EventBus.set_camera(initialDialogue.dialogue_camera)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and _in_coffee_machine_area:
		player.show_interact_prompt(false)
		_start_dialogue(coffeeDialogue)


#region DIALOGUE MANAGEMENT

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

#region SIGNALS
func _on_dialogue_dialogue_started(dialogue_id: String) -> void:
	_dialogue_id = dialogue_id
	_log("Started")

func _on_dialogue_node_entered(node: DialogueNode) -> void:
	_log("Enter Node " + node.id)

func _on_dialogue_node_exited(node: DialogueNode) -> void:
	_log("Exit Node " + node.id)

func _on_initial_dialogue_finished(dialogue_id: String) -> void:
	_finish_dialogue(initialDialogue)

func _on_fix_coffee_machine_dialogue_finished(dialogue_id: String) -> void:
	_finish_dialogue(coffeeDialogue)

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

func _on_dialogue_choice_presented(options: Array) -> void:
	_log("Choice presented with options: " + ",".join(options))

func _on_dialogue_choice_selected(option: DialogueOption) -> void:
	_log("Choice selected: " + option.text + " (next node: " + option.next_node_id + ")")

func _on_coffee_machine_body_entered(body: Node2D) -> void:
	if body is Player:
		_log("Player entered coffee machine area")
		(body as Player).show_interact_prompt(true)
		_in_coffee_machine_area = true

func _on_coffee_machine_body_exited(body: Node2D) -> void:
	if body is Player:
		_log("Player exited coffee machine area")
		(body as Player).show_interact_prompt(false)
		_in_coffee_machine_area = false
#endregion

#region LOGGING

# Helper function to log messages with the current dialogue ID
func _log(message: String) -> void:
	print("Dialogue " + _dialogue_id + " " + message)
#endregion
