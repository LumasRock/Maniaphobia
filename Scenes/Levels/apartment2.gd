extends Node2D

@onready var dialogue : Dialogue = $Dialogue

var _dialogue_id : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await Transition.fade_out_finished


# Helper function to log messages with the current dialogue ID
func _log(message: String) -> void:
	print("Dialogue " + _dialogue_id + " " + message)

# Example code on how to connect to the dialogue signals

func _on_dialogue_dialogue_started(dialogue_id: String) -> void:
	_dialogue_id = dialogue_id
	_log("Started")

func _on_dialogue_node_entered(node: DialogueNode) -> void:
	_log("Enter Node " + node.id)

func _on_dialogue_node_exited(node: DialogueNode) -> void:
	_log("Exit Node " + node.id)

func _on_dialogue_dialogue_finished(dialogue_id: String) -> void:
	_log("Ended")
	_dialogue_id = ""

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
