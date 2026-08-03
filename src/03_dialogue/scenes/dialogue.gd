@tool
@icon("res://src/03_dialogue/editor/dialog-icon.png")
class_name Dialogue 
extends Control
## The main script for the Dialogue System. Manages the `Scenes/Dialogue/Dialogue.tscn` packed scene, used to design and display dialogues in the game. 
## 
## [b]Workflow[/b]: 
## [br]
## 1. Reads and validates the dialogue json file named as [member dialogue_source].[br] 
## 2. If [member dialogue_source] is empty, tries to read a file with the [scene] name.[br]
## 3. Loads the dialogue graph from the json file using [DialogueLoader].[br]
## 4. Depending on the settings, the dialogue text and options are displayed in the scene, and the player can interact with the dialogue by selecting options or advancing the text.[br]
## [br]
##
## [b]Settings[/b]:
## [br]
## - [member start_on_load]: if true, starts the dialogue by entering the first node in the graph, otherwise, waits for the game to call [method start] to begin the dialogue.[br]
## - [member lazy_load]: if true, the dialogue graph is loaded on demand when [method start] is called. If false, it will be loaded in [method _ready].[br]
## [br]
## 
## For each node, the workflow is as follows:[br]
## 1.				Emits the [signal on_node_entered] signal.[br]
## 2.				Updates the dialogue text, speaker name, portrait and emotion based on the node's data.[br]
## 3.				If the node has options, go to step 4. Otherwise, go to step 5 [br]
## 4.				Process dialogue options:[br]
## 4.1.			Emits the [signal on_before_options_presented] signal [br]
## 4.2.			Adds options as buttons in the scene. [br]
## 4.3.			Emits the [signal on_after_options_presented] signal and waits for player input.[br]
## 4.4.			When the player selects an option: [br]
## 4.4.1.		Emits the [signal on_option_selected] signal[br]
## 4.4.2.		Resolves next node using selected option's [next_node_id] and checks if [method request_navigation_override] was called.[br]
## 5.				If [auto_next] is true, moves to the next node automatically. Otherwise, waits for player input to advance.[br]
## 6.				If dialogue has a next node, emits [signal on_node_exited] signal [br]
## 7.				If it was last node, finishes the dialogue and emits the [signal on_dialogue_finished] signal.[br]
## [br]
## [br]
## 
## [b]Portraits[/b]:
## [br]
## Portraits are the character's visual representation in the dialogue. Each portrait is associated with a character and can have different emotions. 
## The dialogue system manages the display of portraits based on the current node's speaker and emotion.
## Portraits are defined and managed with the following properties:[br]
## - [member portrait_names]: String list of portrait names for speakers (e.g. "left", "center", "right")[br]
## - [member portrait_sprites]: Dictionary mapping portrait names to Sprite2D nodes in the scene.[br]
## - [member portrait_labels]: Dictionary mapping portrait names to RichTextLabel nodes in the scene.[br]
## - [member portrait_character]: Dictionary mapping portrait names to character names.[br]
## The dialogue system automatically updates the portrait and name label when the speaker changes or when the node's emotion changes. 
## If a portrait or name label is missing, a warning is logged if [warn_on_missing_portrait] is true.[br]
## [br]
## [br]
##
## [b]Signal Handlers[/b]:
## [br]
## [DialogueSignalHandler] are component that automatically hook into dialogue signals and provide logic for common dialogue interactions. For example:[br]
## 1. Move to a specific node after a specific option is selected.[br]
## 2. Finish the dialogue after a specific option is selected.[br]
## 3. Chain dialogues together by starting a new dialogue after the current one finishes.[br]
## Each handler has their own export settings and can be configured in the Inspector.[br]

#region SIGNALS

# Dialogue Lifecycle
signal on_dialogue_started(dialogue_id: String)
signal on_dialogue_finished(dialogue_id: String)
signal on_dialogue_paused(dialogue_id: String)
signal on_dialogue_resumed(dialogue_id: String)

# Per-node — the primary hook for game-mechanic integration
signal on_node_entered(node: DialogueNode)
signal on_node_exited(node: DialogueNode)
signal on_text_fully_revealed(node: DialogueNode)

