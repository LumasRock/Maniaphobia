## Dialogue.gd 
## The main script for the Dialogue System. Manages the `Scenes/Dialogue/Dialogue.tscn` packed scene, used to design and display dialogues in the game. 
## 
## [b]Signals[/b]:
## - [dialogue_started(dialogue_id: String)]
## - [dialogue_finished(dialogue_id: String)]
## - [dialogue_paused]
## - [dialogue_resumed]
## - [node_entered(node: DialogueNode)]
## - [node_exited(node: DialogueNode)]
## - [text_fully_revealed(node: DialogueNode)]
## - [speaker_changed(previous_speaker: String, new_speaker: String)]
## - [choice_presented(options: Array)]
## - [choice_selected(option: DialogueOption)]
## - [portrait_changed(previous_portrait: String, previous_emotion: String, new_portrait: String, new_emotion: String)]
##
## [b]Overall Workflow[/b]: 
## 1. Reads and validates the dialogue json file named as [dialogue_source]. 
## 2. If [dialogue_source] is empty, tries to read a file with the [scene] name.
## 3. Loads the dialogue graph from the json file using [DialogueLoader].
## 4. Depending on the settings, the dialogue text and options are displayed in the scene, and the player can interact with the dialogue by selecting options or advancing the text.
##
## [b]Settings[/b]:
## - [start_on_load]: if true, starts the dialogue by entering the first node in the graph, otherwise, waits for the game to call [start()] to begin the dialogue.
## - [lazy_load]: if true, the dialogue graph is loaded on demand when [start()] is called. If false, it will be loaded in [_ready()].
##
## For each node, the workflow is as follows:
## 1. Emits the [node_entered] signal.
## 2. Updates the dialogue text and speaker portrait based on the node's data.
## 3. If the node has options: 
##	   3.1. Adds options as buttons in the scene. 
## 			a. If speaker changed, emits the [speaker_changed] signal.
## 			b. If portrait changed, emits the [portrait_changed] signal.
##	   3.2. Emits the [choice_presented] signal and waits for player input.
##     3.3. When the player selects an option: 
##          a. Emits the [choice_selected] signal
##			b. Calls any [DialogueOptionHandler] setup to handle an option selection.
##          c. Resolves the next node based on the option's [next_node_id] or any other logic defined in the dialogue graph.
## 4. If the node has no options, waits for player input to advance.
## 5. If dialogue has a next node, emits [node_exited] signal 
## 6. If there are nodes left, finishes the dialogue and emits the [dialogue_finished] signal.
##
## [b]Portraits[/b]:
## Portraits are the character's visual representation in the dialogue. Each portrait is associated with a character and can have different emotions. The dialogue system manages the display of portraits based on the current node's speaker and emotion.
## Portraits are defined and managed with the following properties:
## - [portrait_names]: String list of portrait names for speakers (e.g. "left", "center", "right")
## - [portrait_sprites]: Dictionary mapping portrait names to Sprite2D nodes in the scene
## - [portrait_labels]: Dictionary mapping portrait names to RichTextLabel nodes in the scene
## - [portrait_character]: Dictionary mapping portrait names to character names
## 
## The dialogue system automatically updates the portrait and name label when the speaker changes or when the node's emotion changes. If a portrait or name label is missing, a warning is logged if [warn_on_missing_portrait] is true.
##
## [b]Dialogue Option Handlers[/b]:
## [DialogueOptionHandlers] are nodes that can be added as children of the Dialogue node to handle specific dialogue options. 
## They provide hooks for three main events in the dialogue option lifecycle:
## 1. Before options are presented: ideal to trigger visual effects, play sounds, or modify the options before they are displayed.
## 2. After options are presented: ideal to alter the option buttons, like glowing effects, blinking, etc.
## 3. After an option is selected: ideal to redirect the dialogue to a different node, finish the dialogue or load a new scene.
## 
## Adding a DialogueOptionHandler consists on adding a child node to the Dialogue node and configuring it to handle specific options.
## The settings depend on the handler implementation, but generally include:
## - [enabled]: whether the handler is enabled and should run. This allows you bypass the handler without removing it from the scene.
## - [target_node_ids]: list of target node IDs that the handler applies to
## - [target_option_ids]: list of target option IDs that the handler applies to
##
## The Dialogue system comes with several built-in handlers, but you can also create your own by extending the [DialogueOptionHandler] class and implementing the hooks for the events you want to handle.
## Explore some built-in handlers: [GoToOptionHandler], [FinishOptionHandler], [LoadSceneOptionHandler], [TrueOptionHandler], [FalseOptionHandler].
## Also, you can combine multiple handlers to create complex behaviours for your dialogue options. 
## For this, check the following: [AndOptionHandler], [OrOptionHandler], [AnyTrueOptionHandler], [AnyFalseOptionHandler], [AllTrueOptionHandler], [AllFalseOptionHandler] to combine multiple handlers with logical AND and OR operations.
@icon("res://Script/Dialogue/Editor/dialog-icon.png")
@tool
class_name Dialogue extends Control

