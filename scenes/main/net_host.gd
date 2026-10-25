class_name NetHost
extends Node
## Online co-op, host side. The whole game runs here; the guest's character is a second Player
## moved by the direction the guest sends. Several times a second this node looks at everything
## drawn in the world around the guest's character (sprites, labels, lines and NetDraw ops) and
## sends it, with the HUD values and the sounds played, as one compressed snapshot. The guest
## draws it as it comes (see NetGuest), so every weapon, enemy and effect works online without
## its own network code. Decorations are not sent: the guest builds them from the same seed.

## Snapshots per second.
const SEND_RATE := 20.0
## Extra world units sent around the guest's visible area, so nothing pops in at the edges.
const VIEW_MARGIN := 160.0
## At most this many sounds per snapshot; a crowd of hits doesn't need more.
const MAX_SOUNDS := 24

## Item kinds in a snapshot (see `_write_item`).
const ITEM_TEXTURE := 0
const ITEM_LABEL := 1
const ITEM_LINE := 2
const ITEM_OPS := 3
## Texture item flags.
const FLAG_SOURCE := 1
const FLAG_OUTLINE := 2

var run: Node
var guest: Player
## Half of the world area the guest sees, as it reports it.
var guest_view_half := Vector2(900, 520)

var _world: Node2D
var _decorations: Node
var _send_left := 0.0
## Resource -> id, for textures and fonts; new ones go to the guest as [id, resource path].
var _resource_ids := {}
var _new_resources: Array = []
## Node instance id -> unit id, so the guest can follow each thing from one snapshot to the next.
var _unit_ids := {}
var _next_unit_id := 1
var _sounds: Array = []
var _events: Array = []
## Number of the last input the guest sent, echoed back so the guest can predict its own movement.
var _guest_input := 0


func setup(owner_run: Node, guest_player: Player) -> void:
	run = owner_run
	guest = guest_player
	_world = run.get_node("World")
	_decorations = run.get_node("World/Actors/Decorations")


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Net.message_received.connect(_on_message)
	Audio.played.connect(_on_sound)


func _exit_tree() -> void:
	if Audio.played.is_connected(_on_sound):
		Audio.played.disconnect(_on_sound)


## Opens, updates or closes the guest's level-up or item menu (see NetGuest._on_menu).
func send_menu(message: Array) -> void:
	Net.send([Net.MSG_MENU, message])


## Shows this HUD message on the guest's screen too (method of the HUD and its arguments).
func queue_event(method: StringName, args: Array) -> void:
	_events.append([method, args])


func _on_sound(sound: StringName, volume_db: float) -> void:
	if _sounds.size() < MAX_SOUNDS:
		_sounds.append([sound, volume_db])


func _on_message(message: Array) -> void:
	match message[0]:
		Net.MSG_INPUT:
			if is_instance_valid(guest):
				guest.remote_direction = message[1]
			guest_view_half = message[2]
			if message.size() > 3:
				_guest_input = message[3]
		Net.MSG_QUIT:
			run.on_guest_left()
		Net.MSG_ACTION:
			run.on_guest_action(message[1])


func _process(delta: float) -> void:
	_send_left -= delta
	if _send_left > 0.0 or not Net.is_host():
		return
	_send_left = 1.0 / SEND_RATE
	var raw := snapshot()
	Net.send([Net.MSG_SNAPSHOT, raw.compress(FileAccess.COMPRESSION_DEFLATE), raw.size()])


## One snapshot: a header Dictionary, then the units (things drawn) near the guest.
func snapshot() -> PackedByteArray:
	var units := StreamPeerBuffer.new()
	var unit_count := 0
	var seen := {}
	var center: Vector2 = guest.global_position if is_instance_valid(guest) else run.player.global_position
	var half := guest_view_half + Vector2.ONE * VIEW_MARGIN
	var view := Rect2(center - half, half * 2.0)
	for index in _world.get_child_count():
		var container := _world.get_child(index) as CanvasItem
		if container == null or not container.visible:
			continue
		unit_count += _collect(container, index, container.z_index, Color.WHITE, view, units, seen)
	for id: int in _unit_ids.keys():
		if not seen.has(id):
			_unit_ids.erase(id)
	var out := StreamPeerBuffer.new()
	out.put_var(_header(center))
	out.put_u32(unit_count)
	out.put_data(units.data_array)
	_new_resources = []
	_sounds = []
	_events = []
	return out.data_array


