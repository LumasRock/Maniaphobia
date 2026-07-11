extends Control


func _on_reset_button_pressed() -> void:
	Transition.transition_to("res://Scenes/Levels/Hide_And_Seek.tscn")

func _on_menu_button_pressed() -> void:
	Transition.transition_to("res://Scenes/MainMenu.tscn")
