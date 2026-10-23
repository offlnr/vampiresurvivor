# Tasks

## 1. Exportación (specs/platform-builds)

- [x] 1.1 Instalar las plantillas web sin hilos de Godot 4.7.2 (`web_nothreads_release.zip`, `web_nothreads_debug.zip`)
- [x] 1.2 Añadir el preset "Web" a `export_presets.cfg`
- [x] 1.3 Exportar en headless con `--export-release "Web"` y comprobar que se generan `index.html`, `.js`, `.wasm` y `.pck`
- [x] 1.4 Servir `builds/web/` con un servidor HTTP local y comprobar que todos los archivos responden con 200

## 2. Publicación

- [x] 2.1 Subir la build a la rama `gh-pages` del repositorio de GitHub
- [ ] 2.2 Activar GitHub Pages en el repositorio (Settings → Pages → rama `gh-pages`, carpeta raíz)

## 3. Verificación jugando

- [ ] 3.1 Abrir la URL de GitHub Pages en Chrome de escritorio, jugar una partida completa con teclado y comprobar que el audio arranca tras el primer clic
- [ ] 3.2 Probar en Firefox y en Chrome para Android