## The shared run values, plus the guest's own character, weapons, scrolls, items and gold.
func _header(center: Vector2) -> Dictionary:
	var seat: Seat = run.guest_seat
	var weapons: Array = []
	var scrolls: Array = []
	var items: Array = []
	if seat != null:
		for weapon in seat.weapons:
			weapons.append([String(weapon.data.id), weapon.level])
		for scroll: UpgradeData in seat.scroll_levels:
			scrolls.append([String(scroll.id), seat.scroll_levels[scroll]])
		for item: ItemData in seat.inventory.stacks:
			items.append([String(item.id), seat.inventory.stacks[item]])
	var alive := is_instance_valid(guest)
	# The guest moves its own character at once and corrects it with these (see NetGuest).
	var moving := alive and not guest.is_dead and not get_tree().paused
	return {
		self_unit = _unit_ids.get(guest.get_instance_id(), 0) if alive else 0, input = _guest_input,
		speed = guest.move_speed() if alive else 0.0, moving = moving,
		resources = _new_resources, seed = _decorations.world_seed, pos = center,
		time = run.elapsed, level = run.level, xp = run.xp, xp_needed = run.xp_to_next_level(),
		kills = run.kills, gold = seat.gold if seat != null else 0, difficulty = run.enemy_manager.difficulty - 1.0,
		health = guest.health if alive else 0.0, max_health = guest.max_health if alive else 1.0,
		dead = guest.is_dead if alive else true, buffs = guest.buffs if alive else {},
		weapons = weapons, scrolls = scrolls, items = items,
		status = _status(), sounds = _sounds, events = _events, result = run.net_result,
	}


## What the host is doing while the game is stopped, for the guest's screen.
func _status() -> String:
	# The guest's own menu covers the screen; nothing to add then.
	if run.finished or run.guest_seat == null or run.guest_seat.menu != &"":
		return ""
	if run.local_seat.menu == &"level_up":
		return "Tu compañero está eligiendo su mejora..."
	if run.local_seat.menu == &"shop":
		return "Tu compañero está en la tienda..."
	if run.pause_menu.visible:
		return "Partida en pausa"
	return ""


## Writes the units under `parent`. In y-sorted groups (the actors) each child is a unit sorted by
## its position; nested y-sorted groups (enemies, merchants...) are flattened, as Godot does.
func _collect(parent: CanvasItem, container: int, parent_z: int, parent_modulate: Color, view: Rect2,
		out: StreamPeerBuffer, seen: Dictionary) -> int:
	var count := 0
	var modulate := parent_modulate * parent.modulate
	for child in parent.get_children():
		var item := child as CanvasItem
		if item == null or not item.visible or item == _decorations:
			continue
		var z := _z_of(item, parent_z)
		if parent.y_sort_enabled and item.y_sort_enabled and item.get_child_count() > 0:
			count += _collect(item, container, z, modulate, view, out, seen)
		elif _write_unit(item, container, z, modulate, view, out, seen):
			count += 1
	return count


func _write_unit(node: CanvasItem, container: int, z: int, parent_modulate: Color, view: Rect2,
		out: StreamPeerBuffer, seen: Dictionary) -> bool:
	var origin := node.get_global_transform().origin
	# Lines and custom drawings sit at the origin and draw in world coordinates: never culled.
	if not (node is Line2D or node.has_method(&"draw_ops")) and not view.has_point(origin):
		return false
	var layers := {}
	_write_items(node, z, parent_modulate, origin, layers)
	if layers.is_empty():
		return false
	var key := node.get_instance_id()
	if not _unit_ids.has(key):
		_unit_ids[key] = _next_unit_id
		_next_unit_id += 1
	seen[key] = true
	out.put_u32(_unit_ids[key])
	out.put_u8(container)
	out.put_float(origin.x)
	out.put_float(origin.y)
	out.put_u8(layers.size())
	for layer_z: int in layers:
		var layer: Array = layers[layer_z]
		out.put_16(layer_z)
		out.put_u16(layer[0])
		out.put_data((layer[1] as StreamPeerBuffer).data_array)
	return true


## The node and its children, in drawing order (children shown behind the parent first).
func _write_items(node: CanvasItem, z: int, parent_modulate: Color, origin: Vector2, layers: Dictionary) -> void:
	var modulate := parent_modulate * node.modulate
	for child in node.get_children():
		var item := child as CanvasItem
		if item != null and item.visible and item.show_behind_parent:
			_write_items(item, _z_of(item, z), modulate, origin, layers)
	if modulate.a > 0.003:
		_write_item(node, z, modulate * node.self_modulate, origin, layers)
	for child in node.get_children():
		var item := child as CanvasItem
		if item != null and item.visible and not item.show_behind_parent:
			_write_items(item, _z_of(item, z), modulate, origin, layers)


