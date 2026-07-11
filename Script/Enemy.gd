extends CharacterBody2D

@onready var state_machine = $"State Machine"
@export var attack_damage: int = 50

func _physics_process(delta: float) -> void:
	move_and_slide()
