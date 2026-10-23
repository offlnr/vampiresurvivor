# Tasks

## 1. Dificultad por nivel (specs/enemy-waves)

- [x] 1.1 Pasar la vida y el daño de los enemigos al nivel del jugador (`player_level`, `LEVEL_HEALTH_GROWTH`, `LEVEL_DAMAGE_GROWTH`), quitar `DAMAGE_GROWTH_PER_MINUTE` y el `health_multiplier` de la tabla de oleadas; verificar con prueba headless los escenarios "Inicio tranquilo", "Más fuertes al subir de nivel" y "El tiempo solo no los hace más fuertes"

## 2. Calderos (specs/map-cauldrons, specs/minimap)

- [x] 2.1 Dibujar `cauldron.svg` y comprobarlo renderizado junto al cofre de pago
- [x] 2.2 Crear `Cauldrons` (aparición, recolocación, progreso de 1,5 s con anillo) y añadirlo a la partida; verificar con prueba headless los escenarios "Aparecen los calderos", "Siempre hay calderos" y que no se activa a los 0,5 s
- [x] 2.3 Aplicar el efecto (`EnemyManager.difficulty`, experiencia, `Player.gold_bonus`), el aviso y el indicador del HUD; verificar con prueba headless el escenario "Un caldero"
- [x] 2.4 Marcar los calderos en verde en el minimapa y añadir el botón "Caldero" al panel de depuración

## 3. Destierro (specs/run-progression)

- [x] 3.1 Comprobar con prueba headless (40 subidas de nivel) que las cartas de nivel nunca vuelven a ofrecer algo desterrado; verificar "Desterrar" y "Desterrar un arma"
- [x] 3.2 Quitar la carta si no hay sustituto, purgar al comerciante al abrir la tienda y buscar en rarezas superiores si no queda nada; verificar con prueba headless "Desterrar sin sustituto", "Comerciante que llegó antes" y "Cofre con comunes desterrados"
- [x] 3.3 Que `ShopMenu` no rompa con una lista vacía en modo cofre

## 4. Verificación jugando

- [ ] 4.1 Con capturas, comprobar los calderos en el mapa y en el minimapa, el anillo de progreso, el aviso y el indicador "+N %" del HUD, en horizontal y en vertical
- [ ] 4.2 Jugar varias partidas y ajustar `LEVEL_HEALTH_GROWTH`/`LEVEL_DAMAGE_GROWTH` si la curva por nivel es demasiado dura o blanda; comprobar que el pergamino de experiencia sigue mereciendo la pena

## 5. Segunda iteración

- [x] 5.1 Que haya 6 calderos desde el inicio de la partida (antes, 3 desde el segundo 30), fuera de la pantalla inicial y separados al menos 450 entre sí; verificar con prueba headless (30 partidas) los escenarios "Aparecen los calderos" y "Calderos repartidos"
