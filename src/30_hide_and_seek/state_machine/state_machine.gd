class_name StateMachine
extends Node

var states: Dictionary[String, State] = {}
var current_state: State
@export var initial_state: State

signal transitioned(state: State, new_state_name: StringName)


func _ready():
	await get_tree().physics_frame
	
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transitioned.connect(on_child_transition)
	
	if initial_state:
		initial_state.state_enter()
		current_state = initial_state


func _process(delta):
	if current_state:
		current_state.state_update(delta)


func _physics_process(delta):
	if current_state:
		current_state.state_physics_update(delta)


func on_child_transition(state, new_state_name):
	if state != current_state:
		return
	
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		print("cannot find state " + new_state_name)
		return
	if current_state:
		current_state.state_exit()
	new_state.state_enter()
	current_state = new_state
