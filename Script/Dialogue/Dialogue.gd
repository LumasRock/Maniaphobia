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
signal speaker_changed(slot: String, previous_speaker: String, new_speaker: String)

# Branching (within one Dialogue)
signal choice_presented(options: Array)
signal choice_selected(option: DialogueOption)

# Portraits
signal portrait_changed(slot: String, speaker: String, emotion: String, texture: Texture2D)


@export var dialogue_source: String = ""   # optional explicit override; see §6 for default resolution

@export_category("Settings")
@export var start_on_load: bool = false
@export var skippable: bool = true
@export var pausable: bool = true
# If true, the dialogue will automatically advance to the next node after the current one finishes displaying. If false, the player must manually advance the dialogue.
@export var auto_next: bool = false

@export_category("Characters")
@export var characters : Array[CharacterDefinition] = []

@export_tool_button("Sync Slot Dictionaries")
var sync_slots_action: Callable = _sync_slot_dictionaries

@export_category("Portrait Slots")
@export var slot_names: Array[String] = []
@export var slot_sprites: Dictionary[String, NodePath] = {}  # slot_name -> TextureRect node
@export var slot_name_labels: Dictionary[String, NodePath] = {}  # slot_name -> character_name

@export_category("Config Overrides")
@export var text_speed: float = -1.0       # -1 = "use DialogueConfig default"
@export var text_size: int = -1
@export var locale: String = ""


var _runtime_source_override : String

@onready var dialogue_loader : DialogueLoader = $DialogueLoader
@onready var dialogue_text : RichTextLabel = $DialogueText
@onready var options_container : BoxContainer = $OptionsContainer

var _character_lookup: Dictionary[String, CharacterDefinition] = {}  # character_name -> CharacterDefinition

func _ready() -> void:
	_build_character_lookup()

func _build_character_lookup() -> void:
	_character_lookup.clear()
	for c in characters:
		if c == null or not c.validate():
			push_warning("Dialogue: invalid CharacterDefinition in %s" % get_scene_file_path())
			continue
		_character_lookup[c.character_name] = c

func _sync_slot_dictionaries() -> void:
	for slot in slot_names:
		if slot == "":
			continue  # skip while the designer is mid-typing a new entry
		if not slot_sprites.has(slot):
			slot_sprites[slot] = NodePath()
		if not slot_name_labels.has(slot):
			slot_name_labels[slot] = NodePath()
	notify_property_list_changed()  # forces the Inspector to redraw and show the new empty entries

func _get_character(speaker: String) -> CharacterDefinition:
	if not _character_lookup.has(speaker):
		push_error("Dialogue: speaker '%s' has no matching CharacterDefinition in this Dialogue instance" % speaker)
		return null
	return _character_lookup[speaker]

func _get_slot_sprite(slot: String) -> Sprite2D:
	if not slot_sprites.has(slot):
		push_error("Dialogue: slot '%s' has no sprite path configured." % slot)
		return null
	return get_node(slot_sprites[slot]) as Sprite2D

func _get_slot_name_label(slot: String) -> Label:
	if not slot_name_labels.has(slot):
		push_error("Dialogue: slot '%s' has no name label path configured." % slot)
		return null
	return get_node(slot_name_labels[slot]) as Label

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _resolve_dialogue_source() -> String:
	if dialogue_source != "":
		return dialogue_source  # 1. explicit export always wins
	if _runtime_source_override != "":
		return _runtime_source_override  # 2. set from code at runtime
	var scene_name := get_scene_file_path().get_file().get_basename()
	return DialogueConfig.json_base_path.path_join(scene_name + ".json")  # 3. naming-convention fallback
