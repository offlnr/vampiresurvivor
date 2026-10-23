class_name Decorations
extends Node2D
## Props that dress the endless graveyard: crypts, dead trees, obelisks, lamps, little graveyards
## and ground details. The world is split in chunks; each chunk's props come from the run's seed
## and the chunk's coordinates, so a place looks the same when the player comes back.
## Only chunks near the player have nodes. Big props are solid: `push_out()` keeps the player
## and walking enemies outside their footprint (an ellipse at the base of the sprite).

const CHUNK := 800.0
## Chunks around the player's chunk that have nodes (the screen is well inside this).
const LOAD_RADIUS := 2
## Data of chunks farther than this is dropped; it can always be generated again.
const FORGET_RADIUS := 6
## No solid prop this close to where the run starts.
const START_CLEAR := 380.0
## Solid props keep at least this gap between their footprints.
const SOLID_GAP := 70.0
const CHUNK_MARGIN := 110.0
const SHADOW := preload("res://art/placeholder/shadow.svg")
const GLOW := preload("res://art/placeholder/puff.svg")
const SMALL_TINT := Color(0.66, 0.62, 0.76)
## Characters y-sort by their centre, but their feet are about this far below it (the player's at 32,
## normal enemies' at 25-30). Upright props sort this much higher than their base, so a character
## standing in front of a prop is drawn in front of it.
const SORT_OFFSET := 30.0

## Solid structures. Footprint: half width `rx`, half depth `ry`, centred `up` units above the base.
const STRUCTURES := {
	&"mausoleum": {texture = preload("res://art/placeholder/props/mausoleum.svg"), rx = 104.0, ry = 34.0, up = 22.0, weight = 1.0},
	&"dead_tree": {texture = preload("res://art/placeholder/props/dead_tree.svg"), rx = 14.0, ry = 9.0, up = 6.0, weight = 3.0},
	&"obelisk": {texture = preload("res://art/placeholder/props/obelisk.svg"), rx = 30.0, ry = 12.0, up = 12.0, weight = 2.0},
	&"broken_pillar": {texture = preload("res://art/placeholder/props/broken_pillar.svg"), rx = 30.0, ry = 12.0, up = 10.0, weight = 2.0},
	&"lamp_post": {texture = preload("res://art/placeholder/props/lamp_post.svg"), rx = 9.0, ry = 6.0, up = 4.0, weight = 2.0, glow = Vector2(0, -118)},
	&"pumpkin_pile": {texture = preload("res://art/placeholder/props/pumpkin_pile.svg"), rx = 50.0, ry = 22.0, up = 22.0, weight = 1.5},
	&"big_tomb": {texture = preload("res://art/placeholder/props/big_tomb.svg"), rx = 38.0, ry = 12.0, up = 10.0, weight = 2.5},
}
## Walk-through details. Flat ones lie on the ground and are always drawn under characters.
const SMALL := {
	&"small_grave": {texture = preload("res://art/placeholder/props/small_grave.svg"), weight = 0.0},
	&"cross": {texture = preload("res://art/placeholder/props/cross.svg"), weight = 0.0},
	&"tall_grass": {texture = preload("res://art/placeholder/props/tall_grass.svg"), weight = 5.0, flat = true},
	&"bones": {texture = preload("res://art/placeholder/props/bones.svg"), weight = 2.0, flat = true},
	&"skull": {texture = preload("res://art/placeholder/props/skull.svg"), weight = 1.5, flat = true},
	&"mushrooms": {texture = preload("res://art/placeholder/props/mushrooms.svg"), weight = 2.0, flat = true},
	&"candles": {texture = preload("res://art/placeholder/props/candles.svg"), weight = 1.0, glow = Vector2(0, -26), flat = true},
}

var player: Node2D
## Changes every run, so each run has its own map.
var world_seed := 0

## Chunk -> {solids: Array[Dictionary], props: Array[Dictionary]}.
var _data := {}
## Chunk -> its node, for chunks that are shown.
var _nodes := {}
var _glows: Array[Sprite2D] = []
var _time := 0.0
var _center_chunk := Vector2i(1 << 30, 0)


