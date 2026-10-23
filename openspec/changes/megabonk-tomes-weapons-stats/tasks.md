# Tasks

## 1. Cantidades enteras (specs/run-progression, specs/auto-weapons)

- [x] 1.1 Redondear `amount` y `pierce` en `UpgradeData.roll_amount()` y `WeaponData.upgrade_value()`, pasar `Player.extra_amount` a `int` y hacer que `count_text()` escriba enteros

## 2. Pergaminos nuevos (specs/run-progression)

- [x] 2.1 Añadir 11 estadísticas al final de `UpgradeData.Stat` y `percent` para valores planos
- [x] 2.2 Implementar en `Player` la regeneración, el escudo (con barra y recarga), la evasión y las espinas
- [x] 2.3 Implementar el crítico, la velocidad de proyectil, la duración y el empuje en `Inventory`, `Weapon` y `EnemyManager`
- [x] 2.4 Implementar el maldito (`_update_difficulty()`) y el caos (`_chaos_tick()` y `hud.show_chaos()`) en `run.gd`
- [x] 2.5 Crear los 11 `.tres` y sus iconos

## 3. Armas nuevas (specs/auto-weapons)

- [x] 3.1 Rayo espectral: `chain_weapon.gd`/`.tscn`, `rayo.tres`, `lightning.svg`
- [x] 3.2 Rastro de brasas: `trail_weapon.gd`/`.tscn`, `brasas.tres`, `embers.svg`
- [x] 3.3 Vórtice de almas: `vortex_weapon.gd`/`.tscn`, `vortice.tres`, `vortex.svg`
- [x] 3.4 Trabuco de plata: `spread_weapon.gd`/`.tscn`, `silver_pellet.tscn`, `trabuco.tres`, `blunderbuss.svg`, `silver_pellet.svg`

## 4. Panel de estadísticas (specs/upgrade-menus)

- [x] 4.1 Crear `StatsPanel` y `run.stats_sections()`
- [x] 4.2 Añadir "Estadísticas" al menú de subida de nivel y a la tienda o cofre

## 5. Verificación

- [x] 5.1 Prueba headless de cantidades, pergaminos, armas y panel; capturas a 1280×720
- [ ] 5.2 Jugar partidas con cada arma nueva y ajustar daño o recarga si alguna destaca demasiado
- [ ] 5.3 Comprobar el panel en vertical (móvil) y con mando

## 6. Sonidos de las armas nuevas

- [x] 6.1 Buscar sonidos con licencia de uso comercial que encajen con la temática:
  - rayo: Electricity Game Sound Pack, CC0;
  - vórtice: Teleport spell, CC0;
  - trabuco: gunshot sounds, CC-BY 3.0;
  - brasas: Fire Crackling, CC0.
- [x] 6.2 Recortarlos, mezclarlos y filtrarlos a mono, 22 050 Hz y 16 bits con picos de 0,45–0,6 como el resto. Ponerlos en `art/sfx/` y acreditarlos en `CREDITS.md`
- [x] 6.3 Registrarlos en `Audio` y usarlos en cada arma. Las brasas crepitan como mucho cada ~1,4 s
- [ ] 6.4 Escucharlos en partida y ajustar volumen o tono

## 7. Destierro y caos

- [x] 7.1 Que el caos no elija pergaminos desterrados: un destierro vale para toda la partida, también para el caos. Comprobado con 400 subidas de nivel con caos y la regeneración desterrada
