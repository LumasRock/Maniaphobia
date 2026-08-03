class_name CoffeeMachine
extends Area2D

var coffee_fixed: bool = false

func _after_dialogue_played() -> void:
	coffee_fixed = true
