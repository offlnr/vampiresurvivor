extends Control
## Pauses the run and lets the player pick one of the offered upgrades, shown as a vertical list.

signal chosen(offer: Dictionary)
signal reroll_requested(index: int)
signal banish_requested(index: int)
signal skip_requested
## The player wants to watch an ad for one more reroll.
signal ad_reroll_requested

## Ignores input for a moment so a player mashing keys doesn't pick by accident.
const INPUT_DELAY := 0.35

## Offers currently on screen, in card order.
var offers_shown: Array[Dictionary] = []
## Skips left this run; set by the run before opening the menu.
var skips_left := 0
## Returns the sections the stats panel shows; set by the run.
var stats_provider: Callable
## Rerolls left to earn with ads this run; set by the run.
var ad_rerolls_left := 0

var _skip_button: Button
var _stats_button: Button
var _ad_button: Button
var _stats_panel: StatsPanel

@onready var panel: PanelContainer = $Center/Panel
@onready var title: Label = $Center/Panel/VBox/Title
@onready var counter: Label = $Center/Panel/VBox/Counter
@onready var cards: VBoxContainer = $Center/Panel/VBox/Cards


func _ready() -> void:
	visible = false
	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 16)
	cards.get_parent().add_child(actions)
	# As in Megabonk: turn the choice down without spending a banish.
	_skip_button = Button.new()
	_skip_button.text = "Saltar"
	_skip_button.custom_minimum_size = Vector2(200, 52)
	_skip_button.pressed.connect(_on_skip_pressed)
	actions.add_child(_skip_button)
	_stats_button = Button.new()
	_stats_button.text = "Estadísticas"
	_stats_button.custom_minimum_size = Vector2(200, 52)
	_stats_button.pressed.connect(_open_stats)
	actions.add_child(_stats_button)
	_ad_button = Button.new()
	_ad_button.text = "+1 tirada (anuncio)"
	_ad_button.custom_minimum_size = Vector2(220, 52)
	_ad_button.pressed.connect(func() -> void:
		Audio.play(&"click", 0.0)
		ad_reroll_requested.emit())
	actions.add_child(_ad_button)
	Ads.availability_changed.connect(func() -> void: _ad_button.visible = ad_rerolls_left > 0 and Ads.is_available())
	_stats_panel = StatsPanel.new()
	_stats_panel.closed.connect(_stats_button.grab_focus)
	add_child(_stats_panel)


func open(offers: Array[Dictionary], heading := "¡Subiste de nivel!", rerolls := 0, banishes := 0) -> void:
	title.text = heading
	var buttons := _show_offers(offers, rerolls, banishes)
	visible = true
	get_tree().paused = true
	panel.scale = Vector2.ONE * 0.85
	panel.pivot_offset = panel.size / 2.0
	create_tween().tween_property(panel, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	for button in buttons:
		button.disabled = true
	_skip_button.disabled = true
	await get_tree().create_timer(INPUT_DELAY, true).timeout
	for button in buttons:
		if is_instance_valid(button):
			button.disabled = false
	_skip_button.disabled = skips_left <= 0
	if not buttons.is_empty() and is_instance_valid(buttons[0]):
		buttons[0].grab_focus()


func close() -> void:
	visible = false
	_stats_panel.visible = false


func _open_stats() -> void:
	Audio.play(&"click", 0.0)
	if stats_provider.is_valid():
		_stats_panel.open(stats_provider.call())


## Swaps one card after a reroll or banish, keeping the others.
func replace_offer(index: int, offer: Dictionary, rerolls: int, banishes: int) -> void:
	var offers := offers_shown.duplicate()
	offers[index] = offer
	_show_offers(offers, rerolls, banishes)
	card_button(index).grab_focus()


## The clickable card at `index`.
func card_button(index: int) -> Button:
	return cards.get_child(index).get_child(0)


## Redraws the cards with new reroll and banish counts (after an ad reroll).
func set_counts(rerolls: int, banishes: int) -> void:
	_show_offers(offers_shown, rerolls, banishes)
	card_button(0).grab_focus()


func _show_offers(offers: Array[Dictionary], rerolls: int, banishes: int) -> Array[Button]:
	offers_shown = offers
	_ad_button.visible = ad_rerolls_left > 0 and Ads.is_available()
	counter.text = UiCards.counter_text(rerolls, banishes, skips_left)
	_skip_button.disabled = skips_left <= 0
	for child in cards.get_children():
		cards.remove_child(child)
		child.queue_free()
	var buttons: Array[Button] = []
	for i in offers.size():
		var offer := offers[i]
		var row := UiCards.make_row(offer.icon, offer.rarity, offer.tag, offer.title, offer.description,
			_on_card_pressed.bind(offer), rerolls > 0, banishes > 0 and offer.has("key"),
			reroll_requested.emit.bind(i), banish_requested.emit.bind(i))
		cards.add_child(row)
		buttons.append(row.get_child(0))
	return buttons


func _on_skip_pressed() -> void:
	Audio.play(&"click", 0.0)
	skip_requested.emit()


func _on_card_pressed(offer: Dictionary) -> void:
	Audio.play(&"click", 0.0)
	chosen.emit(offer)
