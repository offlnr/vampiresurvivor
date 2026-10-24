# Tasks

## 1. Servidor de salas (specs/online-coop)

- [x] 1.1 `server/relay.js`: salas con código de 4 caracteres, reenvío binario, avisos de entrada y salida, ping y cierre de conexiones mudas
- [x] 1.2 `render.yaml` y `server/README.md` con cómo probarlo en local y publicarlo en Render
- [x] 1.3 Publicar el servidor en Render (`https://noche-de-almas-relay.onrender.com`) y poner su dirección `wss://` en `DEFAULT_SERVER` (`autoload/net.gd`)
- [x] 1.4 Verificar con anfitrión e invitado reales (headless) a través del servidor de Render: sala, subida de nivel, compras y cofres
- [x] 1.5 Exportar el ejecutable de Windows con el servidor por defecto y comprobar que arranca sin errores

## 2. Conexión y sala (specs/online-coop, specs/run-session)

- [x] 2.1 Autoload `Net`: conexión WebSocket, crear y unirse a sala, mensajes, desconexión y servidor configurable guardado en `user://net.cfg`
- [x] 2.2 Pantalla "Multijugador online" en el menú principal
- [x] 2.3 Verificar con prueba headless a través de los botones reales: código corto, código inexistente, unirse y empezar los dos

## 3. Réplica al invitado (specs/online-coop)

- [x] 3.1 `NetDraw` y `draw_ops()` en los cinco `_draw()` del juego
- [x] 3.2 `NetHost`: recorrido del mundo, unidades por y-sort y z, recursos por id, recorte por vista, cabecera con HUD, sonidos y avisos, compresión
- [x] 3.3 `NetGuest`: proxies con interpolación, decoraciones con la semilla del anfitrión, cámara, HUD, avisos de estado, sonidos y fin de partida
- [x] 3.4 Verificar con anfitrión e invitado reales y servidor local: el invitado mueve su personaje, la cámara le sigue, se resuelven todas las texturas y se ve en capturas

## 4. Reglas del cooperativo (specs/online-coop)

- [x] 4.1 Segundo jugador con entrada remota
- [x] 4.2 Enemigos: perseguir al más cercano, aparecer junto a cualquiera, explosiones y pociones contra los dos, `coop_health`
- [x] 4.3 Almas, monedas, cofres y power-ups para el jugador vivo más cercano; power-ups para los dos
- [x] 4.4 Caer y revivir en la subida de nivel; fin cuando caen los dos
- [x] 4.5 Reintentar del anfitrión para los dos; salida del anfitrión y del invitado; sin pausa automática online
- [x] 4.6 Verificar con prueba headless: cae el invitado, revive al subir de nivel, caen los dos, reintentar y salida del anfitrión
- [x] 4.7 Verificar que la partida en solitario sigue igual (prueba headless con mejoras, pergaminos, power-ups y muerte)
- [x] 4.8 `Seat`: estado de cada jugador (armas, pergaminos, objetos, oro, tiradas, destierros, saltos, desbloqueos, menú) y `run.gd` reorganizado en torno a él
- [x] 4.9 Menús del invitado: subida de nivel y tienda en su pantalla (`MSG_MENU`, `MSG_ACTION`), con validación en el anfitrión y pausa hasta que todos cierran
- [x] 4.10 Compras individuales: comerciante para los dos, cofres de pago y de élite para quien los toca, oro propio
- [x] 4.11 Daño atribuido a quien golpea en todas las armas, objetos y espinas
- [x] 4.12 Más dificultad en cooperativo: `coop_health` 1,8, `coop_count` 1,35 y experiencia por nivel × 1,5
- [x] 4.13 Desbloqueos del invitado enviados al unirse (`MSG_UNLOCKS`)
- [x] 4.14 Verificar con prueba headless: menús separados en la subida de nivel, espera al compañero, compra del invitado, comerciante para los dos, cofre de pago y cofre de élite del invitado, tirada en el menú del invitado y capturas de sus menús
- [x] 4.15 Volver a pasar las pruebas de solitario, caídas, reintentar, salida y sala con el código nuevo

## 5. Verificación jugando

- [ ] 5.1 Jugar una partida completa entre dos ordenadores a través del servidor publicado y comprobar la latencia del personaje del invitado
- [ ] 5.2 Probar el invitado en la build web y en un móvil (joystick táctil)
- [ ] 5.3 Medir el rendimiento del anfitrión con 400 enemigos en un móvil de gama media
- [ ] 5.4 Ajustar jugando la dificultad del cooperativo (`COOP_ENEMY_HEALTH`, `COOP_ENEMY_COUNT`, `COOP_XP_NEEDED`)
