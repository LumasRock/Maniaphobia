extends CharacterBody2D
class_name NPC

@export var character: Types.NpcCharacter
@export_enum("25","37","46","57","119") var dialogue_id: String

@export var rest_direction: Types.Direction = Types.Direction.DOWN

@export var mansion: Mansion
@export var dialogue: Dialogue

## res://Assets/Npc_Rpg.png
const NPC_RPG: Texture2D = preload("uid://bnqatx8uvcy4q")

@onready var sprite: Sprite2D = $Sprite2D

func _texture_idx_to_rect(i: int) -> Rect2:
	var row: int = i % 5
	var col: int = floori(i / 5.0)
	return Rect2(2 + 36 * row ,1 + 36 * col, 32, 32)
func _get_texture_region(c: Types.NpcCharacter, d: Types.Direction) -> Rect2:
	var dir: int
	match d:
		Types.Direction.DOWN:
			dir = 0
		Types.Direction.UP:
			dir = 1
		Types.Direction.LEFT:
			dir = 2
		Types.Direction.RIGHT:
			dir = 3
	match c:
		Types.NpcCharacter.Connor:
			return _texture_idx_to_rect(0 + dir)
		Types.NpcCharacter.Evelyn:
			return _texture_idx_to_rect(4 + dir)
		Types.NpcCharacter.Sylas:
			return _texture_idx_to_rect(8 + dir)
		Types.NpcCharacter.Evan:
			return _texture_idx_to_rect(12 + dir)
		Types.NpcCharacter.Silvia:
			return _texture_idx_to_rect(16 + dir)
	push_error("npc sprite mismatch, unable to find corresponding sprite", c, d)
	return _texture_idx_to_rect(0)

func _update_sprite(d: Types.Direction) -> void:
	(sprite.texture as AtlasTexture).region = _get_texture_region(character, d)

func _ready() -> void:
	var atlas: AtlasTexture = AtlasTexture.new()
	atlas.atlas = NPC_RPG
	sprite.texture = atlas
	_update_sprite(rest_direction)

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
		_update_sprite(rest_direction)

func follow() -> void:
	if player_node:
		var angle: float = player_node.global_position.angle_to_point(self.global_position)
		if angle - deg_to_rad(45) < 0:
			angle += 2 * PI
		print(angle)
		var ordinal: int = floori((angle - deg_to_rad(45)) / deg_to_rad(90))
		print(ordinal, " ", rad_to_deg(angle))
		if ordinal == 0:
			_update_sprite(Types.Direction.UP)
		elif ordinal == 1:
			_update_sprite(Types.Direction.RIGHT)
		elif ordinal == 2:
			_update_sprite(Types.Direction.DOWN)
		elif ordinal == 3:
			_update_sprite(Types.Direction.LEFT)
		else:
			push_error("npc angle parsing failed ", angle)
