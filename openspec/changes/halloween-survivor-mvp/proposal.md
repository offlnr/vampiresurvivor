# Proposal

## Why

El proyecto Godot está vacío y queremos un primer juego jugable estilo *Vampire Survivors* (auto-ataque, hordas, subir de nivel eligiendo mejoras) con temática de Halloween, que funcione en móvil y en el navegador de PC. Como aún no hay estilo visual ni assets definidos, este cambio construye un MVP con arte provisional (placeholder) fácil de reemplazar, para validar que el juego es divertido antes de invertir en arte.

## What Changes

- Escena de partida (*run*) con un personaje que se mueve con teclado (PC) o joystick virtual táctil (móvil) y una cámara que lo sigue.
- Armas que atacan automáticamente: el MVP incluye 6 armas temáticas (calabaza lanzada, murciélagos orbitales, aura de niebla, guadaña, hueso bumerán y fuego fatuo) con niveles de mejora. Se pueden llevar 3 a la vez.
- Enemigos de Halloween (p. ej. murciélago, zombi, fantasma) que aparecen en oleadas crecientes alrededor del jugador y lo persiguen.
- Hordas periódicas: cada minuto se anuncia y llega una horda especial (anillo de zombis, enjambre de murciélagos o carga de fantasmas) acompañada de un enemigo élite que suelta un cofre.
- Progresión dentro de la partida: los enemigos sueltan "almas"/gemas de experiencia; al subir de nivel se pausa y se elige 1 de 3 mejoras. Cada mejora tiene una rareza (común, poco común, rara, épica, legendaria) que multiplica su efecto, y la suerte del jugador sube la probabilidad de rarezas altas. Hay pasivas de vida, velocidad, imán, recarga, daño, suerte, robo de vida, armadura y área.
- Ciclo de partida: menú principal → partida infinita con temporizador (objetivo: aguantar el máximo tiempo posible, con récord guardado) → pantalla de fin al morir → reintentar. HUD con vida, nivel/XP, tiempo y muertes. Pausa.
- Arte y audio provisionales con paleta de Halloween (naranja, morado, verde, negro), con animaciones por fotogramas y buen contraste de los enemigos sobre el fondo, organizados para poder cambiarlos sin tocar la lógica.
- Exportación a Web (HTML5, jugable en navegador de PC y móvil) y Android. iOS queda preparado pero fuera del alcance de este cambio.

**Fuera de alcance:** progresión entre partidas (tienda, desbloqueos permanentes), varios personajes, varios mapas, jefes con patrones de ataque propios (los élites de las hordas solo son enemigos más grandes y resistentes), guardado en la nube, monetización, arte final, publicación en tiendas.

## Capabilities

### New Capabilities
- `player-control`: movimiento del jugador con teclado y joystick táctil, cámara y vida del jugador.
- `auto-weapons`: armas que atacan solas, su daño, cadencia y niveles de mejora.
- `enemy-waves`: tipos de enemigos, comportamiento de persecución, aparición por oleadas que escala con el tiempo, hordas periódicas y enemigos élite.
- `run-progression`: experiencia, subida de nivel, selección de mejoras con rareza, suerte y estadísticas pasivas del jugador durante la partida.
- `run-session`: ciclo de la partida infinita (menú, temporizador, pausa, muerte, récord, reintento) y HUD.
- `halloween-presentation`: identidad visual/sonora provisional con temática de Halloween y estructura de assets reemplazables.
- `platform-builds`: presets de exportación Web y Android, y adaptación a distintas pantallas y entradas.

### Modified Capabilities
<!-- Ninguna: no existen specs previas en el proyecto. -->

## Impact

- **Proyecto Godot 4.7**: se añaden escenas, scripts GDScript y recursos bajo `res://`. Se modifica `project.godot` (escena principal, acciones de entrada, renderer y ajustes de ventana).
- **Renderer**: hay que pasar de `mobile` a `gl_compatibility` para que la exportación Web funcione (ver design.md).
- **Dependencias**: plantillas de exportación de Godot 4.7; SDK de Android/JDK para el build de Android. Sin plugins de terceros.
- **Rendimiento**: con cientos de enemigos en pantalla en móviles de gama media y en navegador, el rendimiento condiciona varias decisiones técnicas.
