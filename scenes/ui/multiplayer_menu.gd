class_name MultiplayerMenu
extends Control
## Main-menu screen for online co-op: one player creates a room and reads out its code, the other
## joins with it, and the host starts the run for both. Both connect to the room server (see Net).

signal closed

const RUN_SCENE := "res://scenes/main/run.tscn"
const MAX_WIDTH := 560.0

var _server_edit: LineEdit
var _code_edit: LineEdit
var _host_button: Button
var _join_button: Button
var _start_button: Button
var _back_button: Button
var _status: Label
var _code_label: Label
var _character_button: Button
var _character_select: CharacterSelect


func _init() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	var dim := ColorRect.new()
	dim.color = Color(0.03, 0.02, 0.06, 0.85)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	center.add_child(panel)
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(MAX_WIDTH, 0)
	box.add_theme_constant_override("separation", 12)
	panel.add_child(box)

	var title := _label("Multijugador online", 38, Palette.GOLD)
	title.add_theme_font_override("font", Palette.FONT_BOLD)
	box.add_child(title)
	var hint := _label("Cooperativo para dos, cada uno en su dispositivo. Uno crea la sala y le dice el código al otro.", 18, Color(Palette.BONE, 0.75))
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(hint)

	# Each player picks their own character here; the guest's choice is sent to the host.
	_character_button = _button("", _on_character)
	box.add_child(_character_button)
	_host_button = _button("Crear sala", _on_host)
	box.add_child(_host_button)
	_code_label = _label("", 54, Palette.GOLD)
	_code_label.add_theme_font_override("font", Palette.FONT_BOLD)
	_code_label.visible = false
	box.add_child(_code_label)

	var join_row := HBoxContainer.new()
	join_row.add_theme_constant_override("separation", 10)
	box.add_child(join_row)
	_code_edit = LineEdit.new()
	_code_edit.placeholder_text = "Código de sala"
	_code_edit.max_length = 4
	_code_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	_code_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_code_edit.custom_minimum_size = Vector2(0, 56)
	_code_edit.text_submitted.connect(func(_text: String) -> void: _on_join())
	join_row.add_child(_code_edit)
	_join_button = _button("Unirse", _on_join)
	_join_button.custom_minimum_size = Vector2(170, 56)
	join_row.add_child(_join_button)

	_status = _label("", 20, Palette.BONE)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_status)
	_start_button = _button("Empezar partida", _on_start)
	_start_button.visible = false
	box.add_child(_start_button)

	var server_row := HBoxContainer.new()
	server_row.add_theme_constant_override("separation", 8)
	box.add_child(server_row)
	var server_label := _label("Servidor", 16, Color(Palette.BONE, 0.6))
	server_row.add_child(server_label)
	_server_edit = LineEdit.new()
	_server_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_server_edit.add_theme_font_size_override("font_size", 16)
	_server_edit.text_changed.connect(Net.set_server_url)
	server_row.add_child(_server_edit)

	_back_button = _button("Volver", close)
	box.add_child(_back_button)
	_character_select = CharacterSelect.new()
	_character_select.chosen.connect(_on_character_chosen)
	_character_select.closed.connect(_character_button.grab_focus)
	add_child(_character_select)

	Net.room_created.connect(_on_room_created)
	Net.joined.connect(_on_joined)
	Net.peer_joined.connect(_on_peer_joined)
	Net.peer_left.connect(_on_peer_left)
	Net.failed.connect(_on_failed)
	Net.disconnected.connect(_on_failed.bind("Se ha perdido la conexión con el servidor."))
	Net.message_received.connect(_on_message)


func open() -> void:
	_server_edit.text = Net.server_url
	_update_character_button()
	_reset("")
	visible = true
	_host_button.grab_focus()


func close() -> void:
	if not visible:
		return
	Net.leave()
	visible = false
	closed.emit()


func _reset(status: String) -> void:
	_status.text = status
	_code_label.visible = false
	_start_button.visible = false
	_host_button.disabled = false
	_join_button.disabled = false


func _on_character() -> void:
	Audio.play(&"click", 0.0)
	_character_select.open()


func _on_character_chosen(_character: CharacterData) -> void:
	_update_character_button()
	_character_button.grab_focus()
	if Net.is_guest():
		Net.send([Net.MSG_CHARACTER, Progress.character])


func _update_character_button() -> void:
	_character_button.text = "Personaje: %s" % Characters.by_id(Progress.character).display_name


func _on_host() -> void:
	Audio.play(&"click", 0.0)
	_reset("Creando sala... (si el servidor estaba dormido, puede tardar hasta un minuto)")
	_host_button.disabled = true
	Net.host_room()


func _on_join() -> void:
	Audio.play(&"click", 0.0)
	if _code_edit.text.strip_edges().length() != 4:
		_status.text = "Escribe el código de 4 letras que te ha dado tu compañero."
		return
	_reset("Uniéndote a la sala... (si el servidor estaba dormido, puede tardar hasta un minuto)")
	_join_button.disabled = true
	Net.join_room(_code_edit.text)


func _on_room_created(code: String) -> void:
	_code_label.text = code
	_code_label.visible = true
	_status.text = "Dile este código a tu compañero y espera a que se una."


func _on_joined(_code: String) -> void:
	_host_button.disabled = true
	_status.text = "¡Dentro! Espera a que tu compañero empiece la partida."


func _on_peer_joined() -> void:
	Audio.play(&"powerup", 0.0)
	_status.text = "¡Tu compañero se ha unido!"
	_start_button.visible = true
	_start_button.grab_focus()


func _on_peer_left() -> void:
	if Net.role == Net.Role.HOST:
		_start_button.visible = false
		_status.text = "Tu compañero ha salido. Espera a que vuelva a unirse con el código."
	else:
		_reset("La sala se ha cerrado.")


func _on_failed(reason: String) -> void:
	if visible:
		_reset(reason)


func _on_start() -> void:
	if not Net.is_host():
		return
	Audio.play(&"click", 0.0)
	Net.send([Net.MSG_START])
	get_tree().change_scene_to_file(RUN_SCENE)


func _on_message(message: Array) -> void:
	if visible and message[0] == Net.MSG_START and Net.is_guest():
		get_tree().change_scene_to_file(RUN_SCENE)


func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _button(text: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 56)
	button.pressed.connect(action)
	return button
