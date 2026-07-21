extends Area2D
@export var Shadows: TileMapLayer

enum Placement { UP, LEFT, RIGHT, BOTTOM }

@export var my_placement: Placement = Placement.UP

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		@warning_ignore("return_value_discarded")
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		@warning_ignore("return_value_discarded")
		body_exited.connect(_on_body_exited)

func _is_going_same_direction(player: Player) -> bool:
	match my_placement:
		Placement.LEFT:
			return player.velocity.x < 0
		Placement.RIGHT:
			return player.velocity.x > 0
		Placement.UP:
			return player.velocity.y < 0
		Placement.BOTTOM:
			return player.velocity.y > 0
	return false


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		Shadows.modulate.a = 0.5


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		if _is_going_same_direction(body):
			Shadows.modulate.a = 0.0
		else:
			Shadows.modulate.a = 1.0
