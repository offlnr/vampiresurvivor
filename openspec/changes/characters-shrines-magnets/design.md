# Design

## Context

- **Arma inicial**: `run.gd` daba siempre `STARTING_WEAPON` (el orbe).
- **Estadísticas**: solo cambiaban con los pergaminos (`_apply_scroll()`), con un límite de 4 por partida.
- **Estructuras del mapa**: ya existían los calderos (`Cauldrons`): aparecen alrededor del jugador, se activan quedándose encima y se recolocan si quedan lejos.

## Decisions

### Personajes como recursos
`CharacterData` guarda:
- `frames`: un `SpriteFrames` con `idle` y `walk`;
- `starting_weapon`;
- la ventaja como pares `bonus_stats` / `bonus_values`, en las mismas unidades que un pergamino (`UpgradeData.Stat`);
- `bonus_text`, el texto que se muestra.

Así la ventaja se aplica con el mismo código que los pergaminos (`_apply_stat()`), y añadir un personaje es añadir un `.tres` a `Characters.ALL`.

`Player.set_frames()` cambia el aspecto y lo escala a `VISUAL_HEIGHT`, como ya hacía `_ready()` con la bruja.

### Arma inicial bloqueada
El arma inicial se añade a la reserva del asiento (`weapon_pool`) aunque no esté desbloqueada. Si no, el Fantasmita llevaría el rayo espectral pero nunca le saldrían mejoras para él.

### Elección guardada en `Progress`
`Progress.character` se guarda en `progress.cfg`, igual que el resto del progreso:
- la pantalla de selección empieza en el último personaje elegido;
- `run.gd` lo lee al empezar.

En cooperativo, el invitado envía su id con `MSG_CHARACTER` al unirse y cada vez que lo cambia en la sala. El anfitrión lo guarda en `Net.guest_character` y lo usa al crear el asiento del invitado.

### Santuarios: el mismo menú de subida de nivel
La carga del santuario abre el menú de subida de nivel de quien lo cargó, con el título "Santuario de poder". Así funcionan igual en solitario y en el menú remoto del invitado (`MSG_MENU`), con tiradas, saltos, estadísticas y la pausa hasta que todos cierran.

Para eso, las elecciones pendientes del asiento pasan de ser rarezas sueltas a diccionarios `{kind, rarity}`:
- `level`: subida de nivel;
- `chest`: cofre de élite;
- `shrine`: santuario.

`build_offers()` y `replacement_offer()` reciben el tipo y sacan las ofertas del santuario de `_shrine_candidates()`.

**Ofertas**:
- una por pergamino, menos multiplicidad, maldito, caos y plata;
- el valor es el de un pergamino de esa rareza (`roll_amount()`), y la rareza se tira con la suerte del jugador;
- el título es la estadística sin "Pergamino de…".

No llevan clave de destierro (`key`), así que no se pueden desterrar. Para no repetir cartas al volver a tirar se distinguen por `id`.

### Una sola clase para santuarios e imanes
`Shrines` lleva los dos tipos con una tabla `SPECS` (textura, cuántos, reaparición, tiempo de carga, alcance y color).
- **Lo que comparte con los calderos**: aparecer alrededor de un jugador vivo, separados entre sí y fuera de los objetos sólidos, y recolocarse si se quedan muy lejos.
- **A diferencia de los calderos**, un santuario usado no se repone enseguida: vuelve tras un tiempo (`respawn`). Así las mejoras gratuitas tienen un ritmo.

**Activación**: la carga sube mientras algún jugador vivo está dentro del círculo, y la recibe el más cercano.

### El círculo en el suelo
- **Dibujo**: el círculo es un hijo `Zone` con `z_index = -1`, para que quede debajo de los personajes que están encima.
- **Red**: se dibuja con `draw_ops()`, así que llega al invitado igual que el anillo de los calderos.

### Valores
- **Santuario**: 4 s de carga; 2 a la vez; vuelve a los 50 s.
- **Imán**: 1 s de carga; 1 a la vez; vuelve a los 70 s.
- **Ventajas de los personajes**: entre un pergamino común y uno raro, para que se noten sin decidir la partida.

## Risks / Trade-offs

- **Escalado sin límite**: los santuarios no ocupan huecos, así que en partidas largas las estadísticas siguen subiendo. Se compensa con la reaparición lenta; si sobra, se puede alargar `respawn` o la carga.
- **Arte**: los personajes nuevos son dibujos SVG provisionales, generados con el mismo estilo que el resto (contorno oscuro y colores de la paleta).
