# Design

## Context
En Megabonk el contenido se desbloquea así:
1. Cada arma, libro u objeto tiene una misión ("Upgrade the Knockback Tome to level 10" → Black Hole).
2. Cuando se cumple la misión, se compra con plata.
3. La plata se gana jugando.
4. Se empieza con unas pocas armas y unos 13 libros.

Las cantidades exactas de plata no son públicas, así que las de aquí son propias.

## Decisions

### 1. Catálogo en código
`Unlocks.ENTRIES` es una lista de `{key, path, price, stat, target, quest, time?}`. Lo que no está en la lista está desbloqueado desde el principio, así que el contenido futuro no se bloquea por accidente.

### 2. Desafíos como estadísticas acumuladas
Cada desafío compara una estadística de `Progress.stats` con su objetivo:
- `total_*`: suma de todas las partidas (enemigos, experiencia, cofres, objetos comprados, calderos);
- `best_*`: el mejor valor en una sola partida (tiempo, nivel, enemigos, tiempo sin daño, pergaminos distintos, nivel de cada pergamino o arma).

Las estadísticas solo crecen, así que un desafío cumplido no se "descumple" y no hace falta guardar aparte cuáles están cumplidos.

### 3. Desafíos elegidos
Se adaptan las misiones de Megabonk a lo que este juego puede medir:

| Contenido | Desafío | Precio |
|---|---|---|
| Fuego fatuo | Abre 5 cofres | 15 |
| Rayo espectral | Derrota a 1.500 enemigos | 20 |
| Rastro de brasas | Sobrevive 5:00 | 25 |
| Vórtice de almas | Pergamino de empuje a nivel 4 (agujero negro ← libro de empuje en Megabonk) | 35 |
| Trabuco de plata | Derrota a 5.000 enemigos (revólver ← 7.500 en Megabonk) | 40 |
| Espinas | Sobrevive 3:00 | 10 |
| Imán | 5.000 de experiencia | 10 |
| Experiencia | Nivel 15 | 15 |
| Armadura | 1:00 sin recibir daño (aura ← "evita el daño 2 min" en Megabonk) | 15 |
| Duración | Murciélagos a nivel 6 | 15 |
| Vampirismo | Nivel 20 | 20 |
| Suerte | Abre 12 cofres | 20 |
| Maldito | Prepara 5 calderos | 25 |
| Multiplicidad | Un arma a nivel 10 | 30 |
| Caos | 4 pergaminos distintos | 30 |
| Grimorio hecho trizas | Compra 10 objetos | 25 |
| Daga del verdugo | Derrota a 2.500 enemigos | 30 |
| Reloj de bolsillo maldito | Sobrevive 10:00 | 30 |
| Cosechador de almas | 800 enemigos en una partida | 35 |
| Imán succionador | Nivel 30 | 35 |

Todo suma 485 de plata. Una partida de 10 minutos a nivel 35 con 2.000 enemigos da ~51, así que desbloquear todo lleva unas 10–15 partidas.

### 4. Filtrado en la partida
`run._ready()` construye `weapon_pool`, `scroll_pool` e `item_pool` con lo desbloqueado. Esas listas se usan en las cartas (`_offer_candidates`), en el caos, en `_random_item` (cofres y comerciante) y en `merchants.items`. Las listas completas (`WEAPONS`, `SCROLLS`, `ITEMS`) solo se usan para construir esas.

### 5. Guardar la partida
`run._record_run()` se llama al morir y también al abandonar desde la pausa, para no perder la plata. La guarda `_run_recorded`, así que una partida nunca cuenta dos veces. El tiempo sin daño se mide con `Player.time_since_hit()`: se reinicia al perder vida o escudo, pero no al esquivar.

### 6. Guardado aparte
`Progress` guarda en `user://progress.cfg`, separado de `settings.cfg`, y su ruta se puede cambiar para las pruebas.

## Risks / Trade-offs
- [Los jugadores actuales pierden acceso a cosas que ya usaban] → Es lo que pide el cambio. El panel de depuración tiene "+100 plata" para probar.
- [El desafío del vórtice exige coger un pergamino concreto, el de empuje, que está desbloqueado desde el principio] → Es alcanzable con tiradas y destierros. Es igual que en Megabonk.

## Verificación hecha
Godot 4.7.2 headless (`unlock_test`, 25 comprobaciones, todas pasan). El progreso de la prueba va a un archivo temporal.
- **Sin nada desbloqueado**: hay 6 armas, 13 pergaminos y 12 objetos disponibles. En 300 tiradas de cartas y 300 de objetos nunca sale nada bloqueado, y el comerciante solo tiene los 12 objetos.
- **Fin de partida**: una partida de 5:30, nivel 16 y 1.600 enemigos da 32 de plata y anuncia 7 desafíos cumplidos. Las estadísticas se guardan y la partida no cuenta dos veces.
- **Compra**:
  - sin el desafío cumplido o sin plata no se puede comprar;
  - comprar resta la plata, no se puede repetir, y el progreso se guarda y se vuelve a cargar;
  - la partida siguiente ya ofrece lo comprado;
  - abandonar desde la pausa también cuenta.
- **Menú**: tiene 20 filas, comprar desde él funciona y "Volver" lo cierra.

Capturas a 1280×720 del menú principal ("Desbloqueos" junto a "Opciones" para que quepa) y del menú de desbloqueos.
