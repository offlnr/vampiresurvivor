# Design

## Context

- `ProjectileWeapon` lanzaba siempre `pumpkin_projectile.tscn`, con la escena fijada en una constante.
- `pumpkin_projectile.gd` ya es genérico (daño, perforación, alcance y tamaño los lee del arma); solo el giro estaba fijado.
- Los pergaminos (`UpgradeData`) son todos porcentajes: `amount_per_level × multiplicador de rareza × upgrade_scale()`, y ese cálculo estaba repetido en tres sitios de `run.gd`.
- La cantidad de una arma la leen en cada ataque el proyectil, el hueso y el fuego fatuo. Los murciélagos y la guadaña, en cambio, crean sus sprites en `_on_level_changed()`, y la guadaña indexa `_slashes[i]` hasta la cantidad actual.

## Goals / Non-Goals

**Goals:**
- Una arma nueva solo con datos y escenas, reutilizando el código de proyectil.
- Que el pergamino de cantidad afecte también a las armas que se consigan después de cogerlo.

**Non-Goals:**
- Un sistema genérico de stats globales del jugador para todas las estadísticas de arma.

## Decisions

> **Sustituido en parte por `megabonk-progression`:** el pergamino de multiplicidad ya no da +1…+5, sino +1 / 1,2 / 1,4 / 1,6 / 2 con decimales, como las cantidades de Megabonk. El resto de este cambio (orbe, calabaza, `extra_amount`) sigue vigente.

### 1. El orbe reutiliza `ProjectileWeapon`
`ProjectileWeapon` exporta `projectile_scene`, con la calabaza por defecto, para que la calabaza no cambie. `magic_orb_weapon.tscn` es el mismo script con `projectile_scene = magic_orb_projectile.tscn`. El proyectil del orbe usa `pumpkin_projectile.gd` con `spin_speed = 4` (la calabaza, 9) y un hijo `Glow` (`puff.svg` teñido de morado) detrás del sprite.
- **Alternativa**: un script de arma propio. Descartada: el comportamiento es idéntico.

### 2. Estadísticas del orbe
Más rápido y ligero que la calabaza, para que se note la diferencia al cogerla: 11 de daño (calabaza 12), recarga 0,85 s (1), velocidad 520 (430), alcance 440 (420), tamaño 30 (34). Mejora las mismas estadísticas y con los mismos valores que la calabaza. El daño es 11 y no 10 para cumplir el escenario "Inicio tranquilo" del MVP: un zombi (22 de vida) muere con 2 disparos del arma inicial.

### 3. Pergamino de cantidad
`UpgradeData.Stat.AMOUNT` va al final del enum, porque los `.tres` guardan el índice. `UpgradeData.roll_amount(rarity, strength)` centraliza el valor de un pergamino:
- en los porcentajes, igual que antes;
- en las cantidades, `amount_per_level × (rareza + 1)`, sin `strength`.

Así, con 1 por nivel, da +1, +2, +3, +4 y +5. Como la mejora "+1 proyectil" de las armas, no escala con el nivel. `describe()` muestra un entero en vez de un porcentaje.
- **Descartado**: los factores de las mejoras de arma (`WeaponData.RARITY_FACTORS`, redondeados). Daban +1, +1, +1, +2 y +2, así que una carta épica y una legendaria daban lo mismo y la rareza no se notaba (lo detectó el jugador en partida).
- **Descartado**: los multiplicadores de los demás pergaminos (×1; 1,5; 2; 3; 4). Al redondear siempre repiten un valor entre dos rarezas.
- **Equilibrio**: de media, un pergamino da +1,6 proyectiles (60 % ×1, 25 % ×2, 10 % ×3, 4 % ×4, 1 % ×5, sin contar la suerte).

### 4. Bono global en el jugador
`Player.extra_amount` (entero) se suma en `Weapon.stat(&"amount")`, así que lo reciben también las armas nuevas. Al coger el pergamino, `run.gd` llama a `Weapon.refresh()` en todas las armas, que vuelve a ejecutar `_on_level_changed()`. Sin eso, la guadaña intentaría usar un corte que aún no ha creado. La niebla no tiene cantidad y no se ve afectada.

## Risks / Trade-offs

- [Murciélagos y guadaña con varios proyectiles extra pueden quedar muy fuertes] → Probar en partida; si hace falta, bajar sus valores de cantidad o el peso del pergamino.
- [El orbe y la calabaza se parecen] → Diferencia de ritmo y daño (Decisión 2); si se quiere más, dar a la calabaza perforación o explosión en otro cambio.
