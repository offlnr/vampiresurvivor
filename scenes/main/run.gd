extends Node2D
## One run: timer, experience and levels, upgrades with rarity, chests, pause and end of the run.
## What each player owns (weapons, scrolls, items, gold, rerolls...) lives in their Seat; a solo
## run has one, online co-op two, and each levels up and shops on its own screen.

## Weapon and scroll slots: Megabonk's 4 weapons and 4 tomes once all slots are unlocked.
const MAX_WEAPONS := 4
const MAX_SCROLLS := 4
## Experience gain never goes above this multiplier, as in Megabonk.
const MAX_XP_MULTIPLIER := 10.0
const REROLLS_PER_RUN := 5
const BANISHES_PER_RUN := 5
## Times per run the player can turn down a level-up choice, as in Megabonk.
const SKIPS_PER_RUN := 5
## Share of max health healed by the fallback card.
const HEAL_FALLBACK := 0.3
const GOLD_FALLBACK := 25
const CHEST_BASE_PRICE := 25.0
const CHEST_PRICE_GROWTH := 1.35
const BOMB_SPAWN_PAUSE := 8.0
const CHEST_ITEMS := 3
## Each brewed cauldron adds this much difficulty, and this much experience and gold.
const CAULDRON_DIFFICULTY := 0.05
const CAULDRON_REWARD := 0.1
## Rewarded ads (optional, see `Ads`): one revive per run, with this share of health,
## and up to this many extra rerolls per run.
const REVIVE_HEALTH := 0.5
const AD_REROLLS_PER_RUN := 2
## Online co-op (see Net) is harder: two full builds hit the enemies, so they have more health
## and more of them are around, and each level needs more experience (both players collect it).
const COOP_ENEMY_HEALTH := 1.8
const COOP_ENEMY_COUNT := 1.35
const COOP_XP_NEEDED := 1.5
const PLAYER_SCENE := preload("res://scenes/player/player.tscn")
const MENU_SCENE := "res://scenes/main/main_menu.tscn"
const WEAPONS: Array[WeaponData] = [
	preload("res://data/weapons/orbe.tres"),
	preload("res://data/weapons/calabaza.tres"),
	preload("res://data/weapons/murcielagos.tres"),
	preload("res://data/weapons/niebla.tres"),
	preload("res://data/weapons/guadana.tres"),
	preload("res://data/weapons/hueso.tres"),
	preload("res://data/weapons/fuego_fatuo.tres"),
	preload("res://data/weapons/rayo.tres"),
	preload("res://data/weapons/brasas.tres"),
	preload("res://data/weapons/vortice.tres"),
	preload("res://data/weapons/trabuco.tres"),
]
const SCROLLS: Array[UpgradeData] = [
	preload("res://data/scrolls/vida.tres"),
	preload("res://data/scrolls/velocidad.tres"),
	preload("res://data/scrolls/iman.tres"),
	preload("res://data/scrolls/celeridad.tres"),
	preload("res://data/scrolls/dano.tres"),
	preload("res://data/scrolls/suerte.tres"),
	preload("res://data/scrolls/vampirismo.tres"),
	preload("res://data/scrolls/armadura.tres"),
	preload("res://data/scrolls/tamano.tres"),
	preload("res://data/scrolls/experiencia.tres"),
	preload("res://data/scrolls/proyectiles.tres"),
	preload("res://data/scrolls/regeneracion.tres"),
	preload("res://data/scrolls/escudo.tres"),
	preload("res://data/scrolls/evasion.tres"),
	preload("res://data/scrolls/espinas.tres"),
	preload("res://data/scrolls/precision.tres"),
	preload("res://data/scrolls/vuelo.tres"),
	preload("res://data/scrolls/duracion.tres"),
	preload("res://data/scrolls/empuje.tres"),
	preload("res://data/scrolls/codicia.tres"),
	preload("res://data/scrolls/maldito.tres"),
	preload("res://data/scrolls/caos.tres"),
	preload("res://data/scrolls/plata.tres"),
]
## Stats the chaos scroll can improve: every scroll except counts and the ones that change the run itself.
const CHAOS_EXCLUDED: Array[UpgradeData.Stat] = [UpgradeData.Stat.AMOUNT, UpgradeData.Stat.CURSE, UpgradeData.Stat.CHAOS]
## Stats a power shrine never offers: the ones chaos leaves out, and silver (it only counts after the run).
const SHRINE_EXCLUDED: Array[UpgradeData.Stat] = [UpgradeData.Stat.AMOUNT, UpgradeData.Stat.CURSE, UpgradeData.Stat.CHAOS, UpgradeData.Stat.SILVER]
const ITEMS: Array[ItemData] = [
	preload("res://data/items/rotten_pumpkin.tres"),
	preload("res://data/items/skull_candy.tres"),
	preload("res://data/items/frost_crystal.tres"),
	preload("res://data/items/coin_bag.tres"),
	preload("res://data/items/voodoo_doll.tres"),
	preload("res://data/items/elf_shoes.tres"),
	preload("res://data/items/vampire_tooth.tres"),
	preload("res://data/items/fate_candle.tres"),
	preload("res://data/items/echo_shard.tres"),
	preload("res://data/items/moldy_gloves.tres"),
	preload("res://data/items/broken_mirror.tres"),
	preload("res://data/items/skull_glasses.tres"),
	preload("res://data/items/torn_grimoire.tres"),
	preload("res://data/items/executioner_dagger.tres"),
	preload("res://data/items/soul_reaper.tres"),
	preload("res://data/items/cursed_pocket_watch.tres"),
	preload("res://data/items/sucky_magnet.tres"),
	preload("res://data/items/withered_clover.tres"),
	preload("res://data/items/sand_amulet.tres"),
	preload("res://data/items/bat_soup.tres"),
	preload("res://data/items/mandrake_salve.tres"),
	preload("res://data/items/blood_tonic.tres"),
	preload("res://data/items/forbidden_elixir.tres"),
	preload("res://data/items/slime_ring.tres"),
	preload("res://data/items/owl_monocle.tres"),
	preload("res://data/items/hunter_stake.tres"),
	preload("res://data/items/gravedigger_mallet.tres"),
	preload("res://data/items/witch_campfire.tres"),
	preload("res://data/items/coward_cloak.tres"),
	preload("res://data/items/rusty_key.tres"),
	preload("res://data/items/skull_piggy.tres"),
	preload("res://data/items/stillness_potion.tres"),
	preload("res://data/items/cursed_coin.tres"),
	preload("res://data/items/newt_eye.tres"),
	preload("res://data/items/black_cat.tres"),
	preload("res://data/items/sparking_lantern.tres"),
	preload("res://data/items/wind_boots.tres"),
	preload("res://data/items/witch_satchel.tres"),
	preload("res://data/items/bone_knuckles.tres"),
	preload("res://data/items/thirsty_dagger.tres"),
	preload("res://data/items/devil_trident.tres"),
	preload("res://data/items/phantom_shroud.tres"),
	preload("res://data/items/demonic_soul.tres"),
	preload("res://data/items/pumpkin_firecracker.tres"),
	preload("res://data/items/miasma_flask.tres"),
	preload("res://data/items/funeral_bell.tres"),
	preload("res://data/items/cursed_anvil.tres"),
	preload("res://data/items/holy_grimoire.tres"),
	preload("res://data/items/stopped_hourglass.tres"),
	preload("res://data/items/storm_orb.tres"),
	preload("res://data/items/infernal_flame.tres"),
]
const CANDY_ICON := preload("res://art/placeholder/icon_candy.svg")
const COIN_BAG_ICON := preload("res://art/placeholder/items/coin_bag.svg")
## Epic in-run music (all CC0, see CREDITS.md), shuffled one after another. volume_db evens out
## their loudness to about -16 dBFS (measured), so no track jumps out when the next one starts.
const MUSIC_PLAYLIST: Array[Dictionary] = [
	{stream = preload("res://art/music/determined_pursuit.wav"), volume_db = -1.0},
	{stream = preload("res://art/music/battle_theme_a.mp3"), volume_db = -2.7},
	{stream = preload("res://art/music/evil_approach.wav"), volume_db = 2.2},
	{stream = preload("res://art/music/spooky_loop.ogg"), volume_db = 0.4},
]

