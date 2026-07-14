extends CharacterBody2D
class_name Player

signal health_changed(current_health: int)
signal died

@export var animated_sprite: AnimatedSprite2D
@export var move_speed := 100.0
@export var hiding_manager: PlayerHidingManager

@onready var camera: Camera2D = $Camera2D
@onready var breathing = $breathing
@onready var timer = $Timer
@onready var label = $Label
@export var max_health: int = 100

var health: int = max_health
var can_move: bool = true
var last_input := "up"


func _ready() -> void:
	EventBus.set_camera(camera)
	health = max_health
	health_changed.emit(health)


func _physics_process(_delta: float):
	var input_direction = Input.get_vector(&"left", &"right", &"up", &"down")
	
	if can_move:
		var actions := [&"up", &"down", &"right", &"left"]
		
		for action in actions:
			if Input.is_action_pressed(action):
				animated_sprite.play(action)
				last_input = action
				break
	
	velocity = input_direction * move_speed
	move_and_slide()
	
	if input_direction == Vector2.ZERO:
		animated_sprite.play(last_input + "_idle")
	
	if not can_move:
		velocity = Vector2.ZERO
		move_and_slide()
		return


func set_interact_prompt(is_visible: bool):
	$Camera2D/Control/RichTextLabel.visible = is_visible


func _process(_delta):
	if label.visible == true:
		var time_left = timer.time_left
		var minutes = int(time_left) / 60
		var seconds = int(time_left) % 60
		label.text = "%02d:%02d" % [minutes, seconds]


func take_damage(amount: int) -> void:
	if amount <= 0 or health <= 0:
		return

	health = max(health - amount, 0)
	health_changed.emit(health)

	if health == 0:
		can_move = false
		died.emit()
