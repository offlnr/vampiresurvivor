# Spec Delta

## MODIFIED Requirements

### Requirement: Menú principal
Al abrir el juego SHALL mostrarse un menú principal con el título, un botón para jugar, un botón "Multijugador online" y un acceso a opciones de volumen.

#### Scenario: Empezar a jugar
- **WHEN** el jugador pulsa "Jugar" en el menú principal
- **THEN** empieza una partida nueva

#### Scenario: Abrir el multijugador
- **WHEN** el jugador pulsa "Multijugador online"
- **THEN** se abre la pantalla de sala, con "Crear sala", el campo del código, "Unirse" y el servidor