var elapsed := 0.0
var level := 1
var xp := 0
var kills := 0
var finished := false
## Experience gained by everyone (for the unlock challenges).
var xp_total := 0
## Every player's seat (see Seat): the local player's first, then the guest's in online co-op.
var seats: Array[Seat] = []
var local_seat: Seat
var guest_seat: Seat
## Paid chests opened by anyone; every one makes the next dearer.
var chests_opened := 0
var _run_recorded := false
var revive_used := false
var revive_offer: ReviveOffer
var cauldrons_brewed := 0
var bosses_defeated := 0
## Extra difficulty from the cursed scroll, on top of cauldrons.
var curse_difficulty := 0.0
var _xp_fraction := 0.0

## Every character in the run: the player, plus the guest's in online co-op.
var players: Array[Player] = []
## Online co-op, on the host: the guest's character (moved by the guest's input) and the node that
## sends the guest what to draw. On the guest: the node that draws it. See Net.
var guest_player: Player
var net_host: NetHost
var net_guest: NetGuest
## What the guest's end screen shows once the run is over; null until then.
var net_result: Variant = null
## Online host: tells the player the run waits for the guest's menu.
var _waiting_label: Label

# The local player's seat, under the names the debug panel and the tests use.
var weapons: Array[Weapon]:
	get:
		return local_seat.weapons
var scroll_levels: Dictionary:
	get:
		return local_seat.scroll_levels
var gold: int:
	get:
		return local_seat.gold
var rerolls_left: int:
	get:
		return local_seat.rerolls_left
var banishes_left: int:
	get:
		return local_seat.banishes_left
var skips_left: int:
	get:
		return local_seat.skips_left

@onready var player: Player = $World/Actors/Player
@onready var enemy_manager: EnemyManager = $World/Actors/Enemies
@onready var pickups: PickupManager = $World/Souls
@onready var projectiles: Node2D = $World/Projectiles
@onready var effects: Effects = $World/Effects
@onready var hud: Control = $UI/HUD
@onready var joystick: Control = $UI/VirtualJoystick
@onready var level_up_menu: Control = $UI/LevelUp
@onready var pause_menu: Control = $UI/PauseMenu
@onready var game_over: Control = $UI/GameOver
@onready var debug_overlay: Control = $UI/DebugOverlay
@onready var inventory: Inventory = $World/Inventory
@onready var merchants: MerchantDirector = $World/Actors/Merchants
@onready var shop_menu: Control = $UI/ShopMenu
@onready var map_chests: MapChests = $World/Actors/MapChests
@onready var cauldrons: Cauldrons = $World/Actors/Cauldrons
@onready var shrines: Shrines = $World/Actors/Shrines
@onready var decorations: Decorations = $World/Actors/Decorations


func _ready() -> void:
	get_tree().paused = false
	if Net.is_guest():
		_setup_guest()
		return
	player.enemies = enemy_manager
	enemy_manager.player = player
	enemy_manager.effects = effects
	enemy_manager.pickups = pickups
	pickups.player = player
	pickups.enemies = enemy_manager
	pickups.inventory = inventory
	inventory.player = player
	inventory.enemies = enemy_manager
	inventory.pickups = pickups
	inventory.effects = effects
	player.inventory = inventory
	enemy_manager.inventory = inventory
	merchants.player = player
	local_seat = _new_seat(player, inventory, func(key: String) -> bool: return Progress.is_unlocked(key))
	seats = [local_seat]
	merchants.items = local_seat.item_pool
	shop_menu.inventory = inventory
	merchants.is_banished = func(item: ItemData) -> bool: return local_seat.banished.has(_item_key(item))
	map_chests.player = player
	map_chests.price = chest_price()
	cauldrons.player = player
	shrines.player = player
	shrines.decorations = decorations
	decorations.player = player
	player.decorations = decorations
	enemy_manager.decorations = decorations
	pickups.decorations = decorations
	cauldrons.decorations = decorations
	map_chests.decorations = decorations
	merchants.decorations = decorations
	hud.minimap.run = self

	player.health_changed.connect(hud.set_health)
	player.died.connect(_on_player_died)
	pickups.collected.connect(_on_xp_collected)
	pickups.chest_opened.connect(_on_chest_opened)
	pickups.gold_collected.connect(_on_gold_collected)
	pickups.power_up_collected.connect(_on_power_up)
	inventory.changed.connect(func() -> void: hud.set_items(inventory.stacks))
	inventory.gold_gained.connect(func(amount: int) -> void: _add_gold(local_seat, amount))
	merchants.merchant_arrived.connect(hud.show_merchant)
	merchants.shop_requested.connect(_on_shop_requested)
	shop_menu.bought.connect(func(index: int) -> void: _on_item_bought(local_seat, index))
	shop_menu.closed.connect(func() -> void: _on_shop_closed(local_seat))
	shop_menu.reroll_requested.connect(func(index: int) -> void: _on_shop_reroll(local_seat, index))
	shop_menu.banish_requested.connect(func(index: int) -> void: _on_shop_banish(local_seat, index))
	map_chests.chest_touched.connect(_on_map_chest_touched)
	cauldrons.brewed.connect(_on_cauldron_brewed)
	shrines.shrine_charged.connect(_on_shrine_charged)
	shrines.magnet_used.connect(_on_magnet_used)
	level_up_menu.reroll_requested.connect(func(index: int) -> void: _on_card_reroll(local_seat, index))
	level_up_menu.banish_requested.connect(func(index: int) -> void: _on_card_banish(local_seat, index))
	level_up_menu.skip_requested.connect(func() -> void: _on_card_skip(local_seat))
	level_up_menu.chosen.connect(func(offer: Dictionary) -> void: _on_upgrade_chosen(local_seat, offer))
	enemy_manager.horde_warning.connect(hud.show_horde_warning)
	enemy_manager.horde_started.connect(hud.show_horde_started)
	enemy_manager.boss_warning.connect(_on_boss_warning)
	enemy_manager.boss_started.connect(_on_boss_started)
	enemy_manager.boss_defeated.connect(_on_boss_defeated)
	Events.enemy_killed.connect(_on_enemy_killed)
	hud.pause_pressed.connect(open_pause)
	level_up_menu.stats_provider = func() -> Array[Dictionary]: return stats_sections(local_seat)
	level_up_menu.ad_reroll_requested.connect(_on_ad_reroll)
	game_over.double_silver_requested.connect(_on_double_silver)
	revive_offer = ReviveOffer.new()
	$UI.add_child(revive_offer)
	shop_menu.stats_provider = level_up_menu.stats_provider
	pause_menu.resume_requested.connect(_resume)
	pause_menu.quit_requested.connect(_go_to_menu)
	game_over.retry_requested.connect(_retry)
	game_over.menu_requested.connect(_go_to_menu)
	joystick.blocked_rects = func() -> Array[Rect2]: return [hud.pause_button_rect()]
	if is_instance_valid(debug_overlay):
		debug_overlay.run = self
	players = [player]
	enemy_manager.players = players
	pickups.players = players
	merchants.players = players
	map_chests.players = players
	cauldrons.players = players
	shrines.players = players
	_start_character(local_seat, Characters.by_id(Progress.character))
	if Net.is_host():
		_setup_host()

	hud.set_health(player.health, player.max_health)
	hud.set_xp(xp, xp_to_next_level(), level)
	hud.set_kills(kills)
	hud.set_time(elapsed)
	Audio.play_playlist(MUSIC_PLAYLIST)


