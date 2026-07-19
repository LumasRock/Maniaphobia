extends TextureRect
signal fade_out_finished(scene_path: String)

@export_file("*.tscn", "*.scn") var target_scene: String

@onready var anim_player: AnimationPlayer = $AnimationPlayer

var is_transitioning: bool = false

func _ready() -> void:
	anim_player.play_backwards("Fade")
	

func transition_to(_next_scene: String= target_scene) -> void:
	if is_transitioning:
		return
	if _next_scene.is_empty():
		push_warning("Transition target_scene is empty.")
		return

	is_transitioning = true
	anim_player.play("Fade")
	await anim_player.animation_finished

	var request_error: Error = ResourceLoader.load_threaded_request(_next_scene)
	if request_error != OK:
		push_error("Failed to start threaded load for scene: %s" % _next_scene)
		is_transitioning = false
		anim_player.play_backwards("Fade")
		return

	while true:
		var progress: Array[float]= []
		var load_status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(_next_scene, progress)
		if load_status == ResourceLoader.THREAD_LOAD_LOADED:
			break
		if load_status == ResourceLoader.THREAD_LOAD_FAILED:
			push_error("Threaded load failed for scene: %s" % _next_scene)
			is_transitioning = false
			anim_player.play_backwards("Fade")
			return
		await get_tree().process_frame

	var next_scene: PackedScene = ResourceLoader.load_threaded_get(_next_scene)
	if next_scene == null:
		push_error("Loaded resource is not a PackedScene: %s" % _next_scene)
		is_transitioning = false
		anim_player.play_backwards("Fade")
		return

	var _err: Error = get_tree().change_scene_to_packed(next_scene)
	await get_tree().process_frame
	anim_player.play_backwards("Fade")
	await anim_player.animation_finished
	fade_out_finished.emit(_next_scene)
	is_transitioning = false
