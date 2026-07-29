# GoToNodeHandler.gd - Redirects flow to target_node_id, overriding next_node_id / option.next_node_id.
class_name GoToNodeHandler extends DialogueNodeHandler

@export var target_node_id : String

func handle(_dialogue: Dialogue, _node : DialogueNode, call_type: HandlerCallType, _option: DialogueOption = null, _args: Array = []) -> void:
	if target_node_id == "":	
		push_warning("GoToNodeHandler: target_node_id is empty. Handler will not run.")
		return
	super.handle(_dialogue, _node, call_type, _option, _args)

func _on_node_enter(_dialogue: Dialogue, _node: DialogueNode, _option: DialogueOption, _args: Array) -> bool:
	return _goto_node(_dialogue)

func _on_node_exit(_dialogue: Dialogue, _node: DialogueNode, _option: DialogueOption, _args: Array) -> bool:
	return _goto_node(_dialogue)
	
func _goto_node(_dialogue: Dialogue) -> bool:
	_dialogue._move_to_node(target_node_id)
	return true