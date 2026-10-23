class_name MerchantDirector
extends Node2D
## Brings a merchant to the map every so often and asks to open the shop when the player reaches him.

signal merchant_arrived(rarity: int)
signal shop_requested(merchant: Merchant)

const MERCHANT_SCENE := preload("res://scenes/merchant/merchant.tscn")
const FIRST_TIME := 90.0
const INTERVAL := 80.0
const LIFETIME := 60.0
const MIN_DISTANCE := 700.0
const MAX_DISTANCE := 1000.0
const OPEN_RADIUS := 70.0
## After leaving the shop without buying, the player must walk this far before it reopens.
const REOPEN_RADIUS := 140.0
const BASE_PRICES: Array[int] = [15, 30, 50, 85, 140]
const PRICE_GROWTH := 0.25
const OFFER_COUNT := 3

var player: Player
var decorations: Decorations
var items: Array[ItemData] = []
## Tells whether an item was banished this run, so the merchant never offers it.
var is_banished: Callable = func(_item: ItemData) -> bool: return false
var merchant: Merchant
var purchases := 0
## Seconds since the run started; set by the run every frame.
var run_time := 0.0

var _next_time := FIRST_TIME
var _can_open := true


func price(item: ItemData) -> int:
	return roundi(BASE_PRICES[item.rarity] * (1.0 + PRICE_GROWTH * purchases))


func _physics_process(delta: float) -> void:
	if player == null or player.is_dead:
		return
	if merchant == null and run_time >= _next_time:
		spawn(Rarity.roll(player.luck))
	if merchant == null:
		return
	merchant.life_left -= delta
	if merchant.life_left <= 0.0:
		_leave()
		return
	var distance := merchant.position.distance_to(player.global_position)
	if not _can_open and distance > REOPEN_RADIUS:
		_can_open = true
	if _can_open and distance < OPEN_RADIUS:
		_can_open = false
		shop_requested.emit(merchant)


## Places a merchant of this rarity somewhere around the player. Also used by the debug panel.
func spawn(rarity: int) -> void:
	if merchant != null:
		_leave()
	merchant = MERCHANT_SCENE.instantiate()
	add_child(merchant)
	# Somewhere around the player, outside any crypt, tree or other solid prop.
	for i in 12:
		merchant.position = player.global_position + Vector2.from_angle(randf() * TAU) * randf_range(MIN_DISTANCE, MAX_DISTANCE)
		if decorations == null or decorations.is_free(merchant.position, OPEN_RADIUS):
			break
	merchant.setup(rarity, _pick_offers(rarity), LIFETIME)
	_can_open = true
	_next_time = run_time + INTERVAL
	merchant_arrived.emit(rarity)


func sold() -> void:
	purchases += 1
	_leave()


func _leave() -> void:
	if merchant == null:
		return
	var leaving := merchant
	merchant = null
	var tween := leaving.create_tween()
	tween.tween_property(leaving, "scale", Vector2.ZERO, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_callback(leaving.queue_free)


## Three different items of the merchant's rarity, topped up with lower rarities if needed.
func _pick_offers(rarity: int) -> Array[ItemData]:
	var result: Array[ItemData] = []
	for tier in range(rarity, -1, -1):
		var pool: Array[ItemData] = []
		for item in items:
			if item.rarity == tier and not is_banished.call(item):
				pool.append(item)
		pool.shuffle()
		for item in pool:
			if result.size() < OFFER_COUNT:
				result.append(item)
		if result.size() >= OFFER_COUNT:
			break
	return result
