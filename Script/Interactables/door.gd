extends Area2D
@onready var Shadows = %Shadows

enum Placement { UP, LEFT, RIGHT, BOTTOM }

@export var my_placement: Placement = Placement.UP

func _ready():
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	match my_placement:
		Placement.LEFT:
			if body is Player:
				if body.velocity.x < 0: 
					Shadows.modulate.a = 0.5
				if body.velocity.x > 0:
					Shadows.modulate.a = 0.5
		Placement.RIGHT:
			if body is Player:
				if body.velocity.x < 0: 
					Shadows.modulate.a = 0.5
				if body.velocity.x > 0:
					Shadows.modulate.a = 0.5
		Placement.UP:
			if body is Player:
				if body.velocity.y < 0: 
					Shadows.modulate.a = 0.5
				if body.velocity.y > 0:
					Shadows.modulate.a = 0.5
		Placement.BOTTOM:
			if body is Player:
				if body.velocity.y > 0: 
					Shadows.modulate.a = 0.5
				if body.velocity.y < 0:
					Shadows.modulate.a = 0.5


func _on_body_exited(body: Node2D) -> void:
	match my_placement:
		Placement.LEFT:
			if body is Player:
				if body.velocity.x > 0: 
					Shadows.modulate.a = 1
				if body.velocity.x < 0:
					Shadows.modulate.a=0
		Placement.RIGHT:
			if body is Player:
				if body.velocity.x < 0: 
					Shadows.modulate.a=1
				if body.velocity.x > 0:
					Shadows.modulate.a=0
		Placement.UP:
			if body is Player:
				if body.velocity.y > 0: 
					Shadows.modulate.a=1
				if body.velocity.y < 0:
					Shadows.modulate.a=0
		Placement.BOTTOM:
			if body is Player:
				if body.velocity.y < 0: 
					Shadows.modulate.a=1
				if body.velocity.y > 0:
					Shadows.modulate.a=0
