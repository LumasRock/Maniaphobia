extends State
class_name GhostChase

@export var ghost: CharacterBody2D
@export var move_speed : float = 40.0
var player : CharacterBody2D

func enter() -> void:
	player = get_tree().get_first_node_in_group("player")
	
func physics_update(delta: float) -> void:
	var direction = player.global_position - ghost.global_position
	
	ghost.velocity = direction.normalized() * move_speed
	ghost.move_and_slide()
	
	if ghost.global_position.distance_to(player.position) >= 100:
		Transitioned.emit(self, "GhostWander")
	if ghost.global_position.distance_to(player.position) <= 20:
		Transitioned.emit(self, "GhostCall")
