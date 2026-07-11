extends Node2D

@export var player: CharacterBody2D
@export var label: Label
@export var timer: Timer

func _ready():
	if player.get_parent() == self:
		label.visible = true
	if player is Player and not player.died.is_connected(_on_player_died):
		player.died.connect(_on_player_died)

func _on_player_died() -> void:
	Transition.transition_to("res://Scenes/GameOver.tscn")

func _on_timer_timeout() -> void:
	Transition.transition_to("res://Scenes/Levels/Dinner.tscn")
