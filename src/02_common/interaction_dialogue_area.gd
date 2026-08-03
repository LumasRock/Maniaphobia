class_name InteractionDialogueArea
extends Area2D

@export var dialogue: Dialogue
@export var node_id: String = ""
@export var play_once: bool = false

var already_played: bool = false
var _player_in_area: bool = false

func _ready() -> void:
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

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and _player_in_area:
		if play_once and already_played:
			return
		dialogue.start()
		already_played = true
