class_name ReviveOffer
extends Control
## Asked once per run when the player dies: watch an ad to come back, or end the run.

signal answered(revive: bool)

var _revive_button: Button
var _end_button: Button


func _init() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	var dim := ColorRect.new()
	dim.color = Color(0.03, 0.02, 0.06, 0.6)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	center.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	panel.add_child(box)
	var title := Label.new()
	title.text = "¿Segunda oportunidad?"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 38)
	title.add_theme_color_override("font_color", Palette.GOLD)
	box.add_child(title)
	var info := Label.new()
	info.text = "Vuelves con la mitad de la vida y una onda que limpia la pantalla.\nSolo una vez por partida."
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info.add_theme_font_size_override("font_size", 20)
	box.add_child(info)
	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 16)
	box.add_child(buttons)
	_end_button = Button.new()
	_end_button.text = "Terminar"
	_end_button.custom_minimum_size = Vector2(220, 60)
	_end_button.pressed.connect(_answer.bind(false))
	buttons.add_child(_end_button)
	_revive_button = Button.new()
	_revive_button.text = "Revivir (anuncio)"
	_revive_button.custom_minimum_size = Vector2(260, 60)
	_revive_button.pressed.connect(_answer.bind(true))
	buttons.add_child(_revive_button)


## Shows the question and returns the answer. Use with `await`.
func ask() -> bool:
	visible = true
	_revive_button.grab_focus()
	return await answered


func _answer(revive: bool) -> void:
	Audio.play(&"click", 0.0)
	visible = false
	answered.emit(revive)
