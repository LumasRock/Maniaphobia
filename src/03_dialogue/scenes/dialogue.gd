@tool
@icon("res://src/03_dialogue/editor/dialog-icon.png")
class_name Dialogue 
extends Control

## Attach this script to a [Control] node that will handle a `Dialogue`. This script is designed to run one dialogue at a time
##
## [b]Minimum Settings[/b]: 
## - [member dialogue_source] : the path to the JSON file with the dialogue
## - [member start_on_load]: if true, starts the dialogue by entering the first node in the graph, otherwise, waits for the game to call [method start] to begin the dialogue.[br]
## [br]
##
## Additional documentation on [res://src/03_dialogue/README.md]

#region SIGNALS

# Dialogue Lifecycle
signal on_dialogue_started(dialogue_id: String)
signal on_dialogue_finished(dialogue_id: String)
signal on_dialogue_paused(dialogue_id: String)
signal on_dialogue_resumed(dialogue_id: String)

# Per-node — the primary hook for game-mechanic integration
signal on_node_entered(node: DialogueNode)
signal on_node_exited(node: DialogueNode)
@warning_ignore("unused_signal")
signal on_text_fully_revealed(node: DialogueNode)

# Branching (within one Dialogue)
signal on_before_options_presented(node: DialogueNode)
signal on_after_options_presented(node: DialogueNode)
signal on_option_selected(node: DialogueNode, option: DialogueOption)

#endregion

enum DialogueState {
	NotStarted,
	Idle,
	Typing,
	WaitingForInput, # used for both player to advance and for waiting for a choice selection
	Paused,
	Finished
}

#region EXPORT VARS
@export_category("Settings")
@export_file("*.json") var dialogue_source : String = "" :
	## we trigger internal event to validate json file against this dialogue's settings
	set(value):
		if dialogue_source == value :
			return
		dialogue_source = value
		if not dialogue_source.is_empty():
			_on_dialogue_source_changed()

## If true, the dialogue will start on the _ready() method. Otherwise, the game must call [start()] to begin the dialogue.
@export var start_on_load                  : bool = false
## If true, the dialogue packed scene will hide as soon as the dialogue finishes. If false, it will remain visible.
@export var hide_on_finish                 : bool = true
## the time in seconds to wait before starting the dialogue after [start()] is called. This property is independent of [start_on_load]
@export_range(0, 10) var start_delay_time  : float = 0.2
## If [hide_on_finish] is true, this property is the time in seconds before hiding the dialogue. 
@export_range(0, 10) var hide_delay_time   : float = 0.2

@export_category("Speakers")
## List of speakers for this dialogue
@export var speakers_map                  : Dictionary[String, CharacterDefinition] = {} 
@export var has_narrator                  : bool = false

@export_category("Player Actions")
@export var skippable                     : bool = true
@export var pausable                      : bool = true
## If true, the dialogue will automatically advance to the next node after the current one finishes displaying. If false, the player must manually advance the dialogue.
@export var auto_next                     : bool = false

@export_category("Camera")
## alternate camera to use, if not set, no camera changes will be made
@export var camera                        : Camera2D
## if true, will attempt to center on camera when started
@export var center_on_camera              : bool = true

## Optional overrides for this specific dialogue. Do not change them if you want to use game settings
@export_category("Config Overrides")
## The speed in which the text is typed in screen. Use -1.0 to use the default
@export var text_speed                    : float = -1.0       # -1 = "use DialogueConfig default"
## Size of the text in the screen. Use -1.0 to use the default
@export var text_size                     : int = -1
## Locale (language) of the dialogue. Leave empty to use game settings
@export var locale                        : String = ""

@export_category("Debug")
@export var debug_overlay                 : bool = false
@export var warn_on_missing_character     : bool = true
@export var warn_on_missing_portrait      : bool = true
@export var warn_on_missing_node_dialogue : bool = true

#endregion

#region ON-READY VARS
@onready var dialogue_text      : RichTextLabel = $MainContainer/DialogueText
@onready var options_container  : BoxContainer = $MainContainer/OptionsContainer
@onready var debug_overlay_node : Control = $DebugOverlayContainer
@onready var skip_button        : Button = $GUI/SkipButton

#endregion


#region VARS

var current_state     : DialogueState = DialogueState.NotStarted

