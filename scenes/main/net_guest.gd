class_name NetGuest
extends Node
## Online co-op, guest side. Nothing is simulated here: the run scene keeps only the ground, the
## decorations (built from the host's seed), the HUD and the menus. This node sends the guest's
## move direction to the host and draws each snapshot the host sends back (see NetHost): every
## unit becomes a proxy node that slides between its last two positions, so movement stays smooth
## although snapshots arrive only 20 times a second. The guest's own character is predicted: it
## moves here as soon as the guest presses a direction, and each snapshot only corrects it (the
## host's position plus the inputs it hasn't received yet), so it doesn't lag behind the controls.
## The guest's own level-up and item menus open when the host says so, and every choice made in
## them goes back to the host.

const INPUT_RATE := 30.0
## A unit that jumps farther than this between snapshots (a pooled node reused) appears there at once.
const SNAP_DISTANCE := 240.0
const DISCONNECT_DELAY := 2.5
## A predicted position this far from the host's is wrong (revived, pushed by a crypt...): it jumps there.
const PREDICTION_SNAP := 160.0
## Share of the prediction error corrected per second, so corrections don't show as jumps.
const CORRECTION_RATE := 8.0
const OUTLINE_SHADER := preload("res://scenes/enemies/silhouette.gdshader")
const OUTLINE_COLOR := Color(1, 0.79, 0.24, 1)

var run: Node

var _world: Node2D
var _actors: Node2D
var _decorations: Decorations
var _camera_holder: Player
var _hud: Control
## Host world child index -> the node its units go in.
var _containers: Array[Node2D] = []
## Unit id -> Proxy.
var _proxies := {}
## Resource id -> Texture2D or Font (null when it couldn't be found).
var _resources := {}
var _sub_resources := {}
var _input_left := 0.0
var _snapshot_time := 0.0
var _camera_from := Vector2.ZERO
var _camera_to := Vector2.ZERO
var _has_snapshot := false
var _status: Label
var _shown := {}
var _hud_weapons: Array[Weapon] = []
var _result_shown := false
var _leaving := false
var _outline_material: ShaderMaterial
## Stats panel sections and owned item counts, as the host last sent them.
var _stats: Array[Dictionary] = []
var _item_counts := {}
## Prediction of the guest's own character: inputs sent and not yet received by the host
## ([number, direction, seconds it was held]), its unit, speed and predicted position.
var _input_number := 0
var _inputs: Array[Array] = []
var _self_unit := 0
var _speed := 0.0
var _predicting := false
var _predicted := Vector2.ZERO
var _correction := Vector2.ZERO


func setup(owner_run: Node) -> void:
	run = owner_run
	_world = run.get_node("World")
	_actors = run.get_node("World/Actors")
	_decorations = run.get_node("World/Actors/Decorations")
	_camera_holder = run.player
	_hud = run.hud
	_outline_material = ShaderMaterial.new()
	_outline_material.shader = OUTLINE_SHADER
	_outline_material.set_shader_parameter(&"color", OUTLINE_COLOR)
	# Everything that simulates the game goes away; each container becomes an empty layer.
	for child in _world.get_children():
		if child == _actors:
			for actor in _actors.get_children():
				if actor != _decorations and actor != _camera_holder:
					_actors.remove_child(actor)
					actor.queue_free()
			_containers.append(_actors)
			continue
		var layer := Node2D.new()
		layer.name = child.name
		layer.z_index = child.z_index
		var index := child.get_index()
		_world.remove_child(child)
		child.queue_free()
		_world.add_child(layer)
		_world.move_child(layer, index)
		_containers.append(layer)
	# The local character only carries the camera: the guest's real character comes in the snapshots.
	_camera_holder.set_physics_process(false)
	_camera_holder.process_mode = Node.PROCESS_MODE_ALWAYS
	_camera_holder.get_node("Visual").visible = false
	_camera_holder.get_node("Shadow").visible = false
	_camera_holder.get_node("Collision").set_deferred(&"disabled", true)
	# Hides its own health bar too (drawn by the node itself, not by a child).
	_camera_holder.self_modulate = Color.TRANSPARENT
	_hud.minimap.visible = false
	_status = Label.new()
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.add_theme_font_size_override("font_size", 26)
	_status.add_theme_color_override("font_color", Palette.BONE)
	_status.add_theme_constant_override("outline_size", 8)
	_status.add_theme_color_override("font_outline_color", Palette.INK)
	_status.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_status.offset_left = -360
	_status.offset_right = 360
	_status.offset_top = 150
	_status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	run.get_node("UI").add_child(_status)
	_set_status("Conectando con la partida de tu compañero...")
	_connect_menus()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Net.message_received.connect(_on_message)
	Net.peer_left.connect(_on_lost.bind("Tu compañero ha salido de la partida."))
	Net.disconnected.connect(_on_lost.bind("Se ha perdido la conexión con el servidor."))


