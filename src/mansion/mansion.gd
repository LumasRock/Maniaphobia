extends Node2D

@onready var dialogue: Dialogue = $Dialogue
@onready var transition: AnimationPlayer = $Transition/AnimationPlayer
var Npcs_Talked_To: int = 0
var talked_npc_ids: Array[String] = []
var pending_special_dialogue: bool = false
var special_dialogue_played: bool = false
@export_file("*.tscn", "*.scn") var hide_and_seek_scene: String

func _ready() -> void:
	@warning_ignore("return_value_discarded")
	dialogue.visibility_changed.connect(_on_dialogue_visibility_changed)
	if Transition.is_transitioning:
		await Transition.fade_out_finished
	dialogue.play("Mansion")
	transition.play("RESET")

func register_npc_talk(npc_id: String) -> void:
	if talked_npc_ids.has(npc_id):
		return

	talked_npc_ids.append(npc_id)
	Npcs_Talked_To = talked_npc_ids.size()

	if Npcs_Talked_To >= 5 and not special_dialogue_played:
		pending_special_dialogue = true

func _on_dialogue_visibility_changed() -> void:
	if dialogue.visible:
		return

	var finished_node_id: String = str(dialogue.current_node.get("id", ""))

	if finished_node_id == "118":
		Transition.transition_to(hide_and_seek_scene)
		return

	if pending_special_dialogue and Npcs_Talked_To >= 5 and not special_dialogue_played:
		pending_special_dialogue = false
		special_dialogue_played = true
		transition.play("Fade_in")
		await get_tree().create_timer(3.0).timeout
		transition.play("Fade_out")
		await get_tree().create_timer(0.3).timeout
		dialogue.play("Mansion", "70")
