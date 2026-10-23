extends Control
## End-of-run screen shown when the player dies, with the best time.

signal retry_requested
signal menu_requested
## The player wants to watch an ad to get this run's silver again.
signal double_silver_requested(earned: int)

@onready var panel: PanelContainer = $Center/Panel
@onready var title: Label = $Center/Panel/VBox/Title
@onready var subtitle: Label = $Center/Panel/VBox/Subtitle
@onready var time_value: Label = $Center/Panel/VBox/Stats/TimeValue
@onready var level_value: Label = $Center/Panel/VBox/Stats/LevelValue
@onready var kills_value: Label = $Center/Panel/VBox/Stats/KillsValue
@onready var record_value: Label = $Center/Panel/VBox/Stats/RecordValue
@onready var retry_button: Button = $Center/Panel/VBox/Buttons/RetryButton
@onready var menu_button: Button = $Center/Panel/VBox/Buttons/MenuButton
@onready var stats_grid: GridContainer = $Center/Panel/VBox/Stats

var _rewards: VBoxContainer
var _silver_label: Label
var _double_button: Button


func _ready() -> void:
	visible = false
	retry_button.pressed.connect(retry_requested.emit)
	menu_button.pressed.connect(menu_requested.emit)
	_rewards = VBoxContainer.new()
	_rewards.add_theme_constant_override("separation", 2)
	var box := stats_grid.get_parent()
	box.add_child(_rewards)
	box.move_child(_rewards, stats_grid.get_index() + 1)


## Silver earned and the challenges this run completed (now buyable in "Desbloqueos").
func show_rewards(earned: int, total: int, completed: Array) -> void:
	for child in _rewards.get_children():
		child.queue_free()
	_silver_label = _label("+%d de plata  (tienes %d)" % [earned, total], 24, Palette.BONE)
	_rewards.add_child(_silver_label)
	if earned > 0 and Ads.is_available():
		_double_button = Button.new()
		_double_button.text = "×2 de plata (anuncio)"
		_double_button.custom_minimum_size = Vector2(260, 50)
		_double_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		_double_button.pressed.connect(func() -> void:
			Audio.play(&"click", 0.0)
			double_silver_requested.emit(earned))
		_rewards.add_child(_double_button)
	for e: Dictionary in completed:
		var data: Resource = load(e.path)
		_rewards.add_child(_label("¡Desafío cumplido! %s ya se puede desbloquear" % data.display_name, 19, Palette.GOLD))


func silver_doubled(earned: int, total: int) -> void:
	_silver_label.text = "+%d de plata  (tienes %d)" % [earned, total]
	_silver_label.add_theme_color_override("font_color", Palette.GOLD)
	Audio.play(&"coin", 0.0)
	if is_instance_valid(_double_button):
		_double_button.queue_free()
	retry_button.grab_focus()


func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func show_result(seconds: float, level: int, kills: int, new_record: bool) -> void:
	title.text = "Has caído..."
	title.add_theme_color_override("font_color", Palette.RED)
	if new_record:
		subtitle.text = "¡Nuevo récord!"
		subtitle.add_theme_color_override("font_color", Palette.GOLD)
		Audio.play(&"victory", 0.0)
	else:
		subtitle.text = "La noche se llevó tu alma."
		subtitle.remove_theme_color_override("font_color")
	time_value.text = Settings.format_time(seconds)
	record_value.text = Settings.format_time(Settings.best_time)
	level_value.text = str(level)
	kills_value.text = str(kills)
	visible = true
	get_tree().paused = true
	panel.modulate.a = 0.0
	create_tween().tween_property(panel, "modulate:a", 1.0, 0.4)
	retry_button.grab_focus()
