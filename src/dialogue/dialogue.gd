extends Control
class_name Dialogue

@onready var full_body_sprite = $FullBodySprite
@onready var character = $CharacterName
@onready var TypingTimer = $TypingTimer
@onready var content = $Content
@onready var options_container = $Options
@onready var dialogue_camera = $Camera2D
@export_file("*.json") var json_file: String
@export var pause_game_during_dialogue := true

var dialogues = {}	# stores all dialogue sets by dialogue_id
var node_dict = {}	# current scene's nodes keyed by ID
var current_node = {}	# currently active node
var full_text = ""
var visible_characters = 0
var awaiting_option_selection = false
var displayed_option_node_id = ""
var paused_game_for_dialogue = false
# icons
# "res://src/dialogue/Icons.gd"
const npc_icons = preload("uid://d5cnies00afl").npc_icons
func _ready():
	connect("visibility_changed", _on_visibility_changed)
	load_dialogues(json_file)
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	if TypingTimer:
		TypingTimer.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	if self:
		self.visible = false

# this is the parser code which loads the json file into a dictionary for easy access
#you can get a better definition of what a parser is here -> https://www.techtarget.com/searchapparchitecture/definition/parser
func load_dialogues(file_path: String):
	if not FileAccess.file_exists(file_path):
		print("Dialogue file not found")
		return

	var json_text = FileAccess.get_file_as_string(file_path)
	var data = JSON.parse_string(json_text)
	if not data:
		print("Failed to parse JSON")
		return

	# data should be an array of dialogue sets
	#an array in a dictionary is like a word with its list of definitions below it.
	#like a actual dictionary would havve
	for dialogue_set in data:
		var dialogue_id = dialogue_set["dialogue_id"]
		var tmp_node_dict = {}
		for node in dialogue_set["nodes"]:
			tmp_node_dict[node["id"]] = node
		dialogues[dialogue_id] = tmp_node_dict

# start a dialogue set by the scene name and matching id
func start_scene_dialogue(dialogue_id: String):
	if dialogues.has(dialogue_id):
		node_dict = dialogues[dialogue_id]
		if node_dict.has("1"):
			current_node = node_dict["1"]
			start_typing(current_node["text"])
		else:
			print("No node with ID '1' in dialogue", dialogue_id)
	else:
		
		print("No dialogue with ID:", dialogue_id)

# typing animation for dialogue
func start_typing(text):
	clear_options()
	awaiting_option_selection = false
	displayed_option_node_id = ""
	full_text = text
	content.text = full_text
	content.visible_characters = 0

	if current_node.has("speaker"):
		character.text = current_node["speaker"]
	
	var speaker_name = current_node.get("speaker", "")
	var emotion = str(current_node.get("emotion", "neutral")).to_lower()
	if npc_icons.has(speaker_name) and npc_icons[speaker_name].has(emotion):
		var portrait_set: Dictionary = npc_icons[speaker_name][emotion]
		full_body_sprite.texture = portrait_set.get("body", portrait_set.get("icon"))
	else:
		print("Portrait not found — speaker: '%s', emotion: '%s'" % [speaker_name, emotion])

	TypingTimer.start()
#this stops the typing when it is done
func _on_typing_timer_timeout():
	if content.visible_characters < full_text.length():
		content.visible_characters += 1
	else:
		TypingTimer.stop()
		if current_node.has("options") and not awaiting_option_selection:
			show_options(current_node["options"])
#this is for different scenes when the dialogue needs a signal to actually play
func is_active() -> bool:
	return self.visible

func is_playing() -> bool:
	return self.visible

# input handling
func _process(_delta):
	if not is_active():
		return
	if Input.is_action_just_pressed("accept"):
		if content.visible_characters < full_text.length():
			content.visible_characters = full_text.length()
			TypingTimer.stop()
			if current_node.has("options") and not awaiting_option_selection:
				show_options(current_node["options"])
		elif awaiting_option_selection:
			return
		else:
			play_next_node()

# go to next dialogue node
func play_next_node():
	if current_node.has("next_node"):
		var next_id = current_node["next_node"]
		if node_dict.has(next_id):
			current_node = node_dict[next_id]
			start_typing(current_node["text"])
			return
	stop()

func clear_options():
	for child in options_container.get_children():
		if child is Control:
			(child as Control).release_focus()
		child.queue_free()
	options_container.visible = false

func show_options(options: Array):
	var node_id = str(current_node.get("id", ""))
	if displayed_option_node_id == node_id and options_container.get_child_count() > 0:
		return

	clear_options()
	awaiting_option_selection = true
	displayed_option_node_id = node_id

	for option_data in options:
		var option_button := Button.new()
		option_button.text = option_data.get("text", "Continue")
		option_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		option_button.pressed.connect(_on_option_selected.bind(option_data))
		options_container.add_child(option_button)

	options_container.visible = true
	if options_container.get_child_count() > 0:
		(options_container.get_child(0) as Button).grab_focus()

func _on_option_selected(option_data: Dictionary):
	awaiting_option_selection = false
	displayed_option_node_id = ""
	var next_id = option_data.get("next_node", "")
	clear_options()

	if next_id != "" and node_dict.has(next_id):
		current_node = node_dict[next_id]
		start_typing(current_node["text"])
		return

	stop()

func play(dialogue_id: String, node_id: String = "1"):
	print("play dialogue")
	if not dialogues.has(dialogue_id):
		print("No dialogue with ID:", dialogue_id)
		return

	if pause_game_during_dialogue and not get_tree().paused:
		get_tree().paused = true
		paused_game_for_dialogue = true

	self.visible = true
	node_dict = dialogues[dialogue_id]
	
	if node_dict.has(node_id):
		current_node = node_dict[node_id]
		start_typing(current_node["text"])
	else:
		print("No node with ID '1' in dialogue", dialogue_id)
		stop()

func stop():
	TypingTimer.stop()
	awaiting_option_selection = false
	displayed_option_node_id = ""
	clear_options()
	self.visible = false

	if paused_game_for_dialogue:
		get_tree().paused = false
		paused_game_for_dialogue = false

func _on_visibility_changed() -> void:
	if visible:
		EventBus.set_camera(dialogue_camera)
	else:
		var player = get_tree().get_first_node_in_group("player")
		if player:
			EventBus.set_camera(player.get_node("Camera2D"))
