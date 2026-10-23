extends Control
## Title screen with a night sky, drifting bats and the main buttons.

const RUN_SCENE := "res://scenes/main/run.tscn"
const BAT_FRAMES := preload("res://art/placeholder/bat/bat_frames.tres")
const MUSIC := preload("res://art/placeholder/audio/music_night.wav")
const BAT_COUNT := 7
## Silver given once a day for watching an optional ad.
const DAILY_GIFT_SILVER := 5

var _bats: Array[Dictionary] = []
var _unlocks_button: Button
var _unlocks_menu: UnlocksMenu
var _online_button: Button
var _online_menu: MultiplayerMenu
var _gift_button: Button
var _time := 0.0

@onready var title: Label = $Center/VBox/Title
@onready var play_button: Button = $Center/VBox/PlayButton
@onready var options_button: Button = $Center/VBox/OptionsButton
@onready var quit_button: Button = $Center/VBox/QuitButton
@onready var options_menu: Control = $OptionsMenu
@onready var bats_layer: Control = $Bats
@onready var moon: TextureRect = $Moon
@onready var record: Label = $Center/VBox/Record


func _ready() -> void:
	get_tree().paused = false
	play_button.pressed.connect(_on_play)
	options_button.pressed.connect(_on_options)
	quit_button.pressed.connect(get_tree().quit)
	# Quitting makes no sense in a browser tab or on a phone.
	quit_button.visible = not (OS.has_feature("web") or OS.has_feature("mobile"))
	options_menu.closed.connect(options_button.grab_focus)
	title.add_theme_font_override("font", Palette.FONT_BOLD)
	# As in Megabonk: weapons, scrolls and items are unlocked between runs with silver.
	# It shares a row with "Opciones" so the menu still fits a 720 px tall screen.
	_unlocks_button = Button.new()
	_unlocks_button.text = "Desbloqueos"
	_unlocks_button.pressed.connect(_on_unlocks)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var box := options_button.get_parent()
	box.add_child(row)
	box.move_child(row, options_button.get_index())
	options_button.reparent(row)
	row.add_child(_unlocks_button)
	row.move_child(_unlocks_button, 0)
	var half := Vector2((options_button.custom_minimum_size.x - 10.0) / 2.0, options_button.custom_minimum_size.y)
	_unlocks_button.custom_minimum_size = half
	options_button.custom_minimum_size = half
	_unlocks_menu = UnlocksMenu.new()
	_unlocks_menu.closed.connect(_on_unlocks_closed)
	add_child(_unlocks_menu)
	# Online co-op, right under "Jugar".
	_online_button = Button.new()
	_online_button.text = "Multijugador online"
	_online_button.custom_minimum_size = Vector2(340, 64)
	_online_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_online_button.pressed.connect(_on_online)
	box.add_child(_online_button)
	box.move_child(_online_button, play_button.get_index() + 1)
	_online_menu = MultiplayerMenu.new()
	_online_menu.closed.connect(_online_button.grab_focus)
	add_child(_online_menu)
	# Optional daily gift (rewarded ad), in a corner so it never gets in the way.
	_gift_button = Button.new()
	_gift_button.text = "Regalo diario: +%d plata (anuncio)" % DAILY_GIFT_SILVER
	_gift_button.add_theme_font_size_override("font_size", 18)
	_gift_button.position = Vector2(16, 16)
	_gift_button.pressed.connect(_on_daily_gift)
	add_child(_gift_button)
	_update_gift_button()
	# Real ads load in the background; the button appears once one is ready.
	Ads.availability_changed.connect(_update_gift_button)
	_update_record()
	for i in BAT_COUNT:
		var bat := TextureRect.new()
		bat.texture = BAT_FRAMES.get_frame_texture(&"move", 0)
		bat.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bat.modulate = Color(1, 1, 1, randf_range(0.35, 0.8))
		var size := randf_range(0.5, 1.1)
		bat.scale = Vector2.ONE * size
		bats_layer.add_child(bat)
		_bats.append({node = bat, speed = randf_range(40, 110) * size, phase = randf() * TAU,
			y = randf_range(0.05, 0.6), x = randf()})
	play_button.grab_focus()
	Audio.play_music(MUSIC)
	get_viewport().size_changed.connect(_fit_title)
	_fit_title()


func _process(delta: float) -> void:
	_time += delta
	var screen := size
	title.pivot_offset = title.size / 2.0
	title.scale = Vector2.ONE * (1.0 + 0.025 * sin(_time * 2.0))
	title.rotation = sin(_time * 0.8) * 0.015
	moon.modulate.a = 0.85 + 0.15 * sin(_time * 0.6)
	for bat in _bats:
		bat.x += bat.speed * delta / screen.x
		if bat.x > 1.1:
			bat.x = -0.1
			bat.y = randf_range(0.05, 0.6)
		var node: TextureRect = bat.node
		node.position = Vector2(bat.x * screen.x, bat.y * screen.y + sin(_time * 2.0 + bat.phase) * 18.0)
		var frame := int(_time * 12.0 + bat.phase * 2.0) % BAT_FRAMES.get_frame_count(&"move")
		node.texture = BAT_FRAMES.get_frame_texture(&"move", frame)


func _update_record() -> void:
	var lines := PackedStringArray()
	if Settings.best_time > 0.0:
		lines.append("Récord: %s · %d enemigos" % [Settings.format_time(Settings.best_time), Settings.best_kills])
	var buyable := 0
	for e in Unlocks.ENTRIES:
		if Progress.can_buy(e):
			buyable += 1
	if Progress.silver > 0 or buyable > 0:
		lines.append("Plata: %d%s" % [Progress.silver, "  ·  ¡%d desbloqueo%s disponible%s!" % [buyable, "" if buyable == 1 else "s", "" if buyable == 1 else "s"] if buyable > 0 else ""])
	record.text = "\n".join(lines)
	record.visible = not lines.is_empty()


func _on_daily_gift() -> void:
	Audio.play(&"click", 0.0)
	if await Ads.show_rewarded(Ads.DAILY_GIFT):
		Progress.claim_daily_gift(DAILY_GIFT_SILVER)
		Audio.play(&"coin", 0.0)
	_update_gift_button()
	_update_record()
	play_button.grab_focus()


func _update_gift_button() -> void:
	_gift_button.visible = Ads.is_available() and Progress.can_claim_daily_gift()


func _on_unlocks() -> void:
	Audio.play(&"click", 0.0)
	_unlocks_menu.open()


func _on_unlocks_closed() -> void:
	_update_record()
	_unlocks_button.grab_focus()


func _fit_title() -> void:
	var portrait := size.y > size.x
	title.add_theme_font_size_override("font_size", 64 if portrait else 92)


func _on_play() -> void:
	Audio.play(&"click", 0.0)
	get_tree().change_scene_to_file(RUN_SCENE)


func _on_online() -> void:
	Audio.play(&"click", 0.0)
	_online_menu.open()


func _on_options() -> void:
	Audio.play(&"click", 0.0)
	options_menu.open()
