extends InteractionDialogueArea
class_name CoffeMachine

var coffee_fixed: bool = false
func _after_dialogue_played() -> void:
	coffee_fixed = true
