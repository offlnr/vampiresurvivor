# Design

## Context

- El proyecto es un **Godot 4.7** recién creado: no tiene escenas, scripts ni assets, y no es un repositorio git.
- `project.godot` usa el renderer **Mobile** (`renderer/rendering_method="mobile"`), con `stretch/mode="canvas_items"` y `aspect="expand"`. No hay escena principal ni acciones de entrada.
- Plataformas objetivo: web (navegador de escritorio y de móvil) y Android (ver `specs/platform-builds`). Esto, junto con el objetivo de 200 enemigos en pantalla, condiciona casi todas las decisiones de este documento.
- Todavía no hay dirección de arte (ver proposal.md, Why). Todo lo visual es provisional.

## Goals / Non-Goals

**Goals:**
- Una arquitectura basada en datos: añadir un arma, un enemigo, una mejora o una oleada consiste en crear un `Resource` (`.tres`), no en escribir código.
- Separar por completo lo visual de la lógica de juego, para poder cambiar el arte más adelante sin tocar el gameplay.
- Tener margen de rendimiento en móvil y en navegador desde el principio, sin rehacer nada después.
- Un solo código y un solo sistema de entrada para teclado, mando y pantalla táctil.

**Non-Goals:**
- Guardar datos más allá del volumen (no hay sistema de guardado ni meta-progresión).
- Una suite de tests automáticos con plugins de terceros. La verificación se hace con una escena de depuración y con checklists de prueba manual.
- Shaders o efectos visuales que solo funcionen en Forward+.
- iOS: no se configura su exportación, aunque nada del diseño la impide.

## Decisions

### 1. Renderer Compatibility
Cambiar `renderer/rendering_method` a `gl_compatibility`, también en móvil.
- **Por qué**: en Godot 4 la exportación web funciona sobre WebGL 2, y solo el renderer Compatibility lo soporta. Usar el mismo renderer en todas las plataformas garantiza que lo que se ve en el editor es lo que se verá en web y en Android. Para un juego 2D, las funciones que se pierden no importan.
- **Alternativa**: mantener `mobile` en Android y usar `gl_compatibility` solo en web, con ajustes por plataforma. Descartada: duplica las pruebas visuales y no aporta nada en 2D.

### 2. 2D cenital, resolución base 1280×720, `canvas_items` + `expand`
Mantener la configuración de escalado actual y fijar el viewport base en 1280×720. En pantallas verticales `Settings` cambia la resolución base a 720×1280, para que la interfaz conserve su tamaño. El zoom de la cámara se calcula para enseñar siempre un área mínima de mundo (720 unidades en el lado corto), sea cual sea la relación de aspecto.
- **Por qué**: el estilo de arte no está decidido y `canvas_items` sirve tanto para arte vectorial como para sprites en alta resolución.
- **Alternativa**: modo `viewport` en baja resolución para pixel art. Se aplaza (ver Open Questions); el cambio afecta solo a los ajustes del proyecto y a la cámara, no al gameplay.

### 3. Basado en datos con `Resource` propios
Clases de recurso con tipos: `WeaponData`, `EnemyData`, `UpgradeData` y `WaveTable` (una lista de `WaveEntry`: rango de tiempo, tipos de enemigo con pesos, ritmo de aparición, máximo de vivos y multiplicadores de vida y de velocidad). Los valores de balance viven en archivos `.tres` dentro de `res://data/`.
- **Por qué**: permite equilibrar el juego y añadir contenido sin código, y editarlo cómodamente en el inspector de Godot.
- **Alternativa**: JSON o CSV. Descartada para el MVP: se pierde la comprobación de tipos y el selector de recursos del editor.

### 4. Estructura de carpetas
```
res://
  autoload/        # Events.gd (bus de señales global), Settings.gd (volumen, ConfigFile)
  data/            # weapons/, enemies/, upgrades/, waves/ (.tres)
  scenes/
    main/          # main_menu.tscn, run.tscn, game_over.tscn
    player/        # player.tscn
    enemies/       # enemy.tscn (una sola escena, configurada con EnemyData)
    weapons/       # una escena por patrón de ataque: proyectil, orbital, aura
    pickups/       # soul_gem.tscn
    ui/            # hud.tscn, level_up.tscn, pause.tscn, virtual_joystick.tscn
  scripts/         # clases de recurso y utilidades compartidas
  art/placeholder/ # sprites, sonidos y música (reemplazables)
  CREDITS.md
```
La escena de partida (`run.tscn`) tiene un `RunManager` que guarda el temporizador, el nivel y la XP del jugador y el contador de muertes, y coordina spawner → enemigos → recogibles → subida de nivel. El estado global se reduce a tres autoloads: `Events` (señales), `Settings` (volumen, modo de entrada y orientación) y `Audio` (voces de efectos con límite y música).

