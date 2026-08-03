class_name InteractionDialogueArea
extends Area2D

@export var dialogue     : Dialogue
@export var play_once    : bool = false

var already_played       : bool = false
var _player_in_area      : bool = false

func _ready() -> void:
	if dialogue == null :
		push_warning("No dialogue set for InteractionDialogueArea %s" % self.name)
	else: 
		dialogue.start_on_load = false # prevent auto load if is interactive
		# subscribe to dialogue end to mark 'already_player' flag
		if not dialogue.on_dialogue_finished.is_connected(_on_dialogue_finished):
			@warning_ignore("return_value_discarded")
			dialogue.on_dialogue_finished.connect(_on_dialogue_finished)

	if not body_entered.is_connected(_on_body_entered):
		@warning_ignore("return_value_discarded")
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		@warning_ignore("return_value_discarded")
		body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if play_once and already_played:
		return
	if body is Player:
		_player_in_area = true
		body.show_interact_prompt(true)

func _on_body_exited(body: Node2D) -> void:
	if body is Player and _player_in_area:
		_player_in_area = false
		body.show_interact_prompt(false)

## marks already_played = true
func _on_dialogue_finished(dialogue_id : String) -> void :
	if dialogue_id == dialogue.get_dialogue_id() :
		already_played = true
	if not play_once :
		dialogue.reset()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and _player_in_area:
		_try_start_dialogue()

## attempts to start the dialogue checking condition (play_once, already_played, etc)
func _try_start_dialogue() -> void :
	if dialogue == null :
		return
	if play_once and already_played: # played once
		return
	elif not dialogue.is_idle() and not dialogue.is_finished() : # currently playing
		return
	print("starting interactive dialogue " + dialogue.name)
	dialogue.start()
