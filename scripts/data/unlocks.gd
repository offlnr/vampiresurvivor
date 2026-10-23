class_name Unlocks
extends RefCounted
## Catalogue of locked content, as in Megabonk: every entry has a challenge, and once the challenge
## is met it can be bought with silver from the main menu. Everything not listed here is unlocked
## from the start. Locked content never shows up in a run (cards, merchant, chests).
##
## `stat` names a progress stat kept by `Progress` (see `Progress.record_run()`):
## - "total_*": summed over every run;
## - "best_*": the best value reached in a single run.

const ENTRIES: Array[Dictionary] = [
	# --- Weapons -------------------------------------------------------------
	{key = "weapon:wisp", path = "res://data/weapons/fuego_fatuo.tres", price = 15,
		stat = "total_chests", target = 5, quest = "Abre {target} cofres"},
	{key = "weapon:lightning", path = "res://data/weapons/rayo.tres", price = 20,
		stat = "total_kills", target = 1500, quest = "Derrota a {target} enemigos"},
	{key = "weapon:embers", path = "res://data/weapons/brasas.tres", price = 25,
		stat = "best_time", target = 300, quest = "Sobrevive {target} en una partida", time = true},
	{key = "weapon:vortex", path = "res://data/weapons/vortice.tres", price = 35,
		stat = "best_scroll:empuje", target = 4, quest = "Sube el pergamino de empuje a nivel {target}"},
	{key = "weapon:blunderbuss", path = "res://data/weapons/trabuco.tres", price = 40,
		stat = "total_kills", target = 5000, quest = "Derrota a {target} enemigos"},
	# --- Scrolls (Megabonk's unlockable tomes) -------------------------------
	{key = "scroll:espinas", path = "res://data/scrolls/espinas.tres", price = 10,
		stat = "best_time", target = 180, quest = "Sobrevive {target} en una partida", time = true},
	{key = "scroll:iman", path = "res://data/scrolls/iman.tres", price = 10,
		stat = "total_xp", target = 5000, quest = "Consigue {target} de experiencia"},
	{key = "scroll:experiencia", path = "res://data/scrolls/experiencia.tres", price = 15,
		stat = "best_level", target = 15, quest = "Llega al nivel {target} en una partida"},
	{key = "scroll:armadura", path = "res://data/scrolls/armadura.tres", price = 15,
		stat = "best_no_hit", target = 60, quest = "Pasa {target} seguidos sin recibir daño", time = true},
	{key = "scroll:duracion", path = "res://data/scrolls/duracion.tres", price = 15,
		stat = "best_weapon:bats", target = 6, quest = "Sube los murciélagos a nivel {target}"},
	{key = "scroll:vampirismo", path = "res://data/scrolls/vampirismo.tres", price = 20,
		stat = "best_level", target = 20, quest = "Llega al nivel {target} en una partida"},
	{key = "scroll:suerte", path = "res://data/scrolls/suerte.tres", price = 20,
		stat = "total_chests", target = 12, quest = "Abre {target} cofres"},
	{key = "scroll:maldito", path = "res://data/scrolls/maldito.tres", price = 25,
		stat = "total_cauldrons", target = 5, quest = "Prepara {target} calderos"},
	{key = "scroll:proyectiles", path = "res://data/scrolls/proyectiles.tres", price = 30,
		stat = "best_any_weapon", target = 10, quest = "Sube un arma a nivel {target}"},
	{key = "scroll:caos", path = "res://data/scrolls/caos.tres", price = 30,
		stat = "best_scrolls", target = 4, quest = "Lleva {target} pergaminos distintos en una partida"},
	# --- Items ---------------------------------------------------------------
	{key = "item:torn_grimoire", path = "res://data/items/torn_grimoire.tres", price = 25,
		stat = "total_items", target = 10, quest = "Compra {target} objetos al comerciante"},
	{key = "item:executioner_dagger", path = "res://data/items/executioner_dagger.tres", price = 30,
		stat = "total_kills", target = 2500, quest = "Derrota a {target} enemigos"},
	{key = "item:cursed_pocket_watch", path = "res://data/items/cursed_pocket_watch.tres", price = 30,
		stat = "best_time", target = 600, quest = "Sobrevive {target} en una partida", time = true},
	{key = "item:soul_reaper", path = "res://data/items/soul_reaper.tres", price = 35,
		stat = "best_kills", target = 800, quest = "Derrota a {target} enemigos en una partida"},
	{key = "item:sucky_magnet", path = "res://data/items/sucky_magnet.tres", price = 35,
		stat = "best_level", target = 30, quest = "Llega al nivel {target} en una partida"},
	{key = "item:devil_trident", path = "res://data/items/devil_trident.tres", price = 25,
		stat = "best_scroll:precision", target = 5, quest = "Sube el pergamino de precisión a nivel {target}"},
	{key = "item:witch_satchel", path = "res://data/items/witch_satchel.tres", price = 30,
		stat = "best_any_weapon", target = 12, quest = "Sube un arma a nivel {target}"},
	{key = "item:funeral_bell", path = "res://data/items/funeral_bell.tres", price = 30,
		stat = "best_time", target = 480, quest = "Sobrevive {target} en una partida", time = true},
	{key = "item:pumpkin_firecracker", path = "res://data/items/pumpkin_firecracker.tres", price = 30,
		stat = "best_kills", target = 1000, quest = "Derrota a {target} enemigos en una partida"},
	{key = "item:demonic_soul", path = "res://data/items/demonic_soul.tres", price = 35,
		stat = "total_kills", target = 10000, quest = "Derrota a {target} enemigos"},
	{key = "item:storm_orb", path = "res://data/items/storm_orb.tres", price = 40,
		stat = "best_weapon:lightning", target = 8, quest = "Sube el rayo espectral a nivel {target}"},
	{key = "item:infernal_flame", path = "res://data/items/infernal_flame.tres", price = 40,
		stat = "best_weapon:embers", target = 8, quest = "Sube el rastro de brasas a nivel {target}"},
	{key = "item:stopped_hourglass", path = "res://data/items/stopped_hourglass.tres", price = 40,
		stat = "total_runs", target = 15, quest = "Juega {target} partidas"},
	{key = "item:holy_grimoire", path = "res://data/items/holy_grimoire.tres", price = 45,
		stat = "best_no_hit", target = 120, quest = "Pasa {target} seguidos sin recibir daño", time = true},
	{key = "item:cursed_anvil", path = "res://data/items/cursed_anvil.tres", price = 45,
		stat = "best_any_weapon", target = 15, quest = "Sube un arma a nivel {target}"},
]

