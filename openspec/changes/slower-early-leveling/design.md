# Design

## Context

- La curva era `3 + 2n + 0,45n² + 0,03n³`, con n = nivel − 1. Pedía 3, 5, 9, 14 y 20 de experiencia para los niveles 2 a 6, así que con unas pocas almas ya se subía.
- Las partidas varían mucho según las mejoras que salgan: en dos partidas de 10 minutos con la misma curva, el bot mató 844 y 4035 enemigos. Comparar curvas con una sola partida no sirve.

## Goals / Non-Goals

**Goals:**
- Aproximadamente la mitad de subidas de nivel en el primer minuto.
- Dejar igual la curva de los niveles altos.

**Non-Goals:**
- Reequilibrar la experiencia de los enemigos o los pergaminos de experiencia.

## Decisions

> **Sustituido por `megabonk-progression` (segunda iteración):** el jugador pidió copiar el sistema de niveles de Megabonk por encima de esta petición, así que los primeros niveles vuelven a ser rápidos y se quita el extra de experiencia.

### 1. Extra que se desvanece
`coste(n) = 3 + 2n + 0,45n² + 0,03n³ + 20 × max(1 − n/15, 0)`.
- El extra es 20 en el nivel 2 y baja de forma lineal hasta 0 en el nivel 16.
- Costes para los niveles 2 a 12: 23, 24, 26, 30, 35, 41, 50, 60, 72, 87, 105.
- En total añade unos 160 de experiencia, que a partir del nivel 20 es menos de medio nivel.

**Alternativas descartadas:**
- Subir la base y el término lineal (por ejemplo, `12 + 5n`): frenaba igual el principio, pero también bajaba unos 2 niveles el final de la partida.
- Multiplicar toda la curva: no distinguía los niveles bajos de los altos.

### 2. Medición con bot
El bot juega sin ventana (Godot 4.7.2 headless): recoge todas las almas atrayéndolas cada segundo, siempre elige la primera mejora y camina en círculo. Se lanzaron 6 partidas de 3 minutos por curva, en paralelo.

| Nivel medio | Min. 1 | Min. 2 | Min. 3 |
|---|---|---|---|
| Antes | 8,5 (8–10) | 11,8 (11–14) | 14,5 (12–16) |
| Ahora | 4,7 (4–6) | 7,8 (6–9) | 10,2 (7–12) |

El bot juega peor que una persona, porque no elige bien las mejoras, así que un jugador real irá algo por delante.

## Risks / Trade-offs

- [Las partidas con malas mejoras pueden quedarse en nivel 7 en el minuto 3] → El extra se ajusta con `EARLY_XP_EXTRA` y `EARLY_LEVELS`.
- [El objetivo de nivel 30–40 en el minuto 10 del MVP no se ha vuelto a medir] → Con esta curva solo cambia en torno a un nivel; está en las tareas de verificación.
