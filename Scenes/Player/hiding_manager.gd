class_name PlayerHidingManager
extends Node

@export var player: Player
@export var hiding_breathing: HidingBreathing
@export var stop_hiding_timer: Timer

var current_hide_interactable: HideInteractable
var is_hiding: bool = false
var hiding_left: float = 10.0
var hide_timer: float = 0.0

# This avoids multiple breathing corroutines to play at the same time
var _breathing_generation := 0


func _ready() -> void:
	hiding_breathing.result_registered.connect(
		_on_hiding_breathing_result_registered
	)


func _input(_event):
	if (Input.is_action_just_pressed(&"interact") 
		and current_hide_interactable):
		
		if not is_hiding:
			start_hiding()
			stop_hiding_timer.start()
		
		elif not stop_hiding_timer.time_left:
			stop_hiding()


func start_hiding() -> void:
	var interactable := current_hide_interactable
	if is_hiding or not interactable: return
	
	if interactable.current_ID == interactable.ID.one:
		is_hiding = true
		player.animated_sprite.visible = false
		player.hiding_manager.is_hiding = true
		player.global_position = interactable.global_position
		player.can_move = false
		player.velocity = Vector2.ZERO
		player.set_interact_prompt(false)
		
		start_hiding_breathing()
		
	elif interactable.current_ID == interactable.ID.zero:
		interactable.play_occuppied_dialog()


func start_hiding_breathing() -> void:
	_breathing_generation += 1
	var this_breathing_generation = _breathing_generation
	
	while true:
		await get_tree().create_timer(randf_range(2.0, 4.0)).timeout
		
		if not is_hiding or _breathing_generation != this_breathing_generation:
			break
		
		hiding_breathing.execute()
		await hiding_breathing.result_registered


func _on_hiding_breathing_result_registered(result: HidingBreathing.TimingResult) -> void:
	if not is_hiding: return
	
	if result in [HidingBreathing.TimingResult.Miss, HidingBreathing.TimingResult.Bad]:
		stop_hiding()



func stop_hiding() -> void:
	var interactable := current_hide_interactable
	if not is_hiding or not interactable: return

	player.animated_sprite.visible = true
	player.can_move = true
	
	hiding_left = 5.0
	hide_timer = 0.0
	is_hiding = false

	# Move player to the front of the hiding place
	interactable.move_player_back_to_front()
	hiding_breathing.stop()
