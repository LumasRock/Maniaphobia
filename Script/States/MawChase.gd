extends State
class_name MawChase

@export var Maw: CharacterBody2D
var target_to_chase: CharacterBody2D
@export var speed: float = 130.0


@export var navigation_agent: NavigationAgent2D

func Enter():
	await get_tree().physics_frame
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target_to_chase = players[0]

func Physics_Update(_delta: float):
	if not target_to_chase:
		return
	navigation_agent.target_position = target_to_chase.global_position
	

	if navigation_agent.is_navigation_finished():
		Maw.velocity = Vector2.ZERO
		return
	var patrol_state:= get_parent().get_node("MawPatrol") as MawPatrol
	if target_to_chase is Player and target_to_chase.hide_state == true:
		Transitioned.emit(self, "MawPatrol")
		patrol_state.snap_to_nearest_path_point()

	var next_path_pos = navigation_agent.get_next_path_position()
	

	var direction = Maw.global_position.direction_to(next_path_pos)
	Maw.velocity = direction * speed
	
	var distance_to_target = Maw.global_position.distance_to(target_to_chase.global_position)
	
	if Maw.global_position.distance_to(target_to_chase.global_position) < 30 and target_to_chase.hide_state == false:
		Transitioned.emit(self, "MawAttack")
	await get_tree().create_timer(4.0).timeout
	if Maw.global_position.distance_to(target_to_chase.global_position) > 300 and target_to_chase.hide_state != true:
		Transitioned.emit(self, "MawPatrol")
func _on_detection_range_body_exited(body):
	if body is Player:
		Transitioned.emit(self, "MawPatrol")
