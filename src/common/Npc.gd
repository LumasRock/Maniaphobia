extends CharacterBody2D

@export_enum("25","37","46","57","119") var id: String
var player_node : Node2D = null
@onready var sprite = $Sprite2D
@export var left: Vector2i = Vector2i(4,0)
@export var right: Vector2i = Vector2i(4,0)
@export var up: Vector2i = Vector2i(4,0)
@export var down: Vector2i = Vector2i(4,0)
@export var Dialogue : Control
@onready var body_entered := false

func _process(delta: float) -> void:
	if body_entered == true:
		follow()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_node = body
		player_node.set_interact_prompt(true)
		body_entered = true
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_node != null:
		var mansion_script := get_parent()
		if mansion_script != null and mansion_script.has_method("register_npc_talk"):
			mansion_script.register_npc_talk(id)
		Dialogue.play("Mansion", id)
		

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_node.set_interact_prompt(false)
		player_node = null
		sprite.frame_coords = down
		body_entered = false

func follow():
	if player_node:
		if player_node.velocity.x < self.velocity.x:
			sprite.frame_coords = right
		if player_node.velocity.x > self.velocity.x:
			sprite.frame_coords = left
		if player_node.velocity.y < self.velocity.y:
			sprite.frame_coords = down
		if player_node.velocity.y > self.velocity.y:
			sprite.frame_coords = up
