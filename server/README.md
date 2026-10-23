# Servidor de salas (multijugador online)

Pequeño servidor Node.js que une a dos jugadores de *Noche de Almas* con un código de sala y reenvía sus mensajes. No ejecuta el juego: la partida corre entera en el dispositivo del anfitrión (ver `scenes/main/net_host.gd`).

## Probar en local

```
cd server
npm install
npm start          # escucha en ws://localhost:8080 (o en el puerto de la variable PORT)
```

En el juego: **Multijugador online**, deja el servidor en `ws://localhost:8080`, crea una sala en una ventana y únete con el código en otra.

## Publicarlo (Render, gratis)

1. En [render.com](https://render.com): **New → Blueprint** y elige este repositorio. Usa `render.yaml`, en la raíz.
2. Cuando termine, Render da una dirección como `https://noche-de-almas-relay.onrender.com`.
3. En el juego, el servidor es esa dirección con `wss://`: `wss://noche-de-almas-relay.onrender.com`.
   - Para que venga puesta por defecto, cámbiala en `DEFAULT_SERVER` (`autoload/net.gd`) y vuelve a exportar.
   - Cada jugador también puede escribirla en el campo **Servidor** de la pantalla de multijugador; se guarda.

La build web (GitHub Pages, `https://`) solo puede conectarse a servidores `wss://`, salvo `ws://localhost`.

El plan gratuito se duerme tras 15 minutos sin uso: la primera conexión después puede tardar hasta un minuto.

## Protocolo

- Mensajes de texto (JSON) del cliente: `{"t":"host"}`, `{"t":"join","code":"ABCD"}`, `{"t":"leave"}`.
- Respuestas: `{"t":"room","code"}`, `{"t":"joined","code"}`, `{"t":"peer_joined"}`, `{"t":"peer_left"}`, `{"t":"error","msg"}`.
- Los mensajes binarios se reenvían tal cual al otro jugador de la sala.