var _dialogue_loader  : DialogueLoader
var _graph            : DialogueGraph
var _current_node     : DialogueNode
var _current_speaker  : DialogueSpeaker
var _speaker_nodes_lookup  : Array[DialogueSpeaker]
var _previous_camera  : Camera2D = null

## if set, this will be used to override the next node id for the current node. This is used for branching and choice selection.
var _pending_navigation_override : String = ""

#endregion


#region BUILT-IN METHODS

## cache the dialogue files and build the character lookup table
## these are required to setup the dialogue graph and character portraits correctly
func _ready() -> void:
	dialogue_text.bbcode_enabled = true
	# auto-start if configured to do so, but only in the game, not in the editor
	if Engine.is_editor_hint():
		# scan character definitions in the project to populate the speakers_map
		CharacterDefinition._scan_dir("res://src/") 
	else: 
		load_dialogue()
		_update_ui() # skip button
		if start_on_load:
			start()

func _unhandled_input(event: InputEvent) -> void:
	if _current_node == null : 
		return
	# Pause/Unpause the dialogue if pausable is true. This allows the player to pause the dialogue and resume it later.
	if event.is_action_pressed("Pause") and pausable:
		toggle_pause()

	if current_state == DialogueState.WaitingForInput:
		# accept is to select an option
		if event.is_action_pressed("accept") and _current_node.has_options():
			_handle_selected_option(_current_node, _current_node.selected_option()) 

		# continue is to advance the dialogue to the next node		
		if event.is_action_pressed("continue") and not _current_node.has_options():
			if not _move_next_node():
				finish()

func _process(_delta: float) -> void:
	if _graph == null or _current_node == null:
		return

	# TODO : implement text speed and typing effect here
	current_state = DialogueState.Typing
	dialogue_text.text = _current_node.text
	current_state = DialogueState.WaitingForInput
	
	# UI: skip button, debug overlay
	_update_ui()

func _get_configuration_warnings() -> PackedStringArray: 
	var warnings : PackedStringArray = PackedStringArray()
	if dialogue_source == "":
		return warnings # no dialogue selected, nothing to check

	if not FileAccess.file_exists(dialogue_source):
		@warning_ignore("return_value_discarded")
		warnings.append("%s: dialogue source file '%s' does not exist" % [name, dialogue_source])
		return warnings

	if _graph == null:
		@warning_ignore("return_value_discarded")
		warnings.append("%s: missing dialogue reference in 'dialogue_source'" % name)
	else :
		@warning_ignore("return_value_discarded")
		warnings.append_array(_get_speakers_warnings())

	return warnings

#endregion


#region PUBLIC API

## returns the dialogue id of the current graph, or an empty string if the graph is null
func get_dialogue_id() -> String:
	return _graph.dialogue_id if _graph != null else ""

## sugar coating to check if current_state is [DialogueState.Idle]
func is_idle() -> bool:
	return current_state == DialogueState.Idle
## sugar coating to check if current_state is [DialogueState.Typing]
func is_typing() -> bool:
	return current_state == DialogueState.Typing
## sugar coating to check if current_state is [DialogueState.WaitingForInput]	
func is_waiting_for_input() -> bool:
	return current_state == DialogueState.WaitingForInput
## sugar coating to check if current_state is [DialogueState.Paused]
func is_paused() -> bool:
	return current_state == DialogueState.Paused
## sugar coating to check if current_state is [DialogueState.Finished]
func is_finished() -> bool:
	return current_state == DialogueState.Finished

## If a dialogue graph is not loaded, this method will attempt to load it from the [dialogue_source] path. If the graph is already loaded, this method does nothing.
func load_dialogue() -> void:
	if _dialogue_loader == null :
		_dialogue_loader = DialogueLoader.new()

	if dialogue_source.is_empty() :
		push_error("%s: no dialogue source path resolved for %s" % [name, get_scene_file_path()])
		return
	_graph = _dialogue_loader.load_graph(dialogue_source)
	if _graph == null:
		push_error("%s: failed to load dialogue graph from '%s'" % [name, dialogue_source])
		return
	
	_initialize_speakers()
	

