# DialogueOption.gd - Represents a prompt within a dialogue sequence that the player can select to branch the conversation. 
# Each option has a display text and a reference to the next dialogue node it leads to.
class_name DialogueOption extends RefCounted

var text: String  # The text displayed for this option in the dialogue UI.
var next_node_id: String  # The ID of the dialogue node that this option leads to when selected.
var action: String  # Optional identifier for an action that must be performed when this option is selected. If empty, no action is performed.
var condition: Callable  # Optional condition that must be met for this option to be available. If null, the option is always available.
