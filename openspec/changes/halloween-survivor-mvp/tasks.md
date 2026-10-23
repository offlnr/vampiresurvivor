# Tasks

## 1. Base del proyecto

- [x] 1.1 Inicializar git con el `.gitignore` existente y hacer un primer commit; verificar que `git status` sale limpio y que `.godot/` no está versionado
- [x] 1.2 En `project.godot`: renderer `gl_compatibility`, viewport base 1280×720, `canvas_items` + `expand`; verificar que el proyecto abre en Godot 4.7 sin errores y que Project Settings muestra esos valores
- [x] 1.3 Crear la estructura de carpetas de design.md §4 y un `CREDITS.md` vacío con su formato (asset, autor, origen, licencia); verificar que las carpetas aparecen en el FileSystem de Godot
- [x] 1.4 Definir las capas de física con nombre (jugador, enemigos, ataques del jugador, recogibles) y las acciones del `InputMap` (`move_*` con WASD, flechas y stick izquierdo; `pause` con Esc, P y Start); verificar en Project Settings
- [x] 1.5 Crear los autoloads `Events` (señales: enemy_killed, xp_collected, player_damaged, player_died, level_up, run_ended) y `Settings` (ConfigFile con buses `Music` y `SFX`); verificar que, tras cambiar un volumen y reiniciar, el valor se conserva en `user://settings.cfg`

## 2. Jugador y cámara (specs/player-control)

- [x] 2.1 Crear `player.tscn` (CharacterBody2D, colisión separada del sprite, sprite SVG provisional) con movimiento en 8 direcciones normalizado mediante `Input.get_vector()`; verificar los escenarios de movimiento recto, diagonal y sin entrada
- [x] 2.2 Añadir una Camera2D con suavizado y el zoom calculado para mostrar un área mínima de mundo; verificar en ventana 16:9, 9:16 y 4:3 que el área visible es parecida y la imagen no se deforma
- [x] 2.3 Implementar la vida, el daño por contacto, la invulnerabilidad temporal con parpadeo y la muerte, que emite `Events.player_died`; verificar con un enemigo de prueba los escenarios de daño, invulnerabilidad y vida a cero
- [ ] 2.4 Crear `virtual_joystick.tscn` (aparece en el punto de contacto, zona muerta, inyecta las acciones `move_*`) y mostrar u ocultar los controles táctiles según la última entrada; verificar con la emulación táctil del editor y luego en un móvil: tocar y arrastrar, soltar, zona muerta y PC con teclado sin joystick
- [ ] 2.5 Verificar el movimiento con un mando conectado (stick izquierdo con zona muerta)

## 3. Mundo y presentación base (specs/halloween-presentation)

- [x] 3.1 Crear la textura de suelo repetible (cementerio o campo nocturno) y un suelo que se repite siguiendo a la cámara (design.md §10); verificar caminando 3 minutos en una dirección (con velocidad aumentada para la prueba) que no aparecen costuras ni huecos
- [x] 3.2 Definir la paleta de Halloween como recurso o constantes compartidas y crear los SVG provisionales de jugador, murciélago, zombi, fantasma, calabaza y alma; verificar en escala de grises que los enemigos se distinguen por su forma
- [x] 3.3 Sintetizar con un script propio los efectos provisionales (impacto, muerte de enemigo, recoger alma, subir de nivel, daño recibido) y una música en bucle, registrados en `CREDITS.md`; verificar que cada archivo importa sin errores y que `CREDITS.md` tiene sus entradas

## 4. Enemigos y oleadas (specs/enemy-waves)

- [x] 4.1 Crear la clase `EnemyData` y los 3 `.tres` (murciélago, zombi, fantasma) con velocidad, vida, daño, radio de colisión, sprite y valor de XP; verificar que se pueden editar en el inspector
- [x] 4.2 Crear `enemy.tscn` configurable por `EnemyData`, que persigue al jugador y colisiona solo con su capa; verificar el escenario "Seguir al jugador"
- [x] 4.3 Implementar la rejilla espacial y la repulsión suave entre enemigos; verificar el escenario "Sin superposición total" con 100 enemigos rodeando al jugador
- [x] 4.4 Implementar un pool genérico de objetos y usarlo para los enemigos; verificar con el debug overlay (5.4) que, tras matar a 500 enemigos, el número de instancias no pasa del tamaño del pool
- [x] 4.5 Crear las clases `WaveTable`/`WaveEntry`, el `.tres` de los 10 minutos y el spawner: aparición fuera de pantalla, límite de vivos y recolocación de enemigos lejanos; verificar los escenarios "Punto de aparición", "Límite alcanzado" y "Jugador escapa"
- [x] 4.6 Implementar la muerte del enemigo (efecto, sonido, emisión de `enemy_killed`, aparición del alma); verificar el escenario "Enemigo derrotado"
- [x] 4.7 Verificar la curva de oleadas saltando a los minutos 0, 5 y 9 con el debug overlay: escenarios "Inicio tranquilo" y "Escalado"