func _process(delta: float) -> void:
	if finished:
		return
	elapsed += delta
	enemy_manager.run_time = elapsed
	merchants.run_time = elapsed
	map_chests.run_time = elapsed
	hud.set_time(elapsed)
	hud.set_buffs(player.buffs)
	var boss := enemy_manager.boss
	hud.set_boss(boss.data.display_name if boss != null else "", maxf(boss.health, 0.0) / boss.max_health if boss != null else -1.0)
	for seat in seats:
		seat.best_no_hit = maxf(seat.best_no_hit, seat.player.time_since_hit())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause"):
		get_viewport().set_input_as_handled()
		open_pause()


func _notification(what: int) -> void:
	# Online, switching windows must not stop the game for the other player.
	if (what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED) and not Net.is_online():
		open_pause()


## A seat for this character, offered what `unlocked` says its player has unlocked.
func _new_seat(owner_player: Player, owner_inventory: Inventory, unlocked: Callable) -> Seat:
	var seat := Seat.new(owner_player, owner_inventory, REROLLS_PER_RUN, BANISHES_PER_RUN, SKIPS_PER_RUN, AD_REROLLS_PER_RUN)
	for data in WEAPONS:
		if unlocked.call("weapon:%s" % data.id):
			seat.weapon_pool.append(data)
	for scroll in SCROLLS:
		if unlocked.call("scroll:%s" % scroll.id):
			seat.scroll_pool.append(scroll)
	for item in ITEMS:
		if unlocked.call("item:%s" % item.id):
			seat.item_pool.append(item)
	return seat


func _seat_of(character: Player) -> Seat:
	for seat in seats:
		if seat.player == character:
			return seat
	return local_seat


## Gives the seat's player this character: its look, its starting weapon (offered for upgrades
## even if that weapon is still locked) and its passive bonuses.
func _start_character(seat: Seat, character: CharacterData) -> void:
	seat.character = character
	seat.player.set_frames(character.frames)
	if not seat.weapon_pool.has(character.starting_weapon):
		seat.weapon_pool.append(character.starting_weapon)
	add_weapon(character.starting_weapon, seat)
	for i in character.bonus_stats.size():
		_apply_stat(character.bonus_stats[i], character.bonus_values[i], seat)


## Online co-op host: the guest's character joins the run next to the player, with its own seat.
func _setup_host() -> void:
	guest_player = PLAYER_SCENE.instantiate()
	guest_player.name = "Guest"
	guest_player.remote_input = true
	guest_player.get_node("Camera").enabled = false
	guest_player.enemies = enemy_manager
	guest_player.decorations = decorations
	player.get_parent().add_child(guest_player)
	guest_player.global_position = player.global_position + Vector2(70, 0)
	guest_player.died.connect(_on_player_died)
	var guest_inventory := Inventory.new()
	guest_inventory.name = "GuestInventory"
	guest_inventory.player = guest_player
	guest_inventory.enemies = enemy_manager
	guest_inventory.pickups = pickups
	guest_inventory.effects = effects
	inventory.get_parent().add_child(guest_inventory)
	guest_player.inventory = guest_inventory
	guest_seat = _new_seat(guest_player, guest_inventory,
		func(key: String) -> bool: return Net.guest_unlocked.has(key) or Unlocks.entry(key).is_empty())
	guest_seat.remote = true
	guest_inventory.gold_gained.connect(func(amount: int) -> void:
		if guest_seat != null:
			_add_gold(guest_seat, amount))
	seats.append(guest_seat)
	players.append(guest_player)
	enemy_manager.coop_health = COOP_ENEMY_HEALTH
	enemy_manager.coop_count = COOP_ENEMY_COUNT
	net_host = NetHost.new()
	net_host.setup(self, guest_player)
	add_child(net_host)
	Net.peer_left.connect(on_guest_left)
	merchants.merchant_arrived.connect(func(rarity: int) -> void: net_host.queue_event(&"show_merchant", [rarity]))
	enemy_manager.horde_warning.connect(func(title: String) -> void: net_host.queue_event(&"show_horde_warning", [title]))
	enemy_manager.horde_started.connect(func(title: String) -> void: net_host.queue_event(&"show_horde_started", [title]))
	_waiting_label = Label.new()
	_waiting_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_waiting_label.add_theme_font_size_override("font_size", 26)
	_waiting_label.add_theme_constant_override("outline_size", 8)
	_waiting_label.add_theme_color_override("font_outline_color", Palette.INK)
	_waiting_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_waiting_label.offset_left = -360
	_waiting_label.offset_right = 360
	_waiting_label.offset_top = 150
	_waiting_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_waiting_label.visible = false
	$UI.add_child(_waiting_label)
	var guest_character := Characters.by_id(Net.guest_character)
	_start_character(guest_seat, guest_character)
	if guest_character == local_seat.character:
		# Same character for both: the guest's is bluish, so each player tells theirs apart.
		guest_player.get_node("Visual/Sprite").modulate = Color(0.7, 0.88, 1.2)


## Online co-op guest: nothing is simulated here, NetGuest draws what the host sends.
func _setup_guest() -> void:
	set_process(false)
	if is_instance_valid(debug_overlay):
		debug_overlay.queue_free()
	net_guest = NetGuest.new()
	add_child(net_guest)
	net_guest.setup(self)
	hud.pause_pressed.connect(open_pause)
	pause_menu.resume_requested.connect(_resume)
	pause_menu.quit_requested.connect(_go_to_menu)
	game_over.menu_requested.connect(_go_to_menu)
	joystick.blocked_rects = func() -> Array[Rect2]: return [hud.pause_button_rect()]
	Audio.play_playlist(MUSIC_PLAYLIST)


## The guest left or lost the connection: the host goes on alone.
func on_guest_left() -> void:
	if guest_player == null:
		return
	# Its weapons' projectiles may still be flying, so the character stays, out of the game.
	players.erase(guest_player)
	seats.erase(guest_seat)
	guest_player.is_dead = true
	guest_player.visible = false
	guest_player.process_mode = Node.PROCESS_MODE_DISABLED
	guest_player = null
	guest_seat = null
	enemy_manager.coop_health = 1.0
	enemy_manager.coop_count = 1.0
	if net_host != null:
		net_host.queue_free()
		net_host = null
	Net.leave()
	hud.show_message("Tu compañero ha salido de la partida", Palette.PURPLE_LIGHT, 2.4)
	hud.set_xp(xp, xp_to_next_level(), level)
	_update_pause()
	if player.is_dead:
		_finish()


## Messages from the guest's level-up and item menus (see NetGuest).
func on_guest_action(action: Array) -> void:
	if guest_seat == null or action.is_empty():
		return
	var index: int = action[1] if action.size() > 1 else -1
	match String(action[0]):
		"choose":
			if index >= 0 and index < guest_seat.offers.size():
				_on_upgrade_chosen(guest_seat, guest_seat.offers[index])
		"reroll":
			_on_card_reroll(guest_seat, index)
		"banish":
			_on_card_banish(guest_seat, index)
		"skip":
			_on_card_skip(guest_seat)
		"ad_reroll":
			# The guest already watched the ad on its own device.
			if guest_seat.ad_rerolls_left > 0 and guest_seat.menu == &"level_up":
				guest_seat.ad_rerolls_left -= 1
				guest_seat.rerolls_left += 1
				net_host.send_menu([&"counts", guest_seat.rerolls_left, guest_seat.banishes_left, guest_seat.ad_rerolls_left])
		"buy":
			_on_item_bought(guest_seat, index)
		"shop_reroll":
			_on_shop_reroll(guest_seat, index)
		"shop_banish":
			_on_shop_banish(guest_seat, index)
		"shop_close":
			_on_shop_closed(guest_seat)


