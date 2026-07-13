extends Node2D

@onready var Dialogue = $Dialogue
@onready var transition = $Transition/AnimationPlayer
var Npcs_Talked_To := 0
var talked_npc_ids: Array[String] = []
var pending_special_dialogue := false
var special_dialogue_played := false
const HIDE_AND_SEEK_SCENE := "res://Scenes/Levels/Hide_And_Seek.tscn"

func _ready(): 
	Dialogue.visibility_changed.connect(_on_dialogue_visibility_changed)
	Dialogue.play("Mansion")
	transition.play("RESET")

func register_npc_talk(npc_id: String) -> void:
	if talked_npc_ids.has(npc_id):
		return

	talked_npc_ids.append(npc_id)
	Npcs_Talked_To = talked_npc_ids.size()

	if Npcs_Talked_To >= 5 and not special_dialogue_played:
		pending_special_dialogue = true

func _on_dialogue_visibility_changed() -> void:
	if Dialogue.visible:
		return

	var finished_node_id := str(Dialogue.current_node.get("id", ""))

	if finished_node_id == "118":
		Transition.transition_to("res://Scenes/Levels/Hide_And_Seek.tscn")
		return

	if pending_special_dialogue and Npcs_Talked_To >= 5 and not special_dialogue_played:
		pending_special_dialogue = false
		special_dialogue_played = true
		transition.play("Fade_in")
		await get_tree().create_timer(3.0).timeout
		transition.play("Fade_out")
		await get_tree().create_timer(0.3).timeout
		Dialogue.play("Mansion", "70")
