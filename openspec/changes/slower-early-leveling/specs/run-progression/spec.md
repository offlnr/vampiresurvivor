# Spec Delta

## MODIFIED Requirements

### Requirement: Curva de experiencia
Para subir cada nivel SHALL hacer falta más experiencia que para el anterior. La experiencia que sobra al subir MUST conservarse para el nivel siguiente. Los primeros niveles MUST costar una experiencia extra que se reduce en cada nivel hasta desaparecer en el nivel 16, para que el principio de la partida no se llene de subidas de nivel. La curva MUST estar ajustada para que un jugador que recoge todas las almas llegue a un nivel entre 4 y 7 al minuto 1, entre 7 y 11 al minuto 2, y entre 30 y 40 al minuto 10.

#### Scenario: Primeros niveles más lentos
- **WHEN** el jugador empieza una partida
- **THEN** necesita 23 de experiencia para el nivel 2, 24 para el nivel 3 y 26 para el nivel 4. Cada murciélago da 2 de experiencia, cada zombi 3 y cada fantasma 6, de modo que hacen falta unos 12 murciélagos para el nivel 2

#### Scenario: Primer minuto
- **WHEN** termina el primer minuto de una partida en la que el jugador recoge todas las almas
- **THEN** ha subido de nivel unas 4 veces, no 7 u 8

#### Scenario: Niveles altos sin cambios
- **WHEN** el jugador pasa del nivel 16 al 17 o de cualquier nivel superior al siguiente
- **THEN** necesita la misma experiencia que antes de este cambio

#### Scenario: Subida con excedente
- **WHEN** el jugador recoge más experiencia de la que le faltaba para subir de nivel
- **THEN** sube de nivel y la experiencia sobrante cuenta para el siguiente
