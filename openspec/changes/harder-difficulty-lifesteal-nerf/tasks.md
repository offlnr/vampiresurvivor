# Tasks

## 1. Dificultad (specs/enemy-waves)

- [x] 1.1 Subir en `noche.tres` el ritmo, el máximo de enemigos y la vida de cada tramo según la tabla del design, manteniendo la vida y la velocidad del primer tramo
- [x] 1.2 Subir `DAMAGE_GROWTH_PER_MINUTE` de 0,05 a 0,08 y el tamaño de las tres hordas

## 2. Robo de vida (specs/run-progression)

- [x] 2.1 Llamar al robo de vida solo con daño de arma y con `min(daño, vida del enemigo)` en `EnemyManager.damage()`
- [x] 2.2 Añadir el tope del 2 % de vida máxima por segundo en `Player` (`LIFESTEAL_CAP_PER_SECOND` y `_lifesteal_budget`)

## 3. Verificación

- [ ] 3.1 En Godot, verificar los escenarios "Inicio tranquilo", "Enemigos lentos al principio" y "Presión desde el minuto 1" (con el panel de depuración: +1 min y contador de enemigos) (el escenario "Presión desde el minuto 1" queda sustituido por "Más fuertes al subir de nivel" de `level-difficulty-cauldrons`)
- [ ] 3.2 Verificar los escenarios "Curarse atacando", "Sin daño sobrante", "Daño de objetos" y "Tope por segundo"
- [ ] 3.3 Jugar varias partidas completas y ajustar la tabla si el minuto 3–5 resulta imposible o sigue siendo fácil
