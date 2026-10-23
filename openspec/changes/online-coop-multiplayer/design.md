# Design

## Context

- **Simulación**: los enemigos (hasta 400) se mueven con una rejilla espacial propia, no con física, y las armas son muy distintas entre sí (orbitales, proyectiles, auras, rayos, estelas, vórtices).
- **Una sola referencia al jugador**: casi todos los sistemas apuntan a un único `player`.
- **Plataformas**: el juego se publica como build web estática (GitHub Pages) y como app Android y de escritorio.

## Decisions

### WebSocket y un servidor de salas en lugar de WebRTC
- **WebRTC** sería P2P, pero en escritorio necesita la extensión `webrtc-native` y además exige igualmente un servidor de señalización.
- **`WebSocketPeer`** funciona igual en web, Android y escritorio.
- **El servidor** es mínimo: une por código y reenvía bytes, sin conocer el juego. Cabe en el plan gratuito de Render.
- **Coste**: todo el tráfico pasa por el servidor, lo que añade algo de latencia.

### Anfitrión con autoridad, no lockstep
- **Lockstep** (las dos máquinas simulan lo mismo enviando solo entradas) exigiría determinismo total. El juego usa `randf()` global y `delta` variable por todas partes, y una sola desincronización estropearía la partida.
- **Anfitrión con autoridad**: la partida corre en un solo sitio y el invitado es un cliente que solo dibuja.

### Réplica genérica del dibujo
En lugar de escribir código de red para cada sistema (enemigos, almas, cada arma, efectos…), `NetHost` recorre el árbol de `World` y serializa lo que se dibuja:
- `Sprite2D` y `AnimatedSprite2D`: textura, rectángulo como lo calcula Godot (con tamaños negativos para voltear), región, transformación relativa, color con `modulate` acumulado y si usa el shader de contorno;
- `Label`: texto, fuente, tamaño, colores y contorno;
- `Line2D`: puntos, grosor y color;
- nodos con `draw_ops()`: lista de primitivas `NetDraw` (círculo, arco, rectángulo). Los cinco `_draw()` del juego pasan a describirse así.

Cada **unidad** es un hijo de un grupo con y-sort (los grupos anidados se aplanan, como hace Godot) o un hijo directo de un contenedor sin y-sort. En el invitado, cada unidad es un nodo `Proxy` en el mismo contenedor, colocado en su posición, así que el orden de dibujo y el y-sort coinciden con el anfitrión. Cada índice z de la unidad es una capa hija.

**Recursos**: texturas y fuentes se identifican con un número. La primera vez se envía su ruta; las sub-recursos (`archivo.tres::id`) se buscan dentro de su archivo.

**Formato**: binario con `StreamPeerBuffer`:
- transformaciones en enteros de 16 bits (1/1024 para rotación y escala, 1/4 de píxel para la posición);
- colores en 8 bits (RGB hasta 2, para que se vean los destellos de golpe);
- compresión deflate.

**Recorte**: solo se envía lo que está cerca de la vista del invitado. El invitado informa del tamaño de su vista con cada entrada.

**Decoraciones**: no se envían. El invitado recibe la semilla del mapa y genera las mismas tumbas y árboles, que hacen y-sort con las unidades réplica.

### Interpolación
- **Ritmo**: las instantáneas llegan a 20 por segundo.
- **Movimiento**: cada proxy se desliza de su posición mostrada a la nueva durante el intervalo, y la cámara del invitado hace lo mismo.
- **Saltos grandes** (un nodo reciclado del pool) se aplican directamente.

### Un `Seat` por jugador
Todo lo que en solitario era de la partida pero en realidad es del jugador pasa a `Seat`:
- personaje, inventario y armas;
- pergaminos, oro, tiradas, destierros, saltos y anuncios de tirada;
- objetos desterrados, caos y lo que tiene desbloqueado;
- elecciones pendientes, y el menú que tiene abierto con sus cartas o artículos.

Cómo lo usa `run.gd`:
- cada función que antes usaba "el jugador" recibe el asiento;
- las propiedades antiguas (`weapons`, `gold`, `scroll_levels`…) siguen existiendo como atajos al asiento local, para el panel de depuración y las pruebas;
- la partida en solitario es simplemente un asiento.

### Menús del invitado
El asiento del invitado es remoto:
- **Abrir**: en lugar de abrir `level_up_menu` o `shop_menu`, el anfitrión envía `MSG_MENU` con lo que el menú necesita para dibujarse: textos, rareza, ruta del icono, rutas de los objetos, precios, contadores y estadísticas.
- **Responder**: el invitado abre sus menús reales y devuelve cada acción (`MSG_ACTION`: elegir, tirar, desterrar, saltar, comprar, salir). El anfitrión la aplica a ese asiento, la valida (menú abierto, índice, oro) y responde con la carta o la tienda actualizada.
- **Doble clic**: el invitado cierra su menú en cuanto elige, para que un segundo clic no caiga en el siguiente menú.

**Pausa**: la partida se para cuando cualquiera abre un menú y sigue cuando no queda ninguno abierto (`_update_pause()`).

**Desbloqueos**: el invitado envía sus claves de desbloqueo al unirse (`MSG_UNLOCKS`), y su asiento se crea con ellas.

### Daño atribuido
`EnemyManager.damage()` recibe quién golpea (`attacker`), y todas las armas, los objetos y las espinas lo pasan. Así se aplican los objetos, críticos, robo de vida y empuje de ese jugador, y su inventario recibe los golpes y las muertes.

### Reglas del cooperativo
- **Enemigos**: `nearest_player()` para perseguir, `spawn_anchor()` para aparecer junto a cualquiera, `coop_health` = 1,8 y `coop_count` = 1,35.
- **Experiencia por nivel**: × 1,5 (`COOP_XP_NEEDED`). Con dos jugadores recogiendo almas se sube más rápido, y así se compensa.
- **Almas, monedas, cofres y power-ups**: los recoge el jugador vivo más cercano. La experiencia es común, multiplicada por el bonus de quien la recoge; el oro y los cofres son de quien los recoge.
- **Comerciante**: atiende una vez a cada jugador (cada uno ve las mismas ofertas, filtradas por sus destierros y desbloqueos) y se va cuando han comprado todos los que siguen en pie.
- **Cofres de pago**: el precio es común y sube con cada cofre que abre cualquiera, así que la etiqueta del precio vale para los dos.
- **Caídas**: revivir en la subida de nivel con media vida y 3 s de invulnerabilidad; fin cuando caen los dos.
- **Anuncios**: el anuncio de revivir solo se ofrece en solitario.
- **Desconexión del invitado**: su personaje no se borra, porque sus proyectiles pueden seguir en vuelo; se oculta, se desactiva y sale de la lista de jugadores.

## Risks / Trade-offs

- **Latencia**: el invitado ve su personaje con el retraso de ida y vuelta más unos 50 ms de interpolación. Si molesta, el siguiente paso es predecir su movimiento en local.
- **Rendimiento**: el anfitrión recorre el árbol de nodos 20 veces por segundo. Con 140 enemigos va sobrado; con 400 conviene medirlo en móvil.
- **Plan gratuito de Render**: se duerme. La conexión espera hasta 60 s y la pantalla de sala lo avisa.
