class_name CharacterDefinition 
extends Resource
## This resource defines a character's name, emotions and sounds used in the dialogue system.[br]
## For each character in the game, there should be - at least - one [CharacterDefinition] resource.
## [Dialogue] reads [CharacterDefinition] resources to display the names, images, and play the correct sounds during a dialogue.

@export_category("Character Info")
## name shown in the dialogue UI for this character
@export var character_name : String = ""
## dictionary of portraits for this character, keyed by emotion or expression (e.g., "happy", "sad", "angry")
@export var portraits : Dictionary[String, Texture2D] = {}
## default portrait to use if a specific emotion is not found
@export var default_portrait : Texture2D = null
## dictionary of sounds for this character, keyed by sound name (e.g., "greeting", "attack", "death")
@export var sounds : Dictionary[String, AudioStream] = {}

@export_category("Config Overrides")
## portrait path is read from [DialogueConfig] autoload. If this var is true, the portrait images are obtaines from [member portraits_path]
@export var override_portraits_path : bool = false 
## path to the portrait images for this character, used if [member override_portraits_path] is true
@export var portraits_path : String = "res://Assets/sprites/portraits/"
## sounds path is read from [DialogueConfig] autoload. If this var is true, the sounds are obtained from [member sounds_path]
@export var override_sounds_path : bool = false
## path to the sounds for this character, used if [member override_sounds_path] is true
@export var sounds_path : String = "res://Assets/sfx/"

## Validates this resource has the necessary properties to prevent runtime errors: 
## [member character_name] is not empty, [member portraits] has at least one entry, and if [member override_portraits_path] or [member override_sounds_path] are true, their corresponding paths are not empty.
func validate() -> bool:

	if character_name == "":
		push_error("CharacterDefinition must have a name.")
		return false

	if portraits.is_empty() :
		push_error("CharacterDefinition must have at least one portrait defined.")
		return false

#	if sounds.is_empty():
#		push_error("CharacterSet must have at least one sound defined.")
#		return false

	if override_portraits_path and portraits_path == "":
		push_error("CharacterDefinition has override_portraits_path enabled but portraits_path is empty.")
		return false

	if override_sounds_path and sounds_path == "":
		push_error("CharacterDefinition has override_sounds_path enabled but sounds_path is empty.")
		return false
	
	return true

## Returns the portrait image for the given emotion. If the emotion is not found, returns the [member default_portrait].
func get_portrait(emotion: String) -> Texture2D:
	if emotion != "":
		return portraits[emotion] if portraits.has(emotion) else default_portrait
	else :
		return default_portrait

func get_sound(id: String) -> AudioStream:
	return sounds.get(id, null)  # sounds are optional per node, no fallback needed

# hides the portraits_path and sounds_path properties in the Inspector if their corresponding override flags are false
func _validate_property(property: Dictionary) -> void:
	if property.name == "portraits_path" and not override_portraits_path:
		property.usage &= ~PROPERTY_USAGE_EDITOR
	if property.name == "sounds_path" and not override_sounds_path:
		property.usage &= ~PROPERTY_USAGE_EDITOR
