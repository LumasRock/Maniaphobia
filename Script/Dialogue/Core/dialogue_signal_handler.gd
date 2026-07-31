class_name DialogueSignalHandler 
extends Node
## Extend this class to implement common behavior tied to dialogue events. 
## DialogueSignalHandler must be a child of a Dialogue node to work properly.
## Use [target_node_ids] and [target_option_ids] properties to specify which dialogue nodes and options the handler applies to. 
## If both lists are empty, the handler will apply to all nodes and options.

@export_category("Target")
## Drag the Dialogue node from the scene tree to this property. If empty, the handler will attempt to find a Dialogue node in its parent nodes.
@export var dialogue  : Dialogue = get_parent() as Dialogue
## The node_id this handler applies to. If empty, the handler will apply to all nodes.
@export var node_id   : String = ""
## The option_id this handler applies to. If empty, the handler will apply to all options.
@export var option_id : String = ""

## If both [node_id] and [option_id] are empty, the handler always runs for every node and option.
## The value is calculate on _ready()
var _always_run       : bool = false 

func _ready() -> void :
	_always_run = node_id == "" and option_id == ""
	if not dialogue :
		push_warning("DialogueSignalHandler: No Dialogue node found in parent. Handler will be disabled.")
		process_mode = Node.PROCESS_MODE_DISABLED
	else :
		_connect_to_dialogue() 

func _connect_to_dialogue() -> void :
	# dialogue lifecycle signals
	_try_connect(dialogue.on_dialogue_started, _filtered_dialogue.bind(_on_dialogue_started))
	_try_connect(dialogue.on_dialogue_finished, _filtered_dialogue.bind(_on_dialogue_finished))
	_try_connect(dialogue.on_dialogue_paused, _filtered_dialogue.bind(_on_dialogue_paused))
	_try_connect(dialogue.on_dialogue_resumed, _filtered_dialogue.bind(_on_dialogue_resumed))
	
	# per dialogue node signals
	_try_connect(dialogue.on_node_entered, _filtered_node.bind(_on_node_entered))
	_try_connect(dialogue.on_text_fully_revealed, _filtered_node.bind(_on_text_fully_revealed))
	_try_connect(dialogue.on_node_exited, _filtered_node.bind(_on_node_exited))

	# branching
	_try_connect(dialogue.on_before_options_presented, _filtered_option.bind(_on_before_options_presented))
	_try_connect(dialogue.on_after_options_presented, _filtered_option.bind(_on_after_options_presented))
	_try_connect(dialogue.on_option_selected, _filtered_option.bind(_on_option_selected))

func _filtered_dialogue(_dialogue_id : String, callback: Callable) -> void:
	if _always_run or _dialogue_id == dialogue.get_dialogue_id():
		callback.call(dialogue)

func _filtered_node(node: DialogueNode, callback: Callable) -> void:
	if _always_run or node.id == node_id:
		callback.call(dialogue, node)

func _filtered_option(node: DialogueNode, option: DialogueOption, callback: Callable) -> void:
	if _always_run or (node.id == node_id and (option_id == "" or option.id == option_id)):
		callback.call(dialogue, node, option)

func _try_connect(_signal: Signal, callback: Callable) -> void :
	if _signal == null or callback == null :
		push_warning("DialogueSignalHandler: Signal or callback is null. Cannot connect.")
		return
	if not _signal.is_connected(callback) :
		if _signal.connect(callback) != OK :
			push_warning("DialogueSignalHandler: Failed to connect signal %s to callback." % _signal)

#region SIGNAL CALLBACKS STUBS
func _on_dialogue_started(dialogue_id: String) -> void:
	pass

func _on_dialogue_finished(dialogue_id: String) -> void:
	pass
	
func _on_dialogue_paused() -> void:
	pass
	
func _on_dialogue_resumed() -> void:
	pass

func _on_node_entered(node: DialogueNode) -> void:
	pass
	
func _on_text_fully_revealed(node: DialogueNode) -> void:
	pass

func _on_node_exited(node: DialogueNode) -> void:
	pass

func _on_before_options_presented(node: DialogueNode) -> void:
	pass
	
func _on_after_options_presented(node: DialogueNode) -> void:
	pass

func _on_option_selected(node: DialogueNode, option: DialogueOption) -> void:
	pass
	
func _on_speaker_changed(previous_speaker: String, new_speaker: String) -> void:	
	pass
	
func _on_portrait_changed(previous_portrait: String, new_portrait: String) -> void:
	pass

func _on_emotion_changed(previous_emotion: String, new_emotion: String) -> void:
	pass
#endregion