func xp_to_next_level() -> int:
	# Like Megabonk: the first levels come fast, later ones get steep.
	var n := level - 1
	var needed := 3.0 + 2.0 * n + 0.45 * n * n + 0.03 * n * n * n
	return roundi(needed * (COOP_XP_NEEDED if guest_seat != null else 1.0))


func add_weapon(data: WeaponData, seat: Seat = null) -> void:
	if seat == null:
		seat = local_seat
	var weapon: Weapon = data.scene.instantiate()
	seat.player.weapons.add_child(weapon)
	weapon.setup(data, seat.player, enemy_manager, projectiles)
	seat.weapons.append(weapon)
	_refresh_inventory()


func open_pause() -> void:
	if finished or not is_inside_tree() or get_tree().paused:
		return
	pause_menu.open()


func build_offers(minimum_rarity := Rarity.Tier.COMMON, seat: Seat = null, kind := &"level") -> Array[Dictionary]:
	if seat == null:
		seat = local_seat
	var pool := _shrine_candidates() if kind == &"shrine" else _offer_candidates(seat)
	pool.shuffle()
	var offers: Array[Dictionary] = []
	for candidate in pool.slice(0, 3):
		offers.append(_finish_offer(candidate, minimum_rarity, seat))
	if offers.is_empty():
		offers = _fallback_offers(minimum_rarity)
	return offers


## Every option that could appear on a level-up card right now (without rarity).
func _offer_candidates(seat: Seat) -> Array[Dictionary]:
	var pool: Array[Dictionary] = []
	for data in seat.weapon_pool:
		var key := "weapon:%s" % data.id
		if seat.banished.has(key):
			continue
		var owned := seat.owned_weapon(data)
		if owned == null and seat.weapons.size() < MAX_WEAPONS:
			pool.append({kind = &"new_weapon", key = key, weapon = data, title = data.display_name,
				base_description = data.description, icon = data.icon, tag = "¡Nueva arma!"})
		elif owned != null:
			pool.append({kind = &"weapon_level", key = key, weapon = data, title = data.display_name,
				icon = data.icon, tag = "Nivel %d" % (owned.level + 1)})
	for scroll in seat.scroll_pool:
		var key := "scroll:%s" % scroll.id
		var current: int = seat.scroll_levels.get(scroll, 0)
		if seat.banished.has(key) or (current == 0 and seat.scroll_levels.size() >= MAX_SCROLLS):
			continue
		pool.append({kind = &"scroll", key = key, upgrade = scroll, title = scroll.display_name, icon = scroll.icon,
			tag = "¡Nuevo pergamino!" if current == 0 else "Nivel %d" % (current + 1)})
	return pool


## What a power shrine can offer: an upgrade of the character's own stats (as much as a scroll of
## that rarity gives), which doesn't take a scroll slot. Not limited by unlocks, as in Megabonk.
func _shrine_candidates() -> Array[Dictionary]:
	var pool: Array[Dictionary] = []
	for scroll in SCROLLS:
		if not SHRINE_EXCLUDED.has(scroll.stat):
			pool.append({kind = &"stat", id = "stat:%s" % scroll.id, upgrade = scroll, title = _stat_title(scroll),
				icon = scroll.icon, tag = "Mejora del personaje"})
	return pool


## "Pergamino de velocidad" -> "Velocidad", "Pergamino del imán" -> "Imán".
static func _stat_title(scroll: UpgradeData) -> String:
	var title := scroll.display_name
	for prefix: String in ["Pergamino del ", "Pergamino de ", "Pergamino "]:
		if title.begins_with(prefix):
			title = title.substr(prefix.length())
			break
	return title.left(1).to_upper() + title.substr(1)


## Rolls the rarity (new weapons are always common) and the weapon upgrade, and writes the text.
func _finish_offer(candidate: Dictionary, minimum_rarity: int, seat: Seat) -> Dictionary:
	var offer := candidate.duplicate()
	offer.rarity = Rarity.Tier.COMMON if offer.kind == &"new_weapon" else Rarity.roll(seat.player.luck, minimum_rarity)
	if offer.kind == &"weapon_level":
		offer.upgrade = seat.owned_weapon(offer.weapon).roll_upgrade(offer.rarity)
	elif offer.kind == &"scroll" or offer.kind == &"stat":
		var scroll: UpgradeData = offer.upgrade
		offer.amount = scroll.roll_amount(offer.rarity)
	offer.description = _describe(offer)
	return offer


func _fallback_offers(minimum_rarity: int) -> Array[Dictionary]:
	return [
		{kind = &"heal", title = "Caramelo de medianoche", rarity = minimum_rarity,
			description = "Recupera un %d %% de vida." % roundi(HEAL_FALLBACK * 100.0), icon = CANDY_ICON, tag = "Premio"},
		{kind = &"gold", title = "Bolsa de calaveras", rarity = minimum_rarity,
			description = "+%d de oro." % GOLD_FALLBACK, icon = COIN_BAG_ICON, tag = "Premio"},
	]


## A new offer for card `index` that differs from every card on screen. Empty if there is none.
func replacement_offer(offers: Array[Dictionary], index: int, minimum_rarity: int, seat: Seat = null, kind := &"level") -> Dictionary:
	if seat == null:
		seat = local_seat
	var taken := {}
	for offer in offers:
		taken[_offer_id(offer)] = true
	var pool: Array[Dictionary] = []
	for candidate in _shrine_candidates() if kind == &"shrine" else _offer_candidates(seat):
		if not taken.has(_offer_id(candidate)):
			pool.append(candidate)
	if pool.is_empty():
		return {}
	return _finish_offer(pool.pick_random(), minimum_rarity, seat)


## What tells two offers apart: the banish key, or the stat of a shrine upgrade.
static func _offer_id(offer: Dictionary) -> String:
	return offer.get("key", offer.get("id", ""))


func apply_offer(offer: Dictionary, seat: Seat = null) -> void:
	if seat == null:
		seat = local_seat
	var rarity: int = offer.rarity
	match offer.kind:
		&"new_weapon":
			add_weapon(offer.weapon, seat)
		&"weapon_level":
			seat.owned_weapon(offer.weapon).apply_upgrade(offer.upgrade)
			_refresh_inventory()
		&"scroll":
			var scroll: UpgradeData = offer.upgrade
			seat.scroll_levels[scroll] = seat.scroll_levels.get(scroll, 0) + 1
			_apply_scroll(scroll, offer.get("amount", scroll.roll_amount(rarity)), seat)
			_refresh_inventory()
		&"stat":
			var stat_scroll: UpgradeData = offer.upgrade
			_apply_stat(stat_scroll.stat, offer.amount, seat)
		&"heal":
			seat.player.heal(seat.player.max_health * HEAL_FALLBACK)
		&"gold":
			seat.gold += GOLD_FALLBACK
			_refresh_gold(seat)


func chest_price() -> int:
	return roundi(CHEST_BASE_PRICE * pow(CHEST_PRICE_GROWTH, chests_opened))


func debug_level_up() -> void:
	_on_xp_collected(xp_to_next_level() - xp)


func debug_skip(seconds: float) -> void:
	elapsed += seconds
	enemy_manager.run_time = elapsed
	enemy_manager.sync_horde_clock()


