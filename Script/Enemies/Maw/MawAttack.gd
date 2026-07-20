extends State
class_name MawAttack

@export var maw: Maw
@export var player: Player

func enter() -> void:
	maw.velocity = Vector2.ZERO

	if player == null:
		var players := get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0] as Player

	if player != null:
		player.take_damage(maw.attack_damage)

	await get_tree().create_timer(1.0).timeout
	Transitioned.emit(self, "MawChase")
