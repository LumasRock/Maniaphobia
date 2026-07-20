extends Area2D

var Player_node: Node2D = null
var player_inside := false
@onready var Dialogue := $"../Dialogue"
var coffee_fixed := false

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		Player_node = body
		Player_node.set_interact_prompt(true)
		player_inside = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_inside == true:
		Dialogue.play("Apartment", "17")
		coffee_fixed = true
func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		Player_node.set_interact_prompt(false)
		Player_node = null
	player_inside = false
