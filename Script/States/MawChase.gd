extends State
class_name MawChase

@export var maw: Maw
@export var patrol_state: MawPatrol
@export var speed: float = 130.0
@export var navigation_agent: NavigationAgent2D

var target_to_chase: Player


func Enter():
	await get_tree().physics_frame
	target_to_chase = get_tree().get_first_node_in_group("player")


func Physics_Update(_delta: float):
	if not target_to_chase:
		return
	
	navigation_agent.target_position = target_to_chase.global_position

	if navigation_agent.is_navigation_finished():
		maw.velocity = Vector2.ZERO
		return
	
	if target_to_chase.hiding_manager.is_hiding:
		Transitioned.emit(self, "MawPatrol")
		maw.velocity = Vector2.ZERO
		return

	# Move to next path pos
	var next_path_pos = navigation_agent.get_next_path_position()
	var direction = maw.global_position.direction_to(next_path_pos)
	maw.velocity = direction * speed
	
	# Change states if needed
	var distance_to_target = maw.global_position.distance_to(target_to_chase.global_position)
	var target_is_hiding := target_to_chase.hiding_manager.is_hiding
	
	if distance_to_target < maw.attack_range and not target_is_hiding:
		Transitioned.emit(self, "MawAttack")
		return
	
	if distance_to_target > maw.stop_chase_distance and not target_is_hiding:
		Transitioned.emit(self, "MawPatrol")


func _on_detection_range_body_exited(body):
	if body is Player:
		Transitioned.emit(self, "MawPatrol")
