# Spec Delta

## ADDED Requirements

### Requirement: Anuncios opcionales con recompensa
El juego SHALL ofrecer anuncios solo como opción a cambio de una recompensa, en pausas naturales (muerte, fin de partida, subida de nivel y menú). MUST NOT mostrar anuncios obligatorios ni durante el juego. Cerrar un anuncio antes de tiempo MUST NOT dar la recompensa. Si no hay anuncios disponibles, los botones de anuncio MUST NOT mostrarse.

#### Scenario: Sin anuncios disponibles
- **WHEN** el juego se ejecuta en una build de publicación sin SDK de anuncios
- **THEN** no aparece ningún botón de anuncio y el juego funciona igual

#### Scenario: Cerrar el anuncio
- **WHEN** el jugador cierra un anuncio antes de que termine
- **THEN** no recibe la recompensa

### Requirement: Revivir con anuncio
Al morir por primera vez en una partida, si hay anuncios disponibles, el juego SHALL pausarse y preguntar si se quiere revivir. Si el jugador acepta y termina el anuncio, revive con la mitad de la vida, el escudo lleno y 3 s de invulnerabilidad, y una onda limpia la pantalla. Solo MUST poder revivirse una vez por partida.

#### Scenario: Revivir
- **WHEN** el jugador muere por primera vez, elige "Revivir (anuncio)" y termina el anuncio
- **THEN** la partida sigue con el personaje al 50 % de vida

#### Scenario: Segunda muerte
- **WHEN** el jugador ya revivió en la partida y vuelve a morir
- **THEN** aparece directamente la pantalla de fin de partida

### Requirement: Recompensas con límite
El juego SHALL ofrecer:
- ×2 de la plata de la partida en el fin de partida, una vez;
- +1 tirada en la subida de nivel, hasta 2 por partida;
- un regalo diario de +5 de plata en el menú principal, una vez al día.

#### Scenario: Tirada extra
- **WHEN** el jugador ve dos anuncios de tirada extra en una partida
- **THEN** gana 2 tiradas y el botón deja de aparecer en esa partida

#### Scenario: Regalo diario
- **WHEN** el jugador ya reclamó el regalo hoy
- **THEN** el botón no aparece hasta el día siguiente
