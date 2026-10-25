# Tasks

## 1. Predicción (specs/online-coop)

- [x] 1.1 `NetHost`: número de la última entrada, `self_unit`, `speed` y `moving` en la cabecera
- [x] 1.2 `NetGuest`: entradas numeradas, movimiento local, `_predict()` con corrección suave y salto si la diferencia es grande
- [x] 1.3 Proxy del propio personaje y cámara en la posición prevista; sin predicción con la partida parada o el invitado caído

## 2. Verificación

- [x] 2.1 Prueba con anfitrión e invitado reales y un servidor de salas con 120 ms de retraso en cada sentido: el personaje del invitado reacciona a los 19 ms (antes 329 ms), va 52 px por delante de la posición del anfitrión mientras corre y, al soltar, acaba a 0 px de ella
- [x] 2.2 Volver a pasar la prueba de cooperativo (menús, tienda, cofres, santuario) con 60 ms de retraso
- [ ] 2.3 Probarlo jugando entre dos ordenadores a través de Render