func debug_chest() -> void:
	_on_chest_opened()


func debug_gold(amount: int) -> void:
	local_seat.gold += amount
	_refresh_gold(local_seat)


func debug_cauldron() -> void:
	_on_cauldron_brewed(player.global_position)


func debug_shrine() -> void:
	_on_shrine_charged(player.global_position, player)


func debug_magnet() -> void:
	_on_magnet_used(player.global_position, player)


func debug_boss() -> void:
	enemy_manager.start_boss()


func debug_power_up() -> void:
	pickups.spawn_power_up(player.global_position + Vector2(90, 0), PowerUps.roll())


## Power-ups help every character in the run, whoever picked them up.
func apply_power_up(kind: StringName) -> void:
	effects.shockwave(player.global_position, Palette.GOLD, 1.2)
	match kind:
		&"heart":
			for p in players:
				if not p.is_dead:
					p.heal(p.max_health * PowerUps.HEART_HEAL)
		&"candy":
			for p in players:
				if not p.is_dead:
					p.heal(p.max_health * PowerUps.CANDY_HEAL)
		&"magnet":
			pickups.attract_all()
		&"clock":
			enemy_manager.stop_time(PowerUps.duration(kind))
			for p in players:
				p.add_buff(kind, PowerUps.duration(kind))
			Audio.play(&"tick", 0.0)
		&"bomb":
			effects.shockwave(player.global_position, Palette.ORANGE, 6.0)
			Audio.play(&"boom", 0.0)
			enemy_manager.detonate(PowerUps.BOMB_ELITE_DAMAGE)
			enemy_manager.pause_spawning(BOMB_SPAWN_PAUSE)
		_:
			for p in players:
				p.add_buff(kind, PowerUps.duration(kind))


func _apply_scroll(scroll: UpgradeData, amount: float, seat: Seat = null) -> void:
	_apply_stat(scroll.stat, amount, seat)


## Raises one of the character's stats, from a scroll, a power shrine or the character's passive.
func _apply_stat(stat: int, amount: float, seat: Seat = null) -> void:
	if seat == null:
		seat = local_seat
	var p := seat.player
	match stat:
		UpgradeData.Stat.MAX_HEALTH:
			p.increase_max_health(Player.BASE_MAX_HEALTH * amount)
		UpgradeData.Stat.MOVE_SPEED:
			p.speed_multiplier += amount
		UpgradeData.Stat.PICKUP_RADIUS:
			p.pickup_multiplier += amount
		UpgradeData.Stat.ATTACK_SPEED:
			p.attack_speed_bonus += amount
		UpgradeData.Stat.DAMAGE:
			p.damage_multiplier += amount
		UpgradeData.Stat.LUCK:
			p.luck += amount
		UpgradeData.Stat.LIFESTEAL:
			p.lifesteal += amount
		UpgradeData.Stat.ARMOR:
			p.add_armor(amount)
		UpgradeData.Stat.AREA:
			p.area_multiplier += amount
		UpgradeData.Stat.XP:
			p.xp_multiplier += amount
		UpgradeData.Stat.AMOUNT:
			p.extra_amount += roundi(amount)
			for weapon in seat.weapons:
				weapon.refresh()
		UpgradeData.Stat.REGEN:
			p.regen += amount
		UpgradeData.Stat.SHIELD:
			p.add_shield(amount)
		UpgradeData.Stat.EVASION:
			p.evasion += amount
		UpgradeData.Stat.THORNS:
			p.thorns += amount
		UpgradeData.Stat.CRIT:
			p.crit_chance += amount
		UpgradeData.Stat.PROJECTILE_SPEED:
			p.projectile_speed_multiplier += amount
		UpgradeData.Stat.DURATION:
			p.duration_multiplier += amount
		UpgradeData.Stat.KNOCKBACK:
			p.knockback_multiplier += amount
		UpgradeData.Stat.GOLD:
			p.gold_bonus += amount
		UpgradeData.Stat.CURSE:
			# Like Megabonk's cursed tome and the cauldrons: harder, but pays twice as much more.
			curse_difficulty += amount
			p.xp_multiplier += amount * CAULDRON_REWARD / CAULDRON_DIFFICULTY
			p.gold_bonus += amount * CAULDRON_REWARD / CAULDRON_DIFFICULTY
			_update_difficulty()
		UpgradeData.Stat.CHAOS:
			seat.chaos_power += amount
		UpgradeData.Stat.SILVER:
			p.silver_multiplier += amount


## Chaos scroll: on every level up, a random stat gets a share of a common scroll.
func _chaos_tick(seat: Seat) -> void:
	if seat.chaos_power <= 0.0:
		return
	var pool: Array[UpgradeData] = []
	for scroll in seat.scroll_pool:
		# A banished scroll never comes back, not even through chaos.
		if not CHAOS_EXCLUDED.has(scroll.stat) and not seat.banished.has("scroll:%s" % scroll.id):
			pool.append(scroll)
	if pool.is_empty():
		return
	var scroll: UpgradeData = pool.pick_random()
	var amount := scroll.amount_per_level * seat.chaos_power
	_apply_scroll(scroll, amount, seat)
	if seat.remote:
		net_host.queue_event(&"show_chaos", [scroll.describe(amount)])
	else:
		hud.show_chaos(scroll.describe(amount))


func _update_difficulty() -> void:
	enemy_manager.difficulty = 1.0 + CAULDRON_DIFFICULTY * cauldrons_brewed + curse_difficulty
	hud.set_difficulty(enemy_manager.difficulty - 1.0)


## Everything the stats panel shows, as sections of [name, value] rows: the player's stats and the weapons.
func stats_sections(seat: Seat = null) -> Array[Dictionary]:
	if seat == null:
		seat = local_seat
	var p := seat.player
	var rows: Array = [
		["Vida", "%d / %d" % [ceili(p.health), roundi(p.max_health)]],
		["Regeneración", "%s/s" % _num(p.regen)],
		["Escudo", "%d / %d" % [ceili(p.shield), roundi(p.shield_max)]],
		["Armadura (menos daño recibido)", _pct(1.0 - p.damage_taken_multiplier)],
		["Evasión", _pct(p.dodge_chance())],
		["Espinas", _num(p.thorns * p.damage_multiplier)],
		["Robo de vida", _pct(p.lifesteal)],
		["Daño", "×%s" % _num(p.damage_multiplier * p.item_damage_multiplier(), 2)],
		["Probabilidad de crítico", _pct(seat.inventory.crit_chance())],
		["Velocidad de ataque", "+%s" % _pct(p.attack_speed())],
		["Proyectiles extra", "+%d" % p.extra_amount],
		["Tamaño", "×%s" % _num(p.area_multiplier, 2)],
		["Duración", "×%s" % _num(p.duration_multiplier, 2)],
		["Velocidad de proyectiles", "×%s" % _num(p.projectile_speed_multiplier, 2)],
		["Empuje", "×%s" % _num(p.knockback_multiplier, 2)],
		["Velocidad de movimiento", "%d" % roundi(p.move_speed())],
		["Radio de atracción", "%d" % roundi(p.pickup_radius())],
		["Suerte", _pct(p.luck)],
		["Experiencia", "×%s" % _num(minf(p.xp_multiplier, MAX_XP_MULTIPLIER), 2)],
		["Oro", "×%s" % _num(p.gold_multiplier(), 2)],
		["Dificultad", "+%s" % _pct(enemy_manager.difficulty - 1.0)],
	]
	if seat.chaos_power > 0.0:
		rows.append(["Caos por nivel", _pct(seat.chaos_power)])
	rows.append(["Plata al terminar", "×%s" % _num(p.silver_multiplier, 2)])
	var weapon_rows: Array = []
	for weapon in seat.weapons:
		var parts := PackedStringArray(["%s de daño" % _num(weapon.damage()), "cada %s s" % _num(weapon.cooldown(), 2)])
		# Only when there is more than one ("8 orbes"): some singulars read oddly alone ("tajo hacia atrás").
		var amount := int(weapon.stat(&"amount"))
		if amount > 1:
			parts.append("%d %s" % [amount, weapon.data.amount_plural])
		if int(weapon.stat(&"pierce")) > 0:
			parts.append("%s %d" % [weapon.data.pierce_label, int(weapon.stat(&"pierce"))])
		weapon_rows.append(["%s (nv. %d)" % [weapon.data.display_name, weapon.level], " · ".join(parts)])
	return [{title = "Personaje", rows = rows, compact = true}, {title = "Armas", rows = weapon_rows}]


