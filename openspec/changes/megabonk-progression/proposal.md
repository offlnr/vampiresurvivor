# Proposal

## Why

El jugador quiere que la progresión funcione como en Megabonk. Tras investigar el juego (datamine `megabonk_research`, guías y foros de Steam), había cuatro diferencias:
- **Pergaminos:** usaban multiplicadores de rareza mucho mayores que los de Megabonk (×1,5 / 2 / 3 / 4 frente a ×1,2 / 1,4 / 1,6 / 2,0).
- **Suerte:** era lineal y sin límite, frente a la curva logarítmica de Megabonk.
- **Mejoras de arma comunes:** daban siempre 1 estadística; en Megabonk dan 1 o 2.
- **Botón de saltar:** no existía.

Además, la fuerza de los enemigos dependía del nivel del jugador. En Megabonk depende del tiempo y de la Dificultad, y subir de nivel rápido es justo la forma de ganar.

## What Changes

- **Multiplicadores de rareza únicos** para armas y pergaminos: ×1,0 / 1,2 / 1,4 / 1,6 / 2,0. El pergamino de multiplicidad conserva su +1…+5, que el jugador pidió para que cada rareza fuera distinta.
- **Suerte como en Megabonk**:
  - `bonus = ln(suerte + 1) × 1,5`;
  - el peso de cada rareza se multiplica por `1,5^(−escalones hasta legendaria × bonus)`.

  Con suerte 0 no cambia nada (60 / 25 / 10 / 4 / 1 %). Con suerte, bajan sobre todo las comunes y la legendaria sube en proporción, con rendimientos decrecientes.
- **Mejoras de arma comunes**: 1 o 2 estadísticas, al 50 %; las demás rarezas, siempre 2.
- **Saltar**: un botón nuevo en la pantalla de subida de nivel y de cofre, con 5 usos por partida. Rechaza las opciones sin coger nada y sin gastar un destierro. El contador muestra "Saltos N".
- **Enemigos más fuertes con el tiempo, no con el nivel**:
  - vuelve la vida por tramo de la tabla de oleadas y el daño +8 % por minuto;
  - los calderos siguen funcionando como los santuarios de codicia de Megabonk: +5 % de dificultad, que también da más experiencia y oro.

**Fuera de alcance:**
- desbloquear saltar, tirar y desterrar con progresión entre partidas;
- fases y tiers con temporizador;
- la curva exacta de experiencia de Megabonk, que no es pública; se mantiene la de `slower-early-leveling`;
- gemas de experiencia de valor 1 / 10 / 50.

## Capabilities

### New Capabilities
<!-- Ninguna. -->

### Modified Capabilities
- `run-progression`: "Rareza de las mejoras", "Suerte" y "Volver a tirar y desterrar" (añade saltar).
- `auto-weapons`: "Niveles de arma" (comunes de 1 o 2 estadísticas).
- `enemy-waves`: "Dificultad creciente" (vida y daño por tiempo otra vez).

## Impact

- **Código**:
  - `Rarity`: `MULTIPLIERS`, `luck_bonus()` y `roll()`.
  - `WeaponData.RARITY_FACTORS` usa los de `Rarity`.
  - `Weapon.roll_upgrade()`.
  - `EnemyManager`: se quita `player_level` y vuelve `DAMAGE_GROWTH_PER_MINUTE`.
  - `WaveEntry.health_multiplier` vuelve.
  - `LevelUp`: botón "Saltar" y `skip_requested`.
  - `UiCards.counter_text()`.
  - `run.gd`: `SKIPS_PER_RUN` y `_on_card_skip()`.
- **Datos**: `data/waves/noche.tres` recupera la vida por tramo.
- **Sustituye** la parte de dificultad por nivel de `level-difficulty-cauldrons`. Los calderos, el destierro y lo demás de ese cambio siguen igual.

## Segunda iteración: lo más parecido a Megabonk

El jugador pidió que el sistema de niveles se parezca a Megabonk todo lo posible, por encima de sus peticiones anteriores. Además de lo anterior:
- **Cantidades con decimales**:
  - "+1 proyectil" da +1 / 1,2 / 1,4 / 1,6 / 2 según la rareza, también en el pergamino de multiplicidad, que antes daba +1…+5;
  - se acumulan y el arma usa la parte entera.
- **Mejoras sin escalado por nivel**: el valor solo depende de la rareza. Se quita "Mejoras que crecen con el nivel".
- **4 armas y 4 pergaminos**, los huecos de Megabonk con todo desbloqueado (antes, 3 armas y 5 pergaminos).
- **Valores de libros conocidos de Megabonk**: daño +8 % (antes +12 %), velocidad de ataque +7,5 % (antes +10 %) y experiencia +7 % (antes +12 %).
- **Curva de experiencia de Megabonk**: los primeros niveles vuelven a ser rápidos (3 / 5 / 9 de experiencia para los niveles 2 a 4). Se quita el extra de `slower-early-leveling`.
- **Tope de experiencia ×10**.
- **Almas por valor como las gemas**: 1, 10 y 50 o más (antes 1, 5 y 20).

**Sustituye**:
- `slower-early-leveling`, entero;
- los valores +1…+5 de multiplicidad de `witch-magic-orb`.
