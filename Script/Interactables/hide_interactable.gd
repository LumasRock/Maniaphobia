class_name HideInteractable
extends Area2D

var time_passed: float = 0.0
var Set := ["1", "5", "9", "13", "17"]
@export var Dialogue: Control
enum ID { zero, one }
enum PLACEMENT { left, right, up, down }

@export var current_PLACEMENT: PLACEMENT = PLACEMENT.left
@export var current_ID: ID = ID.one

var player: Player
var _player_is_colliding := false
var _player_is_hiding_here := false
var _dialogue_node_id: String

const STOP_HIDING_DISPLACEMENT := 35.0


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")


func _physics_process(delta: float):
	time_passed += delta
	
	var total_IDS: int = ID.size()
	var hiding_manager := player.hiding_manager
	
	if _player_is_colliding:
		if hiding_manager.is_hiding:
			hiding_manager.hide_timer += delta
			hiding_manager.hiding_left -= delta
		
		if hiding_manager.hiding_left <= 0:
			stop_hiding() 

		if time_passed >= 30.0 and not hiding_manager.is_hiding:
			time_passed -= 30.0
			current_ID = (current_ID + 1) % total_IDS


func _on_body_entered(body: Node2D):
	if body is Player:
		_player_is_colliding = true
		player.set_interact_prompt(true)
		player.hiding_manager.current_hide_interactable = self


func _on_body_exited(body: Node2D):
	if body is Player:
		_player_is_colliding = false
		player.set_interact_prompt(false)
		player.hiding_manager.current_hide_interactable = null


func start_hiding():
	if player.hiding_manager.is_hiding: return
	
	if current_ID == ID.one:
		_player_is_hiding_here = true
		player.animated_sprite.visible = false
		player.hiding_manager.is_hiding = true
		player.global_position = global_position
		player.can_move = false
		player.velocity = Vector2.ZERO
		player.set_interact_prompt(false)
		
	elif current_ID == ID.zero:
		if not _dialogue_node_id:
			_dialogue_node_id = Set.pick_random()
		Dialogue.play("Hide_And_Seek", _dialogue_node_id)


func stop_hiding():
	if not player.hiding_manager.is_hiding: return

	_player_is_hiding_here = false
	
	player.animated_sprite.visible = true
	player.hiding_manager.hiding_left = 5.0
	player.hiding_manager.hide_timer = 0.0
	player.hiding_manager.is_hiding = false
	player.can_move = true

	# Move player to the front of the hiding stop
	if current_PLACEMENT == PLACEMENT.left:
		player.global_position.x -= STOP_HIDING_DISPLACEMENT
	elif current_PLACEMENT == PLACEMENT.right:
		player.global_position.x += STOP_HIDING_DISPLACEMENT
	elif current_PLACEMENT == PLACEMENT.up:
		player.global_position.y += STOP_HIDING_DISPLACEMENT
	elif current_PLACEMENT == PLACEMENT.down:
		player.global_position.y -= STOP_HIDING_DISPLACEMENT
