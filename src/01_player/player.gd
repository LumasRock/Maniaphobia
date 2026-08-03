class_name Player
extends CharacterBody2D

signal health_changed(current_health: int)
signal died

@export var move_speed : float = 100.0
@export var hiding_manager: PlayerHidingManager

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer : Timer = $Timer
@onready var label : Label = $Label
@onready var interact_prompt : RichTextLabel = %InteractPrompt

@export var camera: Camera2D
@export var max_health: int = 100

var health: int = max_health
var can_move: bool = true
var last_input: String = "up"


func _ready() -> void:
	EventBus.set_camera(camera)
	health = max_health
	health_changed.emit(health)
	show_interact_prompt(false)

func _process(_delta: float) -> void:
	if label.visible == true:
		var time_left : float = timer.time_left
		var minutes   : int   = int(time_left) / 60
		var seconds   : int   = int(time_left) % 60
		label.text = "%02d:%02d" % [minutes, seconds]
		

func _physics_process(_delta: float) -> void:
	var input_direction : Vector2 = Input.get_vector(&"left", &"right", &"up", &"down")
	if can_move:
		var actions : Array = [&"up", &"down", &"right", &"left"]
		
		for action : String in actions:
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

func show_interact_prompt(toggle_show: bool) -> void:
	interact_prompt.visible = toggle_show

func take_damage(amount: int) -> void:
	if amount <= 0 or health <= 0:
		return
	health = max(health - amount, 0)
	health_changed.emit(health)

	if health == 0:
		can_move = false
		died.emit()
