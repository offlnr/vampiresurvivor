# Proposal

## Why

El jugador quiere jugar con otra persona, cada uno en su ordenador o móvil. El juego solo era para un jugador, y la build web de GitHub Pages no puede alojar ningún servidor.

## What Changes

- **Cooperativo online para dos jugadores.** Uno crea una sala y recibe un código de 4 caracteres; el otro se une con ese código, y el anfitrión empieza la partida para los dos.
- **Servidor de salas** (`server/relay.js`, Node.js con `ws`):
  - solo une a los dos jugadores por código y reenvía sus mensajes;
  - no ejecuta el juego;
  - se publica gratis en Render con `render.yaml`.
- **Anfitrión con autoridad**:
  - la partida entera corre en el dispositivo del anfitrión;
  - el personaje del invitado es un segundo `Player`, que se mueve con la dirección que envía el invitado.
- **Réplica genérica de lo que se dibuja**:
  - 20 veces por segundo, el anfitrión recorre todo lo que se dibuja en el mundo alrededor del invitado (sprites, textos, líneas y dibujos propios);
  - lo envía comprimido, con el HUD y los sonidos;
  - el invitado lo dibuja e interpola las posiciones entre dos instantáneas;
  - así cualquier arma, enemigo o efecto, actual o futuro, funciona online sin código de red propio;
  - las decoraciones no se envían: el invitado las genera con la misma semilla.
- **Cada jugador tiene lo suyo, como en solitario** (`Seat`): armas, pergaminos, objetos, oro, tiradas, destierros, saltos y anuncios de tirada. Al invitado se le ofrece lo que él ha desbloqueado.
- **Nivel compartido, elecciones individuales**:
  - la experiencia y el nivel son comunes;
  - en cada subida de nivel, cada jugador elige su propia mejora en su pantalla;
  - la partida sigue cuando han elegido los dos, y quien termina antes ve "Tu compañero está eligiendo su mejora...".
- **Compras individuales**:
  - comerciante, cofres de pago y cofres de élite funcionan para el invitado igual que para el anfitrión, cada uno con su oro y sus menús;
  - el comerciante atiende a cada jugador una vez y se va cuando han comprado todos los que siguen en pie;
  - el precio de los cofres de pago sube con cada cofre que abre cualquiera.
- **Recogida**: las almas, monedas, cofres y power-ups los recoge el jugador vivo más cercano. La experiencia y los power-ups son de los dos; el oro y los cofres, de quien los recoge.
- **Objetos con efecto personal**: el daño sabe quién golpea, así que los críticos, el robo de vida, el empuje y los efectos al golpear o al matar son los de los objetos de ese jugador.
- **Más dificultad en cooperativo**:
  - los enemigos tienen un 80 % más de vida y puede haber un 35 % más a la vez;
  - cada nivel necesita un 50 % más de experiencia;
  - los calderos suben la dificultad para los dos y dan su recompensa a los dos.
- **Caídas**:
  - si uno cae, la partida sigue, y revive con media vida en la siguiente subida de nivel;
  - la partida acaba cuando caen los dos.
- **Interfaz**:
  - nuevo botón **"Multijugador online"** en el menú principal, con la pantalla de sala;
  - el invitado ve su vida, el nivel, el tiempo, las armas y un aviso cuando está caído o cuando el anfitrión elige mejora o está en la tienda o en pausa;
  - al terminar, el invitado guarda la partida en su propio progreso y gana su plata.
- **Desconexiones**:
  - si el invitado se va, el anfitrión sigue solo;
  - si el anfitrión se va o se pierde la conexión, el invitado vuelve al menú con un aviso.
- **Sin pausa automática online**: cambiar de ventana no detiene la partida del otro jugador.

**Fuera de alcance (posibles siguientes pasos):**
- predicción local del movimiento del invitado (ahora su personaje responde con la latencia de ida y vuelta);
- más de dos jugadores.

## Capabilities

### New Capabilities
- `online-coop`: salas, conexión, réplica de la partida al invitado y reglas del cooperativo.

### Modified Capabilities
- `run-session`: "Menú principal" (botón de multijugador online).

## Impact

- **Nuevo**:
  - `autoload/net.gd` (autoload `Net`);
  - `scenes/main/net_host.gd`, `scenes/main/net_guest.gd`;
  - `scenes/ui/multiplayer_menu.gd`, `scripts/net_draw.gd`, `scripts/seat.gd`;
  - `server/` (relay, `package.json`, README), `render.yaml`.
- **Código modificado**:
  - `run.gd`: el estado de cada jugador pasa a `Seat`; segundo jugador, menús por jugador, pausa hasta que todos cierran, modo invitado, reintentar y salir;
  - `enemy_manager.gd`: varios jugadores, `coop_health`, `coop_count` y daño atribuido a quien golpea;
  - armas, `inventory.gd` y `player.gd` (espinas): indican quién golpea;
  - `pickup_manager.gd`: recoge el jugador más cercano y las señales dicen quién;
  - `merchant_director.gd`, `map_chests.gd`, `cauldrons.gd`: funcionan con los dos jugadores;
  - `shop_menu.gd`: `owned_provider`, para las copias que tiene el invitado;
  - `player.gd`: entrada remota;
  - `audio.gd`: señal `played`;
  - `hud.gd`: `show_message`;
  - `main_menu.gd`: botón nuevo.
- **Dibujos propios**: `_draw()` de `player.gd`, `enemy.gd`, `trail_weapon.gd`, `vortex_weapon.gd` y `cauldrons.gd` pasan por `draw_ops()` + `NetDraw.paint()`, para poder enviarse. Los arcos del vórtice pasan a dibujarse suavizados.
- **Ancho de banda**: unos 2,5–3 KB por instantánea comprimida con 140 enemigos en pantalla (unos 55 KB/s a 20 por segundo).
