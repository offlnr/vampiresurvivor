# Proposal

## Why
El jugador quiere progresión entre partidas como en *Megabonk*: que las armas, los pergaminos y los objetos se vayan desbloqueando, y que lo que no se ha comprado no aparezca en la partida. Ahora todo está disponible desde la primera partida, así que no hay nada que perseguir entre partidas.

## What Changes
- **Plata**: al terminar una partida (muriendo o abandonando desde la pausa) se gana plata. La cantidad es 1 por minuto sobrevivido, más 1 por cada 5 niveles y 1 por cada 200 enemigos derrotados (se rebajó en `megabonk-items`). El total se guarda en el dispositivo.
- **Desafíos**: cada cosa bloqueada tiene un desafío, como las misiones de Megabonk ("Derrota a 1.500 enemigos", "Sube el pergamino de empuje a nivel 4"...). Cuando se cumple, se puede comprar con plata.
- **Contenido bloqueado** (20 en total):
  - 5 armas: fuego fatuo, rayo espectral, rastro de brasas, vórtice de almas y trabuco de plata;
  - 10 pergaminos: los mismos que Megabonk tiene bloqueados (espinas, imán, experiencia, armadura, duración, vampirismo, suerte, maldito, multiplicidad y caos);
  - 5 objetos épicos o legendarios.
- **Lo bloqueado no aparece en la partida**: ni en las cartas de subida de nivel, ni en el comerciante, ni en los cofres, ni en el caos.
- **Menú "Desbloqueos"** en la pantalla de título. Muestra la plata, cada desafío con su progreso y el botón de compra. La pantalla de título indica también cuánta plata hay y cuántos desbloqueos se pueden comprar.
- **Fin de partida**: muestra la plata ganada y los desafíos cumplidos en esa partida.
- **Pergamino de plata** (+12 % de plata): como el libro "Silver" de Megabonk, desbloqueado desde el principio.

## Capabilities

### New Capabilities
- `unlocks`: plata, desafíos, compra y filtrado del contenido bloqueado.

## Impact
- **Nuevos**:
  - `autoload/progress.gd`, registrado como autoload `Progress` y guardado en `user://progress.cfg`;
  - `scripts/data/unlocks.gd`, con el catálogo;
  - `scenes/ui/unlocks_menu.gd`;
  - `data/scrolls/plata.tres` y los iconos `plata.svg` y `silver_coin.svg`.
- **Modificados**:
  - `scenes/main/run.gd`: listas de contenido desbloqueado, contadores de los desafíos y `_record_run()`;
  - `scenes/player/player.gd`: `silver_multiplier` y `time_since_hit()`;
  - `scenes/ui/game_over.gd`, `scenes/main/main_menu.gd` y `scenes/ui/debug_overlay.gd` (+100 plata);
  - `UpgradeData.Stat.SILVER`.
