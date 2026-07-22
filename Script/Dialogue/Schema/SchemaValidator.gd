# SchemaValidator.gd - Validates a raw dictionary against a schema definition, checking for required fields and type correctness.
# Schema rules are defined in DialogueSchema.gd
class_name SchemaValidator

static func validate(raw: Dictionary, schema: Dictionary, context: String) -> Array[String]:
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
