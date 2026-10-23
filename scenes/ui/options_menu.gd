extends Control
## Options window shown over the main menu or the pause menu: volume and full screen.

signal closed

var _value_labels := {}
var _privacy_button: Button

@onready var music_slider: HSlider = $Center/Panel/VBox/Grid/MusicSlider
@onready var sfx_slider: HSlider = $Center/Panel/VBox/Grid/SfxSlider
@onready var music_value: Label = $Center/Panel/VBox/Grid/MusicValue
@onready var sfx_value: Label = $Center/Panel/VBox/Grid/SfxValue
@onready var fullscreen_button: Button = $Center/Panel/VBox/FullscreenButton
@onready var back_button: Button = $Center/Panel/VBox/BackButton
@onready var title: Label = $Center/Panel/VBox/Title


func _ready() -> void:
	visible = false
	title.add_theme_font_override("font", Palette.FONT_BOLD)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	sfx_slider.drag_ended.connect(func(_changed: bool) -> void: Audio.play(&"pickup", 0.0))
	fullscreen_button.pressed.connect(_on_fullscreen)
	back_button.pressed.connect(_on_back)
	# Full screen only makes sense on desktop and web.
	fullscreen_button.visible = not OS.has_feature("mobile")
	# Players where consent law applies (EEA, UK) must be able to change their ad consent.
	_privacy_button = Button.new()
	_privacy_button.text = "Privacidad de anuncios"
	_privacy_button.custom_minimum_size = fullscreen_button.custom_minimum_size
	_privacy_button.pressed.connect(func() -> void:
		Audio.play(&"click", 0.0)
		Ads.show_privacy_options())
	back_button.add_sibling(_privacy_button)
	back_button.get_parent().move_child(_privacy_button, back_button.get_index())


func open() -> void:
	music_slider.set_value_no_signal(Settings.music_volume)
	sfx_slider.set_value_no_signal(Settings.sfx_volume)
	_update_labels()
	_privacy_button.visible = Ads.privacy_options_required()
	visible = true
	back_button.grab_focus()


func close() -> void:
	visible = false


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed(&"pause"):
		get_viewport().set_input_as_handled()
		_on_back()


func _on_music_changed(value: float) -> void:
	Settings.set_music_volume(value)
	_update_labels()


func _on_sfx_changed(value: float) -> void:
	Settings.set_sfx_volume(value)
	_update_labels()


func _on_fullscreen() -> void:
	Audio.play(&"click", 0.0)
	Settings.set_fullscreen(not Settings.fullscreen)
	_update_labels()


func _update_labels() -> void:
	music_value.text = "%d %%" % roundi(Settings.music_volume * 100.0)
	sfx_value.text = "%d %%" % roundi(Settings.sfx_volume * 100.0)
	fullscreen_button.text = "Pantalla completa: %s" % ("Sí" if Settings.fullscreen else "No")


func _on_back() -> void:
	Audio.play(&"click", 0.0)
	close()
	closed.emit()