func _ready() -> void:
	y_sort_enabled = true
	world_seed = randi()


func _process(delta: float) -> void:
	if player == null:
		return
	_time += delta
	var center := chunk_of(player.global_position)
	if center != _center_chunk:
		_center_chunk = center
		_refresh_chunks(center)
	# Lamp and candle light flickers a little.
	for glow in _glows:
		glow.modulate.a = glow.get_meta(&"base_alpha") * (0.85 + 0.15 * sin(_time * 7.0 + glow.position.x))


static func chunk_of(pos: Vector2) -> Vector2i:
	return Vector2i(floori(pos.x / CHUNK), floori(pos.y / CHUNK))


## `pos` moved outside every solid prop footprint it overlaps, for a body of this radius.
func push_out(pos: Vector2, radius: float) -> Vector2:
	var chunk := chunk_of(pos)
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			for solid: Dictionary in _chunk_data(chunk + Vector2i(dx, dy)).solids:
				var center: Vector2 = solid.center
				var stretch: float = solid.rx / solid.ry
				var offset := pos - center
				offset.y *= stretch
				var reach: float = solid.rx + radius
				var length_squared := offset.length_squared()
				if length_squared >= reach * reach:
					continue
				offset = Vector2.DOWN * reach if length_squared < 0.0001 else offset / sqrt(length_squared) * reach
				offset.y /= stretch
				pos = center + offset
	return pos


## True when a body of this radius at `pos` doesn't touch any solid prop.
func is_free(pos: Vector2, radius: float) -> bool:
	return push_out(pos, radius).is_equal_approx(pos)


## Number of solid props in the shown chunks (for tests and debugging).
func solid_count() -> int:
	var total := 0
	for chunk: Vector2i in _nodes:
		total += _chunk_data(chunk).solids.size()
	return total


func _refresh_chunks(center: Vector2i) -> void:
	for dx in range(-LOAD_RADIUS, LOAD_RADIUS + 1):
		for dy in range(-LOAD_RADIUS, LOAD_RADIUS + 1):
			var chunk := center + Vector2i(dx, dy)
			if not _nodes.has(chunk):
				_nodes[chunk] = _build_chunk(chunk)
	for chunk: Vector2i in _nodes.keys():
		if _distance(chunk, center) > LOAD_RADIUS + 1:
			var node: Node2D = _nodes[chunk]
			for glow in node.get_meta(&"glows", []):
				_glows.erase(glow)
			node.queue_free()
			_nodes.erase(chunk)
	for chunk: Vector2i in _data.keys():
		if _distance(chunk, center) > FORGET_RADIUS:
			_data.erase(chunk)


static func _distance(a: Vector2i, b: Vector2i) -> int:
	return maxi(absi(a.x - b.x), absi(a.y - b.y))


func _build_chunk(chunk: Vector2i) -> Node2D:
	var node := Node2D.new()
	node.y_sort_enabled = true
	var glows: Array[Sprite2D] = []
	var data := _chunk_data(chunk)
	for solid: Dictionary in data.solids:
		var spec: Dictionary = STRUCTURES[solid.kind]
		node.add_child(_prop_sprite(spec, solid.base, solid.flip, solid.rx, glows))
	for prop: Dictionary in data.props:
		node.add_child(_prop_sprite(SMALL[prop.kind], prop.base, prop.flip, 0.0, glows))
	node.set_meta(&"glows", glows)
	_glows.append_array(glows)
	add_child(node)
	return node


