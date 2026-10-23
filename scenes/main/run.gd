extends Node2D
## One run: timer, experience and levels, upgrades with rarity, chests, pause and end of the run.

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
const MENU_SCENE := "res://scenes/main/main_menu.tscn"
## The witch starts with her magic orb; the pumpkin is one of the weapons offered during the run.
const STARTING_WEAPON: WeaponData = preload("res://data/weapons/orbe.tres")
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
var weapons: Array[Weapon] = []
## Scroll -> times picked.
var scroll_levels := {}
var gold := 0
var rerolls_left := REROLLS_PER_RUN
var banishes_left := BANISHES_PER_RUN
var skips_left := SKIPS_PER_RUN
## Keys of banished options ("weapon:<id>", "scroll:<id>", "item:<id>").
var banished := {}
var chests_opened := 0
## For the unlock challenges (see `Unlocks`): every chest opened (paid or dropped), items bought
## from merchants, experience gained, and the longest time without being hit.
var chests_total := 0
var items_bought := 0
var xp_total := 0
var best_no_hit := 0.0
## Weapons, scrolls and items this run can offer: the ones bought in the unlocks menu or never locked.
var weapon_pool: Array[WeaponData] = []
var scroll_pool: Array[UpgradeData] = []
var item_pool: Array[ItemData] = []
var _run_recorded := false
var revive_used := false
var ad_rerolls_left := AD_REROLLS_PER_RUN
var revive_offer: ReviveOffer
var cauldrons_brewed := 0
## Extra difficulty from the cursed scroll, on top of cauldrons.
var curse_difficulty := 0.0
## Share of a common scroll the chaos scroll grants on every level up.
var chaos_power := 0.0
var _gold_fraction := 0.0
var _xp_fraction := 0.0
## What the item menu is showing: &"merchant" or &"chest", its items and prices.
var _shop_context := &""
var _shop_items: Array[ItemData] = []
var _shop_prices: Array[int] = []
var _shop_rarity := Rarity.Tier.COMMON

## Pending upgrade choices; each entry is the minimum rarity of that choice.
var _pending_choices: Array[int] = []

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
@onready var decorations: Decorations = $World/Actors/Decorations


func _ready() -> void:
	get_tree().paused = false
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
	for data in WEAPONS:
		if Progress.is_unlocked("weapon:%s" % data.id):
			weapon_pool.append(data)
	for scroll in SCROLLS:
		if Progress.is_unlocked("scroll:%s" % scroll.id):
			scroll_pool.append(scroll)
	for item in ITEMS:
		if Progress.is_unlocked("item:%s" % item.id):
			item_pool.append(item)
	merchants.items = item_pool
	shop_menu.inventory = inventory
	merchants.is_banished = func(item: ItemData) -> bool: return banished.has(_item_key(item))
	map_chests.player = player
	map_chests.price = chest_price()
	cauldrons.player = player
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
	inventory.gold_gained.connect(func(amount: int) -> void: _on_gold_collected(amount))
	merchants.merchant_arrived.connect(hud.show_merchant)
	merchants.shop_requested.connect(_on_shop_requested)
	shop_menu.bought.connect(_on_item_bought)
	shop_menu.closed.connect(_on_shop_closed)
	shop_menu.reroll_requested.connect(_on_shop_reroll)
	shop_menu.banish_requested.connect(_on_shop_banish)
	map_chests.chest_touched.connect(_on_map_chest_touched)
	cauldrons.brewed.connect(_on_cauldron_brewed)
	level_up_menu.reroll_requested.connect(_on_card_reroll)
	level_up_menu.banish_requested.connect(_on_card_banish)
	level_up_menu.skip_requested.connect(_on_card_skip)
	enemy_manager.horde_warning.connect(hud.show_horde_warning)
	enemy_manager.horde_started.connect(hud.show_horde_started)
	Events.enemy_killed.connect(_on_enemy_killed)
	hud.pause_pressed.connect(open_pause)
	level_up_menu.chosen.connect(_on_upgrade_chosen)
	level_up_menu.stats_provider = stats_sections
	level_up_menu.ad_reroll_requested.connect(_on_ad_reroll)
	game_over.double_silver_requested.connect(_on_double_silver)
	revive_offer = ReviveOffer.new()
	$UI.add_child(revive_offer)
	shop_menu.stats_provider = stats_sections
	pause_menu.resume_requested.connect(_resume)
	pause_menu.quit_requested.connect(_go_to_menu)
	game_over.retry_requested.connect(_retry)
	game_over.menu_requested.connect(_go_to_menu)
	joystick.blocked_rects = func() -> Array[Rect2]: return [hud.pause_button_rect()]
	if is_instance_valid(debug_overlay):
		debug_overlay.run = self

	add_weapon(STARTING_WEAPON)
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
	best_no_hit = maxf(best_no_hit, player.time_since_hit())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause"):
		get_viewport().set_input_as_handled()
		open_pause()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		open_pause()


