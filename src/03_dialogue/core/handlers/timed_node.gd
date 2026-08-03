class_name TimedNode 
extends DialogueSignalHandler
## This handler can delay the node workflow. This is useful for adding pauses between nodes, or for adding delays before options are presented.

## If true, the node workflow will be delayed when the node is entered. The delay time will be a random value between [on_node_enter_min_time] and [on_node_enter_max_time].
@export var on_node_enter_enabled  : bool = true
@export var on_node_enter_min_time : float = 1.0
@export var on_node_enter_max_time : float = 1.0

## If true, the node workflow will be delayed when the node is exited. The delay time will be a random value between [on_node_exit_min_time] and [on_node_exit_max_time].
@export var on_node_exit_enabled  : bool = false
@export var on_node_exit_min_time : float = 1.0
@export var on_node_exit_max_time : float = 1.0

func _on_node_entered(node: DialogueNode) -> void:
	if on_node_enter_enabled :
		var delay_time : float = randf_range(on_node_enter_min_time, on_node_enter_max_time)
		await get_tree().create_timer(delay_time).timeout

func _on_node_exited(node: DialogueNode) -> void:
	if on_node_exit_enabled :
		var delay_time : float = randf_range(on_node_exit_min_time, on_node_exit_max_time)
		await get_tree().create_timer(delay_time).timeout