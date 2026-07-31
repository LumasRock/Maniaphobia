# GoToNodeHandler.gd - Redirects flow to target_node_id, overriding next_node_id / option.next_node_id.
class_name GoToNodeOptionHandler extends DialogueOptionHandler

@export var target_node_id : String

func _on_node_enter(_dialogue: Dialogue, _node: DialogueNode, _option: DialogueOption, _args: Array) -> bool:
	return _goto_node(_dialogue)

func _on_node_exit(_dialogue: Dialogue, _node: DialogueNode, _option: DialogueOption, _args: Array) -> bool:
	return _goto_node(_dialogue)
	
func _goto_node(_dialogue: Dialogue) -> bool:
	_dialogue._move_to_node(target_node_id)
	return true