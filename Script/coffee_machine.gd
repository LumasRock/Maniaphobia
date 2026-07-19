extends InteractionDialogueArea

var coffee_fixed := false
func _after_dialogue_played() -> void:
	coffee_fixed = true