# Dialogue Lifecycle
signal dialogue_started(dialogue_id: String)
signal dialogue_finished(dialogue_id: String)
signal dialogue_paused
signal dialogue_resumed

# Per-node — the primary hook for game-mechanic integration
signal node_entered(node: DialogueNode)
signal node_exited(node: DialogueNode)
signal text_fully_revealed(node: DialogueNode)
signal speaker_changed(previous_speaker: String, new_speaker: String)

# Branching (within one Dialogue)
signal choice_presented(options: Array)
signal choice_selected(option: DialogueOption)

# Portraits
signal portrait_changed(previous_portrait: String, previous_emotion: String, 
						new_portrait: String, new_emotion: String)


@export_file("*.json") var dialogue_source: String = ""   # optional explicit override; see §6 for default resolutionon

@export_category("Settings")
## if true, the dialogue graph will be loaded on demand when start() is called. If false, it will be loaded in _ready().
@export var lazy_load                     : bool = true
@export var start_on_load                 : bool = false
@export var skippable                     : bool = true
@export var pausable                      : bool = true
## If true, the dialogue will automatically advance to the next node after the current one finishes displaying. If false, the player must manually advance the dialogue.
@export var auto_next                     : bool = false

@export_category("Characters")
@export var characters                    : Array[CharacterDefinition] = []

@export_category("Portraits")
## list of portraits names for speakers (e.g. "left", "center", "right")
@export var portrait_names                : Array[String] = []

@export_tool_button("Sync Slot Dictionaries", "PlaceholderTexture2D")
var sync_slots_action                     : Callable = _sync_slot_dictionaries

## portrait_name -> TextureRect node
@export var portrait_sprites              : Dictionary[String, NodePath] = {}
## portrait_name -> RichTextLabel node
@export var portrait_labels               : Dictionary[String, NodePath] = {}
## portrait_name -> character_name
@export var portrait_character            : Dictionary[String, String] = {}

@export_category("Config Overrides")
@export var text_speed                    : float = -1.0       # -1 = "use DialogueConfig default"
@export var text_size                     : int = -1
@export var locale                        : String = ""

@export_category("Debug")
@export var warn_on_missing_character     : bool = true
@export var warn_on_missing_portrait      : bool = true
@export var warn_on_missing_node_dialogue : bool = true

@onready var dialogue_text                : RichTextLabel = $DialogueText
@onready var options_container            : BoxContainer = $OptionsContainer
@onready var dialogue_camera              : Camera2D = $Camera2D

var _graph                   : DialogueGraph
var _current_node            : DialogueNode
var _current_char            : CharacterDefinition
var _current_portrait        : String
var _current_portrait_sprite : Sprite2D
var _current_portrait_label  : RichTextLabel

## slot_name -> {Sprite2D, RichTextLabel}
var _portraits : Dictionary               = {}  
## if set, this will be used to override the next node id for the current node. This is used for branching and choice selection.
var _pending_navigation_override : String = ""  

enum DialogueState {
	Idle,
	Typing,
	WaitingForInput, # used for both player to advance and for waiting for a choice selection
	Paused,
	Finished
}
var current_state : DialogueState = DialogueState.Idle

var _character_lookup: Dictionary[String, CharacterDefinition] = {}  # character_name -> CharacterDefinition
var _dialogue_loader : DialogueLoader

func get_dialogue_id() -> String:
	return _graph.dialogue_id if _graph != null else ""

## cache the dialogue files and build the character lookup table
## these are required to setup the dialogue graph and character portraits correctly
func _ready() -> void:
	_dialogue_loader = DialogueLoader.new()
	dialogue_text.bbcode_enabled = true
	build_character_lookup()
	initialize_portraits()
	# auto-start if configured to do so, but only in the game, not in the editor
	if not Engine.is_editor_hint() and start_on_load:
		if not lazy_load:
			load_dialogue_graph()
		start()

