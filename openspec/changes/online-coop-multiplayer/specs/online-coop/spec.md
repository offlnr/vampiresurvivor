# Spec Delta

## Purpose

Define el cooperativo online para dos jugadores: cómo se crea y se une una sala, qué ve y controla cada jugador, y las reglas de una partida compartida.

## ADDED Requirements

### Requirement: Salas con código
El juego SHALL permitir crear una sala online y unirse a ella con un código de 4 caracteres, a través de un servidor de salas configurable. Solo el anfitrión MUST poder empezar la partida, y SHALL empezar para los dos a la vez.

#### Scenario: Crear y unirse
- **WHEN** un jugador pulsa "Crear sala" y otro escribe el código mostrado y pulsa "Unirse"
- **THEN** al anfitrión le aparece "¡Tu compañero se ha unido!" y el botón "Empezar partida"

#### Scenario: Empezar
- **WHEN** el anfitrión pulsa "Empezar partida"
- **THEN** los dos entran en la misma partida

#### Scenario: Código incorrecto
- **WHEN** el invitado escribe un código que no existe
- **THEN** ve "No existe ninguna sala con ese código." y puede volver a intentarlo

### Requirement: Anfitrión con autoridad y réplica al invitado
La partida SHALL ejecutarse solo en el dispositivo del anfitrión. El invitado MUST enviar la dirección de movimiento de su personaje, y SHALL ver, desde la posición de su personaje, todo lo que se dibuja en el mundo (enemigos, personajes, armas, almas, efectos y decoraciones), además de su vida y el HUD compartido.

#### Scenario: Mover al invitado
- **WHEN** el invitado mantiene pulsada una dirección
- **THEN** su personaje se mueve en la partida del anfitrión y la cámara del invitado lo sigue

#### Scenario: Ver la partida
- **WHEN** hay enemigos alrededor del personaje del invitado
- **THEN** el invitado los ve moverse con suavidad, junto con los dos personajes, las armas y los efectos

### Requirement: Nivel compartido, elecciones individuales
En cooperativo, la experiencia y el nivel SHALL ser comunes. Cada jugador MUST tener sus propias armas, pergaminos, objetos, oro, tiradas, destierros y saltos, con las ofertas de lo que ese jugador ha desbloqueado. En cada subida de nivel, cada jugador SHALL elegir su propia mejora en su pantalla, y la partida MUST seguir parada hasta que hayan elegido los dos. Los power-ups SHALL ayudar a los dos personajes.

#### Scenario: Subida de nivel
- **WHEN** suben de nivel
- **THEN** a cada jugador le aparece su propio menú "¡Subiste de nivel!" con sus cartas, tiradas, destierros y saltos

#### Scenario: Esperar al compañero
- **WHEN** el anfitrión ya ha elegido y el invitado no
- **THEN** la partida sigue parada y el anfitrión ve "Tu compañero está eligiendo su mejora..."
- **AND** cuando el invitado elige, la partida continúa

### Requirement: Compras individuales
En cooperativo, cada jugador SHALL poder comprar al comerciante, abrir cofres de pago y elegir la recompensa de los cofres de élite con su propio oro y sus propios menús, igual que en solitario. El comerciante MUST atender una vez a cada jugador y SHALL irse cuando hayan comprado todos los que siguen en pie.

#### Scenario: El invitado compra
- **WHEN** el personaje del invitado llega al comerciante con oro suficiente
- **THEN** al invitado se le abre la tienda en su pantalla, y al comprar se le descuenta su oro y el objeto pasa a su inventario

#### Scenario: El comerciante atiende a los dos
- **WHEN** el invitado ya ha comprado y el anfitrión todavía no
- **THEN** el comerciante sigue ahí hasta que compra el anfitrión

#### Scenario: Cofre de élite
- **WHEN** el invitado recoge el cofre que suelta un enemigo de élite
- **THEN** solo el invitado recibe la elección "¡Cofre maldito!"

### Requirement: Objetos con efecto personal
El daño SHALL atribuirse al personaje que golpea, de modo que sus objetos, críticos, robo de vida y empuje MUST aplicarse a sus golpes y no a los del otro.

#### Scenario: Robo de vida del invitado
- **WHEN** el invitado tiene robo de vida y sus armas golpean
- **THEN** se cura el invitado, no el anfitrión

### Requirement: Más dificultad para dos
En cooperativo, cada enemigo SHALL perseguir al personaje vivo más cercano, y los enemigos MUST aparecer alrededor de cualquiera de los dos. Su vida SHALL ser un 80 % mayor, MUST poder haber un 35 % más a la vez, y cada nivel SHALL necesitar un 50 % más de experiencia.

#### Scenario: Experiencia del primer nivel
- **WHEN** empieza una partida en cooperativo
- **THEN** el primer nivel necesita 5 de experiencia en lugar de 3

#### Scenario: Jugadores separados
- **WHEN** los dos personajes están lejos uno del otro
- **THEN** a cada uno le aparecen enemigos alrededor y le persiguen los más cercanos

### Requirement: Caer y revivir
Si cae uno de los dos personajes, la partida SHALL continuar con el otro. El caído MUST revivir con media vida en la siguiente subida de nivel. La partida SHALL terminar cuando caen los dos.

#### Scenario: Cae el invitado
- **WHEN** el personaje del invitado se queda sin vida
- **THEN** la partida sigue y el invitado ve "Has caído. Revivirás cuando subáis de nivel."

#### Scenario: Revivir
- **WHEN** suben de nivel con un personaje caído
- **THEN** ese personaje revive con la mitad de su vida máxima

#### Scenario: Caen los dos
- **WHEN** caen los dos personajes
- **THEN** los dos ven la pantalla de fin de partida y cada uno gana su plata

### Requirement: Desconexiones
Si el invitado sale o pierde la conexión, el anfitrión SHALL seguir jugando solo. Si el anfitrión sale o se pierde la conexión con el servidor, el invitado MUST volver al menú principal con un aviso.

#### Scenario: Sale el invitado
- **WHEN** el invitado sale de la partida
- **THEN** su personaje desaparece y el anfitrión ve "Tu compañero ha salido de la partida"

#### Scenario: Sale el anfitrión
- **WHEN** el anfitrión vuelve al menú
- **THEN** el invitado ve "Tu compañero ha vuelto al menú." y vuelve al menú principal

### Requirement: Reintentar y pausa online
En cooperativo, solo el anfitrión SHALL poder reintentar, y al hacerlo MUST empezar una partida nueva para los dos. Cambiar de ventana NO MUST pausar la partida online.

#### Scenario: Reintentar
- **WHEN** el anfitrión pulsa "Reintentar" en la pantalla de fin de partida
- **THEN** empieza una partida nueva para los dos

### Requirement: Servidor de salas desplegable
El proyecto SHALL incluir el servidor de salas (`server/`) y su configuración para publicarlo gratis en Render (`render.yaml`). La build web MUST poder conectarse a él con `wss://`.

#### Scenario: Probar en local
- **WHEN** se ejecuta `npm start` en `server/` y dos copias del juego usan `ws://localhost:8080`
- **THEN** pueden crear una sala, unirse y jugar
