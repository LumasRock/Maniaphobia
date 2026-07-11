class_name HidingBreathing
extends Control

@export var fill_rect: TextureRect
@export var ring_rect: TextureRect

@export var initial_scale := 7.0
@export var random_position_minmax := Vector2(100, 500)

var can_exit_hiding:= false
var player: CharacterBody2D = null
var pressed := false
var max_time := 1.7
var miss_timer := 0.2
var current_time := 0.0
var _initial_scale_vec: Vector2

#it takes 4 seconds to reach 1.0 (a miss)
#make a timer that goes down from 4 seconds
#make the ring go down in 4 seconds
#if the ring stops at ~ 3 seconds (3 - 3.5) then its a perfect
# if the ring has a 1.2 second diff from a perfect than its a good
#if neither than its a miss


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")


func execute() -> void:
	# Set start scale
	_initial_scale_vec = Vector2.ONE * initial_scale
	ring_rect.scale = _initial_scale_vec
	
	# Randomize position
	fill_rect.global_position = Vector2(
		randf_range(random_position_minmax.x, random_position_minmax.y),
		randf_range(random_position_minmax.x, random_position_minmax.y)
	)
	


func _process(delta: float) -> void:
	if current_time < max_time:
		current_time += delta
		
		var progress = minf(current_time, max_time) / max_time
		ring_rect.scale = _initial_scale_vec.lerp(Vector2.ONE, progress)
	else:
		queue_free()
		print("Miss!")


func can_leave_hiding() -> bool:
	return can_exit_hiding


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"Q"):
		var time_dif = abs(current_time - max_time)
		print(time_dif)
	
		if time_dif < miss_timer: # Within late/early limits
			print("Bad!")
		elif time_dif < 0.3:  # Within 120ms
			print("Good!")
		elif time_dif < 0.7:  # Within 50ms of perfect timing
			print("Perfect!")
		else:
			print("Miss!") # Hit way too early
		
		queue_free()
