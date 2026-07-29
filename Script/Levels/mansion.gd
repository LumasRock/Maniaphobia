extends Node2D

@export_category("Dialogue")
@export var dialogue_name : String = "Mansion"
@export var transition_dialog_id : String = "118"
@export var special_dialogue_id : String = "70"

@export_category("Scene Transition")
@export_file("*.tscn") var next_scene: String = "res://Scenes/Levels/Hide_And_Seek.tscn"
@export var fade_in_time: float = 3.0
@export var fade_out_time: float = 0.3

@onready var dialog : OldDialogue = $Dialogue
@onready var transition : AnimationPlayer = $Transition/AnimationPlayer

var npcs_talked_to : int = 0
var npcs_count : int = 5
var talked_npc_ids: Array[String] = []
var pending_special_dialogue : bool = false
var special_dialogue_played : bool = false

func _ready() -> void: 
	dialog.visibility_changed.connect(_on_dialogue_visibility_changed)
	dialog.play(dialogue_name)
	transition.play("RESET")

func register_npc_talk(npc_id: String) -> void:
	if talked_npc_ids.has(npc_id):
		return

	talked_npc_ids.append(npc_id)
	npcs_talked_to = talked_npc_ids.size()

	if npcs_talked_to >= npcs_count and not special_dialogue_played:
		pending_special_dialogue = true

func _on_dialogue_visibility_changed() -> void:
	if dialog.visible:
		return

	var finished_node_id : String = str(dialog.current_node.get("id", ""))

	if finished_node_id == transition_dialog_id:
		Transition.transition_to(next_scene)
		return

	if pending_special_dialogue and npcs_talked_to >= npcs_count and not special_dialogue_played:
		pending_special_dialogue = false
		special_dialogue_played = true
		transition.play("Fade_in")
		await get_tree().create_timer(fade_in_time).timeout
		transition.play("Fade_out")
		await get_tree().create_timer(fade_out_time).timeout
		dialog.play(dialogue_name, special_dialogue_id)
