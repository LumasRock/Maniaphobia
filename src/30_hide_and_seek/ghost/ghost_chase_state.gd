extends State
class_name GhostChase

@export var ghost: Ghost
@export var move_speed := 40.0


func state_physics_update(delta: float):
	var direction = ghost.player.global_position - ghost.global_position
	
	ghost.velocity = direction.normalized() * move_speed
	ghost.move_and_slide()
	
	if ghost.global_position.distance_to(ghost.player.position) >= 100:
		transitioned.emit(self, "GhostWander")
	if ghost.global_position.distance_to(ghost.player.position) <= 20:
		transitioned.emit(self, "GhostCall")
