# Design

## Context

Lo que se sabe del sistema de Megabonk, y con qué fiabilidad:

| Dato | Fuente |
|---|---|
| Multiplicadores de rareza en las mejoras: 1,0 / 1,2 / 1,4 / 1,6 / 2,0, que escalan el valor de la mejora | Datamine (`mechanics.md`) y guía |
| Suerte: `luckBonus = ln(luck + 1) × 1,5`; `weight[i] = base[i] × 1,5^(−(maxRarity − i − 1) × luckBonus)` | Datamine |
| Mejora común: "50 % se queda en 1, 50 % sube a 2" estadísticas; rarezas superiores, 2 | Datamine y guía (v1.0.7) |
| Desterrar (toda la partida), saltar (rechazar sin gastar destierro) y refrescar, con usos limitados | Guías |
| Enemigos: estadísticas fijadas al aparecer; más fuertes por fase/tier y tiempo, no por nivel | Foros de Steam (sin confirmación del desarrollador) |
| Dificultad: más enemigos y más fuertes, a cambio de más experiencia y oro; santuarios de codicia +5 % cada uno | Guías |
| Curva de experiencia exacta | No es pública |

El datamine también dice "base count = rarity value", que podría significar más de 2 estadísticas en rarezas altas. Las guías dicen que siempre son 2. Se sigue la guía porque es lo que se ve en el juego.

## Goals / Non-Goals

**Goals:**
- Copiar las reglas conocidas de Megabonk tal cual.
- Que la suerte tenga rendimientos decrecientes y nunca toque la legendaria directamente.

**Non-Goals:**
- Inventar lo que no se sabe (curva de experiencia y valores por fase).

## Decisions

### 1. Un solo juego de multiplicadores
`Rarity.MULTIPLIERS` pasa a ser 1,0 / 1,2 / 1,4 / 1,6 / 2,0, y `WeaponData.RARITY_FACTORS` es una referencia a esa misma constante, para que armas y pergaminos no vuelvan a divergir.
- Un pergamino épico de daño pasa de +36 % a +19,2 %.
- El de multiplicidad sigue en +1…+5 (`roll_amount` lo trata aparte), por la petición anterior del jugador de que cada rareza dé un valor distinto. Con ×1,0–2,0 redondeado saldrían valores repetidos.

### 2. Suerte logarítmica
`Rarity.roll()` aplica la fórmula del datamine con `maxRarity − i − 1` = escalones hasta legendaria:
- con suerte 0 los pesos son los base;
- con suerte 1 queda en 43 / 27 / 17 / 10 / 4 %;
- con suerte 3, en 24 / 23 / 22 / 20 / 12 %.

La legendaria no gana peso propio: sube su parte porque las demás pierden.

Afecta a todo lo que usa `Rarity.roll()`: cartas, cofres, comerciante y cofres de pago.

### 3. Mejora común de 1 o 2 estadísticas
`Weapon.roll_upgrade()` tira al 50 % entre 1 y 2 si la rareza es común; si no, siempre 2. Las armas nuevas siguen saliendo comunes con sus estadísticas base.

### 4. Saltar
- `LevelUp` crea en `_ready()` un botón "Saltar" bajo las cartas y emite `skip_requested`.
- Se desactiva durante el retardo de entrada (0,35 s), igual que las cartas, y cuando no quedan saltos. `skips_left` lo pone la partida antes de abrir el menú.
- `run._on_card_skip()` gasta un salto, quita la elección pendiente y muestra la siguiente o reanuda la partida.
- `UiCards.counter_text()` añade "Saltos N" solo donde aplica; la tienda no lo muestra, porque ya tiene "Salir".
- Son 5 usos por partida, como las tiradas y los destierros. En Megabonk se desbloquean con progresión entre partidas; aquí no hay progresión entre partidas.