## At most `decimals` decimals, without trailing zeros, Spanish style: "1,15", "0,5", "12".
static func _num(value: float, decimals := 1) -> String:
	var text := ("%." + str(decimals) + "f") % value
	if "." in text:
		text = text.rstrip("0").trim_suffix(".")
	return "0" if text == "-0" else text.replace(".", ",")


static func _pct(fraction: float) -> String:
	return "%s %%" % _num(fraction * 100.0)


func _describe(offer: Dictionary) -> String:
	var rarity: int = offer.rarity
	if offer.kind == &"scroll" or offer.kind == &"stat":
		var upgrade: UpgradeData = offer.upgrade
		return upgrade.describe(offer.get("amount", upgrade.roll_amount(rarity)))
	if offer.kind == &"weapon_level":
		var data: WeaponData = offer.weapon
		return data.describe_upgrade(offer.upgrade)
	return offer.base_description


## The local player's weapons and scrolls in the HUD (the guest's go in the snapshots).
func _refresh_inventory() -> void:
	hud.set_weapons(local_seat.weapons)
	var icons: Array[Dictionary] = []
	for scroll: UpgradeData in local_seat.scroll_levels:
		icons.append({icon = scroll.icon, level = local_seat.scroll_levels[scroll]})
	hud.set_passives(icons)


func _refresh_gold(seat: Seat) -> void:
	if seat == local_seat:
		hud.set_gold(seat.gold)


## Experience is shared, multiplied by the experience bonus of whoever collected it.
## Every level up gives each player a choice of their own.
func _on_xp_collected(amount: int, collector: Player = null) -> void:
	if finished:
		return
	var seat := _seat_of(collector) if collector != null else local_seat
	_xp_fraction += amount * minf(seat.player.xp_multiplier, MAX_XP_MULTIPLIER)
	var whole := floori(_xp_fraction)
	_xp_fraction -= whole
	xp += whole
	xp_total += whole
	while xp >= xp_to_next_level():
		xp -= xp_to_next_level()
		level += 1
		_revive_fallen()
		for each in seats:
			each.pending_choices.append({kind = &"level", rarity = Rarity.Tier.COMMON})
			_chaos_tick(each)
		Events.level_up.emit(level)
	hud.set_xp(xp, xp_to_next_level(), level)
	for each in seats:
		_show_next_choice(each)


func _on_gold_collected(amount: int, collector: Player = null) -> void:
	_add_gold(_seat_of(collector) if collector != null else local_seat, amount)


## Gold is each player's own, multiplied by their gold bonus.
func _add_gold(seat: Seat, amount: int) -> void:
	seat.gold_fraction += amount * seat.player.gold_multiplier()
	var whole := floori(seat.gold_fraction)
	seat.gold_fraction -= whole
	seat.gold += whole
	_refresh_gold(seat)


func _on_power_up(kind: StringName) -> void:
	if not finished:
		apply_power_up(kind)


func _on_shop_requested(merchant: Merchant, buyer: Player = null) -> void:
	var seat := _seat_of(buyer) if buyer != null else local_seat
	if finished or get_tree().paused or seat.menu != &"":
		return
	seat.shop_context = &"merchant"
	seat.merchant = merchant
	seat.shop_items = merchant.offers.duplicate()
	# The merchant may offer items this player banished or hasn't unlocked.
	for i in range(seat.shop_items.size() - 1, -1, -1):
		if not _can_offer_item(seat, seat.shop_items[i]) and not _replace_shop_item(seat, i):
			seat.shop_items.remove_at(i)
	_refresh_shop_prices(seat)
	_open_shop(seat, "Comerciante sombrío · %s" % Rarity.name_of(merchant.rarity), Rarity.color(merchant.rarity), false)


func _on_map_chest_touched(chest: Node2D, toucher: Player = null) -> void:
	var seat := _seat_of(toucher) if toucher != null else local_seat
	if finished or get_tree().paused or seat.menu != &"":
		return
	var price := chest_price()
	# Rusty key: some paid chests open for free. Rolled once per chest, not on every touch.
	if not chest.has_meta(&"free"):
		chest.set_meta(&"free", seat.inventory.free_chest())
	if chest.get_meta(&"free"):
		price = 0
	if seat.gold < price:
		map_chests.show_unaffordable(chest)
		return
	seat.gold -= price
	_refresh_gold(seat)
	chests_opened += 1
	seat.chests_total += 1
	seat.inventory.on_chest_opened()
	map_chests.price = chest_price()
	map_chests.open(chest)
	Audio.play(&"chest", 0.0)
	seat.shop_context = &"chest"
	seat.merchant = null
	# Up to three different items, each with its own rarity roll; the player takes one.
	seat.shop_items = []
	for i in CHEST_ITEMS:
		var item := _random_item(Rarity.roll(seat.player.luck), seat.shop_items, seat)
		if item != null:
			seat.shop_items.append(item)
	_refresh_shop_prices(seat)
	_open_shop(seat, "Cofre: elige un objeto", Palette.GOLD, true)


func _on_boss_warning(title: String) -> void:
	_announce("¡Se acerca un jefe!\n%s" % title, Palette.RED, 3.0)


func _on_boss_started(title: String) -> void:
	_announce(title + "!", Palette.ORANGE, 1.6)


## A boss beaten: every player gets an epic choice of their own.
func _on_boss_defeated(_data: EnemyData, pos: Vector2) -> void:
	if finished:
		return
	bosses_defeated += 1
	effects.shockwave(pos, Palette.GOLD, 6.0)
	Audio.play(&"powerup", 0.0)
	for seat in seats:
		seat.pending_choices.append({kind = &"boss", rarity = Rarity.Tier.EPIC})
		_show_next_choice(seat)


## A banner on every player's screen.
func _announce(text: String, color: Color, hold: float) -> void:
	hud.show_message(text, color, hold)
	if net_host != null:
		net_host.queue_event(&"show_message", [text, color, hold])


## A charged power shrine: whoever charged it picks an upgrade for their character.
func _on_shrine_charged(pos: Vector2, activator: Player) -> void:
	if finished:
		return
	var seat := _seat_of(activator)
	effects.shockwave(pos, Shrines.POWER_COLOR, 2.5)
	seat.pending_choices.append({kind = &"shrine", rarity = Rarity.Tier.COMMON})
	_show_next_choice(seat)


## A magnet totem: every soul and coin on the map flies to the players.
func _on_magnet_used(pos: Vector2, _activator: Player) -> void:
	if finished:
		return
	pickups.attract_all()
	effects.shockwave(pos, Shrines.MAGNET_COLOR, 4.0)
	Audio.play(&"powerup", 0.0)
	var text := "¡Imán!\nTodas las almas vuelan hacia vosotros" if guest_seat != null else "¡Imán!\nTodas las almas vuelan hacia ti"
	hud.show_message(text, Shrines.MAGNET_COLOR, 2.0)
	if net_host != null:
		net_host.queue_event(&"show_message", [text, Shrines.MAGNET_COLOR, 2.0])


