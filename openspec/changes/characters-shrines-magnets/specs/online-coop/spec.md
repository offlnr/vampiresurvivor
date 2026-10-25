# Spec Delta

## MODIFIED Requirements

### Requirement: Salas con código
El juego SHALL permitir crear una sala online y unirse a ella con un código de 4 caracteres, a través de un servidor de salas configurable. Solo el anfitrión MUST poder empezar la partida, y SHALL empezar para los dos a la vez. En la pantalla de sala, cada jugador SHALL poder elegir su personaje con el botón "Personaje: …", y cada uno MUST empezar la partida con el suyo. Si los dos eligen el mismo, el del invitado SHALL verse azulado.

#### Scenario: Crear y unirse
- **WHEN** un jugador pulsa "Crear sala" y otro escribe el código mostrado y pulsa "Unirse"
- **THEN** al anfitrión le aparece "¡Tu compañero se ha unido!" y el botón "Empezar partida"

#### Scenario: Empezar
- **WHEN** el anfitrión pulsa "Empezar partida"
- **THEN** los dos entran en la misma partida

#### Scenario: Código incorrecto
- **WHEN** el invitado escribe un código que no existe
- **THEN** ve "No existe ninguna sala con ese código." y puede volver a intentarlo

#### Scenario: Personajes distintos
- **WHEN** el anfitrión elige a la Bruja y el invitado al Fantasmita, y empieza la partida
- **THEN** el anfitrión juega con la bruja y su orbe, y el invitado con el fantasma y su rayo espectral
