class_name LoadSceneAfterOptionSelected 
extends DialogueSignalHandler
## Handler to load a scene in the option workflow. This is useful for options that should load a new scene, like "Enter the castle" or "Go to the forest".
## This handler can run in any moment of the options workflow.

@export_file("*.tscn") var scene_path : String
@export var load_scene_delay : float = 0.0

func _on_option_selected(_node: DialogueNode, _selected_option: DialogueOption) -> void:
	if scene_path != "":
		await get_tree().create_timer(load_scene_delay).timeout
		if get_tree().change_scene_to_file(scene_path) != OK:
			push_warning("LoadSceneAfterOptionSelected: Failed to load scene '%s'." % scene_path)