class_name StartChainedDialogue
extends DialogueSignalHandler
## Use this handler to start a new dialogue after the current one finishes. This is useful for creating chained dialogues.

@export_category("Chained Dialogue")
@export_file("*.json") var chained_dialogue_path : String
@export var start_chained_dialogue_on_load : bool = false
@export var chained_dialogue_start_delay : float = 0.0

func _on_dialogue_finished(dialogue_id: String) -> void:
	if chained_dialogue_path != "":
		dialogue.dialogue_source = chained_dialogue_path
		dialogue.load_dialogue()
		if start_chained_dialogue_on_load :
			await get_tree().create_timer(chained_dialogue_start_delay).timeout
			dialogue.start()
