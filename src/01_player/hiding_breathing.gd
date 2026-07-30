class_name HidingBreathing
extends Control

@export var _testing_mode := false

@export var main_container: Control
@export var ring_rect: TextureRect

@export_group("Text label")
@export var text_label: Label
@export var text_label_animation: AnimationPlayer

@export_group("Transform")
@export var initial_scale := 0.6
@export var position_randomize := Vector2(600, 300)
@export var max_time := 1.7

var can_exit_hiding:= false
var player: CharacterBody2D = null
var pressed := false

var _current_time := 0.0
var _initial_scale_vec: Vector2
var _initial_position: Vector2

var is_playing := false

enum TimingResult {
	Miss,
	Bad,
	Good,
	Perfect
}

signal result_registered(result: TimingResult)

#it takes 4 seconds to reach 1.0 (a miss)
#make a timer that goes down from 4 seconds
#make the ring go down in 4 seconds
#if the ring stops at ~ 3 seconds (3 - 3.5) then its a perfect
# if the ring has a 1.2 second diff from a perfect than its a good
#if neither than its a miss


func _enter_tree() -> void:
	text_label_animation.play(&"hidden")
	
	if _testing_mode:
		execute()
	else:
		main_container.hide()


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	_initial_scale_vec = Vector2.ONE * initial_scale
	ring_rect.scale = _initial_scale_vec
	_initial_position = position


func execute() -> void:
	main_container.show()
	is_playing = true
	_current_time = 0.0
	
	# Set start scale
	ring_rect.scale = _initial_scale_vec
	
	# Randomize position
	position = Vector2(
		randf_range(position.x - position_randomize.x, position.x + position_randomize.x),
		randf_range(position.y - position_randomize.y, position.y + position_randomize.y)
	)


func stop() -> void:
	is_playing = false
	main_container.hide()


func _process(delta: float) -> void:
	if not is_playing: return
	
	if _current_time < max_time:
		_current_time = minf(_current_time + delta, max_time)
		
		var progress = _current_time / max_time
		ring_rect.scale = _initial_scale_vec.lerp(Vector2.ZERO, progress)
	else:
		register_result(TimingResult.Miss)


func can_leave_hiding() -> bool:
	return can_exit_hiding


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"Q"):
		var time_ratio = abs(_current_time / max_time)
		print(time_ratio)
	
		if time_ratio < 0.3: # Within early limits
			register_result(TimingResult.Miss)
			
		elif time_ratio < 0.45:
			register_result(TimingResult.Good)
			
		elif time_ratio < 0.55:
			register_result(TimingResult.Perfect)
			
		elif time_ratio < 0.7:
			register_result(TimingResult.Good)
			
		elif time_ratio < 0.8: 
			register_result(TimingResult.Bad)
			
		else: # Within late limits
			register_result(TimingResult.Miss)


func register_result(result: TimingResult) -> void:
	is_playing = false
	main_container.hide()
	result_registered.emit(result)
	
	var result_text = TimingResult.find_key(result) + "!"
	text_label.text = result_text
	text_label_animation.play(&"jump")
