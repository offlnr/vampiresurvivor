# Proposal

## Why

El proyecto Godot está vacío y queremos un primer juego jugable estilo *Vampire Survivors* (auto-ataque, hordas, subir de nivel eligiendo mejoras) con temática de Halloween, que funcione en móvil y en el navegador de PC. Como aún no hay estilo visual ni assets definidos, este cambio construye un MVP con arte provisional (placeholder) fácil de reemplazar, para validar que el juego es divertido antes de invertir en arte.

## What Changes

- Escena de partida (*run*) con un personaje que se mueve con teclado (PC) o joystick virtual táctil (móvil) y una cámara que lo sigue.
- Armas que atacan automáticamente: el MVP incluye 3 armas temáticas (p. ej. calabaza lanzada, murciélagos orbitales, aura de niebla) con niveles de mejora.
- Enemigos de Halloween (p. ej. murciélago, zombi, fantasma) que aparecen en oleadas crecientes alrededor del jugador y lo persiguen.
- Progresión dentro de la partida: los enemigos sueltan "almas"/gemas de experiencia; al subir de nivel se pausa y se elige 1 de 3 mejoras.
- Ciclo de partida: menú principal → partida con temporizador (objetivo: sobrevivir 10 minutos) → pantalla de derrota o victoria → reintentar. HUD con vida, nivel/XP, tiempo y muertes. Pausa.
- Arte y audio provisionales con paleta de Halloween (naranja, morado, verde, negro), organizados para poder cambiarlos sin tocar la lógica.
- Exportación a Web (HTML5, jugable en navegador de PC y móvil) y Android. iOS queda preparado pero fuera del alcance de este cambio.

**Fuera de alcance:** progresión entre partidas (tienda, desbloqueos permanentes), varios personajes, varios mapas, jefes, guardado en la nube, monetización, arte final, publicación en tiendas.

## Capabilities

### New Capabilities
- `player-control`: movimiento del jugador con teclado y joystick táctil, cámara y vida del jugador.
- `auto-weapons`: armas que atacan solas, su daño, cadencia y niveles de mejora.
- `enemy-waves`: tipos de enemigos, comportamiento de persecución y aparición por oleadas que escala con el tiempo.
- `run-progression`: experiencia, subida de nivel y selección de mejoras durante la partida.
- `run-session`: ciclo de la partida (menú, temporizador, pausa, derrota, victoria, reintento) y HUD.
- `halloween-presentation`: identidad visual/sonora provisional con temática de Halloween y estructura de assets reemplazables.
- `platform-builds`: presets de exportación Web y Android, y adaptación a distintas pantallas y entradas.

### Modified Capabilities
<!-- Ninguna: no existen specs previas en el proyecto. -->

## Impact

- **Proyecto Godot 4.7**: se añaden escenas, scripts GDScript y recursos bajo `res://`. Se modifica `project.godot` (escena principal, acciones de entrada, renderer y ajustes de ventana).
- **Renderer**: hay que pasar de `mobile` a `gl_compatibility` para que la exportación Web funcione (ver design.md).
- **Dependencias**: plantillas de exportación de Godot 4.7; SDK de Android/JDK para el build de Android. Sin plugins de terceros.
- **Rendimiento**: con cientos de enemigos en pantalla en móviles de gama media y en navegador, el rendimiento condiciona varias decisiones técnicas.
