# Design

## Context

- **Enemigos**: los mueve `EnemyManager` con un pool, sin física.
- **Élites**: ya existían (`is_elite`), con contorno dorado, barra sobre la cabeza y cofre al morir.
- **Hordas**: siguen un calendario propio con aviso previo, igual que tendrán los jefes.

## Decisions

### Un jefe es un élite especial
`Enemy.is_boss` implica `is_elite`. Así el jefe hereda lo que ya hacen los élites:
- contorno dorado y marca roja en el minimapa;
- aparta a los enemigos pequeños.

Lo que cambia:
- **Tamaño**: `BOSS_SCALE` (×2,6) en lugar de ×2.
- **Vida**: la de sus datos, sin el ×12 de los élites.
- **Daño**: sin el ×2 de contacto de los élites.
- **Muerte**: no suelta el cofre de élite; en su lugar, emite `boss_defeated`.
- **Barra**: no lleva barra sobre la cabeza, porque la tiene en el HUD.

### Ataques por turnos desde los datos
`EnemyData.boss_attacks` es la lista de ataques que el jefe usa en orden, uno cada `attack_cooldown` segundos. `_boss_act()` lo resuelve dentro del bucle de movimiento de `EnemyManager`:
- **anillo**: reutiliza las pociones de la bruja (`_throw_potion()`), con el 40 % del daño cada una;
- **golpe**: `Enemy.start_slam()` empieza la carga; mientras dura, el jefe no se mueve y su hijo `Telegraph` dibuja el círculo; al terminar, `_slam()` daña a quien esté dentro;
- **esbirros**: enemigos de la oleada actual, que no cuentan en el límite de la oleada.

El círculo es un hijo con `z_index = -1` que se dibuja con `draw_ops()`. Así queda bajo los personajes y llega al invitado con la réplica genérica.

### Calendario
- **Cuándo**: igual que las hordas, cada `BOSS_INTERVAL` (300 s), con aviso `BOSS_WARNING_TIME` (5 s) antes.
- **Jefe vivo**: mientras haya un jefe, el siguiente se aplaza.
- **Saltos de tiempo**: `sync_horde_clock()` también recoloca el calendario de los jefes cuando el tiempo salta (depuración).

### Recompensa para cada jugador
Un cofre en el suelo solo lo recoge uno. Para que en cooperativo los dos reciban premio, `boss_defeated` añade a cada asiento una elección pendiente `{kind = &"boss", rarity = ÉPICA}`. Se muestra con el mismo menú de subida de nivel, con el título "¡Jefe derrotado!".

### Vida ajustada con bots
Seis bots, uno por personaje, jugaron hasta el jefe de los 5:00 eligiendo siempre la primera mejora y quietos en el centro, de modo que sus armas reparten golpes entre el jefe y los enemigos de alrededor.
- **Primera medida**: con 6.000 de vida base (16.800 a los 5:00), ningún bot lo derrotó en 120 s.
- **Fallo encontrado**: casi todo el daño se perdía porque las armas de área no daban a los enemigos de más de 40 de radio (ver tareas, 1.4).
- **Con el arreglo y 1.500 de vida base**: cinco de seis bots lo derrotaron en 44–112 s.
- **Valor final**: 1.100 / 950 / 1.050 (gólem, bruja y calabaza), alrededor de un minuto para estos bots.

Un jugador real, que se mueve y elige mejor, tardará menos.

## Risks / Trade-offs

- **Daño desde las 10:00**: crece con el tiempo (+8 % por minuto y más a partir de las 10:00). Los golpes del tercer jefe pueden ser duros; se ajustará jugando.
- **Cooperativo**: los esbirros y las pociones no se dividen entre los dos jugadores; el jefe persigue al más cercano.
