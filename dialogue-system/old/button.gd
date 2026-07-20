extends Button

func _on_pressed() -> void:
	if self.text == "Othertest scene":
		get_tree().change_scene_to_file("res://othertest.tscn")
	if self.text == "Test scene":
		get_tree().change_scene_to_file("res://test.tscn")
