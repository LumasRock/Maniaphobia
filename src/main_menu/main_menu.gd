extends Control

@export_file("*.tscn", "*.scn") var apartment: String

func _on_play_button_pressed() -> void:
	Transition.transition_to(apartment)


func _on_settings_button_pressed() -> void:
	Transition.transition_to("res://Scenes/Settings.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