### 5. Enemigos: movimiento ligero con separación, sin `move_and_slide` entre ellos
Cada enemigo es un `Node2D` sin cuerpo físico. El `EnemyManager` los mueve a todos en un solo bucle y reconstruye una vez por frame una rejilla espacial (un diccionario de celdas). Esa rejilla sirve para todo: la repulsión suave entre vecinos, el daño por contacto al jugador, los impactos de las armas y la búsqueda del enemigo más cercano. Las capas de física (jugador=1, enemigos=2, ataques del jugador=3, recogibles=4) quedan definidas con nombre para cuando haga falta física real (obstáculos, por ejemplo).
- **Por qué**: las colisiones físicas entre 200 o más cuerpos son el mayor gasto de CPU en este género, y en el navegador es peor porque va en un solo hilo. La rejilla con repulsión suave cuesta O(n) en la práctica y da el aspecto natural de enjambre.
- **Alternativas**: (a) colisión física entre enemigos. Descartada por rendimiento. (b) Usar `PhysicsServer2D`/`RenderingServer` sin nodos, como en los "bullet hell". Descartada para el MVP porque es mucho más compleja; queda como plan B si no se llega al rendimiento objetivo (ver Risks).

### 6. Pools de objetos
Los enemigos, proyectiles, almas y números de daño se reutilizan desde pools en lugar de crearlos y destruirlos cada vez. Un objeto del pool que no está en uso se oculta y queda con `process_mode = DISABLED`.
- **Por qué**: evita los picos de `instantiate()`/`queue_free()` y las pausas del recolector de basura en web y en móvil.
- **Extra**: a partir de unas 300 almas en el suelo, cada alma nueva se suma a la más cercana (su valor se acumula), como hace Vampire Survivors con sus gemas.

### 7. Armas como hijos del jugador, una escena por patrón
Un `WeaponSlot` guarda el `WeaponData` y su nivel actual, e instancia la escena de su patrón (`ProjectileWeapon`, `OrbitWeapon` o `AuraWeapon`). Cada `WeaponData` tiene un array de estadísticas por nivel, con 5 entradas. Las recargas son temporizadores que respetan `get_tree().paused`. El MVP tiene 6 armas: **Calabaza** (proyectil al enemigo más cercano, arma inicial), **Murciélagos** (orbital), **Niebla** (aura), **Guadaña** (barrido en arco hacia el enemigo más cercano dentro de su alcance), **Hueso** (bumerán: sale hacia el enemigo más cercano, frena y vuelve al jugador) y **Fuego fatuo** (llamas que caen sobre enemigos al azar y dejan una zona de daño). Se llevan 3 como máximo. Las armas a distancia tienen `attack_range` en su `WeaponData`: solo eligen objetivos dentro de ese radio y sus proyectiles se liberan al recorrerlo. Todas leen el daño, área y recarga a través de `Weapon`, que aplica los multiplicadores del jugador y la bonificación de rareza del arma (Decisión 16). Para encontrar enemigos se reutiliza la rejilla espacial de la Decisión 5.

### 8. Pausa con `SceneTree.paused` y `process_mode`
El gameplay usa `PROCESS_MODE_PAUSABLE`. Las interfaces de pausa, subida de nivel y fin de partida usan `PROCESS_MODE_WHEN_PAUSED` o `ALWAYS`. La pausa automática escucha `NOTIFICATION_APPLICATION_FOCUS_OUT` y `NOTIFICATION_APPLICATION_PAUSED` (Android). Las subidas de nivel pendientes (varias seguidas) se encolan en el `RunManager` y se muestran una tras otra.

### 9. Entrada unificada
Acciones del `InputMap`: `move_left/right/up/down` (WASD, flechas y stick izquierdo) y `pause` (Esc, P y Start). El movimiento se lee con `Input.get_vector()`. El joystick virtual es un `Control` propio que aparece donde se toca la pantalla e inyecta su dirección en esas mismas acciones `move_*` (con `Input.action_press` e intensidad). Los controles táctiles se muestran cuando la última entrada fue un toque y se ocultan con entrada de teclado o mando. Así también funciona en portátiles con pantalla táctil.

