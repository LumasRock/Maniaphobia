extends TextureRect
signal fade_out_finished(scene_path: String)

@export_file("*.tscn", "*.scn") var target_scene: String

@onready var anim_player : AnimationPlayer = $AnimationPlayer

var is_transitioning : bool = false

func _ready() -> void:
	anim_player.play_backwards("Fade")

func transition_to(_next_scene : String = target_scene) -> void:
	if is_transitioning:
		return
	if _next_scene.is_empty():
		push_warning("Transition target_scene is empty.")
		return

	# start transition
	is_transitioning = true
	anim_player.play("Fade")
	await anim_player.animation_finished

	if ResourceLoader.load_threaded_request(_next_scene) != OK:
		abort_transition("Failed to start threaded load for scene: %s" % _next_scene)
		return

	#TODO: call load_threaded_get_status in _process to avoid blocking the main thread, and yield until the scene is loaded. This is a temporary solution to avoid blocking the main thread.
	#TODO: consider a timeout to prevent blocking the main thread indefinitely if the scene fails to load.
	while true:
		var progress := []
		var load_status := ResourceLoader.load_threaded_get_status(_next_scene, progress)
		if load_status == ResourceLoader.THREAD_LOAD_LOADED:
			break
		if load_status == ResourceLoader.THREAD_LOAD_FAILED:
			abort_transition("Threaded load failed for scene: %s" % _next_scene)
			return
		await get_tree().process_frame

	# sanity check on loaded scene
	var loaded_next_scene := ResourceLoader.load_threaded_get(_next_scene) as PackedScene
	if loaded_next_scene == null or not loaded_next_scene is PackedScene:
		abort_transition("Next Scene could not be loaded or is not a PackedScene: %s" % _next_scene)
		return

	if get_tree().change_scene_to_packed(loaded_next_scene) != OK:
		abort_transition("Failed to change scene to: %s" % _next_scene)
		return
		
	# end transition
	await get_tree().process_frame
	anim_player.play_backwards("Fade")
	await anim_player.animation_finished
	fade_out_finished.emit(_next_scene)
	is_transitioning = false

func abort_transition(msg: String) -> void:
	push_error(msg)
	is_transitioning = false
	anim_player.play_backwards("Fade")
