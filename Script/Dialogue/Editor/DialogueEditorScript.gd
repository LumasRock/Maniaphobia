@tool
extends EditorScript

func _run() -> void:

	_log("[b]Dialogue Validation started...[/b]\n")
	var dir : String = DialogueConfig.json_base_path 
	var files_count : int = 0
	var error_files_count : int = 0

	for file_name : String in DirAccess.get_files_at(dir):

		if not file_name.ends_with(".json"):
			continue
		files_count += 1
		var file_path : String = dir + file_name

		_log("File: %s" % file_path)
		if _validate_dialogue_load(file_path):
			_log_success("Dialogue loaded successfully", 1)
		else:
			error_files_count += 1

	_log("\n[b]Dialogue Validation completed[/b]")
	_log("[b]Total files : %d[/b]" % files_count, 1)
	if error_files_count == 0:
		_log_success("[b]All files successfully validated[/b]",1)
	else:
		_log("[b][color=red]Failed files: %d [/color][/b]" % error_files_count,1)
	
# This method replicates the validation logic in DialogueLoader, logging for errors and success messages
# Returns true if validation is successful, false otherwise
func _validate_dialogue_load(file_path: String) -> bool:
	var loader : DialogueLoader = DialogueLoader.new()
	
	# access and read the file
	var file : FileAccess = loader._get_file(file_path)
	if file == null: 
		_log_error("Dialogue load failed to open file: %s" % file_path, 1)
		return false

	# parse the JSON data into a dictionary
	var json_data : Dictionary = loader._parse_file_as_dictionary(file)
	if not loader._validate_dialogue_data(json_data):
		_log_error("Dialogue load failed to validate json data", 1)
		return false

	var graph_data : DialogueGraph = loader.load_graph(file_path)
	if graph_data == null:
		_log_error("Dialogue load failed to create dialogue graph", 1)
		return false

	return true

func _log_error(message: String, indent: int = 0) -> void:
	var indent_prefix : String = "[indent]".repeat(indent)
	var indent_suffix : String = "[/indent]".repeat(indent)
	print_rich("%s[color=red]Error: %s[/color]%s" % [indent_prefix, message, indent_suffix])
	
func _log_success(message: String, indent: int = 0) -> void:
	var indent_prefix : String = "[indent]".repeat(indent)
	var indent_suffix : String = "[/indent]".repeat(indent)
	print_rich("%s[color=green]%s[/color]%s" % [indent_prefix, message, indent_suffix])
	
func _log(message: String, indent: int = 0) -> void:
	var indent_prefix : String = "[indent]".repeat(indent)
	var indent_suffix : String = "[/indent]".repeat(indent)
	print_rich("%s%s%s" % [indent_prefix, message, indent_suffix])
