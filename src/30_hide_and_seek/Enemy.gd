class_name Maw
extends CharacterBody2D

@onready var state_machine = $"State Machine"

@export_group("Attacking")
@export var attack_damage := 50
@export var attack_range := 30.0

@export_group("Chasing")
@export var start_chase_distance := 300.0
@export var stop_chase_distance := 200.0

func _physics_process(delta: float) -> void:
	move_and_slide()
