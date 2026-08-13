# StringUtils.gd - Provides utility functions for string manipulation and validation.
class_name StringUtils

static func is_null_or_empty(s: String) -> bool:
	return s == null or s.is_empty()
	
static func is_null_or_whitespace(s: String) -> bool:
	return s == null or s.strip_edges() == ""

static func to_absolute_path(relative_path : String) -> String :
	if relative_path.is_relative_path():
		return ProjectSettings.globalize_path(relative_path)
	else:
		return relative_path
	
static func pad(s: String, length: int, pad_char: String = " ", pad_left: bool = false) -> String:
	if s == null:
		s = ""
	while s.length() < length:
		if pad_left:
			s = pad_char + s
		else:
			s += pad_char
	return s
