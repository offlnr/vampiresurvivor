extends Control
## Pause menu with resume, volume and quit.

signal resume_requested
signal quit_requested

@onready var continue_button: Button = $Center/Panel/VBox/ContinueButton
@onready var volume_button: Button = $Center/Panel/VBox/VolumeButton
@onready var options_menu: Control = $OptionsMenu
@onready var center: Control = $Center
@onready var quit_button: Button = $Center/Panel/VBox/QuitButton


func _ready() -> void:
	visible = false
	continue_button.pressed.connect(_on_continue)
	volume_button.pressed.connect(_on_options)
	options_menu.closed.connect(_on_options_closed)
	quit_button.pressed.connect(quit_requested.emit)


func open() -> void:
	visible = true
	center.visible = true
	options_menu.close()
	get_tree().paused = true
	continue_button.grab_focus()


func close() -> void:
	visible = false


func _on_options() -> void:
	Audio.play(&"click", 0.0)
	center.visible = false
	options_menu.open()


func _on_options_closed() -> void:
	center.visible = true
	volume_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if visible and not options_menu.visible and event.is_action_pressed(&"pause"):
		get_viewport().set_input_as_handled()
		_on_continue()


func _on_continue() -> void:
	Audio.play(&"click", 0.0)
	resume_requested.emit()
