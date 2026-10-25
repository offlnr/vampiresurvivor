# Tasks

## 1. Personajes (specs/characters)

- [x] 1.1 `CharacterData`, `Characters` y los 6 `.tres` de `data/characters/`
- [x] 1.2 Arte de 5 personajes nuevos (2 fotogramas quieto y 4 andando) y sus `frames.tres`; la Bruja usa el suyo
- [x] 1.3 `Player.set_frames()` y `run.gd` `_start_character()`: aspecto, arma inicial (también en la reserva si está bloqueada) y ventaja con `_apply_stat()`
- [x] 1.4 `Progress.character` guardado
- [x] 1.5 Verificar con prueba headless: cada personaje empieza con su arma, su aspecto y su ventaja

## 2. Pantalla de selección (specs/characters, specs/run-session)

- [x] 2.1 `CharacterSelect`: tarjetas con el personaje animado, arma, ventaja y frase; recuerda el último; Volver y Escape
- [x] 2.2 "Jugar" abre la selección en el menú principal
- [x] 2.3 Captura de la pantalla a 1280×720

## 3. Cooperativo (specs/online-coop)

- [x] 3.1 Botón "Personaje: …" en la pantalla de sala
- [x] 3.2 `MSG_CHARACTER` al unirse y al cambiar; `Net.guest_character` en el anfitrión
- [x] 3.3 Asiento del invitado con su personaje; azulado solo si coincide con el del anfitrión
- [x] 3.4 Verificar con anfitrión e invitado reales y servidor local: el invitado juega con el Fantasmita y su rayo, y el santuario que carga abre su menú en su pantalla

## 4. Santuarios e imanes (specs/map-shrines, specs/minimap)

- [x] 4.1 `Shrines`: santuarios de poder e imanes, con carga, círculo en el suelo (`draw_ops()`), reaparición y recolocación
- [x] 4.2 Arte: `shrine.svg` y `magnet_totem.svg`
- [x] 4.3 `run.gd`: elecciones pendientes con tipo, ofertas `&"stat"` del santuario (tirar y saltar, sin desterrar) e imán con `attract_all()`
- [x] 4.4 Minimapa, y botones "Santuario" e "Imán" en el panel de depuración
- [x] 4.5 Verificar con prueba headless: santuario por depuración y en el mapa (4 s de pie), tirada, sin destierro, sin hueco de pergamino, imán (1 s, atrae 30 almas lejanas), cofre, subida de nivel y saltar
- [x] 4.6 Capturas del santuario cargando, el imán y el menú "Santuario de poder"
- [x] 4.7 Volver a pasar la prueba de solitario

## 5. Verificación jugando

- [ ] 5.1 Ajustar jugando la reaparición y la carga de los santuarios si las estadísticas suben demasiado
- [ ] 5.2 Revisar jugando el equilibrio entre personajes