func _exit_tree() -> void:
	for weapon in _hud_weapons:
		weapon.free()
	_hud_weapons.clear()


func _process(delta: float) -> void:
	_input_left -= delta
	if _input_left <= 0.0 and Net.is_guest():
		_input_left = 1.0 / INPUT_RATE
		var direction := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
		var half := _camera_holder.get_viewport_rect().size / _camera_holder.camera.zoom * 0.5
		_input_number += 1
		_inputs.append([_input_number, direction, 0.0])
		Net.send([Net.MSG_INPUT, direction, half, _input_number])
	if _predicting and not get_tree().paused and not _inputs.is_empty():
		# Moves with the last direction sent, as the host will.
		var current: Array = _inputs.back()
		current[2] += delta
		_predicted += (current[1] as Vector2) * _speed * delta
		var step := _correction * minf(CORRECTION_RATE * delta, 1.0)
		_predicted += step
		_correction -= step
		_predicted = _decorations.push_out(_predicted, Player.BODY_RADIUS)
	var t := clampf((Time.get_ticks_msec() / 1000.0 - _snapshot_time) * NetHost.SEND_RATE, 0.0, 1.0)
	for id: int in _proxies:
		var proxy: Proxy = _proxies[id]
		proxy.position = _predicted if _predicting and id == _self_unit else proxy.from.lerp(proxy.to, t)
	if _has_snapshot:
		_camera_holder.global_position = _predicted if _predicting else _camera_from.lerp(_camera_to, t)


func _on_message(message: Array) -> void:
	match message[0]:
		Net.MSG_SNAPSHOT:
			var raw: PackedByteArray = (message[1] as PackedByteArray).decompress(message[2], FileAccess.COMPRESSION_DEFLATE)
			apply_snapshot(raw)
		Net.MSG_MENU:
			_on_menu(message[1])
		Net.MSG_START:
			# The host started again ("Reintentar").
			get_tree().paused = false
			get_tree().reload_current_scene()
		Net.MSG_END:
			_on_lost("Tu compañero ha vuelto al menú.")


## The guest's menus send what the guest does to the host, which answers with MSG_MENU. Each menu
## closes as soon as something is taken, so a second click can't land on the next one.
func _connect_menus() -> void:
	var level_up: Control = run.level_up_menu
	level_up.chosen.connect(func(offer: Dictionary) -> void:
		level_up.close()
		_act(["choose", offer.get("index", -1)]))
	level_up.reroll_requested.connect(func(index: int) -> void: _act(["reroll", index]))
	level_up.banish_requested.connect(func(index: int) -> void: _act(["banish", index]))
	level_up.skip_requested.connect(func() -> void:
		level_up.close()
		_act(["skip"]))
	level_up.ad_reroll_requested.connect(_on_ad_reroll)
	level_up.stats_provider = func() -> Array[Dictionary]: return _stats
	var shop: Control = run.shop_menu
	shop.bought.connect(func(index: int) -> void:
		shop.close()
		_act(["buy", index]))
	shop.closed.connect(func() -> void:
		shop.close()
		_act(["shop_close"]))
	shop.reroll_requested.connect(func(index: int) -> void: _act(["shop_reroll", index]))
	shop.banish_requested.connect(func(index: int) -> void: _act(["shop_banish", index]))
	shop.stats_provider = level_up.stats_provider
	shop.owned_provider = func(item: ItemData) -> int: return _item_counts.get(String(item.id), 0)


