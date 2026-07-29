# FinishDialogueHandler.gd - Ends the dialogue as soon as this node/option is reached.
class_name FinishDialogueHandler extends DialogueNodeHandler

func _on_node_enter(_dialogue: Dialogue, _node: DialogueNode, _option: DialogueOption, _args: Array) -> bool:
	return _finish_dialogue(_dialogue)

func _on_node_exit(_dialogue: Dialogue, _node: DialogueNode, _option: DialogueOption, _args: Array) -> bool:
	return _finish_dialogue(_dialogue)
	
func _finish_dialogue(_dialogue: Dialogue) -> bool:
	if _dialogue == null : 
		push_warning("FinishDialogueHandler: Dialogue is null. Cannot finish dialogue.")
		return false
	_dialogue.finish()
	return true