### 10. Fondo infinito
Un `Sprite2D` con `region_enabled` y `texture_repeat` que cubre 4096×4096 unidades y sigue a la cámara a saltos del tamaño de la baldosa, así el dibujo queda fijo al mundo (`scenes/main/ground.gd`).
- **Alternativa probada**: `Parallax2D` con `repeat_size`. Descartada: en la prueba dejaba de repetir el suelo al alejarse del origen y aparecía una franja negra.
- **Alternativa**: un `TileMapLayer` generado por trozos. Descartada para el MVP: solo tiene sentido cuando haya obstáculos o decoración en el mapa.

### 11. Lo visual separado de la colisión
En cada entidad, el nodo de colisión (`CollisionShape2D`, con el radio definido en su `EnemyData`/`WeaponData`) es independiente del nodo visual (`Sprite2D` o `AnimatedSprite2D`, cuyo `scale` se ajusta a un tamaño de referencia). Cambiar una textura nunca toca la colisión. Así se cumple el requisito de assets reemplazables.

### 12. Assets provisionales
- **Sprites**: SVG sencillos hechos para el proyecto (siluetas de murciélago, zombi, fantasma, calabaza, alma y jugador) con la paleta de Halloween. Godot importa SVG directamente, así que se pueden iterar rápido.
- **Efectos de sonido y música**: sintetizados con un script propio en Python (ondas, ruido y envolventes, estilo sfxr). La música es un bucle de 19 s en la menor (Am–F–Dm–E) que se repite sin cortes. Todo es nuestro, sin problemas de licencia, y está registrado en `CREDITS.md`.
- **Datos de balance**: los `.tres` iniciales se generaron con un script de Godot que no forma parte del proyecto; a partir de ahora se editan en el inspector.
- **Alternativa**: packs de Kenney (CC0). Válida si queremos algo más pulido rápidamente; también se anotarían en `CREDITS.md`.

### 13. Exportación web sin hilos
Exportar la build web con `Thread Support` desactivado.
- **Por qué**: sin hilos la build no necesita las cabeceras `Cross-Origin-Opener-Policy`/`Cross-Origin-Embedder-Policy`, así que funciona en itch.io, GitHub Pages o cualquier hosting estático, y también en Safari de iOS.
- **Coste**: con mucha carga, el audio puede entrecortarse un poco. Se mitiga con un bus de audio sencillo y limitando los efectos simultáneos (un pool con un máximo de voces por efecto).

### 14. Guardar los ajustes
`Settings` (un autoload) guarda `music_volume` y `sfx_volume` en `user://settings.cfg` con `ConfigFile`, y los aplica a los buses `Music` y `SFX` al arrancar. En web, `user://` se guarda en IndexedDB.

### 15. Verificación
- Un **`debug_overlay`** (F3 o un toque con 4 dedos) que muestra FPS, enemigos vivos, objetos en los pools y oleada actual, con atajos para subir de nivel, generar 200 enemigos y saltar al minuto X.
- Una escena **`stress_test.tscn`** que mantiene 200 enemigos y muchos proyectiles vivos para medir los FPS en cada plataforma.
- Un checklist manual por spec (cada escenario es un punto a comprobar) que se recorre en web de PC, en web de Android y con el APK de Android.

### 16. Rareza de las mejoras y estadísticas del jugador
- Las estadísticas pasivas viven en `Player`: `damage_multiplier`, `area_multiplier`, `cooldown_multiplier`, `speed_multiplier`, `pickup_multiplier`, `luck`, `lifesteal`, `armor` y vida máxima. Cada `UpgradeData` define un efecto base por elección.
- La rareza es un enum (`Rarity`: común, poco común, rara, épica, legendaria) en un script compartido (`scripts/rarity.gd`) con su color, nombre, peso base (60/25/10/4/1) y multiplicador (1/1,5/2/3/4).
- Al construir las cartas se tira una rareza por carta. La suerte reparte peso desde la común hacia las demás: cada punto de suerte multiplica los pesos no comunes por `1 + suerte`. Un cofre fuerza la rareza mínima a rara.
- En armas se sigue el sistema de Megabonk (ver Decisión 21): la rareza decide cuántas estadísticas se mejoran (1 o 2) y las multiplica por 1/1,2/1,4/1,6/2.
- El robo de vida se acumula en un contador por segundo para respetar el tope de 3 de vida por segundo.
- **Alternativa**: rareza fija por mejora, como en algunos juegos del género. Descartada: el usuario pidió que la suerte influya en lo que sale.

