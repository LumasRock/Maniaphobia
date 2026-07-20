# DialogueLoader.gd - Loads dialogue graphs from JSON files and provides access to them.
class_name DialogueLoader extends Node 

const CORE_SCHEMA_KEYS : Array[String] = ["id", "speaker", "show_portrait", "text", "emotion", "sound", "tags", "next_node_id", "options", "overrides"]

func load_graph(path: String) -> DialogueGraph:

	var file : FileAccess = _get_file(path)
	if file == null: return null
	
	var json_data : Dictionary = _parse_file_as_dictionary(file)
	var graph : DialogueGraph = DialogueGraph.new()
	var raw_nodes : Array = json_data.get("nodes", [])

	graph.dialogue_id = json_data["dialogue_id"]	
	if json_data.has("start_node_id") : 
		graph.start_node_id = json_data["start_node_id"]
	else:
		graph.start_node_id = raw_nodes[0]["id"]
	
	var ordered_node_ids : Array[String] = []
	
	for i in raw_nodes.size():
		var node_data : Dictionary = raw_nodes[i]
		if not _validate_node_data(node_data):
			push_warning("DialogueLoader: invalid node data in '%s'" % path)
			continue
		var node : DialogueNode = _create_node_from_dictionary(node_data)
		if graph.nodes.has(node.id):
			push_warning("DialogueLoader: duplicate node ID '%s' in '%s'" % [node.id, path])
			continue
		graph.nodes[node.id] = node
		ordered_node_ids.append(node.id)
	
	graph.set_order(ordered_node_ids)
	return graph

# validates `path` and returns a FileAccess object if valid, or null if invalid
func _get_file(path: String) -> FileAccess:

	if path == null or path.is_empty(): 
		push_error("DialogueLoader: path is null or empty")
		return null

	if not FileAccess.file_exists(path):
		push_error("DialogueLoader: file does not exist '%s'" % path)
		return null

	var file : FileAccess = FileAccess.open(path, FileAccess.READ)
	
	if file == null:
		push_error("DialogueLoader: failed to open file '%s'" % path)
		return null
	
	return file

# Parses the JSON file and returns a Dictionary of the data, or an empty Dictionary if parsing fails
func _parse_file_as_dictionary(file: FileAccess) -> Dictionary:

	if file == null: return {}
	
	var json_text : String = file.get_as_text()
	file.close()
	
	var json_result : Variant = JSON.parse_string(json_text)
	if json_result == null or json_result.error != OK:
		push_error("DialogueLoader: failed to parse JSON in '%s': %s" % [file.get_path(), json_result.error_string])
		return {}
	
	return json_result.result

func _validate_dialogue_data(data: Dictionary) -> bool:
	if not data.has("dialogue_id") :
		push_error("DialogueLoader: missing 'dialogue_id' in dialogue data")
		return false
	if not data.has("nodes") or not data["nodes"] is Array or data["nodes"].is_empty():
		push_error("DialogueLoader: missing 'nodes' or empty array in dialogue data")
		return false
	return true
	
func _validate_node_data(node_data: Dictionary) -> bool:
	for key in CORE_SCHEMA_KEYS:
		if not node_data.has(key):
			push_error("DialogueLoader: node data missing required key '%s'" % key)
			return false
	return true
	
func _create_node_from_dictionary(node_data: Dictionary) -> DialogueNode:
	var node : DialogueNode = DialogueNode.new()
	node.id = node_data["id"]
	node.speaker = node_data["speaker"]
	node.show_portrait = node_data["show_portrait"]
	node.text = node_data["text"]
	node.emotion = node_data["emotion"]
	node.sound = node_data["sound"]
	node.tags.assign(node_data.get("tags", []))
	node.next_node_id = node_data["next_node_id"]
	node.options = []
	
	for option_data in node_data["options"]:
		var opt : DialogueOption = DialogueOption.new()
		opt.text = option_data["text"]
		opt.next_node_id = option_data["next_node_id"]
		opt.condition_id = option_data["condition_id"]
		node.options.append(opt)
	
	node.overrides = node_data["overrides"]
	
	return node
	
func _validate_graph_order(graph: DialogueGraph) -> bool:
	for node_id in graph.nodes.keys():
		var node : DialogueNode = graph.nodes[node_id]
		if node.next_node_id != "" and not graph.has_node(node.next_node_id):
			push_error("DialogueLoader: dialogue graph '%s' node '%s' next_node_id '%s' does not exist" % [graph.dialogue_id, node.id, node.next_node_id])
		for option in node.options:
			if option.next_node_id != "" and not graph.has_node(option.next_node_id):
				push_error("DialogueLoader: dialogue graph '%s' node '%s' option next_node_id '%s' does not exist" % [graph.dialogue_id, node.id, option.next_node_id])
	return true