func _act(action: Array) -> void:
	Net.send([Net.MSG_ACTION, action])


## The ad is watched on this device; the host grants the reroll.
func _on_ad_reroll() -> void:
	if await Ads.show_rewarded(Ads.EXTRA_REROLL):
		_act(["ad_reroll"])


## Opens, updates or closes the guest's menus (see the host's Run._show_next_choice and _open_shop).
func _on_menu(message: Array) -> void:
	var level_up: Control = run.level_up_menu
	var shop: Control = run.shop_menu
	match StringName(message[0]):
		&"level_up":
			var offers: Array[Dictionary] = []
			for i in message[1].size():
				offers.append(_decode_offer(message[1][i], i))
			_stats.assign(message[7])
			level_up.skips_left = message[5]
			level_up.ad_rerolls_left = message[6]
			run.pause_menu.close()
			level_up.open(offers, message[2], message[3], message[4])
		&"card":
			level_up.replace_offer(message[1], _decode_offer(message[2], message[1]), message[3], message[4])
		&"counts":
			level_up.ad_rerolls_left = message[3]
			level_up.set_counts(message[1], message[2])
		&"shop":
			_item_counts = message[9]
			_stats.assign(message[10])
			run.pause_menu.close()
			shop.open(message[1], message[2], _decode_items(message[3]), _ints(message[4]), message[5], message[6],
				message[7], message[8])
		&"shop_refresh":
			_item_counts = message[6]
			shop.refresh(_decode_items(message[1]), _ints(message[2]), message[3], message[4], message[5])
		&"close":
			level_up.close()
			shop.close()
			if not run.pause_menu.visible:
				get_tree().paused = false


func _decode_offer(data: Dictionary, index: int) -> Dictionary:
	var offer := {icon = _load_resource(data.icon), rarity = data.rarity, tag = data.tag, title = data.title,
		description = data.description, index = index}
	if data.banishable:
		# Only its presence matters here: it shows the banish button.
		offer.key = ""
	return offer


func _decode_items(paths: Array) -> Array[ItemData]:
	var items: Array[ItemData] = []
	for path: String in paths:
		var item := _load_resource(path) as ItemData
		if item != null:
			items.append(item)
	return items


static func _ints(values: Array) -> Array[int]:
	var result: Array[int] = []
	result.assign(values)
	return result


func _on_lost(reason: String) -> void:
	if _leaving or not is_inside_tree():
		return
	_leaving = true
	_set_status(reason)
	Net.leave()
	await get_tree().create_timer(DISCONNECT_DELAY, true).timeout
	get_tree().paused = false
	get_tree().change_scene_to_file(run.MENU_SCENE)


