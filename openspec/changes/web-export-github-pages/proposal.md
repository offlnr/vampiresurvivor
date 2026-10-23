# Proposal

## Why

El jugador quiere poder jugar desde una página web, sin instalar nada. La spec `platform-builds` ya pedía una build web, pero el proyecto solo tenía presets de exportación para Windows y Android, y no había ningún sitio público donde jugarla.

## What Changes

- **Preset de exportación "Web"** en `export_presets.cfg`:
  - salida en `builds/web/index.html`;
  - sin soporte de hilos, para que funcione en cualquier hosting sin cabeceras COOP/COEP;
  - compresión de texturas solo para escritorio;
  - excluye las partes del plugin de AdMob que no sirven en web (`csharp/`, `docs/`, `skills/`).
- **Publicación en GitHub Pages**: la build exportada se sube a la rama `gh-pages` del repositorio, separada del código fuente de `main`.
- **Anuncios**: no cambian. `Ads` ya oculta los botones de anuncio en builds release fuera de Android.

**Fuera de alcance:**
- versión PWA instalable;
- build web con hilos;
- anuncios en web.

## Capabilities

### New Capabilities
<!-- Ninguna. -->

### Modified Capabilities
- `platform-builds`: "Build web jugable en navegador de PC" (preset de exportación y publicación en GitHub Pages).

## Impact

- **Configuración**: `export_presets.cfg` (preset 2, "Web").
- **Plantillas**: hacen falta las plantillas web de Godot 4.7.2 (`web_nothreads_release.zip` y `web_nothreads_debug.zip`).
- **Repositorio**: rama `gh-pages` con la build (unos 54 MB, de los que el `.wasm` ocupa 39 MB). `builds/` sigue ignorada en `main`.
