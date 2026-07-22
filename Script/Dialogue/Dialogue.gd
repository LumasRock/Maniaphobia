# Dialogue.gd - This script manages the Dialogue.tscn packed scene, which is the main UI for displaying dialogue in the game. 
# It handles loading dialogue data, managing character definitions, and emitting signals for various dialogue events.
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
signal portrait_changed(previous_portrait: String, previous_emotion: String, new_portrait: String, new_emotion: String)

@export_file("*.json") var dialogue_source: String = ""   # optional explicit override; see §6 for default resolutionon

@export_category("Settings")
@export var start_on_load: bool = false
@export var skippable: bool = true
@export var pausable: bool = true
# If true, the dialogue will automatically advance to the next node after the current one finishes displaying. If false, the player must manually advance the dialogue.
@export var auto_next: bool = false

@export_category("Characters")
@export var characters : Array[CharacterDefinition] = []

@export_category("Portraits")
@export var portrait_names: Array[String] = [] # list of portraits names for speakers (e.g. "left", "center", "right")
@export var portrait_sprites: Dictionary[String, NodePath] = {}  # portrait_name -> TextureRect node
@export var portrait_labels: Dictionary[String, NodePath] = {}  # portrait_name -> RichTextLabel node
@export var portrait_character : Dictionary[String, String] = {}  # portrait_name -> character_name

@export_tool_button("Sync Slot Dictionaries", "PlaceholderTexture2D")
var sync_slots_action: Callable = _sync_slot_dictionaries

@export_category("Config Overrides")
@export var text_speed: float = -1.0       # -1 = "use DialogueConfig default"
@export var text_size: int = -1
@export var locale: String = ""

@onready var dialogue_text : RichTextLabel = $DialogueText
@onready var options_container : BoxContainer = $OptionsContainer

var _graph : DialogueGraph
var _current_node : DialogueNode
var _current_char : CharacterDefinition
var _current_portrait : String
var _current_portrait_sprite : Sprite2D
var _current_portrait_label : RichTextLabel
var _portraits : Dictionary = {}  # slot_name -> {Sprite2D, RichTextLabel}

enum DialogueState {
	Idle,
	Typing,
	WaitingForInput, # used for both player to advance and for waiting for a choice selection
	Paused,
	Finished
}
var _state : DialogueState = DialogueState.Idle

var _character_lookup: Dictionary[String, CharacterDefinition] = {}  # character_name -> CharacterDefinition
var _dialogue_loader : DialogueLoader

func _ready() -> void:

	# cache the dialogue files and build the character lookup table
	# these are required to setup the dialogue graph and character portraits correctly
	_dialogue_loader = DialogueLoader.new()
	dialogue_text.bbcode_enabled = true
	build_character_lookup()
	initialize_portraits()
	# auto-start if configured to do so, but only in the game, not in the editor
	if not Engine.is_editor_hint() and start_on_load:
		load_dialogue_graph()
		start()

func _unhandled_input(event: InputEvent) -> void:
	# Pause/Unpause the dialogue if pausable is true. This allows the player to pause the dialogue and resume it later.
	if event.is_action_pressed("Pause") and pausable:
		toggle_pause()

	if _state == DialogueState.WaitingForInput:
		# accept is to select an option
		if event.is_action_pressed("accept") and _current_node.has_options():
			handle_option_selection()

		# continue is to advance the dialogue to the next node		
		if event.is_action_pressed("continue"):
			if not _move_next_node():
				finish()

func _process(delta: float) -> void:
	if _graph == null or _current_node == null:
		return

	# TODO : implement text speed and typing effect here
	_state = DialogueState.Typing
	dialogue_text.text = _current_node.text
	_state = DialogueState.WaitingForInput


#############################
## Ready / Initialization
#############################

func initialize_portraits() -> void:
	_portraits.clear()
	for slot_name : String in portrait_names:
		var sprite : Sprite2D = _get_slot_sprite(slot_name)
		var name_label : RichTextLabel = _get_slot_name_label(slot_name)
		if sprite == null or name_label == null:
			push_warning("Dialogue: slot '%s' is missing a Sprite2D or RichTextLabel node" % slot_name)
			continue
		_portraits[slot_name] = {"sprite": sprite, "name_label": name_label}
		sprite.texture = null
		name_label.text = ""

func build_character_lookup() -> void:
	_character_lookup.clear()
	for c : CharacterDefinition in characters:
		if c == null or not c.validate():
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

#############################
## Dialogue Lifecycle
#############################