func _unhandled_input(event: InputEvent) -> void:
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


#region Ready / Initialization

func initialize_portraits() -> void:
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

func build_character_lookup() -> void:
	_character_lookup.clear()
	for c : CharacterDefinition in characters:
		if c == null or not c.validate():
			if warn_on_missing_character:
				push_warning("Dialogue: invalid CharacterDefinition in %s" % get_scene_file_path())
			continue
		_character_lookup[c.character_name.to_lower()] = c

func load_dialogue_graph() -> void:
	var source_path : String = _resolve_dialogue_source()
	if source_path == "":
		push_error("Dialogue: no dialogue source path resolved for %s" % get_scene_file_path())
		return
	_graph = _dialogue_loader.load_graph(source_path)
	if _graph == null:
		push_error("Dialogue: failed to load dialogue graph from '%s'" % source_path)
		return
#endregion

#region Dialogue Lifecycle
func start() -> void:
	if _graph == null :
		if lazy_load: 
			load_dialogue_graph()
		else:
			push_error("Dialogue: cannot start dialogue; graph is null. Did you call load_dialogue_graph() first?")
			return
	dialogue_started.emit(_graph.dialogue_id)
	_enter_node(_graph.start_node_id)

func finish() -> void:
	if _graph == null:
		push_warning("Dialogue: attempt to finish a null Dialogue. Did you call load_dialogue_graph() first?")
		return
	_exit_node()
	var id : String = _graph.dialogue_id
	_current_node = null
	current_state = DialogueState.Finished
	_graph = null
	dialogue_finished.emit(id)

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
		dialogue_resumed.emit()
	else :
		current_state = DialogueState.Paused
		dialogue_paused.emit()

func _enter_node(node_id: String) -> void:
	# if node does not exist in the graph, log an error and return
	if not _graph.has_node(node_id):
		push_error("Dialogue: node '%s' does not exist in graph '%s'" % [node_id, _graph.dialogue_id])
		return
	
	var old_node : DialogueNode = _current_node
	var old_char : CharacterDefinition = _current_char
	var new_node : DialogueNode = _graph.get_node(node_id)
	var new_char : CharacterDefinition = _get_character(new_node.speaker.to_lower())
	
	# exit current node
	if _current_node != null:
		_exit_node()
	_apply_node_changes(old_node, new_node, old_char, new_char)

	_current_node = new_node
	_current_char = new_char

	current_state = DialogueState.Typing
	node_entered.emit(_current_node)

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
	node_exited.emit(_current_node)

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

	# check if speaker changed
	if previous_node == null : 
		if not StringUtils.is_null_or_empty(new_node.speaker):
			speaker_changed.emit("", new_node.speaker)
		if not StringUtils.is_null_or_empty(new_portrait):
			portrait_changed.emit("", new_portrait, "", new_node.emotion)
	else :
		if previous_node.speaker != new_node.speaker:			
			speaker_changed.emit(previous_node.speaker, new_node.speaker)
		# check if portrait slot or emotion changed
		if previous_portrait != new_portrait or previous_node.emotion != new_node.emotion:
			portrait_changed.emit(previous_portrait, new_portrait, previous_node.emotion, new_node.emotion)

	_current_portrait = new_portrait
	_update_portrait(new_portrait, new_node, new_char)

#endregion


#region Dialogue Options

## Called to check if a node has options, and present them in the dialogue container.
## `node` is the node to present options. `Dialogue._enter_node` calls this method.
## If the node has options, this method replace any Nodes in the `options_container` with `Button` for each option,
## emits the `choice_presented` signal and runs DialogueOptionHandlers for `on_before_options_presented` and `on_after_options_presented`.
## If the node has no options this method will do nothing.
func _present_node_options(node: DialogueNode) -> void:
	if node == null or not node.has_options():
		return
	
	# present the options to the player and wait for selection
	choice_presented.emit(node.options)
	current_state = DialogueState.WaitingForInput
	
	# 'on before option presented' 
	_run_option_presented_handlers(node, 
			func(h : DialogueOptionHandler) -> void : 
						h._on_before_options_presented(self, node))
	
	_update_options_container(node, node.options)

	# 'on after options presented' 
	_run_option_presented_handlers(node,  
			func(h : DialogueOptionHandler) -> void : 
						h._on_after_options_presented(self, node))