func xp_to_next_level() -> int:
	# Like Megabonk: the first levels come fast, later ones get steep.
	var n := level - 1
	return roundi(3.0 + 2.0 * n + 0.45 * n * n + 0.03 * n * n * n)


func add_weapon(data: WeaponData) -> void:
	var weapon: Weapon = data.scene.instantiate()
	player.weapons.add_child(weapon)
	weapon.setup(data, player, enemy_manager, projectiles)
	weapons.append(weapon)
	_refresh_inventory()


func open_pause() -> void:
	if finished or not is_inside_tree() or get_tree().paused:
		return
	pause_menu.open()


func build_offers(minimum_rarity := Rarity.Tier.COMMON) -> Array[Dictionary]:
	var pool := _offer_candidates()
	pool.shuffle()
	var offers: Array[Dictionary] = []
	for candidate in pool.slice(0, 3):
		offers.append(_finish_offer(candidate, minimum_rarity))
	if offers.is_empty():
		offers = _fallback_offers(minimum_rarity)
	return offers


## Every option that could appear on a level-up card right now (without rarity).
func _offer_candidates() -> Array[Dictionary]:
	var pool: Array[Dictionary] = []
	for data in weapon_pool:
		var key := "weapon:%s" % data.id
		if banished.has(key):
			continue
		var owned := _owned_weapon(data)
		if owned == null and weapons.size() < MAX_WEAPONS:
			pool.append({kind = &"new_weapon", key = key, weapon = data, title = data.display_name,
				base_description = data.description, icon = data.icon, tag = "¡Nueva arma!"})
		elif owned != null:
			pool.append({kind = &"weapon_level", key = key, weapon = data, title = data.display_name,
				icon = data.icon, tag = "Nivel %d" % (owned.level + 1)})
	for scroll in scroll_pool:
		var key := "scroll:%s" % scroll.id
		var current: int = scroll_levels.get(scroll, 0)
		if banished.has(key) or (current == 0 and scroll_levels.size() >= MAX_SCROLLS):
			continue
		pool.append({kind = &"scroll", key = key, upgrade = scroll, title = scroll.display_name, icon = scroll.icon,
			tag = "¡Nuevo pergamino!" if current == 0 else "Nivel %d" % (current + 1)})
	return pool


## Rolls the rarity (new weapons are always common) and the weapon upgrade, and writes the text.
func _finish_offer(candidate: Dictionary, minimum_rarity: int) -> Dictionary:
	var offer := candidate.duplicate()
	offer.rarity = Rarity.Tier.COMMON if offer.kind == &"new_weapon" else Rarity.roll(player.luck, minimum_rarity)
	if offer.kind == &"weapon_level":
		offer.upgrade = _owned_weapon(offer.weapon).roll_upgrade(offer.rarity)
	elif offer.kind == &"scroll":
		var scroll: UpgradeData = offer.upgrade
		offer.amount = scroll.roll_amount(offer.rarity)
	offer.description = _describe(offer)
	return offer


func _fallback_offers(minimum_rarity: int) -> Array[Dictionary]:
	return [
		{kind = &"heal", title = "Caramelo de medianoche", rarity = minimum_rarity,
			description = "Recupera un %d\u00a0%% de vida." % roundi(HEAL_FALLBACK * 100.0), icon = CANDY_ICON, tag = "Premio"},
		{kind = &"gold", title = "Bolsa de calaveras", rarity = minimum_rarity,
			description = "+%d de oro." % GOLD_FALLBACK, icon = COIN_BAG_ICON, tag = "Premio"},
	]


## A new offer for card `index` that differs from every card on screen. Empty if there is none.
func replacement_offer(offers: Array[Dictionary], index: int, minimum_rarity: int) -> Dictionary:
	var taken := {}
	for offer in offers:
		taken[offer.get("key", "")] = true
	var pool: Array[Dictionary] = []
	for candidate in _offer_candidates():
		if not taken.has(candidate.key):
			pool.append(candidate)
	if pool.is_empty():
		return {}
	return _finish_offer(pool.pick_random(), minimum_rarity)