# Branching (within one Dialogue)
signal on_before_options_presented(node: DialogueNode)
signal on_after_options_presented(node: DialogueNode)
signal on_option_selected(node: DialogueNode, option: DialogueOption)

#endregion

enum DialogueState {
	Idle,
	Typing,
	WaitingForInput, # used for both player to advance and for waiting for a choice selection
	Paused,
	Finished
}

#region EXPORT VARS
@export_file("*.json") var dialogue_source      : String = ""
## if true, the json file will be loaded on demand when [start()] is called. If false, it will be loaded in [_ready()].
@export var lazy_load                                 : bool = true

@export_category("Playback")
## If true, the dialogue will start on the _ready() method. Otherwise, the game must call [start()] to begin the dialogue.
@export var start_on_load                             : bool = false
## If true, the dialogue packed scene will hide as soon as the dialogue finishes. If false, it will remain visible.
@export var hide_on_finish                            : bool = true
## the time in seconds to wait before starting the dialogue after [start()] is called. This property is independent of [start_on_load]
@export_range(0, 10) var start_delay_time  : float = 0.2
## If [hide_on_finish] is true, this property is the time in seconds before hiding the dialogue. 
@export_range(0, 10) var hide_delay_time   : float = 0.2

@export_category("Camera settings")
## if true, when the [method start()] is called, this dialogue will attempt to center the camera on itself
@export var center_camera_on_start                     : bool = true
## if true, when the [method finish()] is called, this dialogue will attempt to reset the camera
@export var reset_camera_on_finish                     : bool = true
## if left empty, the dialogue will use the last known position of the camera before calling start
@export var reset_camera_position                      : Vector2

@export_category("Settings")
@export var skippable                                 : bool = true
@export var skip_button                               : Button
@export var pausable                                  : bool = true
## If true, the dialogue will automatically advance to the next node after the current one finishes displaying. If false, the player must manually advance the dialogue.
@export var auto_next                                 : bool = false

@export_category("Characters")                   
@export var characters                                : Array[CharacterDefinition] = []
@export_category("Portraits")                    
## list of portraits names for speakers (eg. "left", "center", "right")
@export var portrait_names                            : Array[String] = []

@export_tool_button("Sync Slot Dictionaries", "PlaceholderTexture2D")
var sync_slots_action                                 : Callable = _sync_slot_dictionaries

## portrait_name -> TextureRect node             
@export var portrait_sprites                          : Dictionary[String, NodePath] = {}
## portrait_name -> RichTextLabel node                
@export var portrait_labels                           : Dictionary[String, NodePath] = {}
## portrait_name -> character_name                    
@export var portrait_character                        : Dictionary[String, String] = {}

@export_category("Config Overrides")                  
@export var text_speed                                : float = -1.0       # -1 = "use DialogueConfig default"
@export var text_size                                 : int = -1
@export var locale                                    : String = ""

@export_category("Debug")                             
@export var debug_overlay                             : bool = false
@export var warn_on_missing_character                 : bool = true
@export var warn_on_missing_portrait                  : bool = true
@export var warn_on_missing_node_dialogue             : bool = true

#endregion

#region ON-READY VARS
@onready var dialogue_text                            : RichTextLabel = $DialogueText
@onready var options_container                        : BoxContainer = $OptionsContainer
@onready var debug_overlay_node                       : Control = $DebugOverlayContainer
#endregion


#region VARS

var current_state                                     : DialogueState = DialogueState.Idle

var _graph                                            : DialogueGraph
var _current_node                                     : DialogueNode
var _current_char                                     : CharacterDefinition
var _current_portrait                                 : String
var _current_portrait_sprite                          : Sprite2D
var _current_portrait_label                           : RichTextLabel

## slot_name -> {Sprite2D, RichTextLabel}
var _portraits                                        : Dictionary               = {}
## if set, this will be used to override the next node id for the current node. This is used for branching and choice selection.
var _pending_navigation_override                      : String = ""
var _character_lookup                                 : Dictionary[String, CharacterDefinition] = {}  # character_name -> CharacterDefinition
var _dialogue_loader                                  : DialogueLoader

#endregion