## Draws one snapshot (see NetHost.snapshot) and updates the HUD with it.
func apply_snapshot(raw: PackedByteArray) -> void:
	var data := StreamPeerBuffer.new()
	data.data_array = raw
	var header: Dictionary = data.get_var()
	for entry: Array in header.resources:
		_resources[entry[0]] = _load_resource(entry[1])
	if not _has_snapshot:
		# The same seed builds the same graveyard on both screens.
		_decorations.world_seed = header.seed
		_decorations.player = _camera_holder
		_camera_from = header.pos
		_camera_to = header.pos
		_camera_holder.global_position = header.pos
		_has_snapshot = true
	else:
		_camera_from = _camera_holder.global_position
		_camera_to = header.pos
	_snapshot_time = Time.get_ticks_msec() / 1000.0
	_predict(header)
	var seen := {}
	for i in data.get_u32():
		var id := data.get_u32()
		var container := data.get_u8()
		var pos := Vector2(data.get_float(), data.get_float())
		var layers := {}
		for j in data.get_u8():
			var z := data.get_16()
			var items: Array = []
			for k in data.get_u16():
				items.append(_read_item(data))
			layers[z] = items
		seen[id] = true
		var proxy: Proxy = _proxies.get(id)
		if proxy == null or proxy.get_parent() != _containers[container]:
			if proxy != null:
				proxy.queue_free()
			proxy = Proxy.new()
			proxy.outline_material = _outline_material
			proxy.position = pos
			proxy.from = pos
			_containers[container].add_child(proxy)
			_proxies[id] = proxy
		else:
			proxy.from = proxy.position if proxy.position.distance_to(pos) < SNAP_DISTANCE else pos
		proxy.to = pos
		proxy.set_layers(layers)
	for id: int in _proxies.keys():
		if not seen.has(id):
			_proxies[id].queue_free()
			_proxies.erase(id)
	_update_hud(header)


## Where the guest's character should be now: the host's position plus the inputs the host
## hadn't received yet. The difference is corrected little by little, or at once when it is large.
func _predict(header: Dictionary) -> void:
	_self_unit = header.self_unit
	_speed = header.speed
	while not _inputs.is_empty() and _inputs[0][0] <= header.input:
		_inputs.pop_front()
	if not header.moving:
		# Stopped (a menu, the pause, fallen): the host's position as it is.
		_predicting = false
		_predicted = header.pos
		_correction = Vector2.ZERO
		return
	var target: Vector2 = header.pos
	for entry: Array in _inputs:
		target += (entry[1] as Vector2) * _speed * entry[2]
	target = _decorations.push_out(target, Player.BODY_RADIUS)
	if not _predicting or target.distance_to(_predicted) > PREDICTION_SNAP:
		_predicted = target
		_correction = Vector2.ZERO
	else:
		_correction = target - _predicted
	_predicting = true


## The guest's character as drawn here (predicted), for tests.
func predicted_position() -> Vector2:
	return _predicted


func proxy_count() -> int:
	return _proxies.size()


func _read_item(data: StreamPeerBuffer) -> Array:
	var kind := data.get_u8()
	var transform := _get_transform(data)
	match kind:
		NetHost.ITEM_TEXTURE:
			var texture: Texture2D = _resources.get(data.get_u16())
			var flags := data.get_u8()
			var rect := _get_rect(data)
			var source := Rect2(Vector2.ZERO, texture.get_size() if texture != null else Vector2.ONE)
			if flags & NetHost.FLAG_SOURCE:
				source = Rect2(data.get_u16(), data.get_u16(), data.get_u16(), data.get_u16())
			return [kind, transform, texture, flags & NetHost.FLAG_OUTLINE != 0, rect, source, _get_color(data)]
		NetHost.ITEM_LABEL:
			var font: Font = _resources.get(data.get_u16())
			var font_size := data.get_u16()
			var outline_size := data.get_u8()
			var align := data.get_u8()
			var rect := _get_rect(data)
			var color := _get_color(data)
			var outline_color := _get_color(data)
			return [kind, transform, font if font != null else ThemeDB.fallback_font, font_size, outline_size, align,
				rect, color, outline_color, data.get_utf8_string()]
		NetHost.ITEM_LINE:
			var width := data.get_float()
			var color := _get_color(data)
			var points := PackedVector2Array()
			for i in data.get_u16():
				points.append(Vector2(data.get_float(), data.get_float()))
			return [kind, transform, width, color, points]
		_:
			var color := _get_color(data)
			return [kind, transform, color, data.get_var()]


static func _get_transform(data: StreamPeerBuffer) -> Transform2D:
	var x := Vector2(data.get_16(), data.get_16()) / 1024.0
	var y := Vector2(data.get_16(), data.get_16()) / 1024.0
	var origin := Vector2(data.get_16(), data.get_16()) / 4.0
	return Transform2D(x, y, origin)