## A brewed cauldron: the rest of the run is harder, and pays everyone more experience and gold.
func _on_cauldron_brewed(pos: Vector2) -> void:
	if finished:
		return
	cauldrons_brewed += 1
	for seat in seats:
		seat.player.xp_multiplier += CAULDRON_REWARD
		seat.player.gold_bonus += CAULDRON_REWARD
	_update_difficulty()
	effects.shockwave(pos, Palette.GREEN, 2.5)
	Audio.play(&"powerup", 0.0)
	hud.show_cauldron(CAULDRON_DIFFICULTY, CAULDRON_REWARD)
	if net_host != null:
		net_host.queue_event(&"show_cauldron", [CAULDRON_DIFFICULTY, CAULDRON_REWARD])


func _on_item_bought(seat: Seat, index: int) -> void:
	if seat.menu != &"shop" or index < 0 or index >= seat.shop_items.size() or seat.gold < seat.shop_prices[index]:
		return
	var item := seat.shop_items[index]
	seat.gold -= seat.shop_prices[index]
	_refresh_gold(seat)
	seat.inventory.add(item)
	if seat.shop_context == &"merchant":
		merchants.sold(seat.player)
		seat.items_bought += 1
	effects.shockwave(seat.player.global_position, Rarity.color(item.rarity), 1.5)
	_on_shop_closed(seat)


func _on_shop_reroll(seat: Seat, index: int) -> void:
	if seat.menu != &"shop" or seat.rerolls_left <= 0 or index < 0 or index >= seat.shop_items.size():
		return
	if _replace_shop_item(seat, index):
		seat.rerolls_left -= 1
		_reopen_shop(seat)


func _on_shop_banish(seat: Seat, index: int) -> void:
	if seat.menu != &"shop" or seat.banishes_left <= 0 or index < 0 or index >= seat.shop_items.size():
		return
	seat.banished[_item_key(seat.shop_items[index])] = true
	seat.banishes_left -= 1
	# A banished item never stays on screen: with nothing to replace it, its card goes away.
	if not _replace_shop_item(seat, index):
		seat.shop_items.remove_at(index)
		_refresh_shop_prices(seat)
	_reopen_shop(seat)


func _replace_shop_item(seat: Seat, index: int) -> bool:
	var replacement := _random_item(seat.shop_items[index].rarity, seat.shop_items, seat)
	if replacement == null:
		return false
	seat.shop_items[index] = replacement
	_refresh_shop_prices(seat)
	return true


func _open_shop(seat: Seat, heading: String, color: Color, chest_mode: bool) -> void:
	seat.menu = &"shop"
	if seat.remote:
		get_tree().paused = true
		net_host.send_menu([&"shop", heading, color, _item_paths(seat.shop_items), seat.shop_prices, seat.gold,
			seat.rerolls_left, seat.banishes_left, chest_mode, seat.item_counts(), stats_sections(seat)])
	else:
		pause_menu.close()
		shop_menu.open(heading, color, seat.shop_items, seat.shop_prices, seat.gold, seat.rerolls_left, seat.banishes_left, chest_mode)
	_update_waiting()


func _reopen_shop(seat: Seat) -> void:
	if seat.remote:
		net_host.send_menu([&"shop_refresh", _item_paths(seat.shop_items), seat.shop_prices, seat.gold,
			seat.rerolls_left, seat.banishes_left, seat.item_counts()])
	else:
		shop_menu.refresh(seat.shop_items, seat.shop_prices, seat.gold, seat.rerolls_left, seat.banishes_left)


func _refresh_shop_prices(seat: Seat) -> void:
	seat.shop_prices = []
	for item in seat.shop_items:
		seat.shop_prices.append(0 if seat.shop_context == &"chest" else merchants.price(item))


## A random item of this rarity that this player can be offered and isn't in `exclude`. If none
## is left, the nearest lower rarity, and only then a higher one, so a card never comes out empty.
func _random_item(rarity: int, exclude: Array[ItemData], seat: Seat = null) -> ItemData:
	if seat == null:
		seat = local_seat
	var tiers := range(rarity, -1, -1) + range(rarity + 1, Rarity.Tier.size())
	for tier in tiers:
		var pool: Array[ItemData] = []
		for item in seat.item_pool:
			if item.rarity == tier and not seat.banished.has(_item_key(item)) and not exclude.has(item):
				pool.append(item)
		if not pool.is_empty():
			return pool.pick_random()
	return null


func _can_offer_item(seat: Seat, item: ItemData) -> bool:
	return seat.item_pool.has(item) and not seat.banished.has(_item_key(item))


func _item_key(item: ItemData) -> String:
	return "item:%s" % item.id


static func _item_paths(items: Array[ItemData]) -> Array:
	var paths: Array = []
	for item in items:
		paths.append(item.resource_path)
	return paths


func _on_shop_closed(seat: Seat) -> void:
	if seat.menu != &"shop":
		return
	_close_menu(seat)
	seat.shop_context = &""
	seat.merchant = null
	_show_next_choice(seat)
	_update_pause()


func _on_chest_opened(collector: Player = null) -> void:
	if finished:
		return
	var seat := _seat_of(collector) if collector != null else local_seat
	seat.chests_total += 1
	seat.inventory.on_chest_opened()
	seat.pending_choices.append({kind = &"chest", rarity = Rarity.Tier.RARE})
	_show_next_choice(seat)


func _show_next_choice(seat: Seat) -> void:
	if seat.pending_choices.is_empty() or seat.menu != &"":
		return
	var choice: Dictionary = seat.pending_choices[0]
	var heading: String = {&"level": "¡Subiste de nivel!", &"chest": "¡Cofre maldito!", &"shrine": "Santuario de poder",
		&"boss": "¡Jefe derrotado!"}[choice.kind]
	effects.level_ring(seat.player.global_position)
	Audio.play(&"chest" if choice.kind == &"chest" or choice.kind == &"boss" else &"level_up", 0.0)
	seat.offers = build_offers(choice.rarity, seat, choice.kind)
	seat.menu = &"level_up"
	if seat.remote:
		get_tree().paused = true
		var offers: Array = []
		for offer in seat.offers:
			offers.append(_encode_offer(offer))
		net_host.send_menu([&"level_up", offers, heading, seat.rerolls_left, seat.banishes_left, seat.skips_left,
			seat.ad_rerolls_left, stats_sections(seat)])
	else:
		pause_menu.close()
		level_up_menu.skips_left = seat.skips_left
		level_up_menu.ad_rerolls_left = seat.ad_rerolls_left
		level_up_menu.open(seat.offers, heading, seat.rerolls_left, seat.banishes_left)
	_update_waiting()


## What the guest's level-up menu needs to draw a card.
static func _encode_offer(offer: Dictionary) -> Dictionary:
	var icon: Texture2D = offer.get("icon")
	return {icon = icon.resource_path if icon != null else "", rarity = offer.rarity, tag = offer.tag,
		title = offer.title, description = offer.description, banishable = offer.has("key")}


func _replace_card(seat: Seat, index: int) -> void:
	if seat.remote:
		net_host.send_menu([&"card", index, _encode_offer(seat.offers[index]), seat.rerolls_left, seat.banishes_left])
	else:
		level_up_menu.replace_offer(index, seat.offers[index], seat.rerolls_left, seat.banishes_left)


func _close_menu(seat: Seat) -> void:
	seat.menu = &""
	if seat.remote:
		net_host.send_menu([&"close"])
	else:
		level_up_menu.close()
		shop_menu.close()


