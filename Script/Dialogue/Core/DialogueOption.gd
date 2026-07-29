# DialogueOption.gd - Represents a prompt within a dialogue sequence that the player can select to branch the conversation. 
# Each option has a display text and a reference to the next dialogue node it leads to.
class_name DialogueOption extends RefCounted

var id: String  # Unique identifier for this dialogue option. Used to reference the option in handlers and conditions.
var text: String  # The text displayed for this option in the dialogue UI.
var next_node_id: String  # The ID of the dialogue node that this option leads to when selected.
var selected : bool = false # Indicates whether this option has been selected by the player. This is set to true when the option is chosen, and can be used to track player choices in the dialogue flow.