#region BUILT-IN METHODS
## cache the dialogue files and build the character lookup table
## these are required to setup the dialogue graph and character portraits correctly
func _ready() -> void:
	_dialogue_loader = DialogueLoader.new()
	dialogue_text.bbcode_enabled = true
	_build_character_lookup()
	_initialize_portraits()
	_update_ui() # skip button
	# auto-start if configured to do so, but only in the game, not in the editor
	if not Engine.is_editor_hint() and start_on_load:
		if not lazy_load:
			load_dialogue()
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

func _process(delta: float) -> void:
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
		warnings.append("Dialogue: dialogue source file '%s' does not exist" % dialogue_source)
		return warnings

	if _graph == null:
		@warning_ignore("return_value_discarded")
		warnings.append("Dialogue: dialogue graph is null. Did you call load_dialogue_graph() first?")
	if _current_node == null:
		@warning_ignore("return_value_discarded")
		warnings.append("Dialogue: current node is null. Did you call _enter_node() first?")
	if _current_char == null and not StringUtils.is_null_or_empty(_current_node.speaker):
		@warning_ignore("return_value_discarded")
		warnings.append("Dialogue: current character is null, but the current node has a speaker. Did you call build_character_lookup() first?")
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
	var source_path : String = _resolve_dialogue_source()
	if source_path == "":
		push_error("Dialogue: no dialogue source path resolved for %s" % get_scene_file_path())
		return
	_graph = _dialogue_loader.load_graph(source_path)
	if _graph == null:
		push_error("Dialogue: failed to load dialogue graph from '%s'" % source_path)
		return

## Starts the dialogue by entering the first node in the graph and emits [on_dialogue_started] signal.
## If the graph is null, this method will attempt to load it from the [dialogue_source] path if [lazy_load] is true. 
## If the graph is still null after that, this method will log an error and return.
func start() -> void:

	if _graph == null :
		if lazy_load: 
			load_dialogue()
		else:
			push_error("Dialogue: cannot start dialogue; graph is null. Did you call load_dialogue() first?")
			return
	await get_tree().create_timer(start_delay_time).timeout
	
	if reset_camera_on_finish and reset_camera_position == Vector2.ZERO:
		reset_camera_position = EventBus.get_active_camera().position

	if center_camera_on_start :
		EventBus.center_on_active_camera(self, get_global_center())
	show()

	on_dialogue_started.emit(_graph.dialogue_id)
	_enter_node(_graph.start_node_id)

## Finishes the dialogue by exiting the current node and emits [on_dialogue_finished] signal.
func finish() -> void:
	if _graph == null:
		push_warning("Dialogue: attempt to finish a null Dialogue. Did you call load_dialogue() first?")
		return
	_exit_node() # safeguard to exit the last node before finishing the dialogue
	current_state = DialogueState.Finished

	if hide_on_finish:
		await get_tree().create_timer(hide_delay_time).timeout
		hide()
	
	var id : String = _graph.dialogue_id
	on_dialogue_finished.emit(id)
	_current_node = null
	_current_char = null

func reset() -> void :
	current_state = DialogueState.Idle
	_current_char = null
	_current_node = null
	_current_portrait = ""
	_current_portrait_label = null
	_current_portrait_sprite = null


	if reset_camera_on_finish :
		EventBus.get_active_camera().position = reset_camera_position

## Requests a navigation override for the next node to enter. 
## This is used to redirect the dialogue flow to a specific node, regardless of the current node's next_node_id or the selected option's next_node_id.
## This method should be called before the next node is entered, typically in response to a player action or a game event. 
## The override will be cleared after the next node is entered.
## `next_node_id` is the id of the node to enter next.
func request_navigation_override(next_node_id: String) -> void:
	if current_state == DialogueState.Finished :
		push_warning("Dialogue: attempt to request navigation override on a finished dialogue")
		return
	_pending_navigation_override = next_node_id

func toggle_pause() -> void:
	if not pausable:
		push_warning("Dialogue: attempt to pause a non-pausable dialogue")
		return
	if current_state == DialogueState.Paused:
		current_state = DialogueState.WaitingForInput
		on_dialogue_resumed.emit()
	else :
		current_state = DialogueState.Paused
		on_dialogue_paused.emit()

#endregion

#region INITIALIZATION

