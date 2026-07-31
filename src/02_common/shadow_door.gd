extends Area2D

## This should refer to which direction the shadow is from the door
@export var my_placement: Types.Direction = Types.Direction.UP

func _ready() -> void:
	for c: Node2D in self.get_children():
		c.visible = true
	if not body_entered.is_connected(_on_body_entered):
		@warning_ignore("return_value_discarded")
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		@warning_ignore("return_value_discarded")
		body_exited.connect(_on_body_exited)

func _is_going_same_direction(player: Player) -> bool:
	match my_placement:
		Types.Direction.LEFT:
			return player.velocity.x < 0
		Types.Direction.RIGHT:
			return player.velocity.x > 0
		Types.Direction.UP:
			return player.velocity.y < 0
		Types.Direction.DOWN:
			return player.velocity.y > 0
	return false


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		self.modulate.a = 0.5


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		if _is_going_same_direction(body as Player):
			self.modulate.a = 0.0
		else:
			self.modulate.a = 1.0
