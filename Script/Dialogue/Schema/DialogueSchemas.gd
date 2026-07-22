# DialogueNodeSchema.gd - Defines the schema for a dialogue node, specifying required fields, their types, and default values. 
# This schema is used to validate dialogue data loaded from JSON files.
class_name DialogueSchemas

const GRAPH_FIELDS : Dictionary = {
	"dialogue_id":   {"required": true,  "type": TYPE_STRING},
	"start_node_id": {"required": false, "type": TYPE_STRING, "default": ""},
	"nodes":         {"required": true,  "type": TYPE_ARRAY},
}

const NODE_FIELDS : Dictionary = {
	"id":            {"required": true,  "type": TYPE_STRING},
	"speaker":       {"required": false, "type": TYPE_STRING, "default": ""},
	"show_portrait": {"required": false, "type": TYPE_BOOL,   "default": true},
	"text":          {"required": true,  "type": TYPE_STRING},
	"emotion":       {"required": false, "type": TYPE_STRING, "default": ""},
	"sound":         {"required": false, "type": TYPE_STRING, "default": ""},
	"tags":          {"required": false, "type": TYPE_ARRAY,  "default": []},
	"next_node_id":  {"required": false, "type": TYPE_STRING, "default": ""},
	"options":       {"required": false, "type": TYPE_ARRAY,  "default": []},
	"slot":          {"required": false, "type": TYPE_STRING, "default": ""},
}
