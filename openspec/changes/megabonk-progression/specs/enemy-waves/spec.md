# Spec Delta

## MODIFIED Requirements

### Requirement: Dificultad creciente
El ritmo de aparición, la cantidad de enemigos a la vez, la mezcla de tipos y la vida de los enemigos SHALL seguir una tabla de oleadas según el tiempo de partida, y su daño MUST crecer cada minuto. Como en Megabonk, la fuerza de los enemigos MUST NOT depender del nivel del jugador, y la Dificultad (calderos malditos) la multiplica. La dificultad MUST subir sin límite: pasado el último tramo de la tabla, la vida, el daño, la velocidad, el ritmo y el número de enemigos siguen creciendo cada minuto.

#### Scenario: Inicio tranquilo
- **WHEN** lleva menos de 1 minuto de partida
- **THEN** solo aparecen murciélagos y zombis, a ritmo bajo y como mucho 15 a la vez, y un zombi muere con 2 orbes del arma inicial

#### Scenario: Enemigos lentos al principio
- **WHEN** lleva menos de 1 minuto de partida
- **THEN** los murciélagos se mueven como mucho a la mitad de la velocidad base del jugador, y su velocidad sube poco a poco hasta su valor completo en el minuto 5

#### Scenario: Cada vez más rápidos y fuertes
- **WHEN** pasa cada minuto de partida, desde el principio
- **THEN** los enemigos nuevos son un poco más rápidos y hacen más daño que los del minuto anterior, sin límite

#### Scenario: Más fuertes con el tiempo
- **WHEN** lleva 4 minutos de partida
- **THEN** los enemigos que aparecen tienen 2,2 veces su vida base y hacen un 32 % más de daño

#### Scenario: El nivel no los hace más fuertes
- **WHEN** el jugador sube de nivel 1 a nivel 20 sin que pase el tiempo
- **THEN** los enemigos que aparecen tienen la misma vida y el mismo daño

#### Scenario: Después del minuto 10
- **WHEN** lleva 15 minutos de partida
- **THEN** los enemigos tienen más vida y hacen más daño que en el minuto 10, y aparecen más rápido

#### Scenario: Escalado
- **WHEN** lleva más de 5 minutos de partida
- **THEN** aparecen fantasmas y el ritmo de aparición es mayor que en el primer minuto