func apply_offer(offer: Dictionary) -> void:
	var rarity: int = offer.rarity
	match offer.kind:
		&"new_weapon":
			add_weapon(offer.weapon)
		&"weapon_level":
			_owned_weapon(offer.weapon).apply_upgrade(offer.upgrade)
			_refresh_inventory()
		&"scroll":
			var scroll: UpgradeData = offer.upgrade
			scroll_levels[scroll] = scroll_levels.get(scroll, 0) + 1
			_apply_scroll(scroll, offer.get("amount", scroll.roll_amount(rarity)))
			_refresh_inventory()
		&"heal":
			player.heal(player.max_health * HEAL_FALLBACK)
		&"gold":
			debug_gold(GOLD_FALLBACK)


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
	gold += amount
	hud.set_gold(gold)


func debug_cauldron() -> void:
	_on_cauldron_brewed(player.global_position)


func debug_power_up() -> void:
	pickups.spawn_power_up(player.global_position + Vector2(90, 0), PowerUps.roll())


func apply_power_up(kind: StringName) -> void:
	effects.shockwave(player.global_position, Palette.GOLD, 1.2)
	match kind:
		&"heart":
			player.heal(player.max_health * PowerUps.HEART_HEAL)
		&"candy":
			player.heal(player.max_health * PowerUps.CANDY_HEAL)
		&"magnet":
			pickups.attract_all()
		&"clock":
			enemy_manager.stop_time(PowerUps.duration(kind))
			player.add_buff(kind, PowerUps.duration(kind))
			Audio.play(&"tick", 0.0)
		&"bomb":
			effects.shockwave(player.global_position, Palette.ORANGE, 6.0)
			Audio.play(&"boom", 0.0)
			enemy_manager.detonate(PowerUps.BOMB_ELITE_DAMAGE)
			enemy_manager.pause_spawning(BOMB_SPAWN_PAUSE)
		_:
			player.add_buff(kind, PowerUps.duration(kind))


func _apply_scroll(scroll: UpgradeData, amount: float) -> void:
	match scroll.stat:
		UpgradeData.Stat.MAX_HEALTH:
			player.increase_max_health(Player.BASE_MAX_HEALTH * amount)
		UpgradeData.Stat.MOVE_SPEED:
			player.speed_multiplier += amount
		UpgradeData.Stat.PICKUP_RADIUS:
			player.pickup_multiplier += amount
		UpgradeData.Stat.ATTACK_SPEED:
			player.attack_speed_bonus += amount
		UpgradeData.Stat.DAMAGE:
			player.damage_multiplier += amount
		UpgradeData.Stat.LUCK:
			player.luck += amount
		UpgradeData.Stat.LIFESTEAL:
			player.lifesteal += amount
		UpgradeData.Stat.ARMOR:
			player.add_armor(amount)
		UpgradeData.Stat.AREA:
			player.area_multiplier += amount
		UpgradeData.Stat.XP:
			player.xp_multiplier += amount
		UpgradeData.Stat.AMOUNT:
			player.extra_amount += roundi(amount)
			for weapon in weapons:
				weapon.refresh()
		UpgradeData.Stat.REGEN:
			player.regen += amount
		UpgradeData.Stat.SHIELD:
			player.add_shield(amount)
		UpgradeData.Stat.EVASION:
			player.evasion += amount
		UpgradeData.Stat.THORNS:
			player.thorns += amount
		UpgradeData.Stat.CRIT:
			player.crit_chance += amount
		UpgradeData.Stat.PROJECTILE_SPEED:
			player.projectile_speed_multiplier += amount
		UpgradeData.Stat.DURATION:
			player.duration_multiplier += amount
		UpgradeData.Stat.KNOCKBACK:
			player.knockback_multiplier += amount
		UpgradeData.Stat.GOLD:
			player.gold_bonus += amount
		UpgradeData.Stat.CURSE:
			# Like Megabonk's cursed tome and the cauldrons: harder, but pays twice as much more.
			curse_difficulty += amount
			player.xp_multiplier += amount * CAULDRON_REWARD / CAULDRON_DIFFICULTY
			player.gold_bonus += amount * CAULDRON_REWARD / CAULDRON_DIFFICULTY
			_update_difficulty()
		UpgradeData.Stat.CHAOS:
			chaos_power += amount
		UpgradeData.Stat.SILVER:
			player.silver_multiplier += amount


