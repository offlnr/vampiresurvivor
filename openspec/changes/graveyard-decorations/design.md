# Design

## Context

- El suelo (`Ground`) es un `Sprite2D` con la textura repetida que sigue a la cámara a saltos de mosaico. Su SVG tenía los objetos dibujados, así que se repetían cada 512 px.
- `World/Actors` tiene `y_sort_enabled`, igual que `Enemies`, `Merchants`, `MapChests` y `Cauldrons`. En Godot 4, los nodos con y-sort anidados se ordenan juntos, así que cualquier sprite con origen en su base se ordena bien con el jugador y los enemigos.
- Los enemigos no usan físicas: `EnemyManager._move()` los mueve a mano. El jugador es un `CharacterBody2D`, pero no hay nada físico contra lo que chocar.

## Goals / Non-Goals

**Goals:**
- Un mapa con variedad, que no se repita, que sea igual al volver a un sitio y distinto en cada partida.
- Estructuras sólidas sin físicas y baratas con 400 enemigos.
- Que ningún objeto necesario quede inalcanzable.

**Non-Goals:**
- Pathfinding: basta con que los enemigos se deslicen alrededor.
- Que los proyectiles choquen con las estructuras.

## Decisions

### 1. Zonas deterministas
`Decorations` divide el mundo en zonas de 800 unidades.
- **Datos:** `_chunk_data(zona)` es una función pura de `hash([world_seed, x, y])`, que devuelve las estructuras sólidas y los detalles de esa zona. Se cachea, y lo que queda a más de 6 zonas se olvida, porque se puede regenerar.
- **Nodos:** solo tienen nodos las zonas a 2 o menos de la del jugador (5 × 5, mucho más que la pantalla). Se crean al cambiar de zona y se liberan a más de 3.
- **Semilla:** `world_seed = randi()` en cada partida.

Consultar las colisiones solo necesita los datos, así que funciona también fuera de las zonas con nodos. Por eso los calderos pueden comprobar un sitio a 1700 unidades.

### 2. Contenido de una zona
- **Estructuras:** 0, 1 o 2 (20 / 45 / 35 %), elegidas por peso. Árbol, lápida grande, obelisco, columna y farola salen más; el mausoleo y las calabazas, menos. Se colocan dentro de la zona con un margen de 110, para no pisar estructuras de zonas vecinas, separadas entre sí y fuera de un radio de 380 alrededor del inicio.
- **Pequeño cementerio:** con un 35 % de probabilidad, 2–3 filas de 3–5 lápidas o cruces, con huecos al azar.
- **Detalles:** 8–14 sueltos, elegidos por peso; la hierba alta es el más común.
- Ni los cementerios ni los detalles se colocan encima de una estructura.

### 3. Huella elíptica
Cada estructura tiene una huella elíptica en su base (`rx`, `ry`, centrada `up` unidades por encima de la base), ajustada a lo que se ve como suelo ocupado. Por ejemplo, el mausoleo tiene rx 104 y ry 34, y el árbol solo el tronco, rx 14 y ry 9.

`push_out(pos, radio)` estira el eje vertical por `rx/ry` para tratar la elipse como un círculo, y saca el punto por la normal. Revisa las estructuras de la zona del punto y de sus 8 vecinas (1–2 por zona).
- **Alternativa**: `StaticBody2D` y físicas. Descartada, porque los enemigos no usan físicas y 400 cuerpos más saldrían caros.

### 4. Quién choca
- El jugador, después de `move_and_slide()`.
- Los enemigos que caminan, después de moverse en `_move()`, con el 80 % de su radio para que no se queden enganchados en las esquinas.
- No chocan los que tienen `EnemyData.flying`: murciélago y fantasma.
- No chocan los murciélagos en línea recta del enjambre.

La separación entre enemigos rompe la simetría, así que los que quedan justo detrás de una estructura acaban rodeándola sin pathfinding. Se midió con una prueba: 10 zombis justo detrás, en línea con el jugador, llegan todos en menos de 12 s, también con el mausoleo.

### 5. Objetos fuera de las estructuras
- `MapChests`, `MerchantDirector` y `Cauldrons` prueban hasta 12 sitios hasta encontrar uno libre (`is_free`); los calderos, además, deben estar separados entre sí.
- `PickupManager` pasa por `push_out` la posición de los cofres de élite y los power-ups, que puede soltar un murciélago o un fantasma muerto sobre un mausoleo.
- Las almas y las monedas no hace falta moverlas: el radio de recogida (110) alcanza el centro de cualquier estructura desde su borde.

### 6. Aspecto
- **Sprites:** el origen de cada sprite está en la base (`offset.y = −alto/2`), con una sombra elíptica detrás en las estructuras.
- **Luces:** la farola y las velas tienen un halo dorado (`puff.svg`) que parpadea levemente desde `_process`.
- **Detalles:** se tiñen con `SMALL_TINT` para que no destaquen sobre enemigos, almas y orbes. En la primera captura, las calaveras blancas llamaban más la atención que las almas.
- **Orden de profundidad:** los personajes se ordenan por su centro, pero sus pies quedan unos 30 px más abajo (el jugador a 32, los enemigos normales a 25–30). Por eso las estructuras, lápidas y cruces se ordenan `SORT_OFFSET` = 30 por encima de su base: se mueve el nodo y se compensa con el `offset` del sprite. Así, un personaje cuyos pies están por delante de la base se dibuja delante. Los detalles planos (hierba, huesos, calaveras, setas y velas) van con `z_index = −1`, siempre bajo los personajes. En la primera versión todo se ordenaba por la base y los detalles se dibujaban encima del personaje al pisarlos (lo vio el jugador).

## Risks / Trade-offs

- [Una estructura grande puede tapar enemigos que pasan por detrás] → Solo el mausoleo es tan alto, y sale poco (peso 1 de 15).
- [Un jugador puede usar las estructuras para frenar a los enemigos] → Los voladores las ignoran y los demás las rodean en pocos segundos; es una ventaja táctica pequeña e intencionada.

## Verificación hecha

Se usó Godot 4.7.2 con ventana, para las capturas, y en modo headless, para las pruebas.
- **Capturas** del mapa: suelo, árbol, cementerio, detalles, mausoleo, farola y calabazas, con el jugador y zombis.
- **`stuck_test`:** 10 zombis llegan rodeando el mausoleo, las calabazas, la lápida grande y el árbol.
- Después de 2,5 s persiguiendo, ningún enemigo que camina ni el jugador está dentro de una estructura.
- Siguen pasando las pruebas anteriores: destierro, dificultad por nivel y calderos.
