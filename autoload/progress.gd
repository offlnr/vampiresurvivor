extends Node
## Progress kept between runs, as in Megabonk: silver, what has been bought, and the stats
## that challenges are checked against (see `Unlocks`).

signal changed

const PATH := "user://progress.cfg"
## Silver at the end of a run: per minute survived, per level reached and per 100 kills.
## A 10-minute run at level 35 with 2.000 kills gives about 27.
const SILVER_PER_MINUTE := 1.0
const SILVER_PER_LEVEL := 0.2
const SILVER_PER_100_KILLS := 0.5

## Where progress is saved; tests point it somewhere else.
var path := PATH
var silver := 0
## Keys of the entries bought ("weapon:lightning").
var unlocked := {}
## Challenge stats: "total_kills", "best_time", "best_weapon:bats"...
var stats := {}
## Date ("2026-10-15") of the last daily gift claimed.
var last_gift := ""
## Id of the last character chosen (see Characters), so the selection screen starts on it.
var character := "witch"


func _ready() -> void:
	load_progress()


## True unless the key is in the catalogue and hasn't been bought.
func is_unlocked(key: String) -> bool:
	return unlocked.has(key) or Unlocks.entry(key).is_empty()


func stat(stat_name: String) -> float:
	return stats.get(stat_name, 0.0)


func quest_done(e: Dictionary) -> bool:
	return stat(e.stat) >= e.target


func can_buy(e: Dictionary) -> bool:
	return not unlocked.has(e.key) and quest_done(e) and silver >= e.price


func buy(key: String) -> bool:
	var e := Unlocks.entry(key)
	if e.is_empty() or not can_buy(e):
		return false
	silver -= e.price
	unlocked[key] = true
	save_progress()
	changed.emit()
	return true


## Silver earned by a run, before the silver multiplier.
static func run_silver(seconds: float, level: int, kills: int) -> int:
	return floori(seconds / 60.0 * SILVER_PER_MINUTE + level * SILVER_PER_LEVEL + kills / 100.0 * SILVER_PER_100_KILLS)


## Stores a finished run and returns what it gave: {silver, completed = [entries whose challenge it met]}.
## `run` holds: time, level, kills, xp, chests, items, cauldrons, no_hit, scrolls ({id: level}),
## weapons ({id: level}), silver_multiplier.
func record_run(run: Dictionary) -> Dictionary:
	var done_before := {}
	for e in Unlocks.ENTRIES:
		done_before[e.key] = quest_done(e)
	_add("total_kills", run.kills)
	_add("total_xp", run.xp)
	_add("total_chests", run.chests)
	_add("total_items", run.items)
	_add("total_cauldrons", run.cauldrons)
	_add("total_runs", 1)
	_best("best_time", run.time)
	_best("best_level", run.level)
	_best("best_kills", run.kills)
	_best("best_no_hit", run.no_hit)
	_best("best_scrolls", run.scrolls.size())
	for id in run.scrolls:
		_best("best_scroll:%s" % id, run.scrolls[id])
	for id in run.weapons:
		_best("best_weapon:%s" % id, run.weapons[id])
		_best("best_any_weapon", run.weapons[id])
	var earned := roundi(run_silver(run.time, run.level, run.kills) * run.get("silver_multiplier", 1.0))
	silver += earned
	var completed: Array[Dictionary] = []
	for e in Unlocks.ENTRIES:
		if not done_before[e.key] and quest_done(e) and not unlocked.has(e.key):
			completed.append(e)
	save_progress()
	changed.emit()
	return {silver = earned, completed = completed}


func set_character(id: String) -> void:
	character = id
	save_progress()


func add_silver(amount: int) -> void:
	silver += amount
	save_progress()
	changed.emit()


func can_claim_daily_gift() -> bool:
	return last_gift != Time.get_date_string_from_system()


func claim_daily_gift(amount: int) -> void:
	last_gift = Time.get_date_string_from_system()
	add_silver(amount)


func reset() -> void:
	silver = 0
	last_gift = ""
	character = "witch"
	unlocked.clear()
	stats.clear()


func load_progress() -> void:
	reset()
	var cfg := ConfigFile.new()
	if cfg.load(path) != OK:
		return
	silver = cfg.get_value("progress", "silver", 0)
	for key in cfg.get_value("progress", "unlocked", PackedStringArray()):
		unlocked[key] = true
	stats = cfg.get_value("progress", "stats", {})
	last_gift = cfg.get_value("progress", "last_gift", "")
	character = cfg.get_value("progress", "character", "witch")


func save_progress() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "silver", silver)
	cfg.set_value("progress", "unlocked", PackedStringArray(unlocked.keys()))
	cfg.set_value("progress", "stats", stats)
	cfg.set_value("progress", "last_gift", last_gift)
	cfg.set_value("progress", "character", character)
	cfg.save(path)


func _add(stat_name: String, amount: float) -> void:
	stats[stat_name] = stat(stat_name) + amount


func _best(stat_name: String, value: float) -> void:
	stats[stat_name] = maxf(stat(stat_name), value)