## Chaos scroll: on every level up, a random stat gets a share of a common scroll.
func _chaos_tick() -> void:
	if chaos_power <= 0.0:
		return
	var pool: Array[UpgradeData] = []
	for scroll in scroll_pool:
		# A banished scroll never comes back, not even through chaos.
		if not CHAOS_EXCLUDED.has(scroll.stat) and not banished.has("scroll:%s" % scroll.id):
			pool.append(scroll)
	if pool.is_empty():
		return
	var scroll: UpgradeData = pool.pick_random()
	var amount := scroll.amount_per_level * chaos_power
	_apply_scroll(scroll, amount)
	hud.show_chaos(scroll.describe(amount))


func _update_difficulty() -> void:
	enemy_manager.difficulty = 1.0 + CAULDRON_DIFFICULTY * cauldrons_brewed + curse_difficulty
	hud.set_difficulty(enemy_manager.difficulty - 1.0)


## Everything the stats panel shows, as sections of [name, value] rows: the player's stats and the weapons.
func stats_sections() -> Array[Dictionary]:
	var p := player
	var rows: Array = [
		["Vida", "%d / %d" % [ceili(p.health), roundi(p.max_health)]],
		["Regeneración", "%s/s" % _num(p.regen)],
		["Escudo", "%d / %d" % [ceili(p.shield), roundi(p.shield_max)]],
		["Armadura (menos daño recibido)", _pct(1.0 - p.damage_taken_multiplier)],
		["Evasión", _pct(p.dodge_chance())],
		["Espinas", _num(p.thorns * p.damage_multiplier)],
		["Robo de vida", _pct(p.lifesteal)],
		["Daño", "×%s" % _num(p.damage_multiplier * p.item_damage_multiplier(), 2)],
		["Probabilidad de crítico", _pct(inventory.crit_chance())],
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
	if chaos_power > 0.0:
		rows.append(["Caos por nivel", _pct(chaos_power)])
	rows.append(["Plata al terminar", "×%s" % _num(p.silver_multiplier, 2)])
	var weapon_rows: Array = []
	for weapon in weapons:
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
	if offer.kind == &"scroll":
		var upgrade: UpgradeData = offer.upgrade
		return upgrade.describe(offer.get("amount", upgrade.roll_amount(rarity)))
	if offer.kind == &"weapon_level":
		var data: WeaponData = offer.weapon
		return data.describe_upgrade(offer.upgrade)
	return offer.base_description


func _refresh_inventory() -> void:
	hud.set_weapons(weapons)
	var icons: Array[Dictionary] = []
	for scroll: UpgradeData in scroll_levels:
		icons.append({icon = scroll.icon, level = scroll_levels[scroll]})
	hud.set_passives(icons)


func _owned_weapon(data: WeaponData) -> Weapon:
	for weapon in weapons:
		if weapon.data == data:
			return weapon
	return null


func _on_xp_collected(amount: int) -> void:
	if finished:
		return
	_xp_fraction += amount * minf(player.xp_multiplier, MAX_XP_MULTIPLIER)
	var whole := floori(_xp_fraction)
	_xp_fraction -= whole
	xp += whole
	xp_total += whole
	while xp >= xp_to_next_level():
		xp -= xp_to_next_level()
		level += 1
		_pending_choices.append(Rarity.Tier.COMMON)
		_chaos_tick()
		Events.level_up.emit(level)
	hud.set_xp(xp, xp_to_next_level(), level)
	_show_next_choice()


func _on_gold_collected(amount: int) -> void:
	_gold_fraction += amount * player.gold_multiplier()
	var whole := floori(_gold_fraction)
	_gold_fraction -= whole
	gold += whole
	hud.set_gold(gold)


func _on_power_up(kind: StringName) -> void:
	if not finished:
		apply_power_up(kind)


func _on_shop_requested(merchant: Merchant) -> void:
	if finished or get_tree().paused:
		return
	_shop_context = &"merchant"
	_shop_items = merchant.offers
	# The merchant may have arrived before the player banished some of his items.
	for i in range(_shop_items.size() - 1, -1, -1):
		if banished.has(_item_key(_shop_items[i])) and not _replace_shop_item(i):
			_shop_items.remove_at(i)
	_shop_rarity = merchant.rarity
	_refresh_shop_prices()
	pause_menu.close()
	shop_menu.open("Comerciante sombrío · %s" % Rarity.name_of(merchant.rarity), Rarity.color(merchant.rarity),
		_shop_items, _shop_prices, gold, rerolls_left, banishes_left, false)


func _on_map_chest_touched(chest: Node2D) -> void:
	if finished or get_tree().paused:
		return
	var price := chest_price()
	# Rusty key: some paid chests open for free. Rolled once per chest, not on every touch.
	if not chest.has_meta(&"free"):
		chest.set_meta(&"free", inventory.free_chest())
	if chest.get_meta(&"free"):
		price = 0
	if gold < price:
		map_chests.show_unaffordable(chest)
		return
	gold -= price
	hud.set_gold(gold)
	chests_opened += 1
	chests_total += 1
	inventory.on_chest_opened()
	map_chests.price = chest_price()
	map_chests.open(chest)
	Audio.play(&"chest", 0.0)
	_shop_context = &"chest"
	# Up to three different items, each with its own rarity roll; the player takes one.
	_shop_items = []
	for i in CHEST_ITEMS:
		var item := _random_item(Rarity.roll(player.luck), _shop_items)
		if item != null:
			_shop_items.append(item)
	_refresh_shop_prices()
	pause_menu.close()
	shop_menu.open("Cofre: elige un objeto", Palette.GOLD, _shop_items, _shop_prices, gold, rerolls_left, banishes_left, true)


## A brewed cauldron: the rest of the run is harder, and pays more experience and gold.
func _on_cauldron_brewed(pos: Vector2) -> void:
	if finished:
		return
	cauldrons_brewed += 1
	player.xp_multiplier += CAULDRON_REWARD
	player.gold_bonus += CAULDRON_REWARD
	_update_difficulty()
	effects.shockwave(pos, Palette.GREEN, 2.5)
	Audio.play(&"powerup", 0.0)
	hud.show_cauldron(CAULDRON_DIFFICULTY, CAULDRON_REWARD)


func _on_item_bought(index: int) -> void:
	var item := _shop_items[index]
	gold -= _shop_prices[index]
	hud.set_gold(gold)
	inventory.add(item)
	if _shop_context == &"merchant":
		merchants.sold()
		items_bought += 1
	effects.shockwave(player.global_position, Rarity.color(item.rarity), 1.5)
	_on_shop_closed()


func _on_shop_reroll(index: int) -> void:
	if rerolls_left <= 0:
		return
	if _replace_shop_item(index):
		rerolls_left -= 1
		_reopen_shop()


func _on_shop_banish(index: int) -> void:
	if banishes_left <= 0:
		return
	banished[_item_key(_shop_items[index])] = true
	banishes_left -= 1
	# A banished item never stays on screen: with nothing to replace it, its card goes away.
	if not _replace_shop_item(index):
		_shop_items.remove_at(index)
		_refresh_shop_prices()
	_reopen_shop()


func _replace_shop_item(index: int) -> bool:
	var replacement := _random_item(_shop_items[index].rarity, _shop_items)
	if replacement == null:
		return false
	_shop_items[index] = replacement
	_refresh_shop_prices()
	return true


func _reopen_shop() -> void:
	shop_menu.refresh(_shop_items, _shop_prices, gold, rerolls_left, banishes_left)


func _refresh_shop_prices() -> void:
	_shop_prices = []
	for item in _shop_items:
		_shop_prices.append(0 if _shop_context == &"chest" else merchants.price(item))


## A random item of this rarity that isn't banished or in `exclude`. If none is left, the nearest
## lower rarity, and only then a higher one, so a chest or shop card never comes out empty.
func _random_item(rarity: int, exclude: Array[ItemData]) -> ItemData:
	var tiers := range(rarity, -1, -1) + range(rarity + 1, Rarity.Tier.size())
	for tier in tiers:
		var pool: Array[ItemData] = []
		for item in item_pool:
			if item.rarity == tier and not banished.has(_item_key(item)) and not exclude.has(item):
				pool.append(item)
		if not pool.is_empty():
			return pool.pick_random()
	return null


func _item_key(item: ItemData) -> String:
	return "item:%s" % item.id


func _on_shop_closed() -> void:
	shop_menu.close()
	_shop_context = &""
	if _pending_choices.is_empty():
		get_tree().paused = false
	else:
		_show_next_choice()


func _on_chest_opened() -> void:
	if finished:
		return
	chests_total += 1
	inventory.on_chest_opened()
	_pending_choices.append(Rarity.Tier.RARE)
	_show_next_choice()


func _show_next_choice() -> void:
	if _pending_choices.is_empty() or level_up_menu.visible or shop_menu.visible:
		return
	var minimum: int = _pending_choices[0]
	var from_chest := minimum >= Rarity.Tier.RARE
	effects.level_ring(player.global_position)
	Audio.play(&"chest" if from_chest else &"level_up", 0.0)
	pause_menu.close()
	level_up_menu.skips_left = skips_left
	level_up_menu.ad_rerolls_left = ad_rerolls_left
	level_up_menu.open(build_offers(minimum), "¡Cofre maldito!" if from_chest else "¡Subiste de nivel!", rerolls_left, banishes_left)


func _on_card_reroll(index: int) -> void:
	if rerolls_left <= 0:
		return
	var replacement := replacement_offer(level_up_menu.offers_shown, index, _pending_choices[0])
	if replacement.is_empty():
		return
	rerolls_left -= 1
	level_up_menu.replace_offer(index, replacement, rerolls_left, banishes_left)


func _on_card_banish(index: int) -> void:
	var offer: Dictionary = level_up_menu.offers_shown[index]
	if banishes_left <= 0 or not offer.has("key"):
		return
	banished[offer.key] = true
	banishes_left -= 1
	var replacement := replacement_offer(level_up_menu.offers_shown, index, _pending_choices[0])
	if replacement.is_empty():
		replacement = _fallback_offers(_pending_choices[0])[0]
	level_up_menu.replace_offer(index, replacement, rerolls_left, banishes_left)


## Turns down the current choice without taking anything (as in Megabonk), and moves on.
func _on_card_skip() -> void:
	if skips_left <= 0 or _pending_choices.is_empty():
		return
	skips_left -= 1
	_pending_choices.pop_front()
	level_up_menu.close()
	if _pending_choices.is_empty():
		get_tree().paused = false
	else:
		_show_next_choice()


func _on_upgrade_chosen(offer: Dictionary) -> void:
	apply_offer(offer)
	_pending_choices.pop_front()
	level_up_menu.close()
	if _pending_choices.is_empty():
		get_tree().paused = false
	else:
		_show_next_choice()


func _on_enemy_killed(_data: EnemyData, _position: Vector2) -> void:
	kills += 1
	hud.set_kills(kills)


func _on_player_died() -> void:
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
	# Pending level-ups that arrived while dying are offered now.
	_show_next_choice()


## Rewarded ad in the level-up menu: one more reroll.
func _on_ad_reroll() -> void:
	if ad_rerolls_left <= 0:
		return
	if await Ads.show_rewarded(Ads.EXTRA_REROLL):
		ad_rerolls_left -= 1
		rerolls_left += 1
		level_up_menu.ad_rerolls_left = ad_rerolls_left
		level_up_menu.set_counts(rerolls_left, banishes_left)


## Rewarded ad on the game over screen: the run's silver again.
func _on_double_silver(earned: int) -> void:
	if await Ads.show_rewarded(Ads.DOUBLE_SILVER):
		Progress.add_silver(earned)
		game_over.silver_doubled(earned * 2, Progress.silver)


## The run only ends when the player dies.
func _finish() -> void:
	if finished:
		return
	finished = true
	enemy_manager.spawning_enabled = false
	Events.run_ended.emit(false)
	Audio.stop_music()
	var new_record := Settings.submit_run(elapsed, kills)
	var rewards := _record_run()
	Audio.play(&"game_over", 0.0)
	await get_tree().create_timer(1.2).timeout
	level_up_menu.close()
	shop_menu.close()
	game_over.show_result(elapsed, level, kills, new_record)
	game_over.show_rewards(rewards.silver, Progress.silver, rewards.completed)


## Saves the run's silver and challenge progress (once, also when quitting from the pause menu).
func _record_run() -> Dictionary:
	if _run_recorded:
		return {silver = 0, completed = []}
	_run_recorded = true
	var scroll_ids := {}
	for scroll: UpgradeData in scroll_levels:
		scroll_ids[String(scroll.id)] = scroll_levels[scroll]
	var weapon_ids := {}
	for weapon in weapons:
		weapon_ids[String(weapon.data.id)] = weapon.level
	return Progress.record_run({time = elapsed, level = level, kills = kills, xp = xp_total,
		chests = chests_total, items = items_bought, cauldrons = cauldrons_brewed, no_hit = best_no_hit,
		scrolls = scroll_ids, weapons = weapon_ids, silver_multiplier = player.silver_multiplier})


func _resume() -> void:
	pause_menu.close()
	get_tree().paused = false


func _retry() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _go_to_menu() -> void:
	_record_run()
	get_tree().paused = false
	get_tree().change_scene_to_file(MENU_SCENE)
