# Design

## Context

Godot 4.7 exporta a web con WebAssembly y WebGL 2. El proyecto ya usa el renderizador GL Compatibility, que es el único válido para web, así que no hace falta tocar nada del juego.

## Decisions

### Sin hilos
La variante con hilos necesita `SharedArrayBuffer`, y eso obliga a servir la página con las cabeceras `Cross-Origin-Opener-Policy` y `Cross-Origin-Embedder-Policy`. GitHub Pages no permite configurar cabeceras, así que se usa la variante sin hilos. A cambio, el audio puede tener algo más de latencia.

### Rama `gh-pages` en lugar de carpeta `docs/`
La build pesa unos 54 MB y cambia entera en cada exportación. Si estuviera en `main`, cada nueva versión inflaría el historial del código. En una rama aparte se puede reescribir sin afectar a `main`.

### Exclusiones de AdMob
Las carpetas `csharp/`, `docs/` y `skills/` del plugin no se usan en el juego. Los scripts GDScript del plugin sí se incluyen, porque `Ads` los referencia, aunque en web no llega a cargar el plugin nativo.

## Risks

- **Tamaño de la descarga**: unos 54 MB en la primera carga. GitHub Pages sirve los archivos comprimidos, lo que reduce bastante el `.wasm`.
- **Audio**: no suena hasta el primer clic o tecla, por la política de reproducción automática de los navegadores.
