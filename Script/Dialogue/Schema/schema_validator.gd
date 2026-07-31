# SchemaValidator.gd - Validates a raw dictionary against a schema definition, checking for required fields and type correctness.
# Schema rules are defined in DialogueSchema.gd
class_name SchemaValidator


# This method checks if the JSON specified in 'file_path' is a valid JSON file and is parsable, 
# or returns an array of error messages if invalid
# See 'validate_schema' for schema validation
static func validate_json_parsing(file_path: String) -> Array[String]:
	var file : FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		return ["Failed to open file: %s" % file_path]
	var json : JSON = JSON.new()
	var json_result : int = json.parse(file.get_as_text())
	if json_result != OK:
		return ["Failed to parse JSON in '%s': %s" % [file_path, json.get_error_message()]]
	return []

# This method validates a raw dictionary against a schema definition, checking for required fields and type correctness.
# For schemas see DialogueSchema.gd
static func validate_schema(raw: Dictionary, schema: Dictionary, context: String) -> Array[String]:
	var errors: Array[String] = []
	for key : String in schema.keys():

		var rule: Dictionary = schema[key]
		var default_value : Variant = rule.get("default", null)
		# validate required fields
		if rule.get("required", false) and not raw.has(key):
			errors.append("%s: missing required field '%s'" % [context, key])
			continue
		
		if raw.has(key):
			# prevent null values from being assigned if a default value is provided
			if raw[key] == null and default_value != null:
				raw[key] = default_value

			var raw_value : Variant = raw.get(key, default_value)

			var expected: int = rule.get("type", TYPE_NIL)
			if typeof(raw_value) != expected:
				errors.append("%s: field '%s' expected %s, got %s" % [
					context, key, type_string(expected), type_string(typeof(raw_value))
				])
		else :
			# If the field is not present, assign the default value if it exists
			if default_value != null:
				raw[key] = default_value

	return errors

static func validate_schema_key(raw:Dictionary, key: String,  rule: Dictionary, errors: Array[String], context: String) -> Array[String]:

	var default_value : Variant = rule.get("default", null)
	# validate required fields
	if rule.get("required", false) and not raw.has(key):
		errors.append("%s: missing required field '%s'" % [context, key])
	
	if raw.has(key):
		var raw_value : Variant = raw.get(key, default_value)
		if raw_value == null :
			raw_value = default_value

		var expected: int = rule.get("type", TYPE_NIL)
		if typeof(raw_value) != expected:
			errors.append("%s: field '%s' expected %s, got %s" % [
				context, key, type_string(expected), type_string(typeof(raw_value))
			])

	return errors
