# Design

## Context

- `EnemyManager.health_multiplier()` y `damage_multiplier()` dependían del tiempo: la vida venía de la tabla de oleadas y el daño crecía por minuto. Ambos se leen al crear cada enemigo; los que ya están vivos no cambian.
- `MapChests` ya resuelve objetos fijos alrededor del jugador: aparecen a cierta distancia, se recolocan si quedan muy lejos y el minimapa los lee con `positions()`.
- El destierro guarda claves (`weapon:<id>`, `scroll:<id>`, `item:<id>`) en `run.banished`. Las cartas de nivel ya lo respetaban. Una prueba con Godot 4.7.2 en modo headless lo confirmó: 40 subidas de nivel con destierros y tiradas, y nada desterrado volvió a salir. Los huecos estaban en los objetos (tienda, comerciante y cofres).

## Goals / Non-Goals

**Goals:**
- Que la fuerza de los enemigos siga a la del jugador.
- Un riesgo y recompensa opcional, visible en el mapa y en el minimapa, que no se active por accidente.
- Que nada desterrado vuelva a salir en ningún sitio durante la partida.

**Non-Goals:**
- Que el nivel cambie qué enemigos salen o a qué ritmo.
- Guardar la dificultad entre partidas.

## Decisions

> **Sustituido en parte por `megabonk-progression`:** la vida y el daño de los enemigos vuelven a depender del tiempo, como en Megabonk (Decisión 1 y escenarios "Más fuertes al subir de nivel" y "El tiempo solo no los hace más fuertes"). Los calderos, su efecto sobre la dificultad y el destierro siguen vigentes.

### 1. Vida y daño por nivel
- `health = 1,055^(nivel − 1) × escalado infinito × dificultad`.
- `damage = (1 + 0,025 × (nivel − 1)) × escalado infinito × dificultad`.
- `run.gd` pasa el nivel a `EnemyManager.player_level` cada vez que sube.

La curva de vida se eligió para parecerse a la tabla por tiempo anterior en partidas normales: ×2,2 en el minuto 3 y ×5,8 en el minuto 9, frente a ×2,8 a nivel 20 y ×6,2 a nivel 35. A nivel 1 el multiplicador es 1, así que el zombi (22) sigue muriendo con 2 orbes de 11.
- **Alternativa**: sumar nivel y tiempo. Descartada por el jugador; solo la velocidad y el escalado infinito siguen yendo por tiempo.
- La tabla de oleadas pierde `health_multiplier`, para que no quede un dato que ya no se usa.

### 2. Dificultad de los calderos
`EnemyManager.difficulty = 1 + 0,05 × calderos usados` (suma, no se compone). Multiplica la vida, el daño y `max_alive()` (tope `HARD_CAP`). Las recompensas son aditivas: `Player.xp_multiplier += 0,1` y un `Player.gold_bonus` nuevo `+= 0,1`, que entra en `gold_multiplier()` junto al de los objetos.

### 3. `Cauldrons`
Sigue el patrón de `MapChests`:
- 6 calderos desde el primer frame, a 600–1700 unidades del jugador (fuera de la pantalla inicial) y a 450 o más entre sí: `_random_spot()` prueba hasta 12 puntos y se queda con el primero que cumple la separación;
- se recolocan si quedan a más de 2600;
- `positions()` para el minimapa.

Cada caldero es una clase interna (`Cauldron`, un `Node2D`) con el sprite, un halo verde y un anillo de progreso dibujado en `_draw()`. Estar a menos de 46 unidades llena el progreso en 1,5 s, y al alejarse se vacía al mismo ritmo. Al completarse emite `brewed`, se encoge y desaparece, y en el siguiente frame aparece otro.
- **Alternativa**: activarlo al tocarlo. Descartada, porque en plena horda es fácil pisar uno sin querer.

### 4. HUD
`HUD.set_difficulty()` crea, la primera vez, un icono de caldero y una etiqueta "+N %" en la fila de oro y muertes, y la oculta mientras sea 0. `show_cauldron()` usa el aviso grande ya existente.

### 5. Destierro en objetos
- `_random_item(rareza)` busca en la rareza pedida, luego en las inferiores y por último en las superiores. Con 17 objetos y 5 destierros siempre hay alguno, así que un cofre nunca sale vacío.
- `_on_shop_banish`: si no hay sustituto, la carta desaparece en vez de quedarse.
- `_on_shop_requested`: antes de abrir, sustituye o quita los objetos del comerciante que se desterraron después de que llegara.
- `ShopMenu.open` en modo cofre muestra "Salir" si la lista está vacía y no intenta enfocar una carta que no existe. Es solo una protección.
- **Alternativa**: no ofrecer desterrar si no hay sustituto. Descartada, porque el jugador espera que desterrar siempre funcione.

## Risks / Trade-offs

- [Subir de nivel rápido ahora castiga: el pergamino de experiencia y los calderos aceleran la dificultad] → Es la intención (como en Megabonk); vigilar que el pergamino de experiencia no pase a ser una mala elección.
- [Una tienda común puede acabar mostrando un objeto de rareza superior tras desterrar] → Su precio es el de su rareza, así que no se puede abusar.

## Verificación hecha

Se usó Godot 4.7.2 oficial en modo headless con dos scripts de prueba que juegan la partida real:
- `banish_test`: 40 subidas de nivel con destierros y tiradas;
- `features_test`: dificultad por nivel, un caldero activado poniendo al jugador encima, la tienda común sin sustitutos, el comerciante anterior a un destierro, y cofres con todos los comunes desterrados.

Todo pasa. Faltan comprobaciones visuales y de equilibrio jugando.
