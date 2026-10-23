class_name Seat
extends RefCounted
## Everything one player owns in a run: character, weapons, scrolls, items, gold, rerolls,
## banishes and the menu on their screen. A solo run has one seat; online co-op has the host's
## and the guest's, and each buys, levels up and banishes on its own, as in a solo run.

var player: Player
var inventory: Inventory
## The guest's seat: its menus are shown on the guest's screen (see NetHost and NetGuest).
var remote := false
var weapons: Array[Weapon] = []
## Scroll -> times picked.
var scroll_levels := {}
var gold := 0
var gold_fraction := 0.0
var rerolls_left := 0
var banishes_left := 0
var skips_left := 0
var ad_rerolls_left := 0
## Keys of banished options ("weapon:<id>", "scroll:<id>", "item:<id>").
var banished := {}
## Share of a common scroll the chaos scroll grants on every level up.
var chaos_power := 0.0
## Weapons, scrolls and items this seat can be offered: the ones its player unlocked.
var weapon_pool: Array[WeaponData] = []
var scroll_pool: Array[UpgradeData] = []
var item_pool: Array[ItemData] = []
## For the unlock challenges (see `Unlocks`): chests opened (paid or dropped), items bought from
## merchants and the longest time without being hit.
var chests_total := 0
var items_bought := 0
var best_no_hit := 0.0

## Pending upgrade choices; each entry is the minimum rarity of that choice.
var pending_choices: Array[int] = []
## What this seat's screen shows: &"" (nothing), &"level_up" or &"shop".
var menu := &""
## Level-up cards on screen.
var offers: Array[Dictionary] = []
## Item menu on screen: &"merchant" or &"chest", its items, prices and merchant.
var shop_context := &""
var shop_items: Array[ItemData] = []
var shop_prices: Array[int] = []
var merchant: Merchant


func _init(owner_player: Player, owner_inventory: Inventory, rerolls: int, banishes: int, skips: int, ad_rerolls: int) -> void:
	player = owner_player
	inventory = owner_inventory
	rerolls_left = rerolls
	banishes_left = banishes
	skips_left = skips
	ad_rerolls_left = ad_rerolls


func owned_weapon(data: WeaponData) -> Weapon:
	for weapon in weapons:
		if weapon.data == data:
			return weapon
	return null


## How many copies of each owned item, by item id (for the guest's screen).
func item_counts() -> Dictionary:
	var counts := {}
	for item: ItemData in inventory.stacks:
		counts[String(item.id)] = inventory.stacks[item]
	return counts
