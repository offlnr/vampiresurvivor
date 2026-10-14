# Spec Delta

## Purpose

Define en qué plataformas se puede jugar (navegador de PC, navegador móvil y Android), qué rendimiento se espera en cada una y cómo se adapta el juego a pantallas y entradas distintas.

## ADDED Requirements

### Requirement: Build web jugable en navegador de PC
El proyecto SHALL poder exportarse a una build web que se juega en las versiones actuales de Chrome, Firefox, Edge y Safari de escritorio, sin instalar nada.

#### Scenario: Abrir en navegador
- **WHEN** se sirve la build web desde un servidor HTTP y se abre su URL en Chrome de escritorio
- **THEN** el juego carga, muestra el menú principal y se puede jugar una partida completa con teclado

#### Scenario: Audio en web
- **WHEN** el jugador hace su primer clic o toque en la página
- **THEN** el audio empieza a sonar, cumpliendo la política de reproducción automática del navegador

### Requirement: Build Android
El proyecto SHALL poder exportarse a un APK para Android 8.0 o superior, instalable y jugable con controles táctiles.

#### Scenario: Instalar y jugar
- **WHEN** se instala el APK en un teléfono Android compatible
- **THEN** el juego arranca a pantalla completa y se puede jugar una partida completa con el joystick táctil

### Requirement: Navegador móvil
La build web SHALL poder jugarse en el navegador de un móvil, con controles táctiles.

#### Scenario: Jugar en Chrome Android
- **WHEN** se abre la URL de la build web en Chrome para Android
- **THEN** aparece el joystick táctil al tocar la pantalla y la partida se puede jugar

### Requirement: Rendimiento objetivo
El juego SHALL mantener un mínimo de 60 FPS en PC y de 30 FPS en un móvil Android de gama media, con 200 enemigos en pantalla a la vez.

#### Scenario: Horda máxima en móvil
- **WHEN** hay 200 enemigos activos en un móvil Android de gama media
- **THEN** el juego mantiene una media de 30 FPS o más durante al menos 1 minuto

### Requirement: Adaptación de pantalla
El juego SHALL adaptarse a cualquier relación de aspecto y orientación sin deformar la imagen. Además MUST mostrar al menos la misma área de mundo alrededor del jugador en todas las pantallas habituales.

#### Scenario: Cambio de tamaño de ventana
- **WHEN** el jugador cambia el tamaño de la ventana del navegador en PC
- **THEN** el juego se reescala sin deformarse y el HUD se recoloca

#### Scenario: Rotar el móvil
- **WHEN** el jugador gira el móvil de vertical a horizontal
- **THEN** la vista se adapta y la partida sigue sin reiniciarse

### Requirement: Controles según el dispositivo
El juego SHALL mostrar los controles táctiles solo cuando se usa una pantalla táctil, y MUST ocultarlos al jugar con teclado o mando.

#### Scenario: PC con teclado
- **WHEN** el jugador juega en PC con teclado
- **THEN** no aparece ningún joystick táctil ni botones táctiles innecesarios
