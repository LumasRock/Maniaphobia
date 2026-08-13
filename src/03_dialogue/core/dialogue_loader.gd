class_name DialogueLoader 
extends Node 
## Reads, parses and loads JSON files as [DialogueGraph] objects.

var _json : JSON = JSON.new()

#region PUBLIC API

## Main func of this class: loads a dialogue graph from a JSON file at the given path 
## and returns a DialogueGraph object, or null if loading fails.
func load_graph(path: String) -> DialogueGraph:

	# Validate and clean the file path
	path = _clean_file_path(path)
	if path == "":
		return null

	# access and read the file
	var file : FileAccess = _get_file_access(path)
	if file == null: 
		return null

	# parse the JSON data into a dictionary
	var json_data : Dictionary = _parse_file_as_dictionary(file)
	if not _validate_dialogue_data(json_data):
		return null

	# begin constructing the DialogueGraph object
	var graph : DialogueGraph = DialogueGraph.new()
	var raw_nodes : Array = json_data.get("nodes", [])

	graph.dialogue_id = json_data["dialogue_id"]	
	if json_data.has("start_node_id") : 
		graph.start_node_id = json_data["start_node_id"]
	
	var ordered_node_ids : Array[String] = [] # we will store the order of nodes as they appear in the JSON file
	
	for i : int in raw_nodes.size():
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
	# assign first node, if start_node_id is not specified in the JSON
	if StringUtils.is_null_or_empty(graph.start_node_id):
		graph.start_node_id = ordered_node_ids[0]
	return graph

#endregion

#region File Access

## Checks the file name for compliance and ensures is an absolute path
func _clean_file_path(path: String) -> String:

	if StringUtils.is_null_or_empty(path):
		push_error("_clean_file_path: path is null or empty")
		return ""

	# 1. ensure file has absolute path to json file
	path = StringUtils.to_absolute_path(path)

		
	# 2. Validate filename format: alphanumeric, -, _ with .json extension
	var filename_regex : RegEx = RegEx.new()
	if filename_regex.compile("^.*/([a-zA-Z0-9_-]+\\.json)$") != OK:	
		push_error("_clean_file_path: failed to compile regex")
		return ""
	if not filename_regex.search(path):
		push_error("_clean_file_path: invalid filename '%s'. Use only alphanumeric, '-', '_' and '.json'" % path)
		return ""
	
	return path

## validates `path` and returns a FileAccess object if valid, or null if invalid
func _get_file_access(path: String) -> FileAccess:

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
#endregion

#region JSON Parsing and Validation

## Parses the JSON file and returns a Dictionary of the data, or an empty Dictionary if parsing fails
func _parse_file_as_dictionary(file: FileAccess) -> Dictionary:

	if file == null: return {}
	var json_text : String = file.get_as_text()
	file.close()
	
	var json_result : int = _json.parse(json_text)
	if json_result != OK :
		push_error("DialogueLoader: failed to parse JSON in '%s': %s" % [file.get_path(), _json.get_error_message()])
		return {}
	
	return _json.data

func _common_schema_validator(data: Dictionary, schema: Dictionary, context: String) -> bool:
	var errors : Array = SchemaValidator.validate_schema(data, schema, context)
	if not errors.is_empty():
		for e : String in errors:
			push_error("DialogueLoader: " + e)
		return false
	return true

func _validate_dialogue_data(data: Dictionary) -> bool:
	return _common_schema_validator(data, DialogueSchemas.GRAPH_FIELDS, 
			"dialogue '%s'" % data.get("dialogue_id", "?"))

func _validate_node_data(node_data: Dictionary) -> bool:
	return _common_schema_validator(node_data, DialogueSchemas.NODE_FIELDS, 
			"node '%s'" % node_data.get("id", "?"))

func _validate_option_data(option_data: Dictionary) -> bool:
	return _common_schema_validator(option_data, DialogueSchemas.OPTION_FIELDS, 
			"option '%s'" % option_data.get("id", "?"))

## Ensures the graph's node order is valid by checking that all next_node_id references point to existing nodes. 
## If validation is successful, return true. Otherwise, Logs errors and returns false.
func _validate_graph_order(graph: DialogueGraph) -> bool:
	for node_id : String in graph.nodes.keys():
		var node : DialogueNode = graph.nodes[node_id]
		if node.next_node_id != "" and not graph.has_node(node.next_node_id):
			push_error("DialogueLoader: dialogue graph '%s' node '%s' next_node_id '%s' does not exist" % [graph.dialogue_id, node.id, node.next_node_id])
		for option : DialogueOption in node.options:
			if option.next_node_id != "" and not graph.has_node(option.next_node_id):
				push_error("DialogueLoader: dialogue graph '%s' node '%s' option next_node_id '%s' does not exist" % [graph.dialogue_id, node.id, option.next_node_id])
	return true

#endregion

#region Node and Option Creation

func _create_node_from_dictionary(node_data: Dictionary) -> DialogueNode:
	var node : DialogueNode = DialogueNode.new()
	node.id = node_data["id"]
	var speaker : String = node_data.get("speaker", "")
	node.speaker = speaker
	node.show_portrait = node_data.get("show_portrait", DialogueConfig.default_show_portrait)
	node.text = node_data["text"]
	node.emotion = node_data.get("emotion", "")
	node.sound = node_data.get("sound", "")
	var tags : Array = node_data.get("tags", [])
	node.tags.assign(tags)
	node.next_node_id = node_data.get("next_node_id", "")
	node.options = []
	
	for option_data : Dictionary in node_data.get("options", []):
		if _validate_option_data(option_data):
			var option : DialogueOption = _create_option_from_dictionary(option_data)
			node.options.append(option)
		else:
			push_warning("DialogueLoader: invalid option data in node '%s'" % node.id)
	
	node.overrides = node_data.get("overrides", {})
	return node

func _create_option_from_dictionary(option_data: Dictionary) -> DialogueOption:
	var option : DialogueOption = DialogueOption.new()
	option.id = option_data.get("id", "")
	option.text = option_data.get("text", "")
	option.next_node_id = option_data.get("next_node_id", "")
	option.selected = false # default value; will be set to true if this option is chosen during dialogue
	return option

#endregion