## A prop drawn standing on `base`. Upright props y-sort with the player and enemies by their
## feet (see SORT_OFFSET); flat ones are always under them.
func _prop_sprite(spec: Dictionary, base: Vector2, flip: bool, shadow_width: float, glows: Array[Sprite2D]) -> Sprite2D:
	var texture: Texture2D = spec.texture
	var sprite := Sprite2D.new()
	sprite.texture = texture
	var flat: bool = spec.get("flat", false)
	var lift := 0.0 if flat else SORT_OFFSET
	sprite.position = base - Vector2(0, lift)
	sprite.offset = Vector2(0, lift - texture.get_height() / 2.0)
	if flat:
		sprite.z_index = -1
	sprite.flip_h = flip
	if shadow_width <= 0.0:
		# Small details are dimmed so they never compete with enemies, souls and pickups.
		sprite.modulate = SMALL_TINT
	else:
		var shadow := Sprite2D.new()
		shadow.texture = SHADOW
		shadow.show_behind_parent = true
		shadow.position = Vector2(0, lift)
		shadow.modulate.a = 0.7
		shadow.scale = Vector2(shadow_width * 2.4, shadow_width * 0.9) / SHADOW.get_size()
		sprite.add_child(shadow)
	if spec.has("glow"):
		var glow := Sprite2D.new()
		glow.texture = GLOW
		glow.position = spec.glow + Vector2(0, lift)
		glow.scale = Vector2.ONE * (2.6 if shadow_width > 0.0 else 1.2)
		glow.modulate = Color(Palette.GOLD, 0.3)
		glow.set_meta(&"base_alpha", 0.3)
		glow.show_behind_parent = true
		sprite.add_child(glow)
		glows.append(glow)
	return sprite


## What a chunk contains. Pure function of the world seed and the chunk, cached.
func _chunk_data(chunk: Vector2i) -> Dictionary:
	if _data.has(chunk):
		return _data[chunk]
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([world_seed, chunk.x, chunk.y])
	var origin := Vector2(chunk) * CHUNK
	var solids: Array[Dictionary] = []
	var props: Array[Dictionary] = []

	var structures := rng.rand_weighted(PackedFloat32Array([0.2, 0.45, 0.35]))
	for i in structures:
		var kind := _pick(STRUCTURES, rng)
		var spec: Dictionary = STRUCTURES[kind]
		for attempt in 8:
			var base := origin + Vector2(rng.randf_range(CHUNK_MARGIN, CHUNK - CHUNK_MARGIN), rng.randf_range(CHUNK_MARGIN, CHUNK - CHUNK_MARGIN))
			var solid := {kind = kind, base = base, center = base - Vector2(0, spec.up), rx = spec.rx, ry = spec.ry, flip = rng.randf() < 0.5}
			if base.length() > START_CLEAR + spec.rx and _fits(solid, solids):
				solids.append(solid)
				break

	# Now and then, a little graveyard: rows of graves and crosses.
	if rng.randf() < 0.35:
		var rows := rng.randi_range(2, 3)
		var columns := rng.randi_range(3, 5)
		var corner := origin + Vector2(rng.randf_range(60, CHUNK - 60 - columns * 64), rng.randf_range(80, CHUNK - 80 - rows * 70))
		for row in rows:
			for column in columns:
				if rng.randf() < 0.15:
					continue
				var base := corner + Vector2(column * 64 + rng.randf_range(-6, 6), row * 70 + rng.randf_range(-4, 4))
				if _clear_of_solids(base, 30.0, solids):
					props.append({kind = &"small_grave" if rng.randf() < 0.65 else &"cross", base = base, flip = rng.randf() < 0.5})

	for i in rng.randi_range(8, 14):
		var base := origin + Vector2(rng.randf() * CHUNK, rng.randf() * CHUNK)
		if _clear_of_solids(base, 24.0, solids):
			props.append({kind = _pick(SMALL, rng), base = base, flip = rng.randf() < 0.5})

	var data := {solids = solids, props = props}
	_data[chunk] = data
	return data


func _fits(solid: Dictionary, others: Array[Dictionary]) -> bool:
	for other in others:
		var gap: float = solid.rx + other.rx + SOLID_GAP
		if (solid.center as Vector2).distance_to(other.center) < gap:
			return false
	return true


func _clear_of_solids(pos: Vector2, radius: float, solids: Array[Dictionary]) -> bool:
	for solid in solids:
		if pos.distance_to(solid.center) < solid.rx + radius:
			return false
	return true


static func _pick(table: Dictionary, rng: RandomNumberGenerator) -> StringName:
	var kinds: Array = table.keys()
	var weights := PackedFloat32Array()
	for kind in kinds:
		weights.append(table[kind].weight)
	return kinds[rng.rand_weighted(weights)]