### 17. Hordas periódicas y élites
Un `HordeDirector` dentro del `EnemyManager` lleva su propio reloj: desde el minuto 3 y cada 60 s muestra el aviso (señal hacia el HUD y sonido), y 3 s después genera la horda según el tipo del ciclo (anillo, enjambre, carga) y la escala por minuto. Los enemigos de horda llevan una marca para no contar en `max_alive` de la oleada, pero sí en el `HARD_CAP` global, que sube a 400. El enjambre usa enemigos con dirección fija y vida limitada que se liberan al salir de pantalla. El élite es un `Enemy` normal con multiplicadores de tamaño (×2), vida (×12) y daño (×2), un contorno dorado y una barra de vida dibujada por el propio enemigo. Al morir suelta un `Chest` (recogible en `PickupManager`) que abre la selección de mejoras con rareza mínima rara.

### 18. Animaciones por fotogramas generadas
Los sprites provisionales pasan a ser `SpriteFrames` con varios SVG por animación (jugador: reposo ×2 y caminar ×4; murciélago: aletear ×3; zombi: caminar ×4; fantasma: flotar ×3). Los SVG se generan con un script propio en Python, como el resto del arte provisional. Jugador y enemigos usan `AnimatedSprite2D`, y `EnemyData` pasa de una `texture` a unos `frames: SpriteFrames` (se mantiene `visual_height` para escalar). La aparición (zombi surge del suelo, fantasma se materializa, murciélago baja) y la muerte (aplastarse y desvanecerse con partículas) son tweens sobre el nodo visual. Para el contraste, todos los enemigos llevan un contorno claro en el propio SVG y el suelo se oscurece y desatura un poco.

### 19. Partida infinita y escalado sin fin
La partida ya no termina a los 10:00. `EnemyManager` calcula la dificultad a partir del último tramo de `WaveTable` más los minutos que lo superan: la vida crece un 35 % compuesto por minuto, el daño de contacto un 30 % por minuto, la velocidad un 3 % por minuto (hasta ×1,5), el intervalo de aparición baja un 6 % por minuto (hasta la mitad) y el máximo de vivos sube 25 por minuto, siempre dentro de `HARD_CAP`. Las hordas y los comerciantes siguen su ciclo sin fin. Cuando se agotan todas las mejoras, las cartas de respaldo son curar y oro. El récord de tiempo (y sus muertes) se guarda en `Settings`, en el mismo `settings.cfg`.
- **Alternativa**: seguir añadiendo filas a la tabla. Descartada: no hay forma de cubrir un tiempo infinito con datos fijos.

### 20. Comportamientos de enemigo
`EnemyData.behavior` (`CHASE`, `EXPLODER`, `RANGED`) y unos pocos campos de ataque (`attack_damage`, `attack_range`, `attack_cooldown`, `projectile_speed`) y `knockback_immune`. El `EnemyManager` resuelve cada comportamiento en su bucle de movimiento: la calabaza explosiva explota al llegar a `attack_range` del jugador; la bruja se acerca hasta su distancia de ataque, se para y lanza pociones, que son un pool de sprites del propio `EnemyManager` con colisión por distancia contra el jugador (se congelan con el reloj). Los cuatro enemigos nuevos usan el mismo `enemy.tscn` con sus `SpriteFrames`.

### 21. Mejoras de arma estilo Megabonk
`WeaponData` deja las tablas de 5 niveles y pasa a tener estadísticas base más una lista de mejoras posibles (`upgrade_stats` con su valor común en `upgrade_values`): daño (plano), proyectiles y atravesar (+N), y velocidad de ataque, tamaño, duración y velocidad de vuelo (porcentaje). Cada `Weapon` acumula sus bonificaciones y calcula sus estadísticas a partir de la base. Al ofrecer una mejora se tira la rareza, se eligen 1 (común) o 2 (resto) estadísticas al azar sin repetir y sin incluir las que ya tienen tope, y sus valores se multiplican por el factor de rareza; la carta guarda la tirada para aplicar exactamente lo que muestra. No hay nivel máximo, lo que encaja con la partida infinita. Las armas nuevas se ofrecen siempre como comunes.
- **Alternativa**: mantener niveles fijos con varias estadísticas por nivel. Descartada: el jugador la encontró confusa (demasiados cambios en una carta).

