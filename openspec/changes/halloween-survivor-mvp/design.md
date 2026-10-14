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
Mantener la configuración de escalado actual y fijar el viewport base en 1280×720. El zoom de la cámara se calcula para enseñar siempre un área mínima de mundo, sea cual sea la relación de aspecto (vertical u horizontal).
- **Por qué**: el estilo de arte no está decidido y `canvas_items` sirve tanto para arte vectorial como para sprites en alta resolución.
- **Alternativa**: modo `viewport` en baja resolución para pixel art. Se aplaza (ver Open Questions); el cambio afecta solo a los ajustes del proyecto y a la cámara, no al gameplay.

### 3. Basado en datos con `Resource` propios
Clases de recurso con tipos: `WeaponData`, `EnemyData`, `UpgradeData` y `WaveTable` (una lista de `WaveEntry`: rango de tiempo, tipos de enemigo con pesos, ritmo de aparición y máximo de vivos). Los valores de balance viven en archivos `.tres` dentro de `res://data/`.
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
La escena de partida (`run.tscn`) tiene un `RunManager` que guarda el temporizador, el nivel y la XP del jugador y el contador de muertes, y coordina spawner → enemigos → recogibles → subida de nivel. El estado global se reduce a dos autoloads: `Events` (señales) y `Settings`.

### 5. Enemigos: movimiento ligero con separación, sin `move_and_slide` entre ellos
Cada enemigo es una escena con un `CharacterBody2D` que colisiona **solo** con el jugador (capas de física: jugador=1, enemigos=2, ataques del jugador=3, recogibles=4). Los enemigos no chocan físicamente entre sí. En su lugar, cada uno aplica una fuerza suave de repulsión contra sus vecinos, que busca en una rejilla espacial (un diccionario de celdas) que el spawner reconstruye una vez por frame.
- **Por qué**: las colisiones físicas entre 200 o más cuerpos son el mayor gasto de CPU en este género, y en el navegador es peor porque va en un solo hilo. La rejilla con repulsión suave cuesta O(n) en la práctica y da el aspecto natural de enjambre.
- **Alternativas**: (a) colisión física entre enemigos. Descartada por rendimiento. (b) Usar `PhysicsServer2D`/`RenderingServer` sin nodos, como en los "bullet hell". Descartada para el MVP porque es mucho más compleja; queda como plan B si no se llega al rendimiento objetivo (ver Risks).

### 6. Pools de objetos
Los enemigos, proyectiles, almas y números de daño se reutilizan desde pools en lugar de crearlos y destruirlos cada vez. Un objeto del pool que no está en uso se oculta y queda con `process_mode = DISABLED`.
- **Por qué**: evita los picos de `instantiate()`/`queue_free()` y las pausas del recolector de basura en web y en móvil.
- **Extra**: a partir de unas 300 almas en el suelo, cada alma nueva se suma a la más cercana (su valor se acumula), como hace Vampire Survivors con sus gemas.

### 7. Armas como hijos del jugador, una escena por patrón
Un `WeaponSlot` guarda el `WeaponData` y su nivel actual, e instancia la escena de su patrón (`ProjectileWeapon`, `OrbitWeapon` o `AuraWeapon`). Cada `WeaponData` tiene un array de estadísticas por nivel, con 5 entradas. Las recargas son temporizadores que respetan `get_tree().paused`. El MVP tiene 3 armas: **Calabaza** (proyectil al enemigo más cercano, arma inicial), **Murciélagos** (orbital) y **Niebla** (aura). Para encontrar el enemigo más cercano se reutiliza la rejilla espacial de la Decisión 5.

### 8. Pausa con `SceneTree.paused` y `process_mode`
El gameplay usa `PROCESS_MODE_PAUSABLE`. Las interfaces de pausa, subida de nivel y fin de partida usan `PROCESS_MODE_WHEN_PAUSED` o `ALWAYS`. La pausa automática escucha `NOTIFICATION_APPLICATION_FOCUS_OUT` y `NOTIFICATION_APPLICATION_PAUSED` (Android). Las subidas de nivel pendientes (varias seguidas) se encolan en el `RunManager` y se muestran una tras otra.

