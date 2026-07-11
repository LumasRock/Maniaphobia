extends State
class_name  MawPatrol

@export var Maw: CharacterBody2D
@export var path_follow: PathFollow2D
@export var ghost: GhostCall
@export var patrol_speed: float = 90
@export var min_pause_time: float = 1
@export var max_pause_time: float = 3
@export var breathing := AudioStreamPlayer2D
var distance_until_pause: float = 0.0

var is_paused: bool = false
var is_moving: bool = true
var detected_player: Player = null
var timer: float = randf_range(2, 10)
var new_timer_value: float = 0


func Enter(): 
	ghost.ChasePlayer.connect(Chase, CONNECT_ONE_SHOT)


func Exit():
	if ghost.ChasePlayer.is_connected(Chase):
		ghost.ChasePlayer.disconnect(Chase)


func Physics_Update(delta: float):
	var player = get_tree().get_nodes_in_group("player")
	if player.size() > 0:
		player = player[0]
	if is_moving:
		timer -= delta
	if timer <= 0:
		timer = 0
		is_paused = true
		is_moving = false
	
	if is_paused == true:
		patrol_speed = 0
		new_timer_value = randf_range(2, 10)
		timer = new_timer_value
		await get_tree().create_timer(randf_range(min_pause_time, max_pause_time)).timeout
		patrol_speed = 90
		is_moving = true
		is_paused = false
	
	if path_follow and Maw:
		if is_moving == true:
			var move_amount = patrol_speed * delta
			path_follow.progress += move_amount
			Maw.global_position = path_follow.global_position
			distance_until_pause -= move_amount
 
	if player.global_position.distance_to(Maw.global_position) < 200 and player.hiding_manager.is_hiding == false:
		Transitioned.emit(self, "MawChase")


func snap_to_nearest_path_point():
	if not path_follow or not Maw:
		return
	var path := path_follow.get_parent() as Path2D
	if not path or not path.curve:
		return
	var local_pos = path.to_local(Maw.global_position)
	path_follow.progress = path.curve.get_closest_offset(local_pos)
	Maw.global_position = path_follow.global_position


func _on_detection_range_body_entered(body):
	if body is Player:
		detected_player = body
		if not detected_player.hiding_manager.is_hiding:
			Transitioned.emit(self, "MawChase")


func _on_detection_range_body_exited(body):
	if body == detected_player:
		detected_player = null


func Chase():
	Transitioned.emit(self, "MawChase")
