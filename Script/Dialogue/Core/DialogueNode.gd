# DialgueNode.gd - Represents a single node in a dialogue tree. 
# Each node is populated from the json files.
class_name DialogueNode extends RefCounted

var id : String  # Unique identifier for this dialogue node.
var speaker : String  # The name of the character speaking in this node.
var show_portrait : bool = true  # Whether to display the character's portrait during this dialogue node.
var text : String  # The dialogue text to be displayed for this node.
var emotion : String  # The emotion or expression of the character speaking in this node, used to select the appropriate portrait.
var sound : String  # The name of the sound effect to play when this node is displayed
var tags : Array[String] = []  # Optional tags for categorizing or filtering dialogue nodes.
var next_node_id : String  # The ID of the next dialogue node to transition to after this one.
var options : Array[DialogueOption] = []  # An array of DialogueOption objects representing the choices available to the player at this node.
var overrides : Dictionary = {}  # Optional dictionary of override settings for this node, such as text speed or font size.

func has_options() -> bool:
	return not options.is_empty()
