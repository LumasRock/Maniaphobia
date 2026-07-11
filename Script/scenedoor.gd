extends Area2D

var Player_node: Node2D = null
@onready var coffee_machine = $"../CoffeeMachine"
@export_file("*.tscn", "*.scn") var target_scene: String
@onready var Dialogue = $"../Dialogue"


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		Player_node = body
		body.set_interact_prompt(true)

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		Player_node = null
		body.set_interact_prompt(false)


func _input(Event):
	if Input.is_action_just_pressed("interact") and Player_node != null:
		if coffee_machine.coffee_fixed == true:
			if target_scene.is_empty():
				push_warning("No target_scene set for scenedoor at %s" % get_path())
				return
			Transition.transition_to(target_scene)
		elif coffee_machine.coffee_fixed == false:
			Dialogue.play("Apartment", "30")
