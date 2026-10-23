extends Node
## Player settings stored on the device (volume) and the current input mode.

signal input_mode_changed(touch: bool)

const PATH := "user://settings.cfg"
const SAVE_DELAY := 0.5
const LANDSCAPE_SIZE := Vector2i(1280, 720)
const PORTRAIT_SIZE := Vector2i(720, 1280)

var music_volume := 0.7
var sfx_volume := 0.8
## Longest run survived, in seconds, and the kills in that run.
var best_time := 0.0
var best_kills := 0
var fullscreen := false
## True while the player is using a touch screen; touch controls are only shown then.
var touch_mode := false

var _save_timer: SceneTreeTimer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	touch_mode = DisplayServer.is_touchscreen_available()
	load_settings()
	apply()
	_apply_window_mode()
	get_tree().root.size_changed.connect(_fit_orientation)
	_fit_orientation()


func set_music_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	apply()
	_queue_save()


func set_sfx_volume(value: float) -> void:
	sfx_volume = clampf(value, 0.0, 1.0)
	apply()
	_queue_save()


## Stores the run if it beats the record. Returns true when it is a new record.
func submit_run(seconds: float, kills: int) -> bool:
	if seconds <= best_time:
		return false
	best_time = seconds
	best_kills = kills
	save_settings()
	return true


static func format_time(seconds: float) -> String:
	var total := int(seconds)
	if total >= 3600:
		return "%d:%02d:%02d" % [total / 3600, (total / 60) % 60, total % 60]
	return "%02d:%02d" % [total / 60, total % 60]


func set_fullscreen(value: bool) -> void:
	fullscreen = value
	_apply_window_mode()
	save_settings()


func _apply_window_mode() -> void:
	if OS.has_feature("mobile") or DisplayServer.get_name() == "headless":
		return
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)


func apply() -> void:
	_set_bus_volume(&"Music", music_volume)
	_set_bus_volume(&"SFX", sfx_volume)


func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK:
		return
	music_volume = clampf(cfg.get_value("audio", "music", music_volume), 0.0, 1.0)
	sfx_volume = clampf(cfg.get_value("audio", "sfx", sfx_volume), 0.0, 1.0)
	best_time = cfg.get_value("record", "time", best_time)
	best_kills = cfg.get_value("record", "kills", best_kills)
	fullscreen = cfg.get_value("video", "fullscreen", fullscreen)


func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "music", music_volume)
	cfg.set_value("audio", "sfx", sfx_volume)
	cfg.set_value("record", "time", best_time)
	cfg.set_value("record", "kills", best_kills)
	cfg.set_value("video", "fullscreen", fullscreen)
	cfg.save(PATH)


func _queue_save() -> void:
	# Sliders change many times per drag; write the file once they settle.
	if _save_timer != null:
		_save_timer.timeout.disconnect(save_settings)
	_save_timer = get_tree().create_timer(SAVE_DELAY, true)
	_save_timer.timeout.connect(save_settings)


## Uses a portrait base resolution on vertical screens so the UI keeps the same size.
func _fit_orientation() -> void:
	var window := get_tree().root
	var target := PORTRAIT_SIZE if window.size.y > window.size.x else LANDSCAPE_SIZE
	if window.content_scale_size != target:
		window.content_scale_size = target


func _set_bus_volume(bus_name: StringName, value: float) -> void:
	var index := AudioServer.get_bus_index(bus_name)
	if index < 0:
		return
	AudioServer.set_bus_volume_db(index, linear_to_db(maxf(value, 0.0001)))
	AudioServer.set_bus_mute(index, value <= 0.001)


func _input(event: InputEvent) -> void:
	var touch := touch_mode
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		touch = true
	elif event is InputEventKey or event is InputEventJoypadButton:
		touch = false
	elif event is InputEventJoypadMotion and absf(event.axis_value) > 0.5:
		touch = false
	elif event is InputEventMouseButton and event.device != InputEvent.DEVICE_ID_EMULATION:
		touch = false
	if touch != touch_mode:
		touch_mode = touch
		input_mode_changed.emit(touch)