### 22. Pergaminos, sin topes y en porcentaje; volver a tirar y desterrar
- Las pasivas pasan a ser 10 pergaminos (`UpgradeData`, nuevo stat `XP`). El jugador puede tener 5 distintos; el resto de cartas de pergamino solo se ofrecen si ya lo tiene. Sin `max_level`.
- Todo multiplicativo o en porcentaje y sin topes: vida máxima en % de la base; armadura multiplica el daño recibido por (1 − x) en cada nivel, así nunca llega al 100 %; la velocidad de ataque es una suma (`Player.attack_speed_bonus`, objetos y furia) que divide la recarga, así nunca llega a 0; robo de vida sin límite por segundo; el daño de arma sube en % de su base.
- Volver a tirar y desterrar: `Run` lleva los contadores (5 y 5) y un conjunto de claves desterradas (`weapon:<id>`, `scroll:<id>`, `item:<id>`). Cada carta guarda cómo regenerarse: el menú pide al `Run` una oferta de sustitución que no repita las otras cartas visibles ni lo desterrado.
- **Alternativa**: volver a tirar las 3 cartas a la vez, como en Megabonk. Descartada: el usuario pidió cambiar una carta concreta.

### 23. Interfaz pixel art
Fuente Pixelify Sans (OFL, `art/fonts/`) como fuente por defecto del tema, con antialiasing desactivado para que se vea nítida. El tema pasa a esquinas rectas (radio 0–2), bordes de 3 px y una sombra desplazada en bloque (`shadow_offset`), con un borde interior más claro en paneles. Las cartas se reconstruyen en un componente común: fila horizontal compacta (icono 56 px, etiqueta de rareza, nombre, descripción) con los botones de volver a tirar y desterrar a la derecha, apiladas en vertical en cualquier orientación.

### 24. Enemigos cada vez más rápidos y fuertes
Además del escalado tras el minuto 10, la velocidad crece un 2 % y el daño un 5 % por minuto desde el inicio, sin tope (`EnemyManager.speed_multiplier()` y `damage_multiplier()`).

## Risks / Trade-offs

- [No se llega a 200 enemigos en navegadores móviles] → Medir con `stress_test.tscn` desde el primer sprint. Palancas, por orden: bajar el máximo de enemigos vivos de cada `WaveTable`, simplificar la separación de cada frame y pasar los enemigos a `RenderingServer`/`MultiMeshInstance2D` sin nodos (Decisión 5, alternativa b).
- [La web sin hilos tiene peor audio] → Limitar las voces simultáneas. Si da problemas, ofrecer una segunda build con hilos para los hostings que admiten COOP/COEP.
- [El estilo de arte no está definido y el pixel art podría obligar después a cambiar la resolución o el filtrado] → Lo visual está separado del gameplay (Decisión 11) y los tamaños de juego están en unidades del mundo. Pasar a pixel art cambia el modo de escalado, el filtrado de texturas y la cámara, no la lógica.
- [Equilibrar la curva de dificultad sin datos] → Todos los valores están en archivos `.tres` y el debug overlay permite saltar a cualquier minuto. Hacer pruebas de juego en los minutos 1, 5 y 9. Además, un bot de prueba sin ventana recorre partidas completas y comprueba que el nivel al minuto 10 cae entre 15 y 25.
- [Las hordas más los élites superan el rendimiento objetivo] → Las hordas tienen tamaño máximo y respetan el `HARD_CAP` global; si hace falta, se reduce el tamaño de horda por minuto en los datos.
- [Licencias de assets externos] → Solo CC0 o CC-BY, siempre anotados en `CREDITS.md`.
- [El proyecto no tiene control de versiones] → La primera tarea inicializa git con el `.gitignore` que ya existe.

## Migration Plan

No hay nada que migrar (el proyecto está vacío). El único cambio sobre la configuración existente es en `project.godot`: renderer, escena principal, acciones de entrada, resolución base y buses de audio. Para deshacerlo basta con revertir ese archivo.

## Open Questions

- **Estilo de arte definitivo** (pixel art, vectorial o dibujado a mano): se puede decidir después de probar el MVP; las Decisiones 2 y 11 lo dejan abierto.
- **Nombre del juego y del personaje**: se usan nombres provisionales hasta entonces.
- **Hosting web** (itch.io o GitHub Pages): no afecta a la build gracias a la Decisión 13.
- **Números exactos de balance** (vida y daño de los enemigos, curva de XP): se fijan valores iniciales y se ajustan en las pruebas de juego.
