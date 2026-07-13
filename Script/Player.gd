extends CharacterBody2D
class_name Player

signal health_changed(current_health: int)
signal died

@onready var camera: Camera2D = $Camera2D
@onready var breathing = $breathing
@onready var timer = $Timer
@onready var label = $Label
@export var max_health: int = 100
var health: int = max_health
var can_move: bool = true
var hide_state: bool = false
var hiding_left: float = 10.0
var hide_timer: float = 0.0
var last_input := "up"

func _ready() -> void:
	EventBus.set_camera(camera)
	health = max_health
	health_changed.emit(health)
	
func _physics_process(_delta: float):
	var input_direction = Input.get_vector("left","right","up","down")
	if can_move:
		if Input.is_action_pressed("up"):
			$AnimatedSprite2D.play("up")
			last_input = "up"
		elif Input.is_action_pressed("down"):
			$AnimatedSprite2D.play("down")
			last_input = "down"
		elif Input.is_action_pressed("right"):
			$AnimatedSprite2D.play("right")
			last_input = "right"
		elif Input.is_action_pressed("left"):
			$AnimatedSprite2D.play("left")
			last_input = "left"
	velocity = input_direction * 100
	move_and_slide()
	if input_direction == Vector2.ZERO:
		$AnimatedSprite2D.play(last_input + "_idle")
	
	
	if not can_move:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	if hide_state == true:
		self.visible = false
	else:
		self.visible = true
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