## Starts the dialogue by entering the first node in the graph and emits [on_dialogue_started] signal.
## If the graph is null, this method will attempt to load it from the [dialogue_source] path if [lazy_load] is true. 
## If the graph is still null after that, this method will log an error and return.
func start() -> void:
	if _graph == null :
		push_error("%s: cannot start dialogue; graph is null. Did you call load_dialogue() first?" % name)
		return

	await get_tree().create_timer(start_delay_time).timeout
	_setup_camera()
	show()

	on_dialogue_started.emit(_graph.dialogue_id)
	if not _enter_node(_graph.start_node_id) :
		push_error("%s: could not start initial node. Finishing dialogue" % name)
		finish()


## Finishes the dialogue by exiting the current node and emits [on_dialogue_finished] signal.
func finish() -> void:
	if _graph == null:
		push_warning("%s: attempt to finish a null Dialogue. Did you call load_dialogue() first?" % name)
		return
	_exit_node() # safeguard to exit the last node before finishing the dialogue
	current_state = DialogueState.Finished
	_release_camera()

	if hide_on_finish:
		await get_tree().create_timer(hide_delay_time).timeout
		hide()
	
	var id : String = _graph.dialogue_id
	on_dialogue_finished.emit(id)
	_current_node = null
	_current_speaker = null

func reset() -> void :
	current_state = DialogueState.Idle
	_current_node = null
	_current_speaker = null
	_release_camera()

## Requests a navigation override for the next node to enter. 
## This is used to redirect the dialogue flow to a specific node, regardless of the current node's next_node_id or the selected option's next_node_id.
## This method should be called before the next node is entered, typically in response to a player action or a game event. 
## The override will be cleared after the next node is entered.
## `next_node_id` is the id of the node to enter next.
func request_navigation_override(next_node_id: String) -> void:
	if current_state == DialogueState.Finished :
		push_warning("%s: attempt to request navigation override on a finished dialogue" % name)
		return
	_pending_navigation_override = next_node_id

func toggle_pause() -> void:
	if not pausable:
		push_warning("%s: attempt to pause a non-pausable dialogue" % name)
		return
	if current_state == DialogueState.Paused:
		current_state = DialogueState.WaitingForInput
		on_dialogue_resumed.emit()
	else :
		current_state = DialogueState.Paused
		on_dialogue_paused.emit()

#endregion

#region INITIALIZATION

## Finds every speaker found in the JSON file, attempts to find a matching DialogueSpeaker node in the scene tree,	
## and a matching CharacterDefinition in the system. If any of these are not found, a warning is logged.
## If there is no graph loaded, this method logs a warning and does nothing.
func _initialize_speakers() -> void:
	if _graph == null:
		push_warning("%s: cannot initialize speakers; graph is null. Did you call load_dialogue() first?" % name)
		return

	if _speaker_nodes_lookup.is_empty() :
		_speaker_nodes_lookup.assign(
				find_children("*", "DialogueSpeaker", true, false))

	var speaker_names : Array[String] = _graph.collect_speakers()
	print(dialogue_source)
	print("%s: Found %d Speakers : %s" % [name, speaker_names.size(), "' , '".join(speaker_names)])

	for _speaker : String in speaker_names :

		# Narrator use case	
		if DialogueConfig.valid_narrator_names.has(_speaker.to_lower()):
			print("Narrator speaker found '%s'" % _speaker)
			var narrator_speaker : DialogueSpeaker = _get_narrator_speaker(_speaker.to_lower())
			if narrator_speaker == null:
				push_warning("%s: speaker '%s' is a narrator but no DialogueSpeaker node with type NARRATOR was found in the scene tree" % [name, _speaker])
			else :
				narrator_speaker.speaker_name = _speaker
			has_narrator = true
			continue

		# Character/npc use case
		if not speakers_map.has(_speaker):
			speakers_map[_speaker] = null

		var speaker_node : DialogueSpeaker = _get_speaker(_speaker.to_lower())
		if speaker_node == null:
			push_warning("%s: speaker '%s' is used in the dialogue graph but not assigned in the speakers array" % [name, _speaker])
			continue

		# look for CharacterDefinition named 's_name' in the system
		var _found_defs : Array[CharacterDefinition] = CharacterDefinition.ALL.filter(
				func(c: CharacterDefinition) -> bool : return c.character_name.to_lower() == _speaker.to_lower())
		if _found_defs.is_empty():
			push_warning("%s: speaker '%s' has no CharacterDefinition assigned and no matching CharacterDefinition found in the system" % [name, _speaker])
			continue
		var char_def : CharacterDefinition = _found_defs[0]
		speakers_map[_speaker] = char_def
		speaker_node.character = char_def