## 5. Armas (specs/auto-weapons)

- [x] 5.1 Crear las clases `WeaponData` (estadísticas para 5 niveles) y `WeaponSlot`, y el sistema de recarga que respeta la pausa; verificar el escenario "Pausa detiene las armas"
- [x] 5.2 Implementar `ProjectileWeapon` (Calabaza, arma inicial) con pool de proyectiles y búsqueda del enemigo más cercano en la rejilla; verificar los escenarios "Inicio de partida", "Proyectil dirigido" y "Proyectil sin objetivo"
- [x] 5.3 Implementar `OrbitWeapon` (Murciélagos) y `AuraWeapon` (Niebla) con sus `.tres`; verificar los escenarios "Orbitales" y "Aura"
- [ ] 5.4 Crear el `debug_overlay` (FPS, enemigos vivos, objetos en los pools, oleada, atajos para subir de nivel, generar 200 enemigos y saltar de minuto) que solo existe en builds de debug; verificar que se abre con F3 y con 4 dedos, y que no aparece en una exportación release
- [x] 5.5 Implementar el destello de impacto y los números de daño con pool; verificar el escenario "Impacto"

## 6. Progresión de la partida (specs/run-progression)

- [x] 6.1 Crear `soul_gem.tscn` con pool, radio de atracción y fusión al pasar de unas 300 almas; verificar los escenarios "Atracción y recogida" y "Fuera de radio"
- [x] 6.2 Implementar la curva de XP y la subida de nivel con excedente en el `RunManager`; verificar el escenario "Subida con excedente"
- [x] 6.3 Crear la clase `UpgradeData` y los `.tres`: arma nueva y subir de nivel para las 3 armas, y las 4 pasivas (vida máxima, velocidad, radio de atracción, recarga); verificar el escenario "Mejora pasiva"
- [x] 6.4 Crear `level_up.tscn` (pausa, 3 opciones distintas al azar, cola de subidas, respaldo de curar) y excluir las armas a nivel 5; verificar los escenarios "Elegir mejora", "Varias subidas seguidas", "Pocas mejoras disponibles", "Subir un arma de nivel" y "Nivel máximo"

## 7. Ciclo de partida y UI (specs/run-session)

- [x] 7.1 Crear `run.tscn` con el `RunManager` (temporizador, muertes, victoria a 10:00, derrota) y reinicio limpio del estado; verificar los escenarios "Sobrevivir" (saltando al minuto 9:50) y "Nueva partida"
- [ ] 7.2 Crear `hud.tscn` (vida, XP y nivel, tiempo, muertes, iconos de armas) respetando las zonas seguras; verificar el escenario "Actualización del HUD" y comprobar en vertical y horizontal que nada se solapa
- [x] 7.3 Crear `main_menu.tscn` (título provisional, Jugar, Volumen) y asignarla como escena principal; verificar el escenario "Empezar a jugar"
- [x] 7.4 Crear `game_over.tscn` (resultado, tiempo, nivel, muertes, Reintentar, Menú); verificar los escenarios "Reintentar" y "Volver al menú" tanto en derrota como en victoria
- [x] 7.5 Crear `pause.tscn` (Continuar, Volumen, Abandonar), un botón de pausa táctil y la pausa automática al perder el foco o pasar a segundo plano; verificar los escenarios "Pausa manual" y "Pausa automática" y el de "Recordar volumen"
- [x] 7.6 Conectar los efectos de sonido y la música a los eventos, con un límite de voces simultáneas; verificar el escenario "Subir de nivel" de presentación y que, con 200 enemigos muriendo, el audio no se satura

## 8. Segunda iteración: dificultad, rareza, armas, hordas y animaciones

