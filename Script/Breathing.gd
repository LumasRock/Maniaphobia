extends TextureRect

var can_exit_hiding:= false
var player_node: CharacterBody2D = null
var max_size
@onready var Ring = $Control
var pressed := false
var perfect_timer := 1.7
var miss_timer := 0.2
var current_time := 0.0
var start_scale: Vector2
#it takes 4 seconds to reach 1.0 (a miss)
#make a timer that goes down from 4 seconds
#make the ring go down in 4 seconds
#if the ring stops at ~ 3 seconds (3 - 3.5) then its a perfect
# if the ring has a 1.2 second diff from a perfect than its a good
#if neither than its a miss

func _ready() -> void:
	player_node = get_tree().get_first_node_in_group("player")
	if player_node and player_node.hide_state == true:
		pass
	rhythm()
func _process(delta: float) -> void:
	current_time += delta
	if current_time > (perfect_timer + miss_timer):
		print("miss")
		queue_free()
	if current_time < perfect_timer:
		var progress = current_time / perfect_timer
		Ring.scale = start_scale.lerp(Vector2(1.0,1.0), progress)
	else:
		Ring.scale = Vector2(1.0,1.0)

func rhythm():
	var random_multiplier = randf_range(7.0,6.0)
	start_scale = Vector2(random_multiplier,random_multiplier)
	Ring.scale = start_scale
	
	global_position = Vector2(randf_range(100,500), randf_range(100,500))

func can_leave_hiding() -> bool:
	return can_exit_hiding

func _input(event: InputEvent) -> void:
	var time_dif = abs(current_time - perfect_timer)
	if event.is_action_pressed("Q"):
		if time_dif <= 0.69:    # Within 50ms of perfect timing
			print("Perfect!")
		elif time_dif <= 0.29:  # Within 120ms
			print("Good!")
		elif time_dif <= miss_timer: # Within late/early limits
			print("Bad!")
		else:
			print("Miss!") # Hit way too early
		queue_free()
