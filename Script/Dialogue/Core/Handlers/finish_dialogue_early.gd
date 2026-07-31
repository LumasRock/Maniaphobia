class_name FinishDialogueEarly
extends DialogueSignalHandler
## Use this handler to end the dialogue flow. This is useful for branching, if an option should end the dialogue early
## This handler only runs in the node workflow.

enum finish_dialogue_moment { 
	ANY                          = 0, 
	ON_NODE_ENTER                = 1 , 
	ON_NODE_EXIT                 = 2 , 
	ON_TEXT_FULLY_REVEALED       = 3 , 
	ON_BEFORE_OPTIONS_PRESENTED  = 4 , 
	ON_AFTER_OPTIONS_PRESENTED   = 5 , 
	ON_OPTION_SELECTED           = 6
}

@export_flags(
		"ANY", "ON_NODE_ENTER", "ON_NODE_EXIT", 
		"ON_TEXT_FULLY_REVEALED", "ON_BEFORE_OPTIONS_PRESENTED", 
		"ON_AFTER_OPTIONS_PRESENTED", "ON_OPTION_SELECTED") var node_match_type : int = 0

func _on_node_entered(node: DialogueNode) -> void:
	if node_match_type == finish_dialogue_moment.ANY or node_match_type == finish_dialogue_moment.ON_NODE_ENTER:
		dialogue.finish()
	
func _on_node_exited(node: DialogueNode) -> void:
	if node_match_type == finish_dialogue_moment.ANY or node_match_type == finish_dialogue_moment.ON_NODE_EXIT:
		dialogue.finish()

func _on_before_options_presented(node: DialogueNode) -> void:
	if node_match_type == finish_dialogue_moment.ANY or node_match_type == finish_dialogue_moment.ON_BEFORE_OPTIONS_PRESENTED:
		dialogue.finish()
	
func _on_after_options_presented(node: DialogueNode) -> void:
	if node_match_type == finish_dialogue_moment.ANY or node_match_type == finish_dialogue_moment.ON_AFTER_OPTIONS_PRESENTED:
		dialogue.finish()

func _on_option_selected(node: DialogueNode, option: DialogueOption) -> void:
	if node_match_type == finish_dialogue_moment.ANY or node_match_type == finish_dialogue_moment.ON_OPTION_SELECTED:
		dialogue.finish()