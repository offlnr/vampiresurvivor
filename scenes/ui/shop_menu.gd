extends Control
## Item menu for the merchant (items with prices) and paid chests (up to three items, take one).
## Every card can be rerolled or banished.

signal bought(index: int)
signal closed
signal reroll_requested(index: int)
signal banish_requested(index: int)

const COIN_ICON := preload("res://art/placeholder/coin.svg")
const INPUT_DELAY := 0.3

var inventory: Inventory
## Returns the sections the stats panel shows; set by the run.
var stats_provider: Callable
## Returns how many copies of an item the player owns, when there is no local `inventory`
## (the online guest's items live on the host).
var owned_provider: Callable

var _chest_mode := false
var _stats_button: Button
var _stats_panel: StatsPanel

@onready var title: Label = $Center/Panel/VBox/Title
@onready var gold_label: Label = $Center/Panel/VBox/GoldRow/GoldLabel
@onready var counter: Label = $Center/Panel/VBox/Counter
@onready var cards: VBoxContainer = $Center/Panel/VBox/Cards
@onready var leave_button: Button = $Center/Panel/VBox/LeaveButton


func _ready() -> void:
	visible = false
	leave_button.pressed.connect(_on_leave)
	# "Estadísticas" goes next to "Salir", in a row that stays even when a chest hides "Salir".
	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 16)
	var box := leave_button.get_parent()
	box.add_child(actions)
	box.move_child(actions, leave_button.get_index())
	leave_button.reparent(actions)
	_stats_button = Button.new()
	_stats_button.text = "Estadísticas"
	_stats_button.custom_minimum_size = Vector2(200, 54)
	_stats_button.pressed.connect(_open_stats)
	actions.add_child(_stats_button)
	_stats_panel = StatsPanel.new()
	_stats_panel.closed.connect(_stats_button.grab_focus)
	add_child(_stats_panel)


func open(heading: String, color: Color, items: Array[ItemData], prices: Array[int], gold: int,
		rerolls: int, banishes: int, chest_mode: bool) -> void:
	_chest_mode = chest_mode
	title.text = heading
	title.add_theme_color_override("font_color", color)
	# A chest must be taken, but an empty one (should never happen) can still be left.
	leave_button.visible = not chest_mode or items.is_empty()
	var buttons := _build(items, prices, gold, rerolls, banishes)
	visible = true
	get_tree().paused = true
	Audio.play(&"click", 0.0)
	if chest_mode and not buttons.is_empty():
		buttons[0].grab_focus()
	else:
		leave_button.grab_focus()
	for button in buttons:
		button.set_meta(&"affordable", not button.disabled)
		button.disabled = true
	await get_tree().create_timer(INPUT_DELAY, true).timeout
	for button in buttons:
		if is_instance_valid(button):
			button.disabled = not button.get_meta(&"affordable")


## Redraws the cards after a reroll or banish.
func refresh(items: Array[ItemData], prices: Array[int], gold: int, rerolls: int, banishes: int) -> void:
	_build(items, prices, gold, rerolls, banishes)


func close() -> void:
	visible = false
	_stats_panel.visible = false


func _open_stats() -> void:
	Audio.play(&"click", 0.0)
	if stats_provider.is_valid():
		_stats_panel.open(stats_provider.call())


func card_button(index: int) -> Button:
	return cards.get_child(index).get_child(0)


func _build(items: Array[ItemData], prices: Array[int], gold: int, rerolls: int, banishes: int) -> Array[Button]:
	gold_label.text = str(gold)
	counter.text = UiCards.counter_text(rerolls, banishes)
	for child in cards.get_children():
		cards.remove_child(child)
		child.queue_free()
	var buttons: Array[Button] = []
	for i in items.size():
		var item := items[i]
		var affordable := gold >= prices[i]
		var owned: int = inventory.copies(item) if inventory != null else (owned_provider.call(item) if owned_provider.is_valid() else 0)
		var row := UiCards.make_row(item.icon, item.rarity, "Tienes %d" % owned if owned > 0 else "Nuevo",
			item.display_name, item.describe(), _on_buy.bind(i), rerolls > 0, banishes > 0,
			reroll_requested.emit.bind(i), banish_requested.emit.bind(i), _footer(prices[i], affordable), affordable)
		cards.add_child(row)
		buttons.append(row.get_child(0))
	return buttons


func _footer(price: int, affordable: bool) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	if _chest_mode:
		var take := Label.new()
		take.text = "Tomar"
		take.add_theme_font_size_override("font_size", 18)
		take.add_theme_color_override("font_color", Palette.GOLD)
		row.add_child(take)
		return row
	var coin := TextureRect.new()
	coin.texture = COIN_ICON
	coin.custom_minimum_size = Vector2(18, 18)
	coin.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	coin.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	coin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(coin)
	var price_label := Label.new()
	price_label.text = str(price)
	price_label.add_theme_font_size_override("font_size", 20)
	price_label.add_theme_color_override("font_color", Palette.GOLD if affordable else Palette.RED)
	row.add_child(price_label)
	return row


func _unhandled_input(event: InputEvent) -> void:
	if visible and not _chest_mode and not _stats_panel.visible and event.is_action_pressed(&"pause"):
		get_viewport().set_input_as_handled()
		_on_leave()


func _on_buy(index: int) -> void:
	Audio.play(&"buy", 0.0)
	bought.emit(index)


func _on_leave() -> void:
	Audio.play(&"click", 0.0)
	closed.emit()
