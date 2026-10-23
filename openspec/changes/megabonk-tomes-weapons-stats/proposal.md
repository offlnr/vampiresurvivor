# Proposal

## Why
El jugador quiere más variedad de builds, al estilo de *Megabonk*: más pergaminos y más armas. Además:
- el pergamino de multiplicidad sube con decimales ("+1,2 proyectiles"), lo que confunde porque un arma no puede disparar 1,2 proyectiles. Lo quiere en números enteros;
- al elegir una mejora o comprar en la tienda no se pueden ver las estadísticas actuales, así que se elige a ciegas.

## What Changes
- **Cantidades enteras**: el pergamino de multiplicidad y las mejoras de cantidad y de atravesar de las armas dan siempre números enteros. Se redondea el valor común por el multiplicador de rareza: +1 en común, poco común y rara, y +2 en épica y legendaria. Las cartas dicen "+1" o "+2", nunca "+1,2".
- **11 pergaminos nuevos**, basados en los libros de Megabonk, con los valores comunes de Megabonk cuando encajan con la escala del juego:
  - regeneración (+0,5 de vida/s);
  - escudo (+15, se recarga tras 4 s sin recibir golpes);
  - evasión (+10 %, con rendimiento decreciente);
  - espinas (+15 de daño a quien te toca al golpearte);
  - precisión (+7 % de crítico);
  - vuelo (+15 % de velocidad de proyectiles);
  - duración (+15 %);
  - empuje (+20 %);
  - codicia (+12 % de oro);
  - maldito (+5 % de dificultad a cambio de +10 % de experiencia y oro, como los calderos);
  - caos (cada subida de nivel mejora una estadística al azar).

  Pasan de 11 a 22 pergaminos. El límite de 4 por partida no cambia.
- **4 armas nuevas** con patrones nuevos, basadas en armas de Megabonk. Pasan de 7 a 11 armas, y el límite de 4 equipadas no cambia.
  - **Rayo espectral** (bastón de rayos): rayos que caen sobre enemigos cercanos y saltan de uno a otro.
  - **Rastro de brasas** (flamewalker): deja brasas al caminar.
  - **Vórtice de almas** (agujero negro): atrae enemigos a su centro y los daña.
  - **Trabuco de plata** (escopeta): abanico de perdigones de corto alcance.
- **Panel de estadísticas**: botón "Estadísticas" en el menú de subida de nivel (y en el de cofre) y en la tienda o cofre de pago. Abre un panel con todas las estadísticas del personaje y, para cada arma, su daño, su recarga y su cantidad.

## Capabilities

### Modified Capabilities
- `run-progression`: pergaminos nuevos, multiplicidad entera.
- `auto-weapons`: armas nuevas, cantidades enteras, multiplicadores de duración, velocidad de proyectil y empuje.
- `upgrade-menus` (nueva): panel de estadísticas desde los menús de elección.

## Impact
- `scripts/data/upgrade_data.gd`: nuevas estadísticas al final del enum, `percent`, cantidades enteras.
- `scripts/data/weapon_data.gd`: patrones nuevos al final del enum, `pierce_label`, cantidades enteras.
- `scenes/player/player.gd`:
  - regeneración, escudo con barra, evasión y espinas;
  - crítico, velocidad de proyectil, duración y empuje.
- `scenes/weapons/weapon.gd`, `scenes/enemies/enemy_manager.gd` y `scenes/main/inventory.gd`: aplican los multiplicadores nuevos.
- Armas nuevas:
  - `scenes/weapons/chain_weapon.gd`, `trail_weapon.gd`, `vortex_weapon.gd` y `spread_weapon.gd`, con sus `.tscn`;
  - `silver_pellet.tscn`;
  - `data/weapons/{rayo,brasas,vortice,trabuco}.tres`.
- `data/scrolls/*.tres` y `art/placeholder/scrolls/*.svg`: 11 pergaminos nuevos. Iconos nuevos de armas en `art/placeholder/`.
- `scenes/ui/stats_panel.gd` (nuevo), `level_up.gd`, `shop_menu.gd` y `hud.gd` (aviso de caos).
- `scenes/main/run.gd`: catálogos, efectos de los pergaminos, dificultad combinada (calderos + maldito) y `stats_sections()`.
