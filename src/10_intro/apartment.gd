class_name Apartment
extends BaseLevel

@onready var leave_early_dialogue : Dialogue = $Dialogues/LeaveEarly
@onready var exitDoor             : Area2D   = $Interactives/ExitDoor
@onready var playerSpawnMarker    : Node2D   = $Entities/PlayerSpawnMarker

var _coffee_machine_fixed         : bool

func get_default_spawn_point() -> Vector2:
	return playerSpawnMarker.position if playerSpawnMarker != null else Vector2.ZERO

func load_level() -> void:
	player = $Entities/Player
	player.position = get_default_spawn_point()
	leave_early_dialogue.hide()

## Sugar coating to integrate this script with PlayerIntegrationAreas
func is_coffee_machine_fixed() -> bool : return _coffee_machine_fixed

func _on_fix_coffee_machine_option_selected(node:DialogueNode, option:DialogueOption) -> void:
	print("option selected %s '%s' on node text: %s." % [option.id, option.text, node.text] )
	if option.id == "1" :
		_coffee_machine_fixed = true
	if option.id == "2" :
		_coffee_machine_fixed = false