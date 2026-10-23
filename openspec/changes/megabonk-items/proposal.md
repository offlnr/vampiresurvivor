# Proposal

## Why
Con 17 objetos el comerciante y los cofres se repiten pronto, y faltan muchos de los efectos que dan variedad a las partidas de *Megabonk*: daño condicional, efectos al recibir daño, objetos que crecen durante la partida y legendarios que cambian las reglas.

## What Changes
- **34 objetos nuevos (de 17 a 51)**. La mayoría están basados en objetos de Megabonk, con nombre y dibujo de Halloween; unos pocos son propios (gato negro, ojo de tritón, campana fúnebre).
  - **Comunes (18)**:
    - estadísticas: suerte, experiencia, vida, regeneración, daño, crítico, evasión, imán;
    - daño condicional: monóculo de búho (a enemigos sanos), estaca (a élites), mazo (×20 a veces);
    - objetos de situación: hoguera (curarse quieto), capa del cobarde, llave oxidada (cofres gratis), hucha (oro al recibir daño), poción de quietud, moneda maldita (daño por cofre).
  - **Poco comunes (2)**: farol chispeante (descarga al recibir daño) y botas de viento (velocidad de ataque al moverse).
  - **Raros (5)**: morral (+1 proyectil), nudilleras (daño cercano), daga sedienta (críticos que curan), tridente (megacríticos ×4) y sudario (frenesí al esquivar).
  - **Épicos (4)**: alma demoníaca (daño por muerte, máximo +100 %), petardo de calabaza (explosiones), frasco de miasma (veneno al recibir daño) y campana fúnebre (congela la pantalla cada 15 s).
  - **Legendarios (5)**: yunque (+1 estadística en las mejoras de arma), libro sagrado, reloj de arena detenido (salva de un golpe mortal una vez), orbe de tormenta (rayos al golpear) y llama infernal (incendia al golpear).
- **10 de los nuevos empiezan bloqueados**, con su desafío en "Desbloqueos". En total hay 30 desbloqueos.
- **Menos plata**: 1 por minuto, 1 por cada 5 niveles y 1 por cada 200 enemigos (antes 2, 1/3 y 1/100). Una partida de 10 minutos da unas 27 de plata en vez de 51.
- **HUD**: la fila de objetos salta de línea cuando hay muchos.

## Capabilities

### Modified Capabilities
- `merchant-items`: catálogo de objetos y efectos nuevos.
- `unlocks`: 10 desbloqueos más y menos plata (ver `megabonk-unlocks`).

## Impact
- `scripts/data/item_data.gd`: 33 efectos nuevos al final del enum.
- `scenes/main/inventory.gd`:
  - efectos de estadística aplicados al comprar, y `remove_one()`;
  - `hit_multiplier()`, `crit_multiplier()`, `try_last_stand()` y la señal `gold_gained`;
  - campana, rayo y efectos al golpear o al recibir daño.
- Ganchos:
  - `enemy_manager.gd`: multiplicadores por golpe y megacrítico;
  - `player.gd`: esquivar y golpe mortal;
  - `weapon.gd`: yunque;
  - `run.gd`: lista de objetos, llave, moneda maldita y hucha.
- `scripts/data/power_ups.gd`: la capa y el sudario aparecen en el HUD como efectos temporales.
- `scenes/ui/hud.tscn`: la fila de objetos pasa a `HFlowContainer`.
- `data/items/*.tres` y `art/placeholder/items/*.svg`: 34 nuevos.
