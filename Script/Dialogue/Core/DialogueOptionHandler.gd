## DialogueOptionHandler.gd 
## Base class for handlers that respond to specific dialogue options. Extend this class to define custom behaviour when dialogues display options. 
##
## This class provides hooks for three main events in the dialogue option lifecycle:
## 1. Before options are presented: ideal to trigger visual effects, play sounds, or modify the options before they are displayed.
## 2. After options are presented: ideal to alter the option buttons, like glowing effects, blinking, etc.
## 3. After an option is selected: ideal to redirect the dialogue to a different node, finish the dialogue or load a new scene.
class_name DialogueOptionHandler extends Node

@export_category("Target Options")
@export var enabled : bool = true  # Whether the handler is enabled and should run
@export var target_node_ids : Array[String] = []  # List of target node IDs
@export var target_option_ids : Array[String] = []  # List of target option IDs

func _ready() -> void:
	_validate()

## Checks if the handler applies to the given node ID, comparing against the `target_node_ids` list.
## `Dialogue` uses this method to determine if the handler should be invoked for a specific dialogue node.
func applies_to(node_id: String) -> bool:
	return enabled and target_node_ids.has(node_id)

## Checks if the handler applies to the given option ID, comparing against the `target_option_ids` list.
## `Dialogue` uses this method to determine if the handler should be invoked for a specific dialogue node.
func applies_to_option(option_id: String) -> bool:
	return enabled and target_option_ids.has(option_id)

## Called on `_ready()` to validate the handler's configuration. If the handler is not properly configured, it will be disabled and a warning will be issued.	
func _validate() -> void:
	if not enabled:
		return 
	if target_node_ids.is_empty():
		push_warning("DialogueOptionHandler: No target_node_ids specified for handler '%s'. Handler will be disabled." % self.name)
		enabled = false
	if target_option_ids.is_empty():
		push_warning("DialogueOptionHandler: No target_option_ids specified for handler '%s'. Handler will be disabled." % self.name)
		enabled = false

## Called before the dialogue options are added to the current scene. 
## The Dialogue `current_node` is passed in, allowing you to inspect the node and its options before they are presented to the player. 
## This would be the best moment to trigger visual effects, play sounds, or modify the options before they are displayed.
## `_node` is the dialogue node that contains the options
## `_dialogue` is the current dialogue instance.
func _on_before_options_presented(_dialogue: Dialogue, _node: DialogueNode) -> void:
	pass

## Called after the dialogue options are added to the current scene.
## The Dialogue `current_node` is passed in, allowing you to inspect the node and its options before the player makes a selection. 
## This would be the best moment to alter the option buttons, like glowing effects, blinking, etc.
## `_node` is the dialogue node that contains the options
## `_dialogue` is the current dialogue instance.
func _on_after_options_presented(_dialogue: Dialogue, _node: DialogueNode) -> void:
	pass
	
## Called after the player chooses an option.
## The Dialogue `current_node` and the selected option are passed in, allowing you to inspect the node and its options before moving to the next node. 
## This would be the best moment to redirect the dialogue to a different node, finish the dialogue or load a new scene.
## `_node` is the dialogue node that contains the options
## `_dialogue` is the current dialogue instance.
## `_selected_option` is the option that the player has selected.
func _on_after_option_selected(_dialogue: Dialogue, _node: DialogueNode, _selected_option: DialogueOption) -> void:
	pass