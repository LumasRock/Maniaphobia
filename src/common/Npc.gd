extends CharacterBody2D
class_name NPC

@export var character: Types.NpcCharacter
@export_enum("25","37","46","57","119") var dialogue_id: String

@export var mansion: Mansion
@export var dialogue: Dialogue

@onready var sprite: Sprite2D = $Sprite2D

func _texture_idx_to_rect(i: int) -> Rect2:
	var row: int = i % 5
	return Rect2(2 + 36 * (i - row * 5) ,1 + 36 * row,32,32)
func _get_texture_region(c: Types.NpcCharacter, d: Types.Direction) -> Rect2:
	match c:
		Types.NpcCharacter.Connor:
			return _texture_idx_to_rect(0 + d)
		Types.NpcCharacter.Evelyn:
			return _texture_idx_to_rect(4 + d)
		Types.NpcCharacter.Sylas:
			return _texture_idx_to_rect(8 + d)
		Types.NpcCharacter.Evan:
			return _texture_idx_to_rect(12 + d)
		Types.NpcCharacter.Silvia:
			return _texture_idx_to_rect(16 + d)
	push_error("npc sprite mismatch, unable to find corresponding sprite", c, d)
	return _texture_idx_to_rect(0)

func _update_sprite(d: Types.Direction) -> void:
	(sprite.texture as AtlasTexture).region = _get_texture_region(character, d)

func _ready() -> void:
	_update_sprite(Types.Direction.DOWN)

var player_node : Player = null

func _process(_delta: float) -> void:
	if player_node != null:
		follow()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_node != null:
		if mansion != null:
			mansion.register_npc_talk(character)
		dialogue.play("Mansion", dialogue_id)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_node = body
		player_node.set_interact_prompt(true)

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_node.set_interact_prompt(false)
		player_node = null
		_update_sprite(Types.Direction.DOWN)

func follow() -> void:
	if player_node:
		if player_node.velocity.x < self.velocity.x:
			_update_sprite(Types.Direction.RIGHT)
		if player_node.velocity.x > self.velocity.x:
			_update_sprite(Types.Direction.LEFT)
		if player_node.velocity.y < self.velocity.y:
			_update_sprite(Types.Direction.DOWN)
		if player_node.velocity.y > self.velocity.y:
			_update_sprite(Types.Direction.UP)
