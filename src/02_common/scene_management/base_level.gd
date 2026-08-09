class_name BaseLevel
extends Node2D
## 
## This is a base class for levels. Provides common access to the camera, player, and transitioning to scenes.
##
## This is a base class for levels. Provides common access to the camera, player, and transitioning to scenes.
## Levels are expected to extend this class and override the methods:
## - [method load_level]
## - [method unload_level]
## 
## To add custom logic load and unload workflow, is recommended to use the signals:
## - [signal before_level_loaded]
## - [signal after_level_loaded]
## - [signal before_level_unloaded]


signal before_level_loaded(scene_name: String)
signal after_level_loaded(scene_name: String)
signal before_level_unloaded(scene_name: String)


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
## duration in in seconds of the transition to next_scene. If < 0, uses default transition time
@export var transition_time: float = -1.0

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
	

func _exit_tree() -> void :
	if current_state == LevelStates.UNLOADING:
		return
	current_state = LevelStates.UNLOADING
	before_level_unloaded.emit(get_scene_file_path())
	unload_level()

#region VIRTUAL METHODS

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

## If [member next_scene] is defined, unloads this level and transitions to the new scene
func move_to_next_scene() -> void :
	if next_scene != "" :
		if transition_time < 0.0:
			Transition.transition_to(next_scene)
		else:
			Transition.transition_to(next_scene,transition_time )
	else :
		push_warning("BaseLevel: next_scene is empty, cannot move to next scene.")

#endregion 
