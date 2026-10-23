# Spec Delta

## ADDED Requirements

### Requirement: Plata entre partidas
Al terminar una partida, tanto al morir como al abandonar desde la pausa, el jugador SHALL ganar plata:
- 1 por minuto sobrevivido;
- 1 por cada 5 niveles;
- 1 por cada 200 enemigos derrotados;
- multiplicado por la bonificación del pergamino de plata.

La plata MUST guardarse en el dispositivo y mantenerse entre partidas. Una partida MUST NOT dar plata dos veces.

#### Scenario: Plata al morir
- **WHEN** el jugador muere en el minuto 5:30, en nivel 16 y con 1.600 enemigos derrotados
- **THEN** gana 16 de plata y la pantalla de fin de partida lo muestra

#### Scenario: Abandonar
- **WHEN** el jugador sale al menú desde la pausa
- **THEN** la partida cuenta para la plata y los desafíos igual que si hubiera muerto

### Requirement: Contenido bloqueado
Las armas fuego fatuo, rayo espectral, rastro de brasas, vórtice de almas y trabuco de plata SHALL empezar bloqueadas. También 10 pergaminos y 5 objetos.

El contenido bloqueado MUST NOT aparecer en una partida: ni en las cartas de subida de nivel o de cofre, ni en el comerciante, ni en los cofres de pago, ni en el pergamino del caos. Todo lo demás SHALL estar disponible desde la primera partida.

#### Scenario: Arma bloqueada
- **WHEN** el jugador no ha comprado el rayo espectral y sube de nivel
- **THEN** el rayo espectral nunca sale como "¡Nueva arma!"

#### Scenario: Objeto bloqueado
- **WHEN** el jugador no ha comprado el cosechador de almas
- **THEN** ni el comerciante ni los cofres lo ofrecen nunca

### Requirement: Desafíos y compra
Cada elemento bloqueado SHALL tener un desafío y un precio en plata. Hay dos tipos de desafío:
- acumulados entre partidas (por ejemplo, "Derrota a 1.500 enemigos");
- de una sola partida (por ejemplo, "Sobrevive 5:00 en una partida").

Un elemento MUST poder comprarse solo con su desafío cumplido y plata suficiente. Al comprarlo se resta su precio y queda desbloqueado para siempre.

#### Scenario: Desafío cumplido
- **WHEN** una partida hace que se cumpla el desafío del rayo espectral
- **THEN** la pantalla de fin de partida anuncia que ya se puede desbloquear

#### Scenario: Comprar
- **WHEN** el jugador tiene el desafío del rayo cumplido y 100 de plata, y lo compra en "Desbloqueos"
- **THEN** le quedan 80 de plata, y el rayo puede salir en la siguiente partida

#### Scenario: Sin cumplir el desafío
- **WHEN** el jugador tiene plata de sobra pero no ha cumplido el desafío del trabuco
- **THEN** el botón de compra del trabuco está desactivado y muestra el progreso (por ejemplo, "1.720 / 5.000")

### Requirement: Menú de desbloqueos
La pantalla de título SHALL tener un botón "Desbloqueos" que abre la lista de todo lo bloqueable, en tres secciones: armas, pergaminos y objetos. De cada elemento se muestra:
- su icono, en silueta mientras su desafío no esté cumplido;
- su nombre;
- su desafío;
- su progreso, "¡Desafío cumplido!" o "Desbloqueado";
- su precio.

La pantalla de título MUST mostrar la plata y cuántos desbloqueos se pueden comprar.

#### Scenario: Ver el progreso
- **WHEN** el jugador abre "Desbloqueos"
- **THEN** ve su plata y, para cada elemento, cuánto le falta para su desafío
