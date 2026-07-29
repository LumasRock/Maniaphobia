extends CharacterBody2D
class_name Player

signal health_changed(current_health: int)
signal died

@export var animated_sprite: AnimatedSprite2D
@export var move_speed : float = 100.0
@export var hiding_manager: PlayerHidingManager

@onready var camera: Camera2D = $Camera2D
#@onready var breathing = $breathing
@onready var timer : Timer = $Timer
@onready var label : Label = $Label
@onready var cameraLabel : RichTextLabel = $Camera2D/Control/RichTextLabel
@export var max_health: int = 100

var health: int = max_health
var _can_move: bool = true
var _last_input : String = "up"
var _actions : Array = [&"up", &"down", &"right", &"left"]

func _ready() -> void:
	EventBus.set_camera(camera)
	health = max_health
	health_changed.emit(health)

func _physics_process(_delta: float) -> void:
	var input_direction : Vector2 = Input.get_vector(&"left", &"right", &"up", &"down")
	
	if not _can_move:
		velocity = Vector2.ZERO
	else :
		for action : String in _actions:
			if Input.is_action_pressed(action):
				animated_sprite.play(action)
				_last_input = action
				break
	
	velocity = input_direction * move_speed
	move_and_slide()
	
	if input_direction == Vector2.ZERO:
		animated_sprite.play(_last_input + "_idle")

func _process(_delta : float) -> void:
	if label.visible == true:
		var time_left : float = timer.time_left
		var minutes : int = int(time_left) / 60
		var seconds : int = int(time_left) % 60
		label.text = "%02d:%02d" % [minutes, seconds]


func show_interact_prompt(show_prompt: bool) -> void:
	cameraLabel.visible = show_prompt

func take_damage(amount: int) -> void:
	if amount <= 0 :
		return

	health = max(health - amount, 0)
	health_changed.emit(health)

	if health == 0:
		_can_move = false
		died.emit()
