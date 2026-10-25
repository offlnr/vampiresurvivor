# Proposal

## Why

El jugador pidió tres cosas al estilo de *Megabonk*:
- **Selección de personaje**, cada uno con su arma inicial (por ejemplo, un fantasmita con el rayo). Hasta ahora siempre se jugaba con la bruja y su orbe.
- **Mejoras del propio personaje** (escudo, velocidad de movimiento, etc.) que no dependan de un pergamino. Ahora la única forma de subir una estadística es ocupar uno de los 4 huecos de pergamino. Eligió que funcionen como los santuarios de carga de Megabonk.
- **Estructuras como los imanes de Megabonk**, que atraen la experiencia.

## What Changes

- **6 personajes**, cada uno con su aspecto, su arma inicial y una pequeña ventaja pasiva:

  | Personaje | Arma inicial | Ventaja |
  |---|---|---|
  | Bruja | Orbe arcano | +10 % de experiencia |
  | Fantasmita | Rayo espectral | +15 % de evasión |
  | Esqueleto | Hueso | +10 % de armadura |
  | Calabazín | Calabaza | +25 % de vida máxima |
  | Vampiro | Murciélagos | +2 % de robo de vida |
  | Segador | Guadaña | +10 % de probabilidad de crítico |

  - Todos están disponibles desde el principio.
  - El arma inicial se puede mejorar en las subidas de nivel aunque todavía esté bloqueada (el rayo espectral lo está).
  - El juego recuerda el último personaje elegido.
- **Pantalla "Elige personaje"**: aparece al pulsar "Jugar". Cada tarjeta muestra el personaje animado, su arma, su ventaja y una frase.
- **Cooperativo online**: en la pantalla de sala hay un botón "Personaje: …" para que cada jugador elija el suyo. El invitado envía su elección al anfitrión. Si los dos eligen el mismo, el del invitado se ve azulado, como antes.
- **Santuarios de poder** (como los santuarios de carga de Megabonk):
  - hay 2 por el mapa, con un círculo dorado en el suelo;
  - quedarse 4 s dentro lo carga (el anillo se llena, y se vacía poco a poco si sales);
  - al cargarse, quien lo cargó elige 1 de 3 mejoras de estadística con rareza (vida, velocidad, escudo, armadura, daño…). Cada una da lo mismo que un pergamino de esa rareza, pero sube la estadística directamente y no ocupa hueco de pergamino;
  - se pueden volver a tirar y saltar, pero no desterrar;
  - no dependen de los desbloqueos;
  - cada santuario usado vuelve a aparecer en otro sitio a los 50 s.
- **Tótems imán** (como los imanes de Megabonk):
  - hay 1 por el mapa, con un círculo rojo;
  - quedarse 1 s encima atrae todas las almas y monedas del mapa;
  - vuelve a aparecer en otro sitio a los 70 s.
- **Minimapa**: santuarios en dorado e imanes en rojo.
- **Panel de depuración**: botones "Santuario" e "Imán".

**Fuera de alcance:**
- desbloquear personajes con plata;
- mejoras permanentes del personaje entre partidas;
- otros santuarios de Megabonk (desafío, jefe).

## Capabilities

### New Capabilities
- `characters`: personajes, su arma inicial, su ventaja y la pantalla de selección.
- `map-shrines`: santuarios de poder y tótems imán.

### Modified Capabilities
- `run-session`: "Menú principal" ("Jugar" abre la selección de personaje).
- `online-coop`: "Salas con código" (cada jugador elige personaje en la sala).
- `minimap`: "Puntos de interés" (santuarios e imanes).

## Impact

- **Nuevo**:
  - `scripts/data/character_data.gd` (`CharacterData`) y `scripts/data/characters.gd` (`Characters`);
  - `data/characters/*.tres`;
  - `scenes/ui/character_select.gd` (`CharacterSelect`);
  - `scenes/pickups/shrines.gd` (`Shrines`);
  - arte: `art/placeholder/characters/<personaje>/` (2 fotogramas quieto y 4 andando, más `frames.tres`), `shrine.svg` y `magnet_totem.svg`.
- **Código modificado**:
  - `run.gd`: `_start_character()`, `_apply_stat()` (sale de `_apply_scroll()`), ofertas del santuario (`_shrine_candidates()`, tipo `&"stat"`), elecciones pendientes con tipo (`level`, `chest`, `shrine`), imán, depuración. Se quita `STARTING_WEAPON`;
  - `seat.gd`: `character`; `pending_choices` pasa a ser `Array[Dictionary]`;
  - `player.gd`: `set_frames()`;
  - `progress.gd`: `character` guardado;
  - `net.gd`: `MSG_CHARACTER` y `guest_character`;
  - `main_menu.gd`, `multiplayer_menu.gd`, `minimap.gd`, `debug_overlay.gd`;
  - `run.tscn`: nodo `World/Actors/Shrines`.
- **Red**: los santuarios, los imanes y los personajes nuevos llegan al invitado con la réplica genérica (sprites y `draw_ops()`), sin código de red propio.
