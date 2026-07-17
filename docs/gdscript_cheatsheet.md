# GDScript Cheat Sheet (Maniaphobia-focused)

Quick reference for navigating a Godot project, with Unity/Lua parallels.

## Core mental model (Unity shortcut)

- **Scene** = Prefab + Hierarchy + serialized file (`.tscn`)
- **Node** = object in tree (often like GameObject + some behavior role)
- **Signals** = Events
- **Autoload** = global singleton/service

---

## Syntax essentials

``` gdscript 
extends CharacterBody2D class_name Player
signal died
@export var move_speed := 100.0 const MAX_HP := 100
var hp: int = MAX_HP
func ready() -> void: 	print("ready")
func physics_process(delta: float) -> void: 	var dir := Input.get_vector("left", "right", "up", "down") 	velocity = dir * move_speed 	move_and_slide()
```

- Indentation-based (Python-like).
- Types optional, but recommended in team code.
- `@export` exposes fields in inspector (`[SerializeField]`-like).

---

## Methods, parameters, return types

``` gdscript
func add_damage(base: int, multiplier: float = 1.0) -> int:
	return int(base * multiplier)
```
• Default parameters supported.
• Return type optional but recommended.

## Arrays and Dictionaries (objects/maps)
``` gdscript
var arr := [1, 2, 3]
arr.append(4)
var first := arr[0]

var dict := {"id": "17", "text": "Hello"}
var id := dict.get("id", "")
```
• Unity parallel: List<T> + Dictionary<string, object>
• Lua parallel: table-as-array/table-as-map.

## Inheritance, interfaces, abstract-like patterns, generics

• Inheritance: extends BaseClass
• No formal interfaces keyword (use conventions/signals/base classes).
• No formal abstract class keyword; emulate with base methods and overrides.
• No user-defined generics like C# (List<T> style is limited to built-ins/type hints).

Example base-state pattern:
``` gdscript 
# state.gd
extends Node
class_name State
signal transitioned(state: State, next_state: StringName)

func enter(): pass
func exit(): pass
func update(_delta: float): pass
func physics_update(_delta: float): pass
```

## Operations / control flow

``` gdscript
if a > b:
	pass
elif a == b:
	pass
else:
	pass

match state_name:
	"idle":
		pass
	"run":
		pass
	_:
		pass
```
• Boolean ops: and, or, not
• Equality: ==, !=

## Lifecycle (scene/object)

Godot lifecycle (Unity parallel):
• `enter_tree()` ~ Awake
• `ready()` ~ Start
• `process(delta)` ~ Update
• `physics_process(delta)` ~ FixedUpdate
• `exit_tree()` ~ OnDestroy/cleanup

## Scene instancing and transitions

Instantiate scene (prefab-like):
``` gdscript
var packed := preload("res://Scenes/Enemy.tscn")
var enemy := packed.instantiate()
add_child(enemy)
```

Scene change:
``` gdscript
get_tree().change_scene_to_file("res://Scenes/Levels/Apartment.tscn")
```

In Maniaphobia, transitions are typically wrapped by a global autoload:
``` gdscript
Transition.transition_to("res://Scenes/Levels/Mansion.tscn")
```

## Coroutines equivalent (await)

``` gdscript
func do_sequence() -> void:
	print("A")
	await get_tree().create_timer(1.0).timeout
	print("B")
```

• Equivalent mental model to Unity coroutines (yield return).

## Math and vectors

``` gdscript
var dir: Vector2 = (target - global_position).normalized()
var d := global_position.distance_to(target)
var v := Vector2(1, 0) * 100.0
```

Common types:
• `Vector2`, `Vector2i`
• `float`, `int`
• `Color`, `Rect2`, etc.

## Input system

Define actions in `project.godot` input map, then:
``` gdscript
if Input.is_action_just_pressed("interact"):
	pass

var move := Input.get_vector("left", "right", "up", "down")
```

Unity parallel: Input Actions map.

## Sprites and animation
• `Sprite2D`: static sprite
• `AnimatedSprite2D`: frame-based sprite animation
• `AnimationPlayer`: timeline/property animation

``` gdscript
animated_sprite.play("up")
animated_sprite.play("up_idle")
```

## Camera and viewport
• `Camera2D` for 2D camera control.
• `get_viewport()` / `get_window()` for viewport/window behavior.

Maniaphobia uses camera ownership switching via `EventBus.set_camera(...)`.

## Collision / collider / rigidbody equivalents

• `Area2D` = trigger volume (like isTrigger)
• `CharacterBody2D` = code-driven movement controller
• `RigidBody2D` = physics-driven body
• Collision layers/masks control interactions

Signals used often:
• `body_entered`
• `body_exited`

## Error handling and logging

GDScript typically uses explicit checks, not exception-heavy flow:

``` gdscript
var err := ResourceLoader.load_threaded_request(path)
if err != OK:
	push_error("Failed to load: %s" % path)
	return
```

Logging helpers:
• `print()`
• `printerr()`
• `push_warning()`
• `push_error()`
• `assert(condition, "message")`

## Naming conventions (recommended)

• Files/folders: `snake_case`
• Functions/vars/signals: `snake_case`
• Constants: `SCREAMING_SNAKE_CASE`
• Class names/node type names: `PascalCase`

Consistency matters for readability and cross-platform path reliability.

## Maniaphobia quick anchors

• Player logic: `Scenes/Player/Player.gd`
• Dialogue runtime: `Script/dialogue.gd`
• FSM base: `Script/States/state.gd`, `Script/States/state_machine.gd`
• Enemy states: `Script/States/Maw.gd`, `Script/States/Ghost.gd`
• Scene transition wrapper: `Script/Transition.gd`
• Global signals/camera: `Script/Global/Event_Bus.gd`