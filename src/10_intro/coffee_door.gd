class_name CoffeeDoor
extends Area2D

@export_file("*.tscn", "*.scn") var target_scene: String

@export var apartment: Apartment

var start_dialogue: Callable

var has_player : bool

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		has_player = true
		(body as Player).show_interact_prompt(true)

func _on_body_exited(body: Node2D) -> void:
	if body is Player and has_player:
		(body as Player).show_interact_prompt(false)
		has_player = false

## Prevents player from leaving apartment if coffee machine is not fixed
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and has_player:
		if apartment.coffee_machine_fixed == true:
			if target_scene.is_empty():
				push_warning("No target_scene set for scenedoor at %s" % get_path())
				return
			Transition.transition_to(target_scene)
		elif apartment.coffee_machine_fixed == false:
			if start_dialogue == null:
				push_error("CoffeeDoor dialogue not set")
				return
			start_dialogue.call()
