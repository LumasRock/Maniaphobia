class_name Ghost
extends CharacterBody2D


var player: Player
var maw: Maw


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	maw = get_tree().get_first_node_in_group("maw")
