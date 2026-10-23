# Proposal

## Why

Al empezar la partida se sube de nivel demasiado rápido: unas 7–8 subidas en el primer minuto, una cada 8 segundos. Las pantallas de mejora interrumpen el juego constantemente y el arranque se siente acelerado. El jugador quiere que los niveles bajos cuesten más.

## What Changes

- Los primeros niveles piden experiencia extra: +20 para el nivel 2, que se reduce en cada nivel hasta desaparecer en el nivel 16. A partir de ahí la curva es la misma que antes.
  - El nivel 2 pasa de pedir 3 a 23 de experiencia (unos 12 murciélagos en vez de 2).
  - Medido con un bot (6 partidas por curva), el nivel medio pasa de 8,5 a 4,7 en el minuto 1, de 11,8 a 7,8 en el minuto 2 y de 14,5 a 10,2 en el minuto 3.
- Como la vida y el daño de los enemigos dependen del nivel (`level-difficulty-cauldrons`), el principio de la partida también es algo más suave.

**Fuera de alcance:** cambiar la experiencia que da cada enemigo y la curva de los niveles altos.

## Capabilities

### New Capabilities
<!-- Ninguna. -->

### Modified Capabilities
- `run-progression`: "Curva de experiencia" (objetivos de los primeros minutos y coste de los primeros niveles).

## Impact

- **Código**: `run.gd` (`xp_to_next_level()`, `EARLY_XP_EXTRA`, `EARLY_LEVELS`).