- [x] 8.1 Endurecer la curva de XP y los valores de enemigos y oleadas; verificar con el bot sin ventana que un jugador que recoge almas llega a un nivel entre 15 y 25 al minuto 10 y que la partida no es imposible
- [x] 8.2 Mover las estadísticas pasivas a `Player` (daño, área, recarga, velocidad, imán, suerte, robo de vida, armadura, vida) y aplicarlas en `Weapon` y al recibir daño; verificar los escenarios "Pasiva de daño", "Armadura" y "Curarse atacando"
- [x] 8.3 Crear el sistema de rareza (`scripts/rarity.gd`), tirarla por carta con la suerte y mostrar las cartas con el color de su rareza; verificar los escenarios "Pasiva épica", "Arma rara" y "Más suerte, mejores cartas" (con un recuento de 1000 tiradas)
- [x] 8.4 Crear las 5 pasivas nuevas (daño, suerte, robo de vida, armadura, área) con sus iconos y `.tres`; verificar que aparecen en las cartas y aplican su efecto
- [x] 8.5 Bajar el límite a 3 armas y crear Guadaña, Hueso y Fuego fatuo con sus escenas, sprites y `.tres`; verificar los escenarios "Ranuras llenas", "Guadaña", "Bumerán" y "Zona de fuego"
- [x] 8.6 Implementar el director de hordas (aviso, anillo, enjambre, carga, escalado por minuto) y el aviso en el HUD; verificar los escenarios "Aviso de horda", "Anillo" y "Enjambre"
- [x] 8.7 Implementar el élite (tamaño, vida, contorno dorado, barra de vida) y el cofre con selección de rareza rara o superior; verificar los escenarios "Élite derrotado" y "Abrir el cofre"
- [x] 8.8 Redibujar jugador y enemigos con animaciones por fotogramas (`SpriteFrames`), entrada al aparecer y muerte con efecto, contorno claro en enemigos y suelo más oscuro; verificar con capturas los escenarios "Caminar", "Aparición de un zombi" y "Enemigos sobre el fondo"

- [x] 8.9 Suavizar el inicio: menos zombis y con menos vida en los primeros minutos (y un primer anillo más pequeño); verificar el escenario "Inicio tranquilo" y, con el bot, que se sube de nivel con fluidez en los 2 primeros minutos
- [x] 8.10 Hacer que la guadaña apunte al enemigo más cercano y dar alcance máximo a calabaza, hueso y fuego fatuo; verificar los escenarios "Guadaña", "Enemigo fuera de alcance" y "Proyectil que no acierta"

- [x] 8.11 Retrasar la primera horda al minuto 3 y reducir los murciélagos y el número de enemigos de los primeros minutos; verificar los escenarios "Aviso de horda", "Sin hordas al principio" e "Inicio tranquilo", y con el bot que se llega a la primera horda con 2 armas o más

- [x] 8.12 Bajar la experiencia de los primeros niveles y añadir un multiplicador de velocidad por oleada para que los murciélagos empiecen lentos; verificar los escenarios "Primeros niveles rápidos" y "Enemigos lentos al principio", y con el bot que el nivel al minuto 10 sigue entre 15 y 25

- [x] 8.13 Subir la experiencia que dan los enemigos, ampliar el radio base de atracción y endurecer solo el final de la curva; verificar el escenario "Primeros niveles rápidos" y con el bot que se sube de nivel más rápido en los primeros minutos y que el nivel al minuto 10 queda entre 20 y 30

- [x] 8.14 Aplanar la curva de experiencia para que se suba de nivel mucho más rápido; verificar con el bot que llega a nivel 8 o más al minuto 1, 12 o más al minuto 2 y entre 30 y 40 al minuto 10, y que el escenario "Primeros niveles rápidos" sigue pasando

- [x] 8.15 Quitar el final a los 10:00: partida infinita hasta morir, temporizador con horas, récord de tiempo guardado y mostrado en el menú y al morir, hordas y comerciantes sin fin y respaldos cuando se agotan las mejoras; verificar los escenarios "Pasar de los 10 minutos", "Más de una hora" y "Nuevo récord"
- [x] 8.16 Escalado sin fin pasado el último tramo de oleadas (vida, daño, velocidad, ritmo y cantidad) y algo más de dificultad en la tabla; verificar el escenario "Después del minuto 10" y con el bot que muere entre los 10 y los 25 minutos
- [x] 8.17 Añadir esqueleto, calabaza explosiva, bruja (con pociones) y gólem de lápida, con sus animaciones; verificar los escenarios "Calabaza explosiva", "Bruja a distancia" y "Gólem", y con capturas que se distinguen sobre el fondo

