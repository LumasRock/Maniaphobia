extends Area2D

@export var Coords_up: Vector2
@export var Coords_down: Vector2
@onready var Floor2 = $"../Floor2"
@onready var Floor1 = $"../Floor1"
@onready var transition = $"../Transition"
var Player_node: Node2D = null
var can_tp := false
var prompt_visible := false
var Fade_out: Tween
var Fade_in: Tween
func _ready() -> void:
	Floor2.modulate.a = 0.0
	Floor1.modulate.a = 1.0

func _on_body_entered(body: Node2D):
	if body is Player:
		Player_node = body
		Player_node.set_interact_prompt(true)
		prompt_visible = true
func _on_body_exited(body: Node2D):
	if body is Player:
		body.can_move = true
		body.set_interact_prompt(false)
		prompt_visible = false
func _input(event: InputEvent) -> void:
	if prompt_visible == true and event.is_action_pressed("interact"):
		if Player_node != null:
			print("clicked")
			can_tp = true
			toggle_transition()
func toggle_transition():
	if Player_node.global_position.y > self.global_position.y:
		if can_tp == true:
			print("going up")
			Player_node.can_move = false
			Player_node.velocity = Vector2.ZERO
			Fade_in = create_tween()
			Fade_in.tween_property(transition, "modulate:a", 1.0, 0.6)
			await get_tree().create_timer(0.5).timeout
			Floor2.modulate.a = 1
			Floor1.modulate.a = 0
			Player_node.set_collision_mask_value(1, false)
			Player_node.set_collision_mask_value(2, true)
			Fade_out = create_tween()
			Fade_out.tween_property(transition, "modulate:a", 0.0, 0.6)
			Player_node.global_position = Coords_up
			can_tp = false
	elif Player_node.global_position.y > -80:
		if can_tp == true:
			print("going down")
			Player_node.can_move = false
			Player_node.velocity = Vector2.ZERO
			Fade_in = create_tween()
			Fade_in.tween_property(transition, "modulate:a", 1.0, 0.6)
			await get_tree().create_timer(0.5).timeout
			Floor2.modulate.a = 0
			Floor1.modulate.a = 1
			Player_node.set_collision_mask_value(2, false)
			Player_node.set_collision_mask_value(1, true)
			Fade_out = create_tween()
			Fade_out.tween_property(transition, "modulate:a", 0.0, 0.6)
			Player_node.global_position = Coords_down 
			can_tp = false
