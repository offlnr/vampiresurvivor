# Tasks

## 1. Base del proyecto

- [ ] 1.1 Inicializar git con el `.gitignore` existente y hacer un primer commit; verificar que `git status` sale limpio y que `.godot/` no está versionado
- [ ] 1.2 En `project.godot`: renderer `gl_compatibility`, viewport base 1280×720, `canvas_items` + `expand`; verificar que el proyecto abre en Godot 4.7 sin errores y que Project Settings muestra esos valores
- [ ] 1.3 Crear la estructura de carpetas de design.md §4 y un `CREDITS.md` vacío con su formato (asset, autor, origen, licencia); verificar que las carpetas aparecen en el FileSystem de Godot
- [ ] 1.4 Definir las capas de física con nombre (jugador, enemigos, ataques del jugador, recogibles) y las acciones del `InputMap` (`move_*` con WASD, flechas y stick izquierdo; `pause` con Esc, P y Start); verificar en Project Settings
- [ ] 1.5 Crear los autoloads `Events` (señales: enemy_killed, xp_collected, player_damaged, player_died, level_up, run_ended) y `Settings` (ConfigFile con buses `Music` y `SFX`); verificar que, tras cambiar un volumen y reiniciar, el valor se conserva en `user://settings.cfg`

## 2. Jugador y cámara (specs/player-control)

- [ ] 2.1 Crear `player.tscn` (CharacterBody2D, colisión separada del sprite, sprite SVG provisional) con movimiento en 8 direcciones normalizado mediante `Input.get_vector()`; verificar los escenarios de movimiento recto, diagonal y sin entrada
- [ ] 2.2 Añadir una Camera2D con suavizado y el zoom calculado para mostrar un área mínima de mundo; verificar en ventana 16:9, 9:16 y 4:3 que el área visible es parecida y la imagen no se deforma
- [ ] 2.3 Implementar la vida, el daño por contacto, la invulnerabilidad temporal con parpadeo y la muerte, que emite `Events.player_died`; verificar con un enemigo de prueba los escenarios de daño, invulnerabilidad y vida a cero
- [ ] 2.4 Crear `virtual_joystick.tscn` (aparece en el punto de contacto, zona muerta, inyecta las acciones `move_*`) y mostrar u ocultar los controles táctiles según la última entrada; verificar con la emulación táctil del editor y luego en un móvil: tocar y arrastrar, soltar, zona muerta y PC con teclado sin joystick
- [ ] 2.5 Verificar el movimiento con un mando conectado (stick izquierdo con zona muerta)

## 3. Mundo y presentación base (specs/halloween-presentation)

- [ ] 3.1 Crear la textura de suelo repetible (cementerio o campo nocturno) y un `Parallax2D` con `repeat_size`; verificar caminando 3 minutos en una dirección (con velocidad aumentada para la prueba) que no aparecen costuras ni huecos
- [ ] 3.2 Definir la paleta de Halloween como recurso o constantes compartidas y crear los SVG provisionales de jugador, murciélago, zombi, fantasma, calabaza y alma; verificar en escala de grises que los enemigos se distinguen por su forma
- [ ] 3.3 Generar con jsfxr los efectos provisionales (impacto, muerte de enemigo, recoger alma, subir de nivel, daño recibido) y añadir una música CC0 registrada en `CREDITS.md`; verificar que cada archivo importa sin errores y que `CREDITS.md` tiene sus entradas

## 4. Enemigos y oleadas (specs/enemy-waves)

- [ ] 4.1 Crear la clase `EnemyData` y los 3 `.tres` (murciélago, zombi, fantasma) con velocidad, vida, daño, radio de colisión, sprite y valor de XP; verificar que se pueden editar en el inspector
- [ ] 4.2 Crear `enemy.tscn` configurable por `EnemyData`, que persigue al jugador y colisiona solo con su capa; verificar el escenario "Seguir al jugador"
- [ ] 4.3 Implementar la rejilla espacial y la repulsión suave entre enemigos; verificar el escenario "Sin superposición total" con 100 enemigos rodeando al jugador
- [ ] 4.4 Implementar un pool genérico de objetos y usarlo para los enemigos; verificar con el debug overlay (5.4) que, tras matar a 500 enemigos, el número de instancias no pasa del tamaño del pool
- [ ] 4.5 Crear las clases `WaveTable`/`WaveEntry`, el `.tres` de los 10 minutos y el spawner: aparición fuera de pantalla, límite de vivos y recolocación de enemigos lejanos; verificar los escenarios "Punto de aparición", "Límite alcanzado" y "Jugador escapa"
- [ ] 4.6 Implementar la muerte del enemigo (efecto, sonido, emisión de `enemy_killed`, aparición del alma); verificar el escenario "Enemigo derrotado"
- [ ] 4.7 Verificar la curva de oleadas saltando a los minutos 0, 5 y 9 con el debug overlay: escenarios "Inicio tranquilo" y "Escalado"

## 5. Armas (specs/auto-weapons)

