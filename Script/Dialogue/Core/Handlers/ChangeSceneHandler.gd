# ChangeSceneHandler.gd - Changes the scene when this node is reached. This handler is useful for transitioning to a new scene as part of the dialogue flow.
class_name ChangeSceneHandler extends DialogueNodeHandler

@export var target_scene_path : String

func handle(_dialogue: Dialogue, _node : DialogueNode, call_type: HandlerCallType, _option: DialogueOption = null, _args: Array = []) -> void:
	if target_scene_path == "":
		push_warning("ChangeSceneHandler: target_scene_path is empty. Handler will not run.")
		return
	super.handle(_dialogue, _node, call_type, _option, _args)

func _on_node_enter(_dialogue: Dialogue, _node: DialogueNode, _option: DialogueOption, _args: Array) -> bool:
	return _change_scene()

func _on_node_exit(_dialogue: Dialogue, _node: DialogueNode, _option: DialogueOption, _args: Array) -> bool:
	return _change_scene()

func _change_scene() -> bool:
	if not get_tree().change_scene_to_file(target_scene_path):
		push_warning("ChangeSceneHandler: Failed to change scene to %s" % target_scene_path)
		return false
	return true