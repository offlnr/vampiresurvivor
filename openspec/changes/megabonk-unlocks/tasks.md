# Tasks

## 1. Progreso (specs/unlocks)

- [x] 1.1 Crear `Unlocks.ENTRIES` con 5 armas, 10 pergaminos y 5 objetos, cada uno con su desafío y su precio
- [x] 1.2 Crear el autoload `Progress` (plata, desbloqueos, estadísticas, `record_run()`, `buy()`, guardado en `user://progress.cfg`)
- [x] 1.3 Añadir el pergamino de plata (`Stat.SILVER`) y `Player.silver_multiplier`

## 2. Partida (specs/unlocks)

- [x] 2.1 Construir `weapon_pool`, `scroll_pool` e `item_pool` y usarlos en las cartas, el caos, los cofres y el comerciante
- [x] 2.2 Contar cofres, objetos comprados, experiencia y tiempo sin daño; guardar la partida al morir y al abandonar
- [x] 2.3 Mostrar en el fin de partida la plata ganada y los desafíos cumplidos

## 3. Menús (specs/unlocks)

- [x] 3.1 Crear `UnlocksMenu` (plata, secciones, desafío, progreso y compra) y el botón "Desbloqueos" en la pantalla de título
- [x] 3.2 Mostrar en la pantalla de título la plata y los desbloqueos disponibles
- [x] 3.3 Añadir "+100 plata" al panel de depuración

## 4. Verificación

- [x] 4.1 Prueba headless de filtrado, fin de partida, compra, guardado y menú; capturas a 1280×720
- [ ] 4.2 Jugar varias partidas desde cero y ajustar la plata por partida y los precios si el ritmo de desbloqueo es muy lento o muy rápido
- [ ] 4.3 Comprobar el menú de desbloqueos en vertical (móvil) y con mando
