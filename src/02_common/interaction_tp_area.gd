extends Area2D
class_name InteractionTpArea

@export var destination: Marker2D
@export var transition: AnimationPlayer
@export var transition_time: float = 1.0

var player: Player

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		@warning_ignore("return_value_discarded")
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		@warning_ignore("return_value_discarded")
		body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body
		player.set_interact_prompt(true)

func _on_body_exited(body: Node2D) -> void:
	if body is Player and player != null:
		player.set_interact_prompt(false)
		player = null

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player != null:
		player.set_interact_prompt(false)
		if transition != null:
			transition.play("Fade_in")
			await transition.animation_finished
			player.global_position = destination.global_position
			await get_tree().create_timer(transition_time).timeout
			await transition.animation_finished
			transition.play("Fade_out")
		else:
			player.global_position = destination.global_position
		player = null
