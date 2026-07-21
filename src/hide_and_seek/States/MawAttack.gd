extends State
class_name MawAttack

@export var Maw: CharacterBody2D
@export var player: Player

func Enter():
	Maw.velocity = Vector2.ZERO

	if player == null:
		var players := get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0] as Player

	if player != null:
		player.take_damage(Maw.attack_damage)

	await get_tree().create_timer(1.0).timeout
	Transitioned.emit(self, "MawChase")
