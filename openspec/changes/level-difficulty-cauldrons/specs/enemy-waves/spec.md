# Spec Delta

## MODIFIED Requirements

### Requirement: Dificultad creciente
El ritmo de aparición, la cantidad de enemigos a la vez y la mezcla de tipos SHALL seguir una tabla de oleadas según el tiempo de partida. La vida y el daño de los enemigos MUST crecer con el nivel del jugador, no con el tiempo, y los calderos malditos los multiplican. La dificultad MUST subir sin límite: pasado el último tramo de la tabla, la vida, el daño, la velocidad, el ritmo y el número de enemigos siguen creciendo cada minuto.

#### Scenario: Inicio tranquilo
- **WHEN** lleva menos de 1 minuto de partida
- **THEN** solo aparecen murciélagos y zombis, a ritmo bajo y como mucho 15 a la vez, y a nivel 1 un zombi muere con 2 orbes del arma inicial

#### Scenario: Enemigos lentos al principio
- **WHEN** lleva menos de 1 minuto de partida
- **THEN** los murciélagos se mueven como mucho a la mitad de la velocidad base del jugador, y su velocidad sube poco a poco hasta su valor completo en el minuto 5

#### Scenario: Cada vez más rápidos
- **WHEN** pasa cada minuto de partida, desde el principio
- **THEN** los enemigos nuevos son un poco más rápidos que los del minuto anterior, sin límite

#### Scenario: Más fuertes al subir de nivel
- **WHEN** el jugador pasa de nivel 1 a nivel 20
- **THEN** los enemigos que aparecen desde entonces tienen unas 2,8 veces más vida y hacen un 47,5 % más de daño

#### Scenario: El tiempo solo no los hace más fuertes
- **WHEN** el jugador sigue en nivel 1 en el minuto 4
- **THEN** los enemigos tienen la misma vida y el mismo daño que al empezar, aunque aparecen más y más rápido

#### Scenario: Después del minuto 10
- **WHEN** lleva 15 minutos de partida
- **THEN** los enemigos tienen más vida y hacen más daño que en el minuto 10 al mismo nivel, y aparecen más rápido

#### Scenario: Escalado
- **WHEN** lleva más de 5 minutos de partida
- **THEN** aparecen fantasmas y el ritmo de aparición es mayor que en el primer minuto
