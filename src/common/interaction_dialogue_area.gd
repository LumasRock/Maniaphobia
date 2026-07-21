extends Area2D
class_name InteractionDialogueArea

@export var dialogue_id: String = ""
@export var node_id: String = ""

@export var dialogue: Dialogue

@export var play_once: bool = false
var already_played: bool = false

var player: Player

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
		player = body
		player.set_interact_prompt(true)

func _on_body_exited(body: Node2D) -> void:
	if body is Player and player != null:
		player.set_interact_prompt(false)
		player = null

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player != null:
		dialogue.play(dialogue_id, node_id)
		already_played = true
		_after_dialogue_played()
		player.set_interact_prompt(false)
		player = null

func _after_dialogue_played() -> void: pass
