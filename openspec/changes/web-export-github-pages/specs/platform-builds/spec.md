# Spec Delta

## MODIFIED Requirements

### Requirement: Build web jugable en navegador de PC
El proyecto SHALL poder exportarse a una build web que se juega en las versiones actuales de Chrome, Firefox, Edge y Safari de escritorio, sin instalar nada. La build MUST usar la variante sin hilos, para poder servirse desde cualquier hosting estático sin cabeceras especiales, y SHALL publicarse en GitHub Pages desde la rama `gh-pages`.

#### Scenario: Abrir en navegador
- **WHEN** se sirve la build web desde un servidor HTTP y se abre su URL en Chrome de escritorio
- **THEN** el juego carga, muestra el menú principal y se puede jugar una partida completa con teclado

#### Scenario: Audio en web
- **WHEN** el jugador hace su primer clic o toque en la página
- **THEN** el audio empieza a sonar, cumpliendo la política de reproducción automática del navegador

#### Scenario: Exportar desde línea de comandos
- **WHEN** se ejecuta `godot --headless --path . --export-release "Web" builds/web/index.html`
- **THEN** se generan `index.html`, `index.js`, `index.wasm` e `index.pck` en `builds/web/`

#### Scenario: Jugar desde GitHub Pages
- **WHEN** se abre la URL de GitHub Pages del repositorio
- **THEN** se carga la build web publicada en la rama `gh-pages`, sin cabeceras especiales