func _initialize_portraits() -> void:
	_portraits.clear()
	for slot_name : String in portrait_names:
		var sprite : Sprite2D = _get_slot_sprite(slot_name)
		var name_label : RichTextLabel = _get_slot_name_label(slot_name)
		if sprite == null or name_label == null:
			if warn_on_missing_portrait:
				push_warning("Dialogue: slot '%s' is missing a Sprite2D or RichTextLabel node" % slot_name)
			continue
		_portraits[slot_name] = {"sprite": sprite, "name_label": name_label}
		sprite.texture = null
		name_label.text = ""

func _build_character_lookup() -> void:
	_character_lookup.clear()
	for c : CharacterDefinition in characters:
		if c == null or not c.validate():
			if warn_on_missing_character:
				push_warning("Dialogue: invalid CharacterDefinition in %s" % get_scene_file_path())
			continue
		_character_lookup[c.character_name.to_lower()] = c

func _update_ui() -> void:
	if skip_button != null:
		skip_button.visible = skippable
	_update_debug_overlay()

#endregion

#region Dialogue UI

func _on_skip_button_pressed() -> void:
	if skippable:
		finish()

#endregion

#region DialogueNode methods

func _enter_node(node_id: String) -> void:
	# if node does not exist in the graph, log an error and return
	if not _graph.has_node(node_id):
		push_error("Dialogue: node '%s' does not exist in graph '%s'" % [node_id, _graph.dialogue_id])
		return
	
	var old_node : DialogueNode = _current_node
	var old_char : CharacterDefinition = _current_char
	var new_node : DialogueNode = _graph.get_node(node_id)
	var new_char : CharacterDefinition = _get_character_definition(new_node.speaker.to_lower())
	
	# exit current node
	if _current_node != null:
		_exit_node()
	_apply_node_changes(old_node, new_node, old_char, new_char)

	_current_node = new_node
	_current_char = new_char

	current_state = DialogueState.Typing
	on_node_entered.emit(_current_node)

	# will add options to the options container if the node has any
	_present_node_options(_current_node)

## moves the node index forward by one, and enters the next node. 
## Returns true if successful, false if there is no next node.
func _move_next_node() -> bool:
	if _current_node == null:
		if warn_on_missing_node_dialogue:
			push_warning("Dialogue: attempt to move to next node from a null node. Did you call _enter_node() first?")
		return false
	# we use the graph to resolve the next node id, 
	# because it handles branching and explicit next_node jumps.
	var next_id: String = _graph.get_next_id(_current_node.id)
	if StringUtils.is_null_or_empty(next_id):
		return false
	_enter_node(next_id)
	return true

## Moves to the specified node id, if it exists in the graph. If it does not exist, logs a warning and does nothing.
func _move_to_node(node_id: String) -> void:
	if not _graph.has_node(node_id):
		if warn_on_missing_node_dialogue:
			push_warning("Dialogue: node '%s' does not exist in graph '%s'" % [node_id, _graph.dialogue_id])
		return
	_enter_node(node_id)

func _exit_node() -> void:
	if _current_node == null:
		if warn_on_missing_node_dialogue:
			push_warning("Dialogue: attempt to exit a null node. Did you call _enter_node() first?")
		return
	current_state = DialogueState.Idle
	on_node_exited.emit(_current_node)

## Applies the changes between the previous node and the new node, 
## including updating the portrait and emitting signals for speaker and portrait changes.
func _apply_node_changes(previous_node: DialogueNode, new_node: DialogueNode, previous_char: CharacterDefinition, new_char: CharacterDefinition) -> void:
	if new_node == null: 
		return

	var new_portrait : String = ""
	if not StringUtils.is_null_or_empty(new_node.speaker):
		new_portrait = portrait_character.find_key(new_node.speaker.to_lower())
		if StringUtils.is_null_or_empty(new_portrait):
			if warn_on_missing_character:
				push_warning("Dialogue: speaker '%s' has no portrait assigned in portrait_character" % new_node.speaker)
	var previous_portrait : String = _current_portrait
	
	_clear_portrait(previous_portrait)

	_current_portrait = new_portrait
	_update_portrait(new_portrait, new_node, new_char)

func _get_character_definition(speaker: String) -> CharacterDefinition:
	if StringUtils.is_null_or_empty(speaker):
		# no character dialog. eg: narrator. Not an error
		return null
	if not _character_lookup.has(speaker):
		if warn_on_missing_character:
			push_warning("Dialogue: speaker '%s' has no matching CharacterDefinition in this Dialogue instance" % speaker)
		return null
	return _character_lookup[speaker]
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
		push_warning("Dialogue: attempt to select a null option")
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