static func _get_rect(data: StreamPeerBuffer) -> Rect2:
	return Rect2(data.get_16() / 4.0, data.get_16() / 4.0, data.get_16() / 4.0, data.get_16() / 4.0)


static func _get_color(data: StreamPeerBuffer) -> Color:
	return Color(data.get_u8() / 127.5, data.get_u8() / 127.5, data.get_u8() / 127.5, data.get_u8() / 255.0)


## Loads a texture or font by path. Sub-resources ("file.tres::id") are looked up inside their file.
func _load_resource(path: String) -> Resource:
	if path.is_empty():
		return null
	if not "::" in path:
		return load(path) if ResourceLoader.exists(path) else null
	if not _sub_resources.has(path):
		var base := path.get_slice("::", 0)
		var owner_resource: Resource = load(base) if ResourceLoader.exists(base) else null
		_sub_resources[path] = _find_sub_resource(owner_resource, path, {}) if owner_resource != null else null
	return _sub_resources[path]


static func _find_sub_resource(value: Variant, path: String, visited: Dictionary) -> Resource:
	if value is Resource:
		var resource: Resource = value
		if resource.resource_path == path:
			return resource
		if visited.has(resource.get_instance_id()):
			return null
		visited[resource.get_instance_id()] = true
		for property in resource.get_property_list():
			if property.usage & PROPERTY_USAGE_STORAGE:
				var found := _find_sub_resource(resource.get(property.name), path, visited)
				if found != null:
					return found
	elif value is Array:
		for element: Variant in value:
			var found := _find_sub_resource(element, path, visited)
			if found != null:
				return found
	elif value is Dictionary:
		for element: Variant in (value as Dictionary).values():
			var found := _find_sub_resource(element, path, visited)
			if found != null:
				return found
	return null


func _update_hud(header: Dictionary) -> void:
	_hud.set_time(header.time)
	_hud.set_xp(header.xp, header.xp_needed, header.level)
	_hud.set_kills(header.kills)
	_hud.set_gold(header.gold)
	_hud.set_health(header.health, header.max_health)
	_hud.set_buffs(header.buffs)
	if header.difficulty > 0.0:
		_hud.set_difficulty(header.difficulty)
	_hud.set_boss(header.boss[0] if not header.boss.is_empty() else "", header.boss[1] if not header.boss.is_empty() else -1.0)
	if header.weapons != _shown.get("weapons"):
		_shown.weapons = header.weapons
		for weapon in _hud_weapons:
			weapon.free()
		_hud_weapons.clear()
		for entry: Array in header.weapons:
			var data := _find_by_id(run.WEAPONS, entry[0]) as WeaponData
			if data != null:
				var weapon := Weapon.new()
				weapon.data = data
				weapon.level = entry[1]
				_hud_weapons.append(weapon)
		_hud.set_weapons(_hud_weapons)
	if header.scrolls != _shown.get("scrolls"):
		_shown.scrolls = header.scrolls
		var icons: Array[Dictionary] = []
		for entry: Array in header.scrolls:
			var scroll := _find_by_id(run.SCROLLS, entry[0]) as UpgradeData
			if scroll != null:
				icons.append({icon = scroll.icon, level = entry[1]})
		_hud.set_passives(icons)
	if header.items != _shown.get("items"):
		_shown.items = header.items
		var stacks := {}
		for entry: Array in header.items:
			var item := _find_by_id(run.ITEMS, entry[0]) as ItemData
			if item != null:
				stacks[item] = entry[1]
		_hud.set_items(stacks)
	for event: Array in header.events:
		_hud.callv(event[0], event[1])
	for sound: Array in header.sounds:
		Audio.play(sound[0], 0.08, sound[1])
	if not _leaving:
		if header.status != "":
			_set_status(header.status)
		elif header.dead and header.result == null:
			_set_status("Has caído. Revivirás cuando subáis de nivel.")
		else:
			_set_status("")
	if header.result != null and not _result_shown:
		_result_shown = true
		_show_result(header.result)