## This method is hooked to the buttons in the options container when pressed 
## Also, emits the choice_selected signal and runs any DialogueOptionHandlers that apply to the selected option.
func _handle_selected_option(node: DialogueNode, selected_option: DialogueOption) -> void:
	if selected_option == null:
		push_warning("Dialogue: attempt to select a null option")
		return
	
	choice_selected.emit(selected_option)

	_clear_options_container()

	# 'on after option selected'
	_run_option_selected_handlers(node, selected_option, 
			func(h : DialogueOptionHandler) -> void: 
						h._on_after_option_selected(self, node, selected_option))


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

func _run_option_presented_handlers(node: DialogueNode, callback: Callable) -> void:
	for child : Node in get_children():
		if not child is DialogueOptionHandler :
			continue
		var handler : DialogueOptionHandler = child as DialogueOptionHandler
		if not handler.applies_to(node.id) :
			continue
		for option : DialogueOption in node.options:
			if not handler.applies_to_option(option.id):
				continue
			callback.call(handler)

func _run_option_selected_handlers(node: DialogueNode, option_selected: DialogueOption, callback: Callable) -> void:
	for child : Node in get_children():
		if not child is DialogueOptionHandler :
			continue
		var handler : DialogueOptionHandler = child as DialogueOptionHandler
		if not handler.applies_to(node.id) or not handler.applies_to_option(option_selected.id):
			continue
		callback.call(handler)

func _clear_options_container() -> void:
	for child : Node in options_container.get_children():
		child.queue_free()

func _update_options_container(node: DialogueNode, options: Array[DialogueOption]) -> void:
	_clear_options_container()
	for option : DialogueOption in options:
		var button : Button = Button.new()
		button.text = option.text
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
	

func _get_slot_sprite(slot: String) -> Sprite2D:
	if not portrait_sprites.has(slot):
		if warn_on_missing_portrait:
			push_warning("Dialogue: slot '%s' has no sprite path configured." % slot)
		return null
	return get_node(portrait_sprites[slot]) as Sprite2D

func _get_slot_name_label(slot: String) -> RichTextLabel:
	if not portrait_labels.has(slot):
		if warn_on_missing_portrait:
			push_warning("Dialogue: slot '%s' has no name label path configured." % slot)
		return null
	return get_node(portrait_labels[slot]) as RichTextLabel

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


#region Editor / Tooling

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

func _get_character(speaker: String) -> CharacterDefinition:
	if StringUtils.is_null_or_empty(speaker):
		# no character dialog. eg: narrator. Not an error
		return null
	if not _character_lookup.has(speaker):
		if warn_on_missing_character:
			push_warning("Dialogue: speaker '%s' has no matching CharacterDefinition in this Dialogue instance" % speaker)
		return null
	return _character_lookup[speaker]

## This method resolves the name of the json file with the dialogue data to load. It uses the following priority:
## 1. If dialogue_source export variable is set, use that.
## 2. If dialogue_source export variable is empty, use the scene name (without extension) and append ".json". 
## 	 The file is then looked for in the DialogueConfig.json_base_path directory.
func _resolve_dialogue_source() -> String:
	if dialogue_source != "":
		return dialogue_source  # 1. explicit export always wins
	var scene_name : String = get_scene_file_path().get_file().get_basename()
	return DialogueConfig.json_base_path.path_join(scene_name + ".json")  # 3. naming-convention fallback

func _get_configuration_warnings() -> PackedStringArray: 
	var warnings : PackedStringArray = PackedStringArray()
	if dialogue_source == "":
		return warnings # no dialogue selected, nothing to check

	if not FileAccess.file_exists(dialogue_source):
		warnings.append("Dialogue: dialogue source file '%s' does not exist" % dialogue_source)
		return warnings

	if _graph == null:
		warnings.append("Dialogue: dialogue graph is null. Did you call load_dialogue_graph() first?")
	if _current_node == null:
		warnings.append("Dialogue: current node is null. Did you call _enter_node() first?")
	if _current_char == null and not StringUtils.is_null_or_empty(_current_node.speaker):
		warnings.append("Dialogue: current character is null, but the current node has a speaker. Did you call build_character_lookup() first?")
	return warnings
#endregion
