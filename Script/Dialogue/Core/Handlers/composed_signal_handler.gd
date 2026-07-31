## Use this handler if you want to combine multiple handlers into one. This is useful if you want to have a single handler that can run multiple actions in the option workflow.
class_name ComposedSignalHandler
extends DialogueSignalHandler

@export var handlers : Array[DialogueSignalHandler] = []

@export_category("Workflow settings")
@export var run_before_options_presented : bool = true
@export var run_after_options_presented : bool = true
@export var run_after_option_selected : bool = true

@export_category("Execution settings")
@export var randomize_order : bool = false
@export var stop_on_first_success : bool = false
@export var stop_on_first_failure : bool = false

## If true, the handler will limit the number of handlers that can run. Use in combination with [randomize_order] to create unique experiences for the player. 
@export var limit_handlers_to_run : bool = false
@export var max_handlers_to_run : int = 1

func _on_before_options_presented(_dialogue: Dialogue, _node: DialogueNode) -> void:
	_run_handlers(_dialogue, _node, null, run_before_options_presented)
	
func _on_after_options_presented(_dialogue: Dialogue, _node: DialogueNode) -> void:
	_run_handlers(_dialogue, _node, null, run_after_options_presented)

func _on_after_option_selected(_dialogue: Dialogue, _node: DialogueNode, _selected_option: DialogueOption) -> void:
	_run_handlers(_dialogue, _node, _selected_option, run_after_option_selected)
	
func _run_handlers(_dialogue: Dialogue, _node: DialogueNode, _selected_option: DialogueOption, should_run: bool) -> void:
	if not should_run:
		return
	
	var handlers_to_run : Array[DialogueSignalHandler] = handlers.duplicate()
	if randomize_order:
		handlers_to_run.shuffle()
	
	var handlers_run_count : int = 0
	for handler : DialogueSignalHandler in handlers_to_run:
		var skip_handler : bool = not handler.enabled or not handler.applies_to(_node.id) or (_selected_option and not handler.applies_to_option(_selected_option.id))
		if skip_handler:
			if stop_on_first_failure:
				break
			else: 
				continue

		if not handler.applies_to(_node.id):
			continue
		if _selected_option and not handler.applies_to_option(_selected_option.id):
			continue
		
		_run_handler(handler, _dialogue, _node, _selected_option)
		
		handlers_run_count += 1
		
		if stop_on_first_success and handler.enabled:
			break
		if stop_on_first_failure and not handler.enabled:
			break
		if limit_handlers_to_run and handlers_run_count >= max_handlers_to_run:
			break

func _run_handler(handler: DialogueSignalHandler, _dialogue: Dialogue, _node: DialogueNode, _selected_option: DialogueOption) -> void:
	if _selected_option and run_after_option_selected:
		handler._on_after_option_selected(_dialogue, _node, _selected_option)
	if run_before_options_presented:
		handler._on_before_options_presented(_dialogue, _node)
	if run_after_options_presented:
		handler._on_after_options_presented(_dialogue, _node)