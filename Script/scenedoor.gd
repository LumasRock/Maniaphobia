extends Area2D

var player_node: Player = null
@export_file("*.tscn", "*.scn") var target_scene: String
@onready var dialogue: Dialogue = $"../Dialogue"
@onready var coffee_machine: CoffeMachine = $"../CoffeeMachine"


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_node = body
		player_node.set_interact_prompt(true)

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_node.set_interact_prompt(false)
		player_node = null


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and player_node != null:
		if coffee_machine.coffee_fixed == true:
			player_node.set_interact_prompt(false)
			if target_scene.is_empty():
				push_warning("No target_scene set for scenedoor at %s" % get_path())
				return
			Transition.transition_to(target_scene)
		elif coffee_machine.coffee_fixed == false:
			dialogue.play("Apartment", "30")
