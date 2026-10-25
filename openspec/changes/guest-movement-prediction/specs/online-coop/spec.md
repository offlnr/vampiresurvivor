# Spec Delta

## MODIFIED Requirements

### Requirement: Anfitrión con autoridad y réplica al invitado
La partida SHALL ejecutarse solo en el dispositivo del anfitrión. El invitado MUST enviar la dirección de movimiento de su personaje, y SHALL ver, desde la posición de su personaje, todo lo que se dibuja en el mundo (enemigos, personajes, armas, almas, efectos y decoraciones), además de su vida y el HUD compartido. El personaje del invitado SHALL moverse en su pantalla en cuanto pulsa una dirección, sin esperar la respuesta del anfitrión, y MUST corregirse poco a poco hacia la posición que tiene en el anfitrión.

#### Scenario: Mover al invitado
- **WHEN** el invitado mantiene pulsada una dirección
- **THEN** su personaje se mueve en la partida del anfitrión y la cámara del invitado lo sigue

#### Scenario: Respuesta inmediata
- **WHEN** el invitado pulsa una dirección con una conexión de 240 ms de ida y vuelta
- **THEN** su personaje empieza a moverse en su pantalla en menos de 50 ms

#### Scenario: Soltar los controles
- **WHEN** el invitado suelta la dirección
- **THEN** su personaje se para y, en menos de un segundo, queda en la misma posición que en la partida del anfitrión

#### Scenario: Partida parada
- **WHEN** el anfitrión tiene un menú abierto y el invitado pulsa una dirección
- **THEN** el personaje del invitado no se mueve en ninguna de las dos pantallas

#### Scenario: Ver la partida
- **WHEN** hay enemigos alrededor del personaje del invitado
- **THEN** el invitado los ve moverse con suavidad, junto con los dos personajes, las armas y los efectos