## The run stays stopped while any player has a menu open, and goes on once every menu is closed.
func _update_pause() -> void:
	_update_waiting()
	for seat in seats:
		if seat.menu != &"":
			return
	if not finished and not pause_menu.visible:
		get_tree().paused = false


## Online host: "waiting for your partner" while only the guest's menu is open.
func _update_waiting() -> void:
	if _waiting_label == null:
		return
	var waiting := guest_seat != null and local_seat.menu == &"" and guest_seat.menu != &"" and not finished
	_waiting_label.visible = waiting
	if waiting:
		_waiting_label.text = ("Tu compañero está en la tienda..." if guest_seat.menu == &"shop"
			else "Tu compañero está eligiendo su mejora...")


func _on_card_reroll(seat: Seat, index: int) -> void:
	if seat.menu != &"level_up" or seat.rerolls_left <= 0 or index < 0 or index >= seat.offers.size():
		return
	var choice: Dictionary = seat.pending_choices[0]
	var replacement := replacement_offer(seat.offers, index, choice.rarity, seat, choice.kind)
	if replacement.is_empty():
		return
	seat.rerolls_left -= 1
	seat.offers[index] = replacement
	_replace_card(seat, index)


func _on_card_banish(seat: Seat, index: int) -> void:
	if seat.menu != &"level_up" or index < 0 or index >= seat.offers.size():
		return
	var offer: Dictionary = seat.offers[index]
	if seat.banishes_left <= 0 or not offer.has("key"):
		return
	seat.banished[offer.key] = true
	seat.banishes_left -= 1
	var choice: Dictionary = seat.pending_choices[0]
	var replacement := replacement_offer(seat.offers, index, choice.rarity, seat, choice.kind)
	if replacement.is_empty():
		replacement = _fallback_offers(choice.rarity)[0]
	seat.offers[index] = replacement
	_replace_card(seat, index)


## Turns down the current choice without taking anything (as in Megabonk), and moves on.
func _on_card_skip(seat: Seat) -> void:
	if seat.menu != &"level_up" or seat.skips_left <= 0 or seat.pending_choices.is_empty():
		return
	seat.skips_left -= 1
	seat.pending_choices.pop_front()
	_close_menu(seat)
	_show_next_choice(seat)
	_update_pause()


func _on_upgrade_chosen(seat: Seat, offer: Dictionary) -> void:
	if seat.menu != &"level_up" or seat.pending_choices.is_empty():
		return
	apply_offer(offer, seat)
	seat.pending_choices.pop_front()
	_close_menu(seat)
	_show_next_choice(seat)
	_update_pause()


func _on_enemy_killed(_data: EnemyData, _position: Vector2) -> void:
	kills += 1
	hud.set_kills(kills)


## Co-op: a fallen character gets back up on every level up, while the other one is still standing.
func _revive_fallen() -> void:
	if not enemy_manager.any_player_alive():
		return
	for p in players:
		if p.is_dead:
			p.revive(REVIVE_HEALTH)
			effects.shockwave(p.global_position, Palette.GOLD, 3.0)


func _on_player_died() -> void:
	if players.size() > 1:
		# Co-op: the run goes on while someone is still standing.
		if not enemy_manager.any_player_alive():
			_finish()
		return
	# Optional second chance, once per run, before the run really ends.
	if not revive_used and Ads.is_available():
		await get_tree().create_timer(0.8).timeout
		level_up_menu.close()
		shop_menu.close()
		pause_menu.close()
		get_tree().paused = true
		var wants := await revive_offer.ask()
		if wants and await Ads.show_rewarded(Ads.REVIVE):
			_revive()
			return
		get_tree().paused = false
	_finish()


func _revive() -> void:
	revive_used = true
	player.revive(REVIVE_HEALTH)
	effects.shockwave(player.global_position, Palette.GOLD, 6.0)
	Audio.play(&"powerup", 0.0)
	enemy_manager.detonate(PowerUps.BOMB_ELITE_DAMAGE)
	get_tree().paused = false
	# The menu was closed while dying; pending level-ups are offered now.
	local_seat.menu = &""
	_show_next_choice(local_seat)


## Rewarded ad in the level-up menu: one more reroll.
func _on_ad_reroll() -> void:
	if local_seat.ad_rerolls_left <= 0:
		return
	if await Ads.show_rewarded(Ads.EXTRA_REROLL):
		local_seat.ad_rerolls_left -= 1
		local_seat.rerolls_left += 1
		level_up_menu.ad_rerolls_left = local_seat.ad_rerolls_left
		level_up_menu.set_counts(local_seat.rerolls_left, local_seat.banishes_left)


## Rewarded ad on the game over screen: the run's silver again.
func _on_double_silver(earned: int) -> void:
	if await Ads.show_rewarded(Ads.DOUBLE_SILVER):
		Progress.add_silver(earned)
		game_over.silver_doubled(earned * 2, Progress.silver)


## The run only ends when every player has fallen.
func _finish() -> void:
	if finished:
		return
	finished = true
	enemy_manager.spawning_enabled = false
	Events.run_ended.emit(false)
	Audio.stop_music()
	var new_record := Settings.submit_run(elapsed, kills)
	if guest_seat != null:
		# The guest saves its part of the run in its own progress (see NetGuest).
		net_result = {time = elapsed, level = level, kills = kills, record = _run_summary(guest_seat)}
		_close_menu(guest_seat)
	var rewards := _record_run()
	Audio.play(&"game_over", 0.0)
	_update_waiting()
	await get_tree().create_timer(1.2).timeout
	level_up_menu.close()
	shop_menu.close()
	local_seat.menu = &""
	game_over.show_result(elapsed, level, kills, new_record)
	game_over.show_rewards(rewards.silver, Progress.silver, rewards.completed)


## Saves the run's silver and challenge progress (once, also when quitting from the pause menu).
func _record_run() -> Dictionary:
	if _run_recorded:
		return {silver = 0, completed = []}
	_run_recorded = true
	return Progress.record_run(_run_summary(local_seat))


## What Progress records of this run for this player.
func _run_summary(seat: Seat) -> Dictionary:
	var scroll_ids := {}
	for scroll: UpgradeData in seat.scroll_levels:
		scroll_ids[String(scroll.id)] = seat.scroll_levels[scroll]
	var weapon_ids := {}
	for weapon in seat.weapons:
		weapon_ids[String(weapon.data.id)] = weapon.level
	return {time = elapsed, level = level, kills = kills, xp = xp_total,
		chests = seat.chests_total, items = seat.items_bought, cauldrons = cauldrons_brewed, no_hit = seat.best_no_hit,
		scrolls = scroll_ids, weapons = weapon_ids, silver_multiplier = seat.player.silver_multiplier}


func _resume() -> void:
	pause_menu.close()
	# Online, a player's menu may still be open; the run goes on when it closes.
	if net_guest != null:
		get_tree().paused = run_menu_open()
	else:
		_update_pause()


## The guest's own level-up or item menu is on screen.
func run_menu_open() -> bool:
	return level_up_menu.visible or shop_menu.visible


func _retry() -> void:
	if Net.is_host():
		# The guest starts the new run with us.
		Net.send([Net.MSG_START])
	get_tree().paused = false
	get_tree().reload_current_scene()


func _go_to_menu() -> void:
	if net_guest != null:
		Net.send([Net.MSG_QUIT])
		Net.leave()
	else:
		_record_run()
		if Net.is_host():
			Net.send([Net.MSG_END])
		Net.leave()
	get_tree().paused = false
	get_tree().change_scene_to_file(MENU_SCENE)