func _write_item(node: CanvasItem, z: int, color: Color, origin: Vector2, layers: Dictionary) -> void:
	var transform := node.get_global_transform()
	transform.origin -= origin
	if node is Sprite2D or node is AnimatedSprite2D:
		var texture: Texture2D
		var size: Vector2
		var source := Rect2()
		if node is Sprite2D:
			var sprite := node as Sprite2D
			texture = sprite.texture
			if texture == null:
				return
			source = sprite.region_rect if sprite.region_enabled else Rect2(Vector2.ZERO, texture.get_size())
			var frames := Vector2i(sprite.hframes, sprite.vframes)
			if frames != Vector2i.ONE:
				var frame_size := source.size / Vector2(frames)
				source = Rect2(source.position + frame_size * Vector2(sprite.frame_coords), frame_size)
			size = source.size
		else:
			var animated := node as AnimatedSprite2D
			if animated.sprite_frames == null or not animated.sprite_frames.has_animation(animated.animation):
				return
			texture = animated.sprite_frames.get_frame_texture(animated.animation, animated.frame)
			if texture == null:
				return
			size = texture.get_size()
		# Same rectangle Sprite2D and AnimatedSprite2D draw: negative sizes flip the image.
		var offset: Vector2 = node.get(&"offset") - (size / 2.0 if node.get(&"centered") else Vector2.ZERO)
		var rect := Rect2(offset, size)
		if node.get(&"flip_h"):
			rect.size.x = -rect.size.x
		if node.get(&"flip_v"):
			rect.size.y = -rect.size.y
		var full := source == Rect2() or source == Rect2(Vector2.ZERO, texture.get_size())
		var out := _layer(layers, z)
		out.put_u8(ITEM_TEXTURE)
		_put_transform(out, transform)
		out.put_u16(_resource_id(texture))
		# Only the elites' golden outline uses a shader.
		out.put_u8((0 if full else FLAG_SOURCE) | (FLAG_OUTLINE if node.material is ShaderMaterial else 0))
		_put_rect(out, rect)
		if not full:
			for value in [source.position.x, source.position.y, source.size.x, source.size.y]:
				out.put_u16(clampi(roundi(value), 0, 65535))
		_put_color(out, color)
	elif node is Label:
		var label := node as Label
		if label.text.is_empty():
			return
		var settings := label.label_settings
		var font: Font = settings.font if settings != null and settings.font != null else label.get_theme_font(&"font")
		var font_size: int = settings.font_size if settings != null else label.get_theme_font_size(&"font_size")
		var font_color: Color = settings.font_color if settings != null else label.get_theme_color(&"font_color")
		var outline_size: int = settings.outline_size if settings != null else label.get_theme_constant(&"outline_size")
		var outline_color: Color = settings.outline_color if settings != null else label.get_theme_color(&"font_outline_color")
		var out := _layer(layers, z)
		out.put_u8(ITEM_LABEL)
		_put_transform(out, transform)
		out.put_u16(_resource_id(font))
		out.put_u16(font_size)
		out.put_u8(outline_size)
		out.put_u8(label.horizontal_alignment)
		_put_rect(out, Rect2(Vector2.ZERO, label.size))
		_put_color(out, color * font_color)
		_put_color(out, color * outline_color)
		out.put_utf8_string(label.text)
	elif node is Line2D:
		var line := node as Line2D
		if line.points.size() < 2:
			return
		var out := _layer(layers, z)
		out.put_u8(ITEM_LINE)
		_put_transform(out, transform)
		out.put_float(line.width)
		_put_color(out, color * line.default_color)
		out.put_u16(line.points.size())
		for point in line.points:
			out.put_float(point.x)
			out.put_float(point.y)
	if node.has_method(&"draw_ops"):
		var ops: Array = node.call(&"draw_ops")
		if ops.is_empty():
			return
		var out := _layer(layers, z)
		out.put_u8(ITEM_OPS)
		_put_transform(out, transform)
		_put_color(out, color)
		out.put_var(ops)


## The buffer for this z layer of the current unit, counting one more item in it.
func _layer(layers: Dictionary, z: int) -> StreamPeerBuffer:
	if not layers.has(z):
		layers[z] = [0, StreamPeerBuffer.new()]
	layers[z][0] += 1
	return layers[z][1]


static func _z_of(item: CanvasItem, parent_z: int) -> int:
	return item.z_index + (parent_z if item.z_as_relative else 0)


func _resource_id(resource: Resource) -> int:
	if resource == null:
		return 0
	if not _resource_ids.has(resource):
		var id := _resource_ids.size() + 1
		_resource_ids[resource] = id
		_new_resources.append([id, resource.resource_path])
	return _resource_ids[resource]


## Rotation and scale in 1/1024 steps, position (relative to the unit) in 1/4 pixel steps.
static func _put_transform(out: StreamPeerBuffer, transform: Transform2D) -> void:
	for value in [transform.x.x, transform.x.y, transform.y.x, transform.y.y]:
		out.put_16(clampi(roundi(value * 1024.0), -32768, 32767))
	out.put_16(clampi(roundi(transform.origin.x * 4.0), -32768, 32767))
	out.put_16(clampi(roundi(transform.origin.y * 4.0), -32768, 32767))


static func _put_rect(out: StreamPeerBuffer, rect: Rect2) -> void:
	for value in [rect.position.x, rect.position.y, rect.size.x, rect.size.y]:
		out.put_16(clampi(roundi(value * 4.0), -32768, 32767))


## Red, green and blue up to 2 (so hit flashes still show), alpha up to 1.
static func _put_color(out: StreamPeerBuffer, color: Color) -> void:
	out.put_u8(clampi(roundi(color.r * 127.5), 0, 255))
	out.put_u8(clampi(roundi(color.g * 127.5), 0, 255))
	out.put_u8(clampi(roundi(color.b * 127.5), 0, 255))
	out.put_u8(clampi(roundi(color.a * 255.0), 0, 255))
