# DialogueGraph.gd - Represents a complete dialogue graph, which is a collection of interconnected DialogueNode objects.
# 
# Usage:
#
# var graph = DialogueLoader.load_graph("res://path/to/dialogue.json") 
# var current_node_id = graph.start_node_id  # Start at the beginning of the dialogue.
#
# while current_node_id != "":
#     var current_node = graph.get_node(current_node_id)  # Retrieve the current DialogueNode object.  
#	  # Display current_node.text, current_node.speaker, etc. in the dialogue UI.
#	  current_node_id = current_node.id  # Move to the next node in the dialogue sequence.
class_name DialogueGraph extends RefCounted

var dialogue_id : String  # Unique identifier for this dialogue graph.
var start_node_id : String  # The ID of the starting dialogue node in this graph.

var nodes : Dictionary[String, DialogueNode] = {}  # A dictionary mapping node IDs to DialogueNode objects, representing the nodes in this dialogue graph.
var _order : Array[String] = []  # An array of node IDs in the order they must be returned.
var _index : Dictionary[String, int] = {}  # A dictionary mapping node IDs to their index in the _order array.

func set_order(ids_in_file_order: Array[String]) -> void:
	_order = ids_in_file_order
	_index.clear()
	for i in _order.size():
		_index[_order[i]] = i

func get_node(node_id: String) -> DialogueNode:
	if nodes.has(node_id):
		return nodes[node_id]
	push_warning("DialogueGraph '%s': node ID '%s' not found" % [dialogue_id, node_id])
	return null
	
func has_node(node_id: String) -> bool:
	return nodes.has(node_id)
	
# Lazily resolves "what comes after this node" — nothing is precomputed on DialogueNode itself.
func get_next_id(current_id: String) -> String:
	if StringUtils.is_null_or_empty(current_id) :
		current_id = start_node_id
	
	var node := get_node(current_id)
	if node == null:
		return ""
	if node.has_options():
		return ""  # branching resolves via the chosen DialogueOption, not a linear "next"
	if node.next_node != "":
		return node.next_node  # explicit jump always wins
	var idx: int = _index.get(current_id, -1)
	if idx == -1 or idx >= _order.size() - 1:
		return ""  # last node, or an id outside this graph
	return _order[idx + 1]