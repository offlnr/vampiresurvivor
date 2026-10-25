# Proposal

## Why

La partida no tenía momentos clave: solo crecían las oleadas, con hordas y élites de vez en cuando. En Megabonk los jefes marcan el ritmo y dan las mejores recompensas. El jugador dejó en manos de Claude mejorar el juego, y los jefes eran lo que más faltaba.

## What Changes

- **Un jefe cada 5 minutos** (5:00, 10:00, 15:00…), avisado 5 s antes con "¡Se acerca un jefe!" y su nombre. Si el anterior sigue vivo, el siguiente espera.
- **Tres jefes por turnos**, versiones gigantes (×2,6) y teñidas de enemigos conocidos, cada uno con su orden de ataques:
  - **Gólem de la cripta**: golpe, esbirros, golpe, anillo;
  - **Reina bruja**: anillo, esbirros, anillo, golpe;
  - **Rey calabaza**: golpe, anillo, esbirros, anillo.
- **Ataques**:
  - **anillo**: 14 pociones en todas direcciones;
  - **golpe**: un círculo rojo avisa 1,2 s antes de dañar a quien siga dentro;
  - **esbirros**: 7 enemigos de la oleada actual.
- **Barra del jefe** en el HUD, bajo el tiempo, con su nombre. También la ve el invitado.
- **Vida**: crece con el tiempo, la dificultad y el cooperativo como la del resto de enemigos, más un 50 % por cada vuelta completa de los tres. Se ajustó con bots, ver el diseño.
- **Recompensa**: cada jugador elige su propia mejora épica o legendaria ("¡Jefe derrotado!"). El jefe suelta además un alma grande y 30 monedas.
- **Defensas del jefe**: no recibe empuje, y la bomba solo le quita un 4 % de su vida.
- **Panel de depuración**: botón "Jefe".

## Capabilities

### New Capabilities
- `bosses`: aparición, ataques, barra y recompensa de los jefes.

### Modified Capabilities
- `minimap`: "Puntos de interés" (los jefes, en rojo como los élites).

## Impact

- **Datos**: `data/enemies/jefe_golem.tres`, `jefe_bruja.tres` y `jefe_calabaza.tres`.
- **`EnemyData`**: `BossAttack` y `boss_attacks`.
- **`Enemy`**:
  - `is_boss`, `BOSS_SCALE` y el estado del golpe;
  - hijo `Telegraph` con el círculo de aviso, que se dibuja con `draw_ops()` para que lo vea el invitado.
- **`EnemyManager`**:
  - calendario y lista de jefes, `start_boss()` y `_boss_act()`;
  - anillo, golpe y esbirros;
  - señales `boss_warning`, `boss_started` y `boss_defeated`;
  - la bomba contra jefes;
  - `_throw_potion()` con parte del daño.
- **`run.gd`**: avisos para los dos jugadores (`_announce()`), elección pendiente `&"boss"`, barra del HUD y `debug_boss()`.
- **`hud.gd`**: `set_boss()`.
- **Red**: `net_host.gd` y `net_guest.gd` llevan la barra del jefe en la cabecera de la instantánea.