## Called during _process() to update the Skip button and debug overlay features
func _update_ui() -> void:
	if skip_button != null:
		skip_button.visible = skippable
	_update_debug_overlay()


## Called everytime the dialogue_source property value changes
## This method loads the json and triggers validations for speakers and portraits.
func _on_dialogue_source_changed() -> void :
	if _dialogue_loader == null :
		_dialogue_loader = DialogueLoader.new()
	if Engine.is_editor_hint() :
		load_dialogue()
		update_configuration_warnings()
		
func _get_speakers_warnings() -> PackedStringArray :
	var warnings : PackedStringArray = PackedStringArray()
	if _graph == null :
		return warnings
	var speaker_names : Array[String] = _graph.collect_speakers()
	for sn : String in speaker_names :
		if DialogueConfig.valid_narrator_names.has(sn.to_lower()):
			var narrator_speaker : DialogueSpeaker = _get_narrator_speaker(sn.to_lower())
			if narrator_speaker == null:
				@warning_ignore("return_value_discarded")
				warnings.append("%s: speaker '%s' is a narrator but no DialogueSpeaker node with type NARRATOR was found in the scene tree" % [name, sn])
			else :
				continue
		if _get_speaker(sn.to_lower()) == null :
			@warning_ignore("return_value_discarded")
			warnings.append("%s: speaker '%s' is used in the dialogue graph but not assigned in the speakers array" % [name, sn])			

	return warnings
#endregion

#region CAMERA

func _setup_camera() -> void :
	if camera != null:
		_previous_camera = get_viewport().get_camera_2d()
		camera.enabled = true
		camera.make_current()
	else:
		_previous_camera = null

	if center_on_camera:
		if camera != null:
			global_position = camera.get_screen_center_position() - get_rect().size / 2.0
	else:
			global_position = get_viewport().get_camera_2d().get_screen_center_position() - get_rect().size / 2.0

func _release_camera() -> void :
	if _previous_camera != null:
		camera.enabled = false
		_previous_camera.make_current()

#endregion

#region Dialogue UI

func _on_skip_button_pressed() -> void:
	if skippable:
		finish()

#endregion

#region DialogueNode methods

func _enter_node(node_id: String) -> bool:
	# if node does not exist in the graph, log an error and return
	if not _graph.has_node(node_id):
		push_error("%s: node '%s' does not exist in graph '%s'" % [name, node_id, _graph.dialogue_id])
		return false
	
	var entering_node : DialogueNode = _graph.get_node(node_id)
	var entering_speaker : DialogueSpeaker = _get_speaker(entering_node.speaker.to_lower())

	# exit current node
	if _current_node != null:
		_exit_node()
	
	if entering_node : 
		_apply_speaker_change(entering_speaker, entering_node.emotion)
		_current_node = entering_node
		_current_speaker = entering_speaker
		current_state = DialogueState.Typing
		on_node_entered.emit(_current_node)
		# will add options to the options container if the node has any
		_present_node_options(_current_node)
		return true

	# did not enter any node
	return false


## moves the node index forward by one, and enters the next node. 
## Returns true if successful, false if there is no next node.
func _move_next_node() -> bool:
	if _current_node == null:
		if warn_on_missing_node_dialogue:
			push_warning("%s: attempt to move to next node from a null node. Did you call _enter_node() first?" % name)
		return false
	# we use the graph to resolve the next node id 
	var next_id: String = _graph.get_next_id(_current_node.id)
	return _enter_node(next_id)


## Moves to the specified node id, if it exists in the graph. If it does not exist, logs a warning and does nothing.
func _move_to_node(node_id: String) -> void:
	if not _graph.has_node(node_id):
		if warn_on_missing_node_dialogue:
			push_warning("%s: node '%s' does not exist in graph '%s'" % [name, node_id, _graph.dialogue_id])
		return
	if not _enter_node(node_id) :
		push_warning("%s: failed to enter node '%s' in graph '%s'" % [name, node_id, _graph.dialogue_id])


func _exit_node() -> void:
	if _current_node == null:
		if warn_on_missing_node_dialogue:
			push_warning("%s: attempt to exit a null node. Did you call _enter_node() first?" % name)
		return
	current_state = DialogueState.Idle
	on_node_exited.emit(_current_node)

