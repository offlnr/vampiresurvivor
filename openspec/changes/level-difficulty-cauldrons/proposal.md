# Proposal

## Why

- **Dificultad por nivel**: con la dificultad ligada solo al tiempo, un jugador que sube de nivel muy rápido arrasa, y uno que se queda atrás no puede seguir el ritmo. El jugador quiere que la dificultad suba con su nivel, como en Megabonk.
- **Calderos**: no hay forma de elegir jugar más difícil a cambio de progresar más rápido. Un objeto de riesgo y recompensa da una decisión más en el mapa y una razón para explorarlo.
- **Destierro**: el jugador vio cosas desterradas que volvían a salir. El destierro tiene que valer para toda la partida, y en la tienda no siempre era así:
  - en una tienda común, desterrar cuando ya no quedaban comunes para sustituir gastaba el destierro y dejaba el objeto a la venta;
  - un comerciante que llegó antes de un destierro seguía vendiendo lo desterrado;
  - un cofre con todos los comunes desterrados podía salir vacío y bloquear la partida.

## What Changes

- **Dificultad por nivel**: la vida y el daño de los enemigos pasan a depender del nivel del jugador, no del tiempo.
  - Vida: ×1,055 por nivel (×2,8 a nivel 20, ×6,2 a nivel 35).
  - Daño: +2,5 % de la base por nivel.
  - Siguen dependiendo del tiempo:
    - qué enemigos salen, cuántos y a qué ritmo;
    - su velocidad;
    - las hordas;
    - el escalado infinito a partir del minuto 10.
  - La tabla de oleadas deja de tener multiplicador de vida.
- **Calderos malditos**: 6 calderos repartidos por el mapa desde el inicio de la partida, separados entre sí y marcados en el minimapa.
  - Se activan quedándose 1,5 s encima; un anillo verde muestra el progreso.
  - Cada caldero sube la dificultad un 5 % (vida, daño y número máximo de enemigos a la vez) y da +10 % de experiencia y de oro para el resto de la partida.
  - Al usarlo, aparece otro en otro sitio.
  - El HUD muestra la dificultad extra acumulada junto al oro y las muertes.
- **Destierro para toda la partida**:
  - si un objeto desterrado no se puede sustituir, su carta desaparece;
  - al abrir la tienda se retiran los objetos desterrados después de que llegara el comerciante;
  - si no quedan objetos de la rareza pedida ni de las inferiores, se buscan en las superiores, para que un cofre nunca salga vacío.

  En las cartas de nivel, lo desterrado ya no volvía a salir: se comprobó en 40 subidas de nivel.

**Fuera de alcance:** cambiar el ritmo de aparición o los tipos de enemigo según el nivel, y que los calderos cuesten oro.

## Capabilities

### New Capabilities
- `map-cauldrons`: calderos malditos del mapa, su activación y su efecto.

### Modified Capabilities
- `enemy-waves`: "Dificultad creciente" (vida y daño por nivel; los calderos la suben).
- `minimap`: "Puntos de interés" (los calderos).
- `run-progression`: "Volver a tirar y desterrar" (para toda la partida, también en tiendas y cofres).

## Impact

- **Código**:
  - `EnemyManager`: `player_level`, `difficulty`, crecimiento por nivel; se quita `DAMAGE_GROWTH_PER_MINUTE`.
  - `WaveEntry`: se quita `health_multiplier`.
  - Nuevo `Cauldrons` (`scenes/pickups/cauldrons.gd`).
  - `run.gd`: calderos, nivel y destierro en la tienda.
  - `Player.gold_bonus`.
  - HUD: indicador de dificultad y aviso del caldero.
  - Minimapa.
  - `ShopMenu`: protección ante una tienda vacía.
  - Panel de depuración: botón "Caldero".
- **Datos**: `data/waves/noche.tres` sin multiplicadores de vida.
- **Arte**: `art/placeholder/cauldron.svg`.
- **Sustituye** parte de `harder-difficulty-lifesteal-nerf`: la columna de vida de su tabla de oleadas, el daño por minuto (0,08) y su escenario "Presión desde el minuto 1". El nerf del robo de vida y el ritmo y la cantidad de enemigos se mantienen.