func start() -> void:
	if _graph == null :
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
	_state = DialogueState.Finished
	_graph = null
	dialogue_finished.emit(id)

func toggle_pause() -> void:
	if not pausable:
		push_warning("Dialogue: attempt to pause a non-pausable dialogue")
		return
	if _state == DialogueState.Paused:
		_state = DialogueState.WaitingForInput
		dialogue_resumed.emit()
	else :
		_state = DialogueState.Paused
		dialogue_paused.emit()

func handle_option_selection() -> void:
	if _current_node == null or not _current_node.has_options():
		push_warning("Dialogue: attempt to select an option when there are no options available")
		return
	# TODO For now, we just select the first option.
	var selected_option : DialogueOption = _current_node.options[0]
	choice_selected.emit(selected_option)
	# TODO implement condition callable
	_move_to_node(selected_option.next_node_id)

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

	_state = DialogueState.Typing
	node_entered.emit(_current_node)


# moves the node index forward by one, and enters the next node. 
# Returns true if successful, false if there is no next node.
func _move_next_node() -> bool:
	if _current_node == null:
		push_warning("Dialogue: attempt to move to next node from a null node. Did you call _enter_node() first?")
		return false
	# we use the graph to resolve the next node id, 
	# because it handles branching and explicit next_node jumps.
	var next_id: String = _graph.get_next_id(_current_node.id)
	if StringUtils.is_null_or_empty(next_id):
		return false
	_enter_node(next_id)
	return true

func _move_to_node(node_id: String) -> void:
	if not _graph.has_node(node_id):
		push_error("Dialogue: node '%s' does not exist in graph '%s'" % [node_id, _graph.dialogue_id])
		return
	_enter_node(node_id)

func _exit_node() -> void:
	if _current_node == null:
		push_warning("Dialogue: attempt to exit a null node. Did you call _enter_node() first?")
		return
	_state = DialogueState.Idle
	node_exited.emit(_current_node)

# Applies the changes between the previous node and the new node, 
# including updating the portrait and emitting signals for speaker and portrait changes.
func _apply_node_changes(previous_node: DialogueNode, new_node: DialogueNode, previous_char: CharacterDefinition, new_char: CharacterDefinition) -> void:
	if previous_node == null or new_node == null: 
		return

	var new_portrait : String = ""
	if not StringUtils.is_null_or_empty(new_node.speaker):
		new_portrait = portrait_character.find_key(new_node.speaker.to_lower())
		if StringUtils.is_null_or_empty(new_portrait):
			push_error("Dialogue: speaker '%s' has no portrait assigned in portrait_character" % new_node.speaker)
			return
	var previous_portrait : String = _current_portrait
	
	_clear_portrait(previous_portrait)

	# check if speaker changed
	if previous_node.speaker != new_node.speaker:			
		speaker_changed.emit(previous_node.speaker, new_node.speaker)
	# check if portrait slot or emotion changed
	if previous_portrait != new_portrait or previous_node.emotion != new_node.emotion:
		portrait_changed.emit(previous_portrait, previous_node.emotion, new_portrait, new_node.emotion)

	_current_portrait = new_portrait
	_update_portrait(new_portrait, new_node, new_char)


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
		push_error("Dialogue: slot '%s' has no sprite path configured." % slot)
		return null
	return get_node(portrait_sprites[slot]) as Sprite2D

func _get_slot_name_label(slot: String) -> RichTextLabel:
	if not portrait_labels.has(slot):
		push_error("Dialogue: slot '%s' has no name label path configured." % slot)
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

#############################
## Editor / Tooling
#############################

# For each slot name, ensure that the slot_sprites, slot_name_labels, and slot_character dictionaries have an entry. If not, create an empty entry.
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
		push_error("Dialogue: speaker '%s' has no matching CharacterDefinition in this Dialogue instance" % speaker)
		return null
	return _character_lookup[speaker]

# This method resolves the name of the json file with the dialogue data to load. It uses the following priority:
# 1. If dialogue_source export variable is set, use that.
# 2. If dialogue_source export variable is empty, use the scene name (without extension) and append ".json". 
# 	 The file is then looked for in the DialogueConfig.json_base_path directory.
func _resolve_dialogue_source() -> String:
	if dialogue_source != "":
		return dialogue_source  # 1. explicit export always wins
	var scene_name : String = get_scene_file_path().get_file().get_basename()
	return DialogueConfig.json_base_path.path_join(scene_name + ".json")  # 3. naming-convention fallback
