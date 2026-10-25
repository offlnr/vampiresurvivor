class_name CharacterData
extends Resource
## A playable character: its look, the weapon it starts with and a small passive bonus.

@export var id: StringName
@export var display_name := ""
@export_multiline var description := ""
@export var frames: SpriteFrames
@export var starting_weapon: WeaponData
## Passive bonuses applied when the run starts, as scroll stats (see UpgradeData.Stat).
@export var bonus_stats: Array[int] = []
## Value of each bonus in `bonus_stats`, same order and units as a scroll.
@export var bonus_values: PackedFloat32Array
## The passive as shown on the selection screen.
@export var bonus_text := ""
