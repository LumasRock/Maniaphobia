class_name BaseLevel
extends Node2D
## 
## This is a base class for levels. Provides common access to the camera, player, and transitioning to scenes.
##
## This is a base class for levels. Provides common access to the camera, player, and transitioning to scenes.
## Levels are expected to extend this class and override the methods:
## - [method get_default_spawn_point] 
## - [method load_level] 
## - [method unload_level]
## 
## To add custom logic load and unload workflow, is recommended to use the signals:
## - [signal before_level_loaded] 
## - [signal after_level_loaded] 
## - [signal before_level_unloaded] 
## BaseLevel can define a default dialogue to load as soon as the level is loaded. [br]
## Also, has methods to add and find Dialogue node instances in runtime. 


signal before_level_loaded(scene_name: String)
signal after_level_loaded(scene_name: String)
signal before_level_unloaded(scene_name: String)

const DIALOGUE_SCENE: PackedScene = preload("res://src/03_dialogue/scenes/Dialogue.tscn")
const DIALOGUE_GROUP: StringName  = &"level_dialogues"

## Defines the states of a level to determine if the level is ready to run gameplay or not
enum LevelStates {
	INACTIVE  = 0,	# default state
	STARTED   = 1, 	# when `_ready()` begins
	LOADED    = 2, 	# after `load_level()` runs
	UNLOADING = 3		# when `unload_level()` begins
}

@export_category("Transitions")
## if true, the level will wait until all transition effects are complete before begin loading
@export var load_scene_after_transitioning       : bool = true
## name of the next scene. This is useful if you have a sequence of scenes that make an entire level
@export_file("*.tscn") var next_scene      : String 
## duration in in seconds of the transition to next_scene
@export var transition_time                      : float = 0.2

@export_category("Default Dialogue")
## if provided, the level will automatically load and add to the tree this dialogue
@export var default_dialogue                     : Dialogue
## if provided, this node will be the parent for Dialogues programmatically added to the level. If empty, the parent will be the level root node
@export var dialogues_parent                     : Node2D 

var player           : Player 
var current_state    : LevelStates = LevelStates.INACTIVE

func _ready() -> void:
	if load_scene_after_transitioning :
		if Transition.is_transitioning :
			await Transition.fade_out_finished

	current_state = LevelStates.STARTED
	before_level_loaded.emit(get_scene_file_path())
	
	load_level()
	
	current_state = LevelStates.LOADED
	after_level_loaded.emit(get_scene_file_path())
	
	_init_default_dialogue()
	if default_dialogue.start_on_load :
			default_dialogue.start()

func _exit_tree() -> void :
	if current_state == LevelStates.UNLOADING:
		return
	current_state = LevelStates.UNLOADING
	before_level_unloaded.emit(get_scene_file_path())
	unload_level()

#region VIRTUAL METHODS

## Override this method to return the default spawn position of the player
func get_default_spawn_point() -> Vector2 : 
	return Vector2.ZERO

## Override this method  with the level loading logic. This is where you load the level objects. 
## This methods runs during `_ready()`
func load_level() -> void :
	pass

## Override this method with the logic when the level is unloaded. This is where you will free resources, or reset global values
## This method is called on `_exit_tree()`
func unload_level() -> void :
	pass

#endregion

#region SCENE PUBLIC API

## Returns the camera assigned to the player. If not found, returns the EventBus active camera
func get_player_camera() -> Camera2D :
	if player != null :
		return player.camera
	else :
		return EventBus.get_active_camera()

## Adds a Dialogue to this level node tree.
## - [param json_path] is the path to the json file with the dialogue. [br]
## - [param start_on_load] (optional) if true, the dialogue will start once added to the level
## - [param parent] (optional) the parent for this new Dialogue. If absent, this method will use [member dialogues_parent] or itself 
## returns the newly added Dialogue instance
func add_dialogue_to_level(json_path: String, start_on_load: bool = false, parent: Node = null) -> Dialogue:
	if StringUtils.is_null_or_empty(json_path):
		push_error("BaseLevel: json_path is empty")
		return null

	var parent_node       : Node = parent if parent != null else (dialogues_parent if dialogues_parent != null else self)
	var dialogue_instance : Dialogue = _dialogue_instance(json_path, start_on_load)

	parent_node.add_child(dialogue_instance)
	dialogue_instance.add_to_group(DIALOGUE_GROUP)
	return dialogue_instance

## Returns all the dialogues present in this level
func get_dialogues() -> Array[Dialogue] :
	var result: Array[Dialogue] = []
	for node: Node in get_tree().get_nodes_in_group(DIALOGUE_GROUP):
		if node is Dialogue and is_ancestor_of(node):
			result.append(node)
	return result

## Returns the first Dialogue node named [param _name]. Returns null if none is found
func get_dialogue_by_name(_name: String) -> Dialogue : 
	for dialogue: Dialogue in get_dialogues() :
		if dialogue.name == _name : 
			return dialogue
	return null

## Returns the first Dialogue with id [param _id]. Returns null if none if found
func get_dialogue_by_id(_id: String) -> Dialogue :
	for dialogue: Dialogue in get_dialogues() :
		if dialogue.get_dialogue_id() == _id :
			return dialogue
	return null

## If [member next_scene] is defined, unloads this level and transitions to the new scene
func move_to_next_scene() -> void :
	if next_scene != "" :
		Transition.transition_to(next_scene,transition_time )
	else :
		push_warning("BaseLevel: next_scene is empty, cannot move to next scene.")

#endregion 

#region PRIVATE METHODS

## Inner function to setup the default_dialogue, if any. 
## This method is called after 'load_scene'. 
## If the dialogue has `start_on_load = true`, `default_dialogue.start()` is called as soon as this method returns
## 
## You can override this method to customize the setup of the dialogue this way:
## [codeblock]
## 	func _init_default_dialogue() -> void :
## 		super._init_default_dialogue() # this ensures the dialogue json is loaded
## 		# do your custom setup here
## 
func _init_default_dialogue() -> void :
	if default_dialogue != null :
		default_dialogue.load_dialogue()


## Inner function to create a Dialogue instance.
## If you want to extend the dialogue setup, override this method this way:
## [codeblock]
## 	func _dialogue_instance(json_path: String, start_on_load : bool = false) -> Dialogue :
## 		var dialogue_instance: Dialogue = super._dialogue_instance(json_path, start_on_load)
## 		# do your custom setup here
## 
func _dialogue_instance(json_path: String, start_on_load : bool = false) -> Dialogue :
	var dialogue_instance: Dialogue = DIALOGUE_SCENE.instantiate() as Dialogue
	if dialogue_instance == null:
		push_error("BaseLevel: failed to instantiate Dialogue scene")
		return null
	dialogue_instance.dialogue_source = json_path
	dialogue_instance.start_on_load = start_on_load
	dialogue_instance.name = json_path.get_file().get_basename()
	default_dialogue.load_dialogue()
	return dialogue_instance

#endregion