## Section titles in the unlocks menu, by key prefix.
const SECTIONS: Array[Dictionary] = [
	{prefix = "weapon:", title = "Armas"},
	{prefix = "scroll:", title = "Pergaminos"},
	{prefix = "item:", title = "Objetos"},
]


static func entry(key: String) -> Dictionary:
	for e in ENTRIES:
		if e.key == key:
			return e
	return {}


## The challenge as shown to the player: "Derrota a 1.500 enemigos", "Sobrevive 5:00 en una partida".
static func quest_text(e: Dictionary) -> String:
	var target := Settings.format_time(e.target) if e.get("time", false) else thousands(e.target)
	return e.quest.replace("{target}", target)


## Progress towards the challenge, e.g. "320 / 1.500".
static func progress_text(e: Dictionary, value: float) -> String:
	if e.get("time", false):
		return "%s / %s" % [Settings.format_time(minf(value, e.target)), Settings.format_time(e.target)]
	return "%s / %s" % [thousands(mini(int(value), e.target)), thousands(e.target)]


## 12345 -> "12.345", Spanish style.
static func thousands(value: int) -> String:
	var digits := str(value)
	var out := ""
	for i in digits.length():
		if i > 0 and (digits.length() - i) % 3 == 0:
			out += "."
		out += digits[i]
	return out
