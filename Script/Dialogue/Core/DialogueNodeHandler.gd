# DialogueNodeHandler.gd - Base class to implement custom behaviour when entering or exiting specific dialogue nodes. 
# Subclass this to create your own handlers for dialogue nodes.
class_name DialogueNodeHandler extends Node

@export_category("Target Nodes")
@export var enabled : bool = true  # Whether the handler is enabled and should run
@export var target_ids : Array[String] = []  # List of target node IDs to handle
@export var runs_on_enter : bool = false  # Whether to run the handler when entering the node
@export var runs_on_exit : bool = false  # Whether to run the handler when exiting

@export_category("Dialogue Options")
@export var target_option_ids : Array[String] = []  # List of target option IDs to handle (optional)

@export_category("Debug")
@export var warn_on_missing_node : bool = true  # Whether to warn if a target node is missing
@export var warn_on_failure : bool = true  # Whether to warn if the handler fails to run

enum HandlerCallType {
	ENTER,
	EXIT
}

func _ready() -> void:
	if not enabled:
		return 
	if target_ids.is_empty():
		push_warning("DialogueNodeHandler: No target_ids specified for handler '%s'. Handler will be disabled." % self.name)
		enabled = false
	if not runs_on_enter and not runs_on_exit:
		push_warning("DialogueNodeHandler: Neither runs_on_enter nor runs_on_exit is enabled for handler '%s'. Handler will be disabled." % self.name)
		enabled = false

# Checks if the handler applies to the given node ID
func applies_to(node_id: String) -> bool:
	return enabled and target_ids.has(node_id)

# Checks if the handler applies to the given option ID
func applies_to_option(option_id: String) -> bool:
	return enabled and target_option_ids.has(option_id)

# Handles the dialogue node event based on the call type (enter or exit)
func handle(_dialogue: Dialogue, _node : DialogueNode, call_type: HandlerCallType, _option : DialogueOption = null, _args: Array = []) -> void:
	if not enabled:
		return

	if not applies_to(_node.id):
		if warn_on_missing_node:
			push_warning("DialogueNodeHandler: Node '%s' is not in target_ids. Handler will not run." % _node.id)
		return

	var success : bool = false
	match call_type:
		HandlerCallType.ENTER:
			if runs_on_enter:
				success = _on_node_enter(_dialogue, _node, _option, _args)
		HandlerCallType.EXIT:
			if runs_on_exit:
				success = _on_node_exit(_dialogue, _node, _option, _args)

	if not success and warn_on_failure:
		push_warning("DialogueNodeHandler: Failed to handle node '%s' on %s" % [_node.id, str(call_type)])

# Override this method in subclasses to implement custom behavior on node enter
func _on_node_enter(_dialogue: Dialogue, _node: DialogueNode, _option: DialogueOption, _args: Array) -> bool:
	return true

	
# Override this method in subclasses to implement custom behavior on node exit
func _on_node_exit(_dialogue: Dialogue, _node: DialogueNode, _option: DialogueOption, _args: Array) -> bool:
	return true
