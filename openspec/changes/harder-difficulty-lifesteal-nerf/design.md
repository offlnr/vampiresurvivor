# Design

## Context

- La dificultad sale de tres sitios:
  - la tabla de oleadas `data/waves/noche.tres`: ritmo, enemigos por tanda, máximo a la vez, vida y velocidad por tramo;
  - las constantes de crecimiento por minuto de `EnemyManager`;
  - el tamaño de las hordas en `EnemyManager.start_horde()`.
- `EnemyManager.damage()` llamaba a `player.on_damage_dealt(amount)` con cualquier daño y con el golpe entero, aunque superase la vida que le quedaba al enemigo.
- El design del MVP tuvo en su momento un tope de robo de vida de 3 de vida por segundo, que se quitó al pasar todo a porcentajes ("robo de vida sin límite por segundo"). El design del comerciante decidió que "el robo de vida sigue contando todo el daño". Este cambio revierte las dos decisiones.

## Goals / Non-Goals

**Goals:**
- Que la partida apriete antes y más, sin cambiar el carácter del primer minuto.
- Que el robo de vida ayude a aguantar, pero no cure de golpe ni deje al jugador inmortal con armas de área.

**Non-Goals:**
- Reequilibrar armas, objetos o pergaminos aparte del robo de vida.

## Decisions

> **Sustituido en parte por `level-difficulty-cauldrons`:** la columna "Vida" de la tabla de la Decisión 1 y el daño por minuto de la Decisión 2 ya no se usan; la vida y el daño de los enemigos dependen ahora del nivel del jugador. Siguen vigentes el ritmo, el máximo de enemigos, las hordas y todo el nerf del robo de vida.

### 1. Tabla de oleadas

| Tramo | Ritmo (s) | Máx. a la vez | Vida |
|---|---|---|---|
| 0:00 | 1,3 → 1,1 | 12 → 15 | 1,0 (igual) |
| 0:30 | 1,1 → 0,95 | 20 → 25 | 1,0 → 1,1 |
| 1:00 | 0,9 → 0,75 | 35 → 42 | 1,15 → 1,4 |
| 2:00 | 0,75 → 0,62 | 60 → 72 | 1,35 → 1,65 |
| 3:00 | 0,6 → 0,5 | 100 → 120 | 1,8 → 2,2 |
| 5:00 | 0,5 → 0,42 | 145 → 175 | 2,3 → 2,8 |
| 6:00 | 0,45 → 0,38 | 175 → 210 | 2,9 → 3,5 |
| 7:00 | 0,38 → 0,32 | 215 → 255 | 3,7 → 4,5 |
| 9:00 | 0,3 → 0,26 | 265 → 310 | 4,8 → 5,8 |

- **Sin cambios**: las tandas, la mezcla de enemigos y la velocidad de cada tramo.
- La vida del primer tramo se queda en 1,0 para que el zombi (22 de vida) siga muriendo con 2 orbes de 11.
- El máximo del último tramo (310) más las hordas sigue por debajo de `HARD_CAP` (400).

### 2. Crecimiento por minuto y hordas
- `DAMAGE_GROWTH_PER_MINUTE` pasa de 0,05 a 0,08. A los 10 minutos los enemigos pegan ×1,8 en vez de ×1,5.
- `SPEED_GROWTH_PER_MINUTE` no cambia: con 0,72 de velocidad en el primer tramo y ±10 % de variación, un murciélago ya roza la mitad de la velocidad base del jugador (105) al final del primer minuto.
- **Hordas**:
  - anillo: 14 + 7n (tope 52) → 18 + 8n (tope 64);
  - enjambre: 22 + 7n (tope 64) → 28 + 8n (tope 80);
  - carga: 10 + 4n (tope 36) → 13 + 5n (tope 45).

### 3. Robo de vida
- **Solo daño de arma**: `EnemyManager.damage()` solo llama a `on_damage_dealt` si `source == SOURCE_WEAPON`. Así queda fuera el daño de objetos y de la bomba, que usan `SOURCE_ITEM`.
- **Sin daño sobrante**: se pasa `min(daño, vida del enemigo antes del golpe)`.
- **Tope por segundo**: `Player._lifesteal_budget` se rellena a `LIFESTEAL_CAP_PER_SECOND` (2 %) de la vida máxima por segundo, y como mucho acumula un segundo. Cada curación por robo de vida lo gasta. Se usa porcentaje y no vida fija para que el tope siga teniendo sentido con el pergamino de vida.
- **Alternativa**: solo bajar el valor del pergamino. Descartada, porque no arregla lo de las armas de área ni la bomba: el problema es el número de golpes, no el porcentaje.

## Risks / Trade-offs

- [El juego se vuelve demasiado difícil para jugadores nuevos] → Los valores están en la tabla de oleadas y en tres constantes; se pueden bajar a mitad de camino tras probar.
- [Con el tope, el pergamino de vampirismo se nota poco con armas de golpe único] → Con 1 % de robo y un orbe de 11, cura 0,11 por golpe, muy por debajo del tope (2 por segundo con 100 de vida). El tope solo actúa con mucho robo de vida o con armas de área.
