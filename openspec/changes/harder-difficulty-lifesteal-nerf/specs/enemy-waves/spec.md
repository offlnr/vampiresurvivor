# Spec Delta

## MODIFIED Requirements

### Requirement: Dificultad creciente
El ritmo de aparición, la cantidad de enemigos a la vez y la mezcla de tipos SHALL seguir una tabla de oleadas según el tiempo de partida, y la dificultad MUST subir sin límite: pasado el último tramo de la tabla, la vida, el daño, la velocidad, el ritmo y el número de enemigos siguen creciendo cada minuto.

#### Scenario: Inicio tranquilo
- **WHEN** lleva menos de 1 minuto de partida
- **THEN** solo aparecen murciélagos y zombis, a ritmo bajo y como mucho 15 a la vez, y un zombi muere con 2 orbes del arma inicial

#### Scenario: Enemigos lentos al principio
- **WHEN** lleva menos de 1 minuto de partida
- **THEN** los murciélagos se mueven como mucho a la mitad de la velocidad base del jugador, y su velocidad sube poco a poco hasta su valor completo en el minuto 5

#### Scenario: Cada vez más rápidos y fuertes
- **WHEN** pasa cada minuto de partida, desde el principio
- **THEN** los enemigos nuevos son un poco más rápidos y hacen más daño que los del minuto anterior, sin límite

#### Scenario: Presión desde el minuto 1
- **WHEN** lleva 3 minutos de partida
- **THEN** los enemigos tienen al menos el doble de vida que en el primer minuto, puede haber hasta 120 a la vez y su daño ha subido al menos un 20 %

#### Scenario: Después del minuto 10
- **WHEN** lleva 15 minutos de partida
- **THEN** los enemigos tienen más vida y hacen más daño que en el minuto 10, y aparecen más rápido

#### Scenario: Escalado
- **WHEN** lleva más de 5 minutos de partida
- **THEN** aparecen fantasmas y el ritmo de aparición es mayor que en el primer minuto
