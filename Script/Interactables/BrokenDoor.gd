extends Area2D
@onready var Shadows = %Shadows
@onready var Dialogue = $"../Dialogue"

func _ready():
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		Dialogue.play("Apartment", "29")
	

func _on_body_exited(body: Node2D) -> void:
	pass
