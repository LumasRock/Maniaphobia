extends Area2D

@export_file("*.tscn", "*.scn") var target_scene: String

@onready var coffee_machine : CoffeeMachine = $"../CoffeeMachine"
@onready var dialogue : OldDialogue = $"../Dialogue"

var has_player : bool

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		has_player = true
		body.show_interact_prompt(true)

func _on_body_exited(body: Node2D) -> void:
	if body is Player and has_player:
		body.show_interact_prompt(false)
		has_player = false

## Prevents player from leaving apartment if coffee machine is not fixed
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and has_player:
		if coffee_machine.coffee_fixed == true:
			if target_scene.is_empty():
				push_warning("No target_scene set for scenedoor at %s" % get_path())
				return
			Transition.transition_to(target_scene)
		elif coffee_machine.coffee_fixed == false:
			dialogue.play("Apartment", "30")
