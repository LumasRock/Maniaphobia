extends State
class_name MawPatrol

@export var maw: Maw
@export var path_follow: PathFollow2D
@export var ghost: GhostCall
@export var speed: float = 90
@export var pause_duration_minmax := Vector2(1.0, 2.5)
@export var pause_cooldown_minmax := Vector2(5.0, 12.0)
@export var pause_timer: Timer

var detected_player: Player = null
var player: Player

var _is_moving := true
var _is_paused := false
var _is_current_state := false


func Enter(): 
	ghost.ChasePlayer.connect(Chase, CONNECT_ONE_SHOT)
	player = get_tree().get_first_node_in_group(&"player")

	snap_to_nearest_path_point()
	_is_moving = true
	_is_paused = false
	_is_current_state = true
	
	pause_timer.timeout.connect(_on_pause_timer_timeout)
	_start_pause_timer_from_minmax(pause_cooldown_minmax)


func Exit():
	if ghost.ChasePlayer.is_connected(Chase):
		ghost.ChasePlayer.disconnect(Chase)
	
	_is_moving = false
	_is_current_state = false
	_is_paused = false
	
	pause_timer.timeout.disconnect(_on_pause_timer_timeout)
	pause_timer.stop()


func Physics_Update(delta: float):
	if _is_paused:
		return
	
	if path_follow and maw and _is_moving:
		var move_amount = speed * delta
		path_follow.progress += move_amount
		maw.global_position = path_follow.global_position
 
	var distance_to_target := player.global_position.distance_to(maw.global_position)
	if distance_to_target < maw.start_chase_distance and not player.hiding_manager.is_hiding:
		Transitioned.emit(self, "MawChase")


func snap_to_nearest_path_point():
	if not path_follow or not maw: return
	var path := path_follow.get_parent() as Path2D
	if not path or not path.curve: return

	var local_pos := path.to_local(maw.global_position)
	path_follow.progress = path.curve.get_closest_offset(local_pos)
	maw.global_position = path_follow.global_position


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


func _start_pause_timer_from_minmax(minmax: Vector2) -> void:
	var time := randf_range(minmax.x, minmax.y)
	pause_timer.start(time)


func _on_pause_timer_timeout() -> void:
	if not _is_current_state: return
	
	var was_paused := _is_paused
	_is_paused = not was_paused
	var new_minmax := pause_cooldown_minmax if was_paused else pause_duration_minmax
	_start_pause_timer_from_minmax(new_minmax)