## Returns the [DialogueSpeaker] from [member _speakers_lookup] where 
## [CharacterDefinition.character_name] equals to [param character_name] (no case-sensitive). 
## Returns null if not found
func _get_speaker(character_name : String) -> DialogueSpeaker :
	for speaker : DialogueSpeaker in _speaker_nodes_lookup :
		if speaker.has_name(character_name) :
			return speaker
	return null

func _get_narrator_speaker(character_name : String = "") -> DialogueSpeaker:
	for speaker : DialogueSpeaker in _speaker_nodes_lookup :
		if speaker.speaker_type == DialogueSpeaker.SpeakerType.NARRATOR:
			return speaker
	return null

## Applies the changes to the portrait mapped to [param _speaker], based on 
## [param _emotion] value. 
## If you need to customize this behaviour, extending [method DialogueSpeaker.update_portrait]
func _apply_speaker_change(_speaker: DialogueSpeaker, _emotion : String = "neutral") -> void:
	if _speaker == null:
		if warn_on_missing_character:
			push_warning("%s: speaker '%s' has no portrait assigned " % [name, _speaker.name])
	else :
		_speaker.update_portrait(_emotion)

#endregion


#region DialogueOption methods

## Called to check if a node has options, and present them in the dialogue container.
## `node` is the node to present options. `Dialogue._enter_node` calls this method.
## If the node has options, this method replace any Nodes in the `options_container` with `Button` for each option,
## emits the `on_choice_presented` signal and runs DialogueOptionHandlers for `on_before_options_presented` and `on_after_options_presented`.
## If the node has no options this method will do nothing.
func _present_node_options(node: DialogueNode) -> void:
	if node == null or not node.has_options():
		return
	current_state = DialogueState.WaitingForInput
	on_before_options_presented.emit(node)
	_update_options_container(node, node.options)
	on_after_options_presented.emit(node)


## This method is hooked to the buttons in the options container when pressed 
## Also, emits the choice_selected signal and runs any DialogueOptionHandlers that apply to the selected option.
func _handle_selected_option(node: DialogueNode, selected_option: DialogueOption) -> void:
	if selected_option == null:
		push_warning("%s: attempt to select a null option" % name)
		return
	on_option_selected.emit(node, selected_option)
	_clear_options_container()


## Attempts to resolve where the graph goes next, based on the selected option and any pending navigation override.
## If it can resolve, this method actually calls 'move_to_node' or 'finish'. Otherwise, this method does nothing.
## `selected_option` is optional, if not provided, uses `_current_node.selected_option()`.
func _resolve_option_navigation(selected_option: DialogueOption = null) -> void:
	# if dialogue is finished, clear the pending navigation override and return
	if current_state == DialogueState.Finished:
		_pending_navigation_override = ""
		return
	
	if selected_option == null :
		_pending_navigation_override = ""
		selected_option = _current_node.selected_option()	
	
	if selected_option != null:		
		if _pending_navigation_override != "":
			var target : String = _pending_navigation_override
			_pending_navigation_override = ""
			_move_to_node(target)
		elif not StringUtils.is_null_or_empty(selected_option.next_node_id):
			_move_to_node(selected_option.next_node_id)
		else:
			finish()
	else :
		_pending_navigation_override = ""

func _clear_options_container() -> void:
	for child : Node in options_container.get_children():
		child.queue_free()

func _update_options_container(node: DialogueNode, options: Array[DialogueOption]) -> void:
	_clear_options_container()
	for option : DialogueOption in options:
		var button : Button = Button.new()
		button.text = option.text
		@warning_ignore("return_value_discarded")
		button.pressed.connect(_on_option_button_pressed(node, option))
		options_container.add_child(button)

## Returns a callable that will be connected to the button pressed signal for each option button.
func _on_option_button_pressed(node: DialogueNode, option: DialogueOption) -> Callable:
	return func() -> void:
		option.selected = true
		_handle_selected_option(node, option)
		_resolve_option_navigation(option)

#endregion

#region DEBUG

func _update_debug_overlay() -> void:
	if debug_overlay:
		var debug_text : Label = debug_overlay_node.get_node("Label") as Label
		debug_text.text = "Dialogue: " + dialogue_source
		debug_overlay_node.visible = true
	else:
		debug_overlay_node.visible = false

func _on_debug_exit_button_pressed() -> void:
	finish()
	hide()

#endregion
