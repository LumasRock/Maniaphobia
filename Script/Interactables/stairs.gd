extends Area2D

@onready var Floor2 = $"../Floor2"
@onready var Floor1 = $"../Floor1"
@onready var transition = $"../Transition/AnimationPlayer"

func _ready() -> void:
	if Floor2.modulate.a == 0:
		Floor2.tile_set.set_physics_layer_collision_layer(0, 0)

func _on_body_entered(body: Node2D):
	if body is Player:
		await get_tree().create_timer(0.3).timeout
		body.can_move = false
		body.velocity = Vector2.ZERO
		if body.global_position.y > self.global_position.y:
			await get_tree().create_timer(1.0).timeout
			transition.play("Fade_in")
			await get_tree().create_timer(1.0).timeout
			Floor1.tile_set.set_physics_layer_collision_layer(0, 0)
			Floor1.modulate.a = 0
			Floor2.modulate.a = 1
			if Floor2.modulate.a == 1:
				body.global_position.y -= 35
		elif body.global_position.y < self.global_position.y:
			await get_tree().create_timer(1.0).timeout
			transition.play("Fade_in")
			await get_tree().create_timer(0.5).timeout
			Floor1.modulate.a = 1
			Floor2.modulate.a = 0
			if Floor1.modulate.a == 1:
				body.global_position.y += 35
func _on_body_exited(body: Node2D):
	if body is Player:
		body.can_move = true
		if Floor2.modulate.a == 1:
			transition.play("Fade_out")
			Floor2.tile_set.set_physics_layer_collision_layer(0, 1)
			Floor1.tile_set.set_physics_layer_collision_layer(0,0)
		elif Floor1.modulate.a == 1:
			transition.play("Fade_out")
			Floor2.tile_set.set_physics_layer_collision_layer(0, 0)
			Floor1.tile_set.set_physics_layer_collision_layer(0,1)
