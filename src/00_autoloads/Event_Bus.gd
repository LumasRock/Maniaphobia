extends Node

var _active_camera: Camera2D = null

func set_camera(cam: Camera2D) -> void:
	if _active_camera:
		_active_camera.enabled = false
	_active_camera = cam
	if _active_camera:
		_active_camera.enabled = true

func get_active_camera() -> Camera2D :
	return _active_camera if _active_camera != null else get_viewport().get_camera_2d()
	
func clear_camera(cam: Camera2D) -> void:
	if _active_camera == cam:
		_active_camera = null

func center_on_active_camera(target: Node, offset: Vector2 = Vector2.ZERO) -> void:
	if target == null:
		return
	var cam: Camera2D = get_active_camera()
	if cam == null:
		return

	var screen_center: Vector2 = cam.get_screen_center_position()
	var item : CanvasItem = _resolve_canvas_item(target)

	if item == null:
		push_warning("EventBus.center_on_active_camera: target '%s' is not a CanvasItem" % target.name)
		return
	item.global_position = screen_center - offset


func _resolve_canvas_item(node: Node) -> CanvasItem:
	if node is CanvasItem:
		return node as CanvasItem

	for child: Node in node.get_children():
		if child is CanvasItem:
			return child as CanvasItem

	return null
