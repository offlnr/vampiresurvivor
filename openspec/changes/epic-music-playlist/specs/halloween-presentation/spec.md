# Spec Delta

## MODIFIED Requirements

### Requirement: Respuesta visual y sonora
El juego SHALL dar respuesta visual y sonora a los eventos clave: impacto en un enemigo, muerte de un enemigo, recoger un alma, subir de nivel y recibir daño.
- **Menú principal:** MUST sonar música ambiental de Halloween.
- **Partida:** MUST sonar una lista de varias pistas épicas de temática oscura, con licencia libre para uso comercial:
  - suenan enteras, una tras otra, en orden aleatorio y sin repetir seguida la misma;
  - tienen un volumen parecido entre sí.

#### Scenario: Subir de nivel
- **WHEN** el jugador sube de nivel
- **THEN** suena un efecto propio y se ve un destello o efecto en el personaje

#### Scenario: Varias pistas en la partida
- **WHEN** termina la pista que suena durante la partida
- **THEN** empieza otra distinta de la lista, entrando con un fundido breve

#### Scenario: Sin repeticiones seguidas
- **WHEN** ha sonado toda la lista y vuelve a empezar
- **THEN** la primera pista de la nueva vuelta no es la misma que acaba de sonar

#### Scenario: Música en pausa
- **WHEN** el juego se pausa para elegir una mejora o comprar
- **THEN** la música sigue sonando

#### Scenario: Reintentar
- **WHEN** el jugador reintenta tras morir
- **THEN** vuelve a sonar la lista de partida
