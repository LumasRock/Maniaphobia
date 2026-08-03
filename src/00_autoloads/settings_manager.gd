extends Node

signal settings_applied
signal ui_scale_changed(scale: float)

const SAVE_PATH := "user://settings.cfg"
const RESOLUTIONS := [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080)
]
const WINDOW_SCALES := [0.75, 1.0, 1.25, 1.5]
const WINDOW_MODE_WINDOWED := 0
const WINDOW_MODE_BORDERLESS := 1
const WINDOW_MODE_FULLSCREEN := 2

var settings := {
	"resolution_index": 0,
	"window_scale_index": 1,
	"window_mode": WINDOW_MODE_WINDOWED,
	"master_volume": 0.8,
	"ui_scale": 1.0
}

func _ready() -> void:
	load_settings()
	apply_settings()

func get_resolution_labels() -> PackedStringArray:
	var labels := PackedStringArray()
	for resolution in RESOLUTIONS:
		labels.append("%s x %s" % [resolution.x, resolution.y])
	return labels

func get_window_scale_labels() -> PackedStringArray:
	var labels := PackedStringArray()
	for scale in WINDOW_SCALES:
		labels.append("%s%%" % int(round(scale * 100.0)))
	return labels

func get_window_mode_labels() -> PackedStringArray:
	return PackedStringArray(["Windowed", "Borderless", "Fullscreen"])

func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return

	settings["resolution_index"] = clampi(int(config.get_value("display", "resolution_index", settings["resolution_index"])), 0, RESOLUTIONS.size() - 1)
	settings["window_scale_index"] = clampi(int(config.get_value("display", "window_scale_index", settings["window_scale_index"])), 0, WINDOW_SCALES.size() - 1)
	settings["window_mode"] = clampi(int(config.get_value("display", "window_mode", settings["window_mode"])), WINDOW_MODE_WINDOWED, WINDOW_MODE_FULLSCREEN)
	settings["master_volume"] = clampf(float(config.get_value("audio", "master_volume", settings["master_volume"])), 0.0, 1.0)
	settings["ui_scale"] = clampf(float(config.get_value("display", "ui_scale", settings["ui_scale"])), 0.75, 1.5)

func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("display", "resolution_index", settings["resolution_index"])
	config.set_value("display", "window_scale_index", settings["window_scale_index"])
	config.set_value("display", "window_mode", settings["window_mode"])
	config.set_value("display", "ui_scale", settings["ui_scale"])
	config.set_value("audio", "master_volume", settings["master_volume"])
	config.save(SAVE_PATH)

func apply_settings() -> void:
	_apply_window_settings()
	_apply_audio_settings()
	ui_scale_changed.emit(settings["ui_scale"])
	settings_applied.emit()

func set_resolution_index(index: int) -> void:
	settings["resolution_index"] = clampi(index, 0, RESOLUTIONS.size() - 1)
	commit_settings()

func set_window_scale_index(index: int) -> void:
	settings["window_scale_index"] = clampi(index, 0, WINDOW_SCALES.size() - 1)
	commit_settings()

func set_window_mode(index: int) -> void:
	settings["window_mode"] = clampi(index, WINDOW_MODE_WINDOWED, WINDOW_MODE_FULLSCREEN)
	commit_settings()

func set_master_volume_percent(value: float) -> void:
	settings["master_volume"] = clampf(value / 100.0, 0.0, 1.0)
	commit_settings()

func set_ui_scale(value: float) -> void:
	settings["ui_scale"] = clampf(value, 0.75, 1.5)
	commit_settings()

func get_master_volume_percent() -> float:
	return settings["master_volume"] * 100.0

func commit_settings() -> void:
	apply_settings()
	save_settings()

func _apply_window_settings() -> void:
	var base_resolution: Vector2i = RESOLUTIONS[settings["resolution_index"]]
	var scale: float = WINDOW_SCALES[settings["window_scale_index"]]
	var window_size := Vector2i(
		int(round(base_resolution.x * scale)),
		int(round(base_resolution.y * scale))
	)

	var window := get_window()
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, settings["window_mode"] == WINDOW_MODE_BORDERLESS)

	match settings["window_mode"]:
		WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		_:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			window.size = window_size

	window.content_scale_size = base_resolution

func _apply_audio_settings() -> void:
	var volume: float = settings["master_volume"]
	if volume <= 0.001:
		AudioServer.set_bus_volume_db(0, -80.0)
	else:
		AudioServer.set_bus_volume_db(0, linear_to_db(volume))
