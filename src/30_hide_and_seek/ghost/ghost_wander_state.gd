extends State
class_name GhostWander

var move_direction: Vector2
var wander_time: float
var home_position: Vector2
@export var ghost: Ghost
@export var sprite: Sprite2D
@export var move_speed := 25.0
@export var wander_radius := 50.0


func _ready():
	home_position = ghost.global_position


func state_enter():
	randomize_wander()


func state_update(delta: float):
	wander_time -= delta
	if wander_time <= 0:
		randomize_wander()
	if ghost.velocity.x < 0:
		sprite.flip_h = true
	if ghost.velocity.x > 0:
		sprite.flip_h = false


func state_physics_update(delta: float):
	if not ghost or not ghost.player:
		return
	ghost.velocity = move_direction * move_speed
	ghost.move_and_slide()
	
	if ghost.global_position.distance_to(home_position) >= wander_radius:
		move_direction = ghost.global_position.direction_to(home_position)
	
	if ghost.global_position.distance_to(ghost.player.global_position)<= 50:
		transitioned.emit(self, "GhostChase")


func randomize_wander():
	move_direction = Vector2(randf_range(-1, 1), randf_range(-1,1)).normalized()
	wander_time = randf_range(1, 3)