### 5. Enemigos por tiempo
- `EnemyManager.health_multiplier()` vuelve a `tabla × escalado infinito × dificultad`.
- `damage_multiplier()` vuelve a `(1 + 0,08 × minutos) × escalado infinito × dificultad`.
- La tabla recupera la vida por tramo de `harder-difficulty-lifesteal-nerf`: 1,0 / 1,1 / 1,4 / 1,65 / 2,2 / 2,8 / 3,5 / 4,5 / 5,8.
- Se quitan `player_level`, `LEVEL_HEALTH_GROWTH` y `LEVEL_DAMAGE_GROWTH`.
- `difficulty` (calderos) sigue multiplicando vida, daño y número de enemigos.

## Risks / Trade-offs

- [Pergaminos de rareza alta más débiles que antes] → Es lo que hace Megabonk; si la suerte pierde valor, se puede subir el valor base del pergamino de suerte.
- [La dificultad vuelve a no depender del nivel, cuando el jugador la pidió por nivel hace poco] → Este cambio responde a la petición posterior de copiar el sistema de Megabonk; queda anotado en `level-difficulty-cauldrons`.

## Verificación hecha

Pruebas con Godot 4.7.2 headless:
- **`megabonk_test`** (40 000 tiradas por nivel de suerte):
  - con suerte 0, 60 % de comunes y 1 % de legendarias;
  - más suerte, menos comunes y más legendarias, con rendimientos decrecientes;
  - multiplicadores 1,0–2,0, y pergamino épico de daño +19,2 %;
  - multiplicidad +1…+5;
  - mejora común con 2 estadísticas el 50,4 % de las veces, y la rara siempre 2;
  - saltar: cierra y reanuda, gasta un salto, con dos elecciones muestra la siguiente, y sin saltos no hace nada y el botón está desactivado.
- **`features_test`:** en el minuto 4, vida ×2,2 y daño ×1,32 por tiempo; a nivel 20 la vida de los enemigos no cambia por el nivel.
- Siguen pasando las pruebas de destierro, calderos y atascos.
- **Captura** de la pantalla de subida de nivel con "Saltar" y "Saltos 5".

## Segunda iteración

### 6. Cantidades fraccionarias
Una guía muestra la mejora de cantidad de la espada de Megabonk como +1 / +1,2 / +1,4 / +1,6 / +2 según la rareza. Por eso:
- `WeaponData.upgrade_value()` ya no redondea `amount` ni `pierce`;
- `UpgradeData.roll_amount()` trata las cantidades como cualquier otro valor;
- `Player.extra_amount` es `float`.

Las armas ya leían `int(stat(&"amount"))` e `int(stat(&"pierce"))`, así que usan la parte entera sin más cambios. `WeaponData.count_text()` escribe "1", "1,2" o "1,6".

### 7. Sin escalado por nivel
Se quitan `run.upgrade_scale()` y el parámetro `strength`. El valor de cualquier mejora es su valor común por el multiplicador de rareza.

### 8. Huecos, valores y experiencia
- **Huecos:** `MAX_WEAPONS` = 4 y `MAX_SCROLLS` = 4. En Megabonk se empieza con 2 y 2, y se amplía a 4 y 4 con progresión entre partidas, que aquí no existe. Se usa el máximo.
- **Valores de los libros:** solo se cambian los tres que dan las guías (daño 0,08, velocidad de ataque 0,075, experiencia 0,07). Los demás no se conocen y se quedan igual.
- **Curva de experiencia:** vuelve a `3 + 2n + 0,45n² + 0,03n³`. La curva real de Megabonk no es pública, pero se sabe que empieza rápida y se vuelve muy empinada, y esta lo cumple.
- **Tope de experiencia:** `MAX_XP_MULTIPLIER` = 10 se aplica al recoger almas.
- **Almas:** `SoulGem` cambia de color a 10 y a 50, como las gemas dorada y roja de Megabonk.

### Verificación de la segunda iteración
`megabonk_test` también comprueba:
- 1 + 1,2 + 1,4 proyectiles disparan 3;
- la carta "+1,2 …";
- el libro de daño vale 8 % × rareza a nivel 1 y a nivel 30;
- 4 y 4 huecos;
- el nivel 2 cuesta 3 de experiencia;
- la experiencia tiene tope ×10.

Siguen pasando las pruebas de destierro, calderos y atascos, y `features_test`. Una captura muestra el HUD con 4 armas y 4 pergaminos.
