extends State
class_name MawChase

@export var Maw: CharacterBody2D
var target_to_chase: Player
@export var speed: float = 130.0
@export var navigation_agent: NavigationAgent2D


func Enter():
	await get_tree().physics_frame
	target_to_chase = get_tree().get_first_node_in_group("player")


func Physics_Update(_delta: float):
	if not target_to_chase:
		return
	
	navigation_agent.target_position = target_to_chase.global_position

	if navigation_agent.is_navigation_finished():
		Maw.velocity = Vector2.ZERO
		return
	var patrol_state:= get_parent().get_node("MawPatrol") as MawPatrol
	
	if target_to_chase.hiding_manager.is_hiding:
		Transitioned.emit(self, "MawPatrol")
		patrol_state.snap_to_nearest_path_point()

	var next_path_pos = navigation_agent.get_next_path_position()
	

	var direction = Maw.global_position.direction_to(next_path_pos)
	Maw.velocity = direction * speed
	
	var distance_to_target = Maw.global_position.distance_to(target_to_chase.global_position)
	
	if Maw.global_position.distance_to(target_to_chase.global_position) < 30 and not target_to_chase.hiding_manager:
		Transitioned.emit(self, "MawAttack")
	await get_tree().create_timer(4.0).timeout

	if Maw.global_position.distance_to(target_to_chase.global_position) > 300 and not target_to_chase.hiding_manager:
		Transitioned.emit(self, "MawPatrol")


func _on_detection_range_body_exited(body):
	if body is Player:
		Transitioned.emit(self, "MawPatrol")