#region Portrait Management

## Update the portrait node in the scene based on the current node's speaker and emotion.
func _update_portrait(portrait: String, node: DialogueNode, char_def: CharacterDefinition) -> void:

	_current_portrait = portrait
	_current_portrait_sprite = _get_slot_sprite(_current_portrait)
	_current_portrait_label = _get_slot_name_label(_current_portrait)

	if not StringUtils.is_null_or_empty(node.speaker): 
		if _current_portrait_sprite != null:
			var emotion_texture : Texture2D = char_def.get_portrait(node.emotion)
			_current_portrait_sprite.texture = emotion_texture

		if _current_portrait_label != null:
			_current_portrait_label.text = char_def.character_name
	else:
		if _current_portrait_sprite != null:
			_current_portrait_sprite.texture = null
		if _current_portrait_label != null:
			_current_portrait_label.text = ""
	
## Returns the [Sprite2D] node for the given portrait slot name, or null if not found. Logs a warning if [warn_on_missing_portrait] is true.
func _get_slot_sprite(slot: String) -> Sprite2D:
	if not portrait_sprites.has(slot):
		if warn_on_missing_portrait:
			push_warning("Dialogue: slot '%s' has no sprite path configured." % slot)
		return null
	return get_node(portrait_sprites[slot]) as Sprite2D

## Returns the [RichTextLabel] node for the given portrait slot name, or null if not found. Logs a warning if [warn_on_missing_portrait] is true.
func _get_slot_name_label(slot: String) -> RichTextLabel:
	if not portrait_labels.has(slot):
		if warn_on_missing_portrait:
			push_warning("Dialogue: slot '%s' has no name label path configured." % slot)
		return null
	return get_node(portrait_labels[slot]) as RichTextLabel

## Clears the portrait sprite and name label for the given portrait slot name. If the slot name is empty or null, does nothing.
func _clear_portrait(portrait_name: String) -> void:
	if StringUtils.is_null_or_empty(portrait_name):
		return
	var sprite : Sprite2D = _get_slot_sprite(portrait_name)
	var name_label : RichTextLabel = _get_slot_name_label(portrait_name)
	if sprite != null:
		sprite.texture = null
	if name_label != null:
		name_label.text = ""
#endregion

#region UTILS
func get_global_center() -> Vector2:
	var rect: Rect2 = get_global_rect()
	return rect.size * 0.5
#endregion

#region EDITOR/TOOLING

## Inspector only. 
## For each slot name, ensure that the slot_sprites, slot_name_labels, and slot_character dictionaries have an entry. If not, create an empty entry.
func _sync_slot_dictionaries() -> void:
	for slot : String in portrait_names:
		if slot == "":
			continue  # skip while the designer is mid-typing a new entry
		if not portrait_sprites.has(slot):
			portrait_sprites[slot] = NodePath()
		if not portrait_labels.has(slot):
			portrait_labels[slot] = NodePath()
		if not portrait_character.has(slot):
			portrait_character[slot] = ""  # initialize with empty string if no character is assigned
	
	notify_property_list_changed()  # forces the Inspector to redraw and show the new empty entries

## This method resolves the json file with the dialogue data to load. It uses the following priority:
## 1. File name in [dialogue_source], if set.
## 2. File name with [scene_name] (without extension) and append ".json". 
## Files are looked in the [DialogueConfig.json_base_path] directory.
func _resolve_dialogue_source() -> String:
	if dialogue_source != "":
		return dialogue_source  # 1. explicit export always wins
	var scene_name : String = get_scene_file_path().get_file().get_basename()
	var base_path : String = DialogueConfig.json_base_path
	return base_path.path_join(scene_name + ".json") 


func _update_debug_overlay() -> void:
	if debug_overlay:
		var debug_text : Label = debug_overlay_node.get_node("Label") as Label
		debug_text.text = "Dialogue: " + _resolve_dialogue_source()
		debug_overlay_node.visible = true
	else:
		debug_overlay_node.visible = false

func _on_debug_exit_button_pressed() -> void:
	finish()
	hide()

#endregion