### 9. Entrada unificada
Acciones del `InputMap`: `move_left/right/up/down` (WASD, flechas y stick izquierdo) y `pause` (Esc, P y Start). El movimiento se lee con `Input.get_vector()`. El joystick virtual es un `Control` propio que aparece donde se toca la pantalla e inyecta su dirección en esas mismas acciones `move_*` (con `Input.action_press` e intensidad). Los controles táctiles se muestran cuando la última entrada fue un toque y se ocultan con entrada de teclado o mando. Así también funciona en portátiles con pantalla táctil.

### 10. Fondo infinito
Un `Parallax2D` con `repeat_size` y una textura que se repite (un cementerio o un campo de noche), que sigue a la cámara.
- **Alternativa**: un `TileMapLayer` generado por trozos. Descartada para el MVP: solo tiene sentido cuando haya obstáculos o decoración en el mapa.

### 11. Lo visual separado de la colisión
En cada entidad, el nodo de colisión (`CollisionShape2D`, con el radio definido en su `EnemyData`/`WeaponData`) es independiente del nodo visual (`Sprite2D` o `AnimatedSprite2D`, cuyo `scale` se ajusta a un tamaño de referencia). Cambiar una textura nunca toca la colisión. Así se cumple el requisito de assets reemplazables.

### 12. Assets provisionales
- **Sprites**: SVG sencillos hechos para el proyecto (siluetas de murciélago, zombi, fantasma, calabaza, alma y jugador) con la paleta de Halloween. Godot importa SVG directamente, así que se pueden iterar rápido.
- **Efectos de sonido**: generados con sfxr/jsfxr (el resultado es nuestro, sin problemas de licencia).
- **Música**: una pista CC0 (por ejemplo de OpenGameArt), registrada en `CREDITS.md`.
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

## Risks / Trade-offs

- [No se llega a 200 enemigos en navegadores móviles] → Medir con `stress_test.tscn` desde el primer sprint. Palancas, por orden: bajar el máximo de enemigos vivos de cada `WaveTable`, simplificar la separación de cada frame y pasar los enemigos a `RenderingServer`/`MultiMeshInstance2D` sin nodos (Decisión 5, alternativa b).
- [La web sin hilos tiene peor audio] → Limitar las voces simultáneas. Si da problemas, ofrecer una segunda build con hilos para los hostings que admiten COOP/COEP.
- [El estilo de arte no está definido y el pixel art podría obligar después a cambiar la resolución o el filtrado] → Lo visual está separado del gameplay (Decisión 11) y los tamaños de juego están en unidades del mundo. Pasar a pixel art cambia el modo de escalado, el filtrado de texturas y la cámara, no la lógica.
- [Equilibrar la curva de dificultad sin datos] → Todos los valores están en archivos `.tres` y el debug overlay permite saltar a cualquier minuto. Hacer pruebas de juego en los minutos 1, 5 y 9.
- [Licencias de assets externos] → Solo CC0 o CC-BY, siempre anotados en `CREDITS.md`.
- [El proyecto no tiene control de versiones] → La primera tarea inicializa git con el `.gitignore` que ya existe.

## Migration Plan

No hay nada que migrar (el proyecto está vacío). El único cambio sobre la configuración existente es en `project.godot`: renderer, escena principal, acciones de entrada, resolución base y buses de audio. Para deshacerlo basta con revertir ese archivo.

## Open Questions

- **Estilo de arte definitivo** (pixel art, vectorial o dibujado a mano): se puede decidir después de probar el MVP; las Decisiones 2 y 11 lo dejan abierto.
- **Nombre del juego y del personaje**: se usan nombres provisionales hasta entonces.
- **Hosting web** (itch.io o GitHub Pages): no afecta a la build gracias a la Decisión 13.
- **Números exactos de balance** (vida y daño de los enemigos, curva de XP): se fijan valores iniciales y se ajustan en las pruebas de juego.
