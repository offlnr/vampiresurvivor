extends Node
## Online co-op connection. Both players connect to the room relay (server/relay.js) over a
## WebSocket: the host asks for a room and gets a code, the guest joins with it, and from then on
## every message is forwarded to the other player. The host runs the whole game; the guest only
## sends its input and draws what the host sees around the guest's character (see NetHost, NetGuest).

signal room_created(code: String)
signal joined(code: String)
signal peer_joined
signal peer_left
## A message from the other player: an Array whose first element is one of the MSG_ constants.
signal message_received(message: Array)
signal failed(reason: String)
## The connection to the relay was lost or closed.
signal disconnected

enum Role { NONE, HOST, GUEST }

## Host -> guest: a run starts (also sent on "Reintentar").
const MSG_START := 0
## Guest -> host: move direction and the guest's visible world size.
const MSG_INPUT := 1
## Host -> guest: what the guest has to draw and show, compressed (see NetHost).
const MSG_SNAPSHOT := 2
## Guest -> host: the guest leaves the run.
const MSG_QUIT := 3
## Host -> guest: the host left the run for the menu.
const MSG_END := 4
## Host -> guest: open, update or close the guest's level-up or item menu (see Run, NetGuest).
const MSG_MENU := 5
## Guest -> host: what the guest did in that menu (choose, reroll, banish, buy...).
const MSG_ACTION := 6
## Guest -> host, on joining: what the guest has unlocked, so its cards and shops offer that.
const MSG_UNLOCKS := 7

const CONFIG_PATH := "user://net.cfg"
## The room server on Render (see server/README.md). For local tests: ws://localhost:8080
## (`node server/relay.js`), typed in the "Servidor" field.
const DEFAULT_SERVER := "wss://noche-de-almas-relay.onrender.com"
## Snapshots can be tens of KB; the default 64 KB buffers are too tight.
const BUFFER_SIZE := 1 << 21
## Free hosting plans put the server to sleep when nobody uses it; waking it up can take most of a minute.
const CONNECT_TIMEOUT := 60.0

var server_url := DEFAULT_SERVER
var role := Role.NONE
var room_code := ""
## True while the other player is in the room.
var peer_connected := false
## On the host: the unlock keys the guest sent (see Progress.unlocked).
var guest_unlocked := {}

var _socket: WebSocketPeer
var _open := false
## Control message to send as soon as the socket opens.
var _on_open := {}
var _connect_left := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var config := ConfigFile.new()
	if config.load(CONFIG_PATH) == OK:
		server_url = config.get_value("net", "server_url", DEFAULT_SERVER)


func is_online() -> bool:
	return role != Role.NONE and peer_connected


func is_host() -> bool:
	return role == Role.HOST and peer_connected


func is_guest() -> bool:
	return role == Role.GUEST and peer_connected


func set_server_url(url: String) -> void:
	server_url = url.strip_edges()
	var config := ConfigFile.new()
	config.set_value("net", "server_url", server_url)
	config.save(CONFIG_PATH)


## Opens a room on the relay; `room_created` brings its code.
func host_room() -> void:
	guest_unlocked = {}
	_connect({t = "host"})


## Joins the room with this code; `joined` or `failed` follows.
func join_room(code: String) -> void:
	_connect({t = "join", code = code.strip_edges().to_upper()})


## Leaves the room and closes the connection.
func leave() -> void:
	if _socket != null:
		if _open:
			_socket.send_text(JSON.stringify({t = "leave"}))
		_socket.close()
	_reset()


func send(message: Array) -> void:
	if _open and peer_connected:
		_socket.send(var_to_bytes(message), WebSocketPeer.WRITE_MODE_BINARY)


func _connect(control: Dictionary) -> void:
	leave()
	_socket = WebSocketPeer.new()
	_socket.inbound_buffer_size = BUFFER_SIZE
	_socket.outbound_buffer_size = BUFFER_SIZE
	var error := _socket.connect_to_url(server_url)
	if error != OK:
		_socket = null
		failed.emit("No se pudo conectar con %s." % server_url)
		return
	_on_open = control
	_connect_left = CONNECT_TIMEOUT


func _reset() -> void:
	_socket = null
	_open = false
	_on_open = {}
	role = Role.NONE
	room_code = ""
	peer_connected = false


func _process(delta: float) -> void:
	if _socket == null:
		return
	_socket.poll()
	match _socket.get_ready_state():
		WebSocketPeer.STATE_CONNECTING:
			_connect_left -= delta
			if _connect_left <= 0.0:
				_socket.close()
				_reset()
				failed.emit("El servidor %s no responde." % server_url)
		WebSocketPeer.STATE_OPEN:
			if not _open:
				_open = true
				_socket.send_text(JSON.stringify(_on_open))
			while _socket != null and _socket.get_available_packet_count() > 0:
				var packet := _socket.get_packet()
				if _socket.was_string_packet():
					_on_control(packet.get_string_from_utf8())
				else:
					var message: Variant = bytes_to_var(packet)
					if message is Array and not message.is_empty():
						if message[0] == MSG_UNLOCKS:
							guest_unlocked = {}
							for key: String in message[1]:
								guest_unlocked[key] = true
						message_received.emit(message)
		WebSocketPeer.STATE_CLOSED:
			var was_open := _open
			_reset()
			if was_open:
				disconnected.emit()
			else:
				failed.emit("No se pudo conectar con %s." % server_url)


func _on_control(text: String) -> void:
	var message: Variant = JSON.parse_string(text)
	if not message is Dictionary:
		return
	match message.get("t", ""):
		"room":
			role = Role.HOST
			room_code = message.code
			room_created.emit(room_code)
		"joined":
			role = Role.GUEST
			room_code = message.code
			peer_connected = true
			send([MSG_UNLOCKS, Progress.unlocked.keys()])
			joined.emit(room_code)
		"peer_joined":
			peer_connected = true
			peer_joined.emit()
		"peer_left":
			peer_connected = false
			peer_left.emit()
			if role == Role.GUEST:
				# Without a host the room is gone.
				leave()
		"error":
			failed.emit(str(message.get("msg", "Error del servidor.")))
