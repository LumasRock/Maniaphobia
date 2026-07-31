class_name RedirectAfterOptionSelected 
extends DialogueSignalHandler
## Redirects dialogue to [target_node_id], overriding [Dialogue.next_node_id] and [selected_option.next_node_id].
## This handler always run after option is selected

@export var next_node_id : String

func _on_after_option_selected(_dialogue: Dialogue, _node: DialogueNode, _selected_option: DialogueOption) -> void:
	if next_node_id != "":
		_dialogue.request_navigation_override(next_node_id)