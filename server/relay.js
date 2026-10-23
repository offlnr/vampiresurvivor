// Room relay for Noche de Almas' online co-op.
//
// The host asks for a room and gets a short code; the guest joins with that code. From then on,
// every binary message one of them sends is forwarded unchanged to the other. Text messages are
// control messages (JSON): {"t":"host"}, {"t":"join","code":"ABCD"}. The server answers with
// {"t":"room","code"}, {"t":"joined"}, {"t":"peer_joined"}, {"t":"peer_left"} or {"t":"error","msg"}.
// The game itself runs on the host; this server never looks inside the relayed messages.

const http = require("http");
const { WebSocketServer } = require("ws");

const PORT = Number(process.env.PORT) || 8080;
// No 0/O or 1/I, so a code read aloud or copied by hand can't be mistyped.
const CODE_ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
const CODE_LENGTH = 4;
// Clients ping through WebSocket frames; a socket silent for this long is dropped.
const IDLE_TIMEOUT_MS = 30000;
// A relayed message larger than this is dropped (a snapshot is a few tens of KB).
const MAX_MESSAGE_BYTES = 1 << 20;

/** code -> {host: WebSocket, guest: WebSocket|null} */
const rooms = new Map();

const server = http.createServer((req, res) => {
  // Health check for hosting services, and a friendly page for people who open the URL.
  res.writeHead(200, { "Content-Type": "text/plain; charset=utf-8" });
  res.end(`Noche de Almas relay: ${rooms.size} sala(s) abierta(s)\n`);
});

const wss = new WebSocketServer({ server, maxPayload: MAX_MESSAGE_BYTES });

function send(socket, message) {
  if (socket && socket.readyState === socket.OPEN) {
    socket.send(JSON.stringify(message));
  }
}

function newCode() {
  for (;;) {
    let code = "";
    for (let i = 0; i < CODE_LENGTH; i++) {
      code += CODE_ALPHABET[Math.floor(Math.random() * CODE_ALPHABET.length)];
    }
    if (!rooms.has(code)) return code;
  }
}

function other(socket) {
  const room = rooms.get(socket.room);
  if (!room) return null;
  return room.host === socket ? room.guest : room.host;
}

function leave(socket) {
  const room = rooms.get(socket.room);
  if (!room) return;
  if (room.host === socket) {
    // Without its host the room is over: the guest is told and the code is freed.
    send(room.guest, { t: "peer_left" });
    if (room.guest) room.guest.room = null;
    rooms.delete(socket.room);
  } else if (room.guest === socket) {
    room.guest = null;
    send(room.host, { t: "peer_left" });
  }
  socket.room = null;
}

function onControl(socket, text) {
  let message;
  try {
    message = JSON.parse(text);
  } catch {
    return send(socket, { t: "error", msg: "Mensaje no válido." });
  }
  if (message.t === "host") {
    leave(socket);
    const code = newCode();
    rooms.set(code, { host: socket, guest: null });
    socket.room = code;
    send(socket, { t: "room", code });
  } else if (message.t === "join") {
    const code = String(message.code || "").trim().toUpperCase();
    const room = rooms.get(code);
    if (!room) return send(socket, { t: "error", msg: "No existe ninguna sala con ese código." });
    if (room.guest) return send(socket, { t: "error", msg: "La sala ya está llena." });
    leave(socket);
    room.guest = socket;
    socket.room = code;
    send(socket, { t: "joined", code });
    send(room.host, { t: "peer_joined" });
  } else if (message.t === "leave") {
    leave(socket);
  }
}

wss.on("connection", (socket) => {
  socket.room = null;
  socket.lastSeen = Date.now();
  socket.on("message", (data, isBinary) => {
    socket.lastSeen = Date.now();
    if (!isBinary) return onControl(socket, data.toString());
    const peer = other(socket);
    if (peer && peer.readyState === peer.OPEN) peer.send(data, { binary: true });
  });
  socket.on("pong", () => (socket.lastSeen = Date.now()));
  socket.on("close", () => leave(socket));
  socket.on("error", () => leave(socket));
});

// Keeps connections alive behind proxies and drops the ones that went silent.
setInterval(() => {
  const now = Date.now();
  for (const socket of wss.clients) {
    if (now - socket.lastSeen > IDLE_TIMEOUT_MS) {
      socket.terminate();
    } else {
      socket.ping();
    }
  }
}, 10000);

server.listen(PORT, () => console.log(`Relay listening on port ${PORT}`));
