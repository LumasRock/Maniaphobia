class_name Outside
extends BaseLevel

func _on_dialogue_finished(dialogue_id: String) -> void:
	move_to_next_scene()