extends Area2D

@onready var dialogue : OldDialogue = $"../Dialogue"

var Player_node: Node2D = null
var player_inside : bool = false
var coffee_fixed : bool = false

#func _input(event: InputEvent) -> void:
#	if event.is_action_pressed("interact") and player_inside == true:
#		dialogue.play("Apartment", "17")
#		coffee_fixed = true
#
#func _on_body_entered(body: Node2D) -> void:
#	if body is Player:
#		(body as Player).show_interact_prompt(true)
#		player_inside = true
#
#func _on_body_exited(body: Node2D) -> void:
#	if body is Player:
#		(body as Player).show_interact_prompt(false)
#	player_inside = false
