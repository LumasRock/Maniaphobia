# DialogueOptionHandler.gd - Base class for handlers that respond to specific dialogue options. 
# This class allows you to define handlers that trigger when certain dialogue options are presented or selected.
class_name DialogueOptionHandler extends Node

@export_category("Target Options")
@export var enabled : bool = true  # Whether the handler is enabled and should run
@export var target_node_ids : Array[String] = []  # List of target node IDs
@export var target_option_ids : Array[String] = []  # List of target option IDs


func applies_to(node_id: String) -> bool:
	return enabled and target_node_ids.has(node_id)

# Checks if the handler applies to the given option ID
func applies_to_option(option_id: String) -> bool:
	return enabled and target_option_ids.has(option_id)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_validate()
	
func _validate() -> void:
	if not enabled:
		return 
	if target_node_ids.is_empty():
		push_warning("DialogueOptionHandler: No target_node_ids specified for handler '%s'. Handler will be disabled." % self.name)
		enabled = false
	if target_option_ids.is_empty():
		push_warning("DialogueOptionHandler: No target_option_ids specified for handler '%s'. Handler will be disabled." % self.name)
		enabled = false

func _on_before_option_presented(_dialogue: Dialogue, _node: DialogueNode) -> void:
	pass

func _on_after_option_presented(_dialogue: Dialogue, _node: DialogueNode) -> void:
	pass

func _on_before_option_selected(_dialogue: Dialogue, _node: DialogueNode, _selected_option: DialogueOption) -> void:
	pass
	
func _on_after_option_selected(_dialogue: Dialogue, _node: DialogueNode, _selected_option: DialogueOption) -> void:
	pass