- [x] 8.18 Generar las descripciones de subida de nivel de las armas a partir de sus estadísticas (daño, recarga, cantidad, tamaño, duración, velocidad, atravesar) y poner valores exactos en todas las pasivas y objetos; verificar los escenarios "Valores exactos en la carta" y "Sin descripciones vagas" recorriendo todas las cartas posibles

- [x] 8.19 Mostrar la recarga como "+X % de velocidad de ataque" y la velocidad de proyectil como "velocidad de vuelo", y comprobar que ninguna estadística de arma empeora al subir de nivel; verificar el escenario "Solo mejoras"

- [x] 8.20 Cambiar las mejoras de arma al sistema de Megabonk (1 o 2 estadísticas al azar por carta, valores por rareza, sin nivel máximo, topes de proyectiles y atravesar, armas nuevas comunes); verificar los escenarios "Pocas estadísticas por carta", "Valores exactos en la carta", "Tope de proyectiles", "Arma rara" y "Arma nueva"

- [x] 8.21 Convertir las pasivas en 10 pergaminos (con experiencia), máximo 5 distintos por partida, sin niveles máximos, todo en porcentaje (vida, armadura multiplicativa, velocidad de ataque sin tope); verificar los escenarios "Límite de pergaminos", "Experiencia", "Armadura" y "Pasiva épica"
- [x] 8.22 Daño de arma en porcentaje y sin topes de cantidad ni atravesar (guadaña con N tajos); verificar los escenarios "Daño en porcentaje" y "Sin topes"
- [x] 8.23 Botones de volver a tirar y desterrar en cada carta (5 y 5 por partida, con contador); verificar los escenarios "Volver a tirar una carta", "Desterrar" y "Sin tiradas"

- [x] 8.24 Interfaz pixel art: fuente Pixelify Sans (OFL, en créditos), tema de esquinas rectas con borde y sombra, HUD y menús con más diseño, y cartas de mejora, tienda y cofre en lista vertical compacta; verificar los escenarios "Cartas en vertical" y "Fuente pixel art" con capturas en horizontal y en vertical
- [x] 8.25 Velocidad y daño de los enemigos que crecen cada minuto desde el inicio y sin tope; verificar el escenario "Cada vez más rápidos y fuertes" y medir con el bot

- [x] 8.26 Escalar el valor de mejoras de arma y pergaminos con el nivel (mitad en la primera subida, normal a nivel 22, sin tope), quitar la franja gruesa de las cartas y reordenar el HUD (experiencia abajo del todo, objetos abajo al centro, minimapa arriba a la derecha con oro y muertes debajo); verificar los escenarios "Mejora pequeña al principio", "Mejora grande al final" y "Actualización del HUD" con capturas

## 9. Exportación (specs/platform-builds)

- [ ] 9.1 Instalar las plantillas de exportación de Godot 4.7 y crear el preset Web (sin hilos); verificar que la build servida con `python3 -m http.server` funciona en Chrome, Firefox, Edge y Safari de escritorio: escenarios "Abrir en navegador" y "Audio en web"
- [ ] 9.2 Verificar la build web en Chrome de Android: escenario "Jugar en Chrome Android", más rotación del móvil y zona segura
- [ ] 9.3 Configurar el JDK y el SDK de Android y crear el preset Android (API mínima 26, pantalla completa, orientación libre, keystore de debug); verificar que el APK se instala y se puede jugar: escenarios "Instalar y jugar" y "Rotar el móvil"
- [ ] 9.4 Crear `stress_test.tscn` (200 enemigos y proyectiles durante 1 minuto, con registro de FPS) y medir en PC web, Android web y APK; verificar ≥60 FPS en PC y ≥30 FPS en Android de gama media, o aplicar las palancas de design.md (Risks) hasta conseguirlo
- [ ] 9.5 Documentar en `README.md` cómo abrir el proyecto, exportar cada build y servir la web; verificar siguiendo los pasos desde cero

## 10. Integración final

- [ ] 10.1 Jugar 3 partidas completas (una ganada, dos perdidas) en cada plataforma recorriendo el checklist de todos los escenarios de specs; verificar que no hay errores en la consola ni escenarios fallidos
- [ ] 10.2 Revisar `CREDITS.md` frente a todos los archivos de `art/placeholder/`; verificar que cada asset de terceros tiene autor, origen y licencia compatible con uso comercial