- [ ] 5.1 Crear las clases `WeaponData` (estadísticas para 5 niveles) y `WeaponSlot`, y el sistema de recarga que respeta la pausa; verificar el escenario "Pausa detiene las armas"
- [ ] 5.2 Implementar `ProjectileWeapon` (Calabaza, arma inicial) con pool de proyectiles y búsqueda del enemigo más cercano en la rejilla; verificar los escenarios "Inicio de partida", "Proyectil dirigido" y "Proyectil sin objetivo"
- [ ] 5.3 Implementar `OrbitWeapon` (Murciélagos) y `AuraWeapon` (Niebla) con sus `.tres`; verificar los escenarios "Orbitales" y "Aura"
- [ ] 5.4 Crear el `debug_overlay` (FPS, enemigos vivos, objetos en los pools, oleada, atajos para subir de nivel, generar 200 enemigos y saltar de minuto) que solo existe en builds de debug; verificar que se abre con F3 y con 4 dedos, y que no aparece en una exportación release
- [ ] 5.5 Implementar el destello de impacto y los números de daño con pool; verificar el escenario "Impacto"

## 6. Progresión de la partida (specs/run-progression)

- [ ] 6.1 Crear `soul_gem.tscn` con pool, radio de atracción y fusión al pasar de unas 300 almas; verificar los escenarios "Atracción y recogida" y "Fuera de radio"
- [ ] 6.2 Implementar la curva de XP y la subida de nivel con excedente en el `RunManager`; verificar el escenario "Subida con excedente"
- [ ] 6.3 Crear la clase `UpgradeData` y los `.tres`: arma nueva y subir de nivel para las 3 armas, y las 4 pasivas (vida máxima, velocidad, radio de atracción, recarga); verificar el escenario "Mejora pasiva"
- [ ] 6.4 Crear `level_up.tscn` (pausa, 3 opciones distintas al azar, cola de subidas, respaldo de curar) y excluir las armas a nivel 5; verificar los escenarios "Elegir mejora", "Varias subidas seguidas", "Pocas mejoras disponibles", "Subir un arma de nivel" y "Nivel máximo"

## 7. Ciclo de partida y UI (specs/run-session)

- [ ] 7.1 Crear `run.tscn` con el `RunManager` (temporizador, muertes, victoria a 10:00, derrota) y reinicio limpio del estado; verificar los escenarios "Sobrevivir" (saltando al minuto 9:50) y "Nueva partida"
- [ ] 7.2 Crear `hud.tscn` (vida, XP y nivel, tiempo, muertes, iconos de armas) respetando las zonas seguras; verificar el escenario "Actualización del HUD" y comprobar en vertical y horizontal que nada se solapa
- [ ] 7.3 Crear `main_menu.tscn` (título provisional, Jugar, Volumen) y asignarla como escena principal; verificar el escenario "Empezar a jugar"
- [ ] 7.4 Crear `game_over.tscn` (resultado, tiempo, nivel, muertes, Reintentar, Menú); verificar los escenarios "Reintentar" y "Volver al menú" tanto en derrota como en victoria
- [ ] 7.5 Crear `pause.tscn` (Continuar, Volumen, Abandonar), un botón de pausa táctil y la pausa automática al perder el foco o pasar a segundo plano; verificar los escenarios "Pausa manual" y "Pausa automática" y el de "Recordar volumen"
- [ ] 7.6 Conectar los efectos de sonido y la música a los eventos, con un límite de voces simultáneas; verificar el escenario "Subir de nivel" de presentación y que, con 200 enemigos muriendo, el audio no se satura

## 8. Exportación (specs/platform-builds)

- [ ] 8.1 Instalar las plantillas de exportación de Godot 4.7 y crear el preset Web (sin hilos); verificar que la build servida con `python3 -m http.server` funciona en Chrome, Firefox, Edge y Safari de escritorio: escenarios "Abrir en navegador" y "Audio en web"
- [ ] 8.2 Verificar la build web en Chrome de Android: escenario "Jugar en Chrome Android", más rotación del móvil y zona segura
- [ ] 8.3 Configurar el JDK y el SDK de Android y crear el preset Android (API mínima 26, pantalla completa, orientación libre, keystore de debug); verificar que el APK se instala y se puede jugar: escenarios "Instalar y jugar" y "Rotar el móvil"
- [ ] 8.4 Crear `stress_test.tscn` (200 enemigos y proyectiles durante 1 minuto, con registro de FPS) y medir en PC web, Android web y APK; verificar ≥60 FPS en PC y ≥30 FPS en Android de gama media, o aplicar las palancas de design.md (Risks) hasta conseguirlo
- [ ] 8.5 Documentar en `README.md` cómo abrir el proyecto, exportar cada build y servir la web; verificar siguiendo los pasos desde cero

## 9. Integración final

- [ ] 9.1 Jugar 3 partidas completas (una ganada, dos perdidas) en cada plataforma recorriendo el checklist de todos los escenarios de specs; verificar que no hay errores en la consola ni escenarios fallidos
- [ ] 9.2 Revisar `CREDITS.md` frente a todos los archivos de `art/placeholder/`; verificar que cada asset de terceros tiene autor, origen y licencia compatible con uso comercial
