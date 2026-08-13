@tool
extends Control
class_name DialogueSpeaker 
## Visual representation of a speaker in a dialogue. Speakers can be characters, npc or a narrator

enum SpeakerType {
	CHARACTER = 0, # considers both playable and NPCs 
	NARRATOR  = 1
}

## If 'CHARACTER', the script will check for the CharacterDefinition as well
@export var speaker_type : SpeakerType = SpeakerType.CHARACTER :
	set(value):
		speaker_type = value
		_on_speaker_type_changed()
		update_configuration_warnings()

## The name of the speaker. This is used to match the 'speaker' tag in the dialogue JSON files.
@export var speaker_name : String = ""

## Reference to the resource for the character. Mandatory field for speaker_type == Character. 
@export var character : CharacterDefinition :
	set(value):
		character = value
		_on_character_definition_changed()
		update_configuration_warnings()

@export_category("Portrait Settings")
## Reference to the Sprite2D to show the character's emotion image
@export var portrait_sprite : Sprite2D
## Reference to the RichTextLabel to print the character's name
@export var portrait_label  : RichTextLabel

#region PUBLIC API

func has_name(char_name : String) -> bool :
	if char_name.is_empty() : return false
	return speaker_name.to_lower() == char_name.to_lower()

func clear_portrait() -> void :
	portrait_sprite.texture = null
	portrait_label.text = ""

## Update the speaker's portrait to the image associated to [param emotion]. 
## You can specify the name in [param label_text]. By default, [member speaker_name] is used
func update_portrait(emotion : String, label_text : String = "") -> void:
	portrait_sprite.texture = character.get_portrait(emotion)
	if label_text.is_empty():
		portrait_label.text = speaker_name
	else:
		portrait_label.text = label_text

#endregion

#region INTERNALS

func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray = []
	
	if speaker_type == SpeakerType.CHARACTER :
		if character == null : 
			@warning_ignore("return_value_discarded")
			warnings.append("character definition is missing for speaker '%s'" % speaker_name)

		if portrait_sprite == null :
			@warning_ignore("return_value_discarded")
			warnings.append("portrait's Sprite2D node is missing for speaker '%s'" % speaker_name)
		
		if portrait_label == null :
			@warning_ignore("return_value_discarded")
			warnings.append("portrait's RichTextLabel node is missing for speaker '%s'" % speaker_name)

	if speaker_type == SpeakerType.NARRATOR :
		if not DialogueConfig.valid_narrator_names.has(speaker_name.to_lower()) :
			@warning_ignore("return_value_discarded")
			warnings.append("unexpected narrator name :'%s'. Expected values: %s" % 
					[speaker_name, ",".join(DialogueConfig.valid_narrator_names)])

	return warnings

func _on_speaker_type_changed() -> void:
	if speaker_type == SpeakerType.CHARACTER :
		if character != null :
			speaker_name = character.character_name
	if speaker_type == SpeakerType.NARRATOR :
		if not DialogueConfig.valid_narrator_names.has(speaker_name.to_lower()) :
			speaker_name = ""

func _on_character_definition_changed() -> void:
	if character != null :
		speaker_name = character.character_name
		if DialogueConfig.valid_narrator_names.has(speaker_name.to_lower()) :
			speaker_type = SpeakerType.NARRATOR
		else :
			speaker_type = SpeakerType.CHARACTER

#endregion