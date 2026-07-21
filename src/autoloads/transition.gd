extends TextureRect

signal fade_out_finished(scene_path: String)

var is_transitioning: bool = false
var _loading_path: String
var _loaded_resource: PackedScene

signal _load_finished
@onready var _anim_player: AnimationPlayer = $AnimationPlayer
const _USE_THREADED: bool = true

#@export_file("*.tscn", "*.scn") var target_scene: String

func _ready() -> void:
	_anim_player.play_backwards("Fade")
	await _anim_player.animation_finished
	set_process(false)


func _start_load() -> void:
	var req_err: Error = ResourceLoader.load_threaded_request(_loading_path, "", _USE_THREADED)
	if req_err != OK:
		push_error("Failed to start threaded load for scene: %s" % _loading_path)
		_cleanup_load()
		return
	else:
		set_process(true)

func _process(_delta: float) -> void:
	if not is_transitioning:
		return
	if _loaded_resource != null:
		return

	var progress: Array[float]= []
	var load_status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(_loading_path, progress)
	match load_status:
		ResourceLoader.THREAD_LOAD_LOADED:
			_loaded_resource = ResourceLoader.load_threaded_get(_loading_path)
			if _loaded_resource == null:
				push_error("Loaded resource is not a PackedScene: %s" % _loading_path)
				_cleanup_load()
				return
			_load_finished.emit()
		ResourceLoader.THREAD_LOAD_FAILED:
			push_error("Threaded load failed for scene: %s" % _loading_path)
			_cleanup_load()

func _switch_scene() -> void:
	var err: Error = get_tree().change_scene_to_packed(_loaded_resource)
	if err != OK:
		push_error("Failed to change to packed scene: %s" % _loading_path)
		_cleanup_load()
		return
	_cleanup_load(true)

func _cleanup_load(do_finished: bool = false) -> void:
	var tmp: String = _loading_path
	_loading_path = ""
	_loaded_resource = null
	_anim_player.play_backwards("Fade")
	await _anim_player.animation_finished
	if do_finished:
		fade_out_finished.emit(tmp)
	is_transitioning = false
	set_process(false)

func transition_to(next_scene: String, minimum_transition_blackout_seconds: float = 1.0) -> void:
	if is_transitioning:
		return
	if next_scene.is_empty():
		push_warning("Transition target_scene is empty.")
		return

	is_transitioning = true
	_loading_path = next_scene
	_start_load()
	_anim_player.play("Fade")
	await _anim_player.animation_finished
	await get_tree().create_timer(minimum_transition_blackout_seconds).timeout
	if _loaded_resource == null:
		await _load_finished
	_switch_scene()
