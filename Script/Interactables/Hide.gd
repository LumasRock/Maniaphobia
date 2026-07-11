class_name Interactable
extends Area2D

var time_passed: float = 0.0
var Player_node: Node2D = null
@export var player_sprite: AnimatedSprite2D
var Set := ["1", "5", "9", "13", "17"]
@export var Dialogue: Control
@export var breathing: Control
enum ID { zero, one }
enum PLACEMENT {left, right, up, down}

@export var current_PLACEMENT: PLACEMENT = PLACEMENT.left
@export var current_ID: ID = ID.one

func _physics_process(delta: float):
	var total_IDS: int = ID.size()
	time_passed += delta
	if Player_node:
		if Player_node.hide_state == true:
			Player_node.hide_timer += delta
			Player_node.hiding_left -= delta
		if Player_node.hiding_left <= 0:
			toggle_hide() 
	if Player_node:
		if time_passed >= 30.0 and Player_node.hide_state == false:
			time_passed -= 30.0
			current_ID = (current_ID + 1) % total_IDS
	else:
		return
func _on_body_entered(body: Node2D):
	if body is Player:
		Player_node = body
		body.set_interact_prompt(true)
func _on_body_exited(body: Node2D):
	if body is Player:
		Player_node = null
		body.set_interact_prompt(false)
func _input(Event):
	if Input.is_action_just_pressed("interact") and Player_node != null:
		if Player_node.hide_state and not breathing.can_leave_hiding():
			return
		toggle_hide()

func toggle_hide():
	if Player_node.hide_state == false:
		if current_ID == ID.one:
			player_sprite.visible = false
			Player_node.hide_state = true
			Player_node.global_position = self.global_position
			Player_node.can_move = false
			Player_node.velocity = Vector2.ZERO
			Player_node.set_interact_prompt(false)
		if current_ID == ID.zero:
			var random_node_id = Set.pick_random()
			Dialogue.play("Hide_And_Seek", random_node_id)
	else:
		player_sprite.visible = true
		Player_node.hiding_left = 5.0
		Player_node.hide_timer = 0.0
		Player_node.hide_state = false
		Player_node.can_move = true
		if current_PLACEMENT == PLACEMENT.left:
			Player_node.global_position.x -= 40
		if current_PLACEMENT == PLACEMENT.right:
			Player_node.global_position.x += 40
		if current_PLACEMENT == PLACEMENT.up:
			Player_node.global_position.y += 40
		if current_PLACEMENT == PLACEMENT.down:
			Player_node.global_position.y -= 40
