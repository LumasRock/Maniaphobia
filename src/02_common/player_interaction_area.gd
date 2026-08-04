class_name PlayerInteractionArea
extends Area2D

@export_category("Interaction Settings")
## if true, only the first interaction will be monitored
@export var interact_once          : bool = false
@export var ignore_on_enter        : bool = false
@export var ignore_on_exit         : bool = false
@export var allowed_input_actions  : Array[String] = ["interact"]

@export_category("Default Interaction Logic")
@export var condition_target       : NodePath
@export var condition_method       : String
@export var action_target          : NodePath
@export var action_method          : String

@export_category("Condition Failed")
@export var ignore_condition_failed: bool = true
@export var failed_target          : NodePath
@export var failed_method          : String

@export_category("On Enter/On Exit Settings")
## if true, on_enter is also considered as played interaction
@export var count_enter_as_played  : bool = false
## if true, on_exit is also considered as played interaction
@export var count_exit_as_played   : bool = false

@onready var player                : Player = get_tree().get_first_node_in_group("player")

var already_played                 : bool = false

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		@warning_ignore("return_value_discarded")
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		@warning_ignore("return_value_discarded")
		body_exited.connect(_on_body_exited)

func _input(event : InputEvent) -> void :
	
	if player in get_overlapping_bodies() :
		for allowed_action : String in allowed_input_actions:
			if event.is_action_pressed(allowed_action):
				player.show_interact_prompt(false)
				if interact_once and already_played: return
				if _call_condition() : 
					_call_action()
					already_played = true
				else :
					_condition_failed()

func _condition_failed() -> void :
	if ignore_condition_failed : return
	if failed_target.is_empty() or failed_method.is_empty() : return
	var node : Node = get_node_or_null(failed_target)
	if node == null : return
	node.call(failed_method)

func _call_condition() -> bool :
	if condition_target.is_empty() or condition_method.is_empty() : return true
	var node : Node = get_node_or_null(condition_target)
	return node.call(condition_method) if node else false

func _call_action() -> void :
	if action_target.is_empty() or action_method.is_empty() : return
	var node : Node = get_node_or_null(action_target)
	if node == null : return
	return node.call(action_method)

func _on_body_entered(body: Node2D) -> void:
	if body is Player and body == player :
		player.show_interact_prompt(true)
		if count_enter_as_played :
			already_played = true

func _on_body_exited(body: Node2D) -> void:
	if body is Player and body == player :
		player.show_interact_prompt(false)
		if count_exit_as_played :
			already_played = true