func _show_result(result: Dictionary) -> void:
	_set_status("")
	var new_record := Settings.submit_run(result.time, result.kills)
	var rewards := Progress.record_run(result.record)
	run.game_over.retry_button.visible = false
	run.game_over.show_result(result.time, result.level, result.kills, new_record)
	run.game_over.show_rewards(rewards.silver, Progress.silver, rewards.completed)


func _set_status(text: String) -> void:
	_status.text = text
	_status.visible = text != ""


static func _find_by_id(list: Array, id: String) -> Resource:
	for entry: Resource in list:
		if String(entry.get(&"id")) == id:
			return entry
	return null


## One unit of the host's world: positioned like it, with one Layer per z index it draws on.
class Proxy extends Node2D:
	var from := Vector2.ZERO
	var to := Vector2.ZERO
	var outline_material: Material
	var _layers := {}

	func set_layers(layers: Dictionary) -> void:
		for z: int in _layers.keys():
			if not layers.has(z):
				_layers[z].queue_free()
				_layers.erase(z)
		for z: int in layers:
			var layer: Layer = _layers.get(z)
			if layer == null:
				layer = Layer.new()
				layer.z_index = z
				layer.z_as_relative = false
				layer.outline_material = outline_material
				add_child(layer)
				_layers[z] = layer
			layer.set_items(layers[z])


## Draws the items of one unit on one z index, in the host's order.
class Layer extends Node2D:
	var outline_material: Material
	var _items: Array = []
	## Elite outlines need the silhouette shader, so they are drawn by a child behind this layer.
	var _outline: Node2D

	func set_items(items: Array) -> void:
		_items = items
		queue_redraw()
		var has_outline := false
		for item: Array in items:
			if item[0] == NetHost.ITEM_TEXTURE and item[3]:
				has_outline = true
				break
		if has_outline and _outline == null:
			_outline = Node2D.new()
			_outline.material = outline_material
			_outline.show_behind_parent = true
			_outline.draw.connect(func() -> void: NetGuest.paint(_outline, _items, true))
			add_child(_outline)
		if _outline != null:
			_outline.visible = has_outline
			_outline.queue_redraw()

	func _draw() -> void:
		NetGuest.paint(self, _items, false)


## Draws snapshot items on `canvas`: only the outlined textures, or everything else.
static func paint(canvas: CanvasItem, items: Array, outline: bool) -> void:
	for item: Array in items:
		var kind: int = item[0]
		if kind == NetHost.ITEM_TEXTURE:
			if item[3] != outline or item[2] == null:
				continue
			canvas.draw_set_transform_matrix(item[1])
			canvas.draw_texture_rect_region(item[2], item[4], item[5], item[6])
			continue
		if outline:
			continue
		canvas.draw_set_transform_matrix(item[1])
		match kind:
			NetHost.ITEM_LABEL:
				var font: Font = item[2]
				var font_size: int = item[3]
				var rect: Rect2 = item[6]
				var text: String = item[9]
				var width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
				var x := 0.0
				match item[5]:
					HORIZONTAL_ALIGNMENT_CENTER:
						x = (rect.size.x - width) / 2.0
					HORIZONTAL_ALIGNMENT_RIGHT:
						x = rect.size.x - width
				var baseline := (rect.size.y - font.get_height(font_size)) / 2.0 + font.get_ascent(font_size)
				var pos := rect.position + Vector2(x, baseline)
				if item[4] > 0:
					canvas.draw_string_outline(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, item[4], item[8])
				canvas.draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, item[7])
			NetHost.ITEM_LINE:
				canvas.draw_polyline(item[4], item[3], item[2], true)
			NetHost.ITEM_OPS:
				NetDraw.paint(canvas, item[3])
	canvas.draw_set_transform_matrix(Transform2D.IDENTITY)
