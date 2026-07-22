# DialogueConfig.gd -- stores global dialogue configuration settings
extends Node

@export var json_base_path: String = "res://Assets/Dialogues/"
@export var text_speed: float = 0.05
@export var text_size: int = 24
@export var font_path: String = "res://Assets/Fonts/"
@export var font: String = "HandymandiFree.ttf"
@export var font_color: Color = Color.WHITE
@export var locale: String = "en"
@export var auto_next_delay : float = 1.0

@export var default_show_portrait: bool = true
