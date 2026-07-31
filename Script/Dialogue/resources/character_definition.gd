# CharacterSet.gd - 
# Represents the assets for a character (portraits, sounds, etc.) in the dialogue system.
# For each character in the game, there should be one CharacterDefinition resource that defines their visual and audio assets.
# Dialogue nodes can reference these CharacterDefinitions to display the correct portraits and play the correct sounds for each character.
class_name CharacterDefinition extends Resource

# name shown in the dialogue system
@export var character_name : String = ""

# dictionary of portraits for this character, keyed by emotion or expression (e.g., "happy", "sad", "angry")
@export var portraits : Dictionary[String, Texture2D] = {}

# default portrait to use if a specific emotion is not found
@export var default_portrait : Texture2D = null

# dictionary of sounds for this character, keyed by sound name (e.g., "greeting", "attack", "death")
@export var sounds : Dictionary[String, AudioStream] = {}

@export_category("Config Overrides")
# portrait path is read from DialogueConfig.gd. If this var is true, you can specific a path for this Set
@export var override_portraits_path : bool = false 
@export var portraits_path : String = "res://Assets/Portraits/"

# sounds path is read from DialogueConfig.gd. If this var is true, you can specific a path for this Set.
@export var override_sounds_path : bool = false
@export var sounds_path : String = "res://Assets/Sounds/"

# Validates the CharacterSet properties to prevent runtime errors.
func validate() -> bool:

	if character_name == "":
		push_error("CharacterSet must have a name.")
		return false

	if portraits.is_empty() :
		push_error("CharacterSet must have at least one portrait defined.")
		return false

#	if sounds.is_empty():
#		push_error("CharacterSet must have at least one sound defined.")
#		return false

	if override_portraits_path and portraits_path == "":
		push_error("CharacterSet has override_portraits_path enabled but portraits_path is empty.")
		return false

	if override_sounds_path and sounds_path == "":
		push_error("CharacterSet has override_sounds_path enabled but sounds_path is empty.")
		return false
	
	return true


func get_portrait(emotion: String) -> Texture2D:
	if portraits.has(emotion):
		return portraits[emotion]
	if default_portrait:
		if emotion != "":
			push_warning("CharacterSet '%s': emotion '%s' not found, using default_portrait" % [character_name, emotion])	
		return default_portrait
	push_error("CharacterSet '%s': no portrait for emotion '%s' and no default_portrait set" % [character_name, emotion])
	return null

func get_sound(id: String) -> AudioStream:
	return sounds.get(id, null)  # sounds are optional per node, no fallback needed

# hides the portraits_path and sounds_path properties in the Inspector if their corresponding override flags are false
func _validate_property(property: Dictionary) -> void:
	if property.name == "portraits_path" and not override_portraits_path:
		property.usage &= ~PROPERTY_USAGE_EDITOR
	if property.name == "sounds_path" and not override_sounds_path:
		property.usage &= ~PROPERTY_USAGE_EDITOR
