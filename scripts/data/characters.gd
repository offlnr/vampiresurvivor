class_name Characters
extends RefCounted
## Every playable character, in the order the selection screen shows them.

const ALL: Array[CharacterData] = [
	preload("res://data/characters/bruja.tres"),
	preload("res://data/characters/fantasmita.tres"),
	preload("res://data/characters/esqueleto.tres"),
	preload("res://data/characters/calabazin.tres"),
	preload("res://data/characters/vampiro.tres"),
	preload("res://data/characters/segador.tres"),
]


## The character with this id, or the first one if there is none (an old or unknown save).
static func by_id(id: String) -> CharacterData:
	for character in ALL:
		if String(character.id) == id:
			return character
	return ALL[0]
