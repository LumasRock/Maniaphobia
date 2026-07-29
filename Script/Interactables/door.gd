extends Area2D
class_name Door

@export var shadowsMapLayer: TileMapLayer

enum Placement { UP, LEFT, RIGHT, BOTTOM }

@export var my_placement: Placement = Placement.UP

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	var pl: Player = body as Player
	match my_placement:
		Placement.LEFT, Placement.RIGHT:
			if pl.velocity.x != 0: 
				shadowsMapLayer.modulate.a = 0.5
		Placement.UP, Placement.BOTTOM:
			if pl.velocity.y != 0: 
				shadowsMapLayer.modulate.a = 0.5

func _on_body_exited(body: Node2D) -> void:
	if not body is Player:
		return
	var pl : Player = body as Player
	match my_placement:
		Placement.LEFT:
			if pl.velocity.x > 0: 
				shadowsMapLayer.modulate.a = 1
			elif pl.velocity.x < 0:
				shadowsMapLayer.modulate.a = 0
		Placement.RIGHT:
			if pl.velocity.x < 0: 
				shadowsMapLayer.modulate.a = 1
			elif pl.velocity.x > 0:
				shadowsMapLayer.modulate.a = 0
		Placement.UP:
			if pl.velocity.y > 0: 
				shadowsMapLayer.modulate.a = 1
			elif pl.velocity.y < 0:
				shadowsMapLayer.modulate.a = 0
		Placement.BOTTOM:
			if pl.velocity.y < 0: 
				shadowsMapLayer.modulate.a = 1
			elif pl.velocity.y > 0:
				shadowsMapLayer.modulate.a = 0
