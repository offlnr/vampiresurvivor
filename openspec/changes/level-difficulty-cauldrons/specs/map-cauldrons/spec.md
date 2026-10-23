# Spec Delta

## Purpose

Calderos malditos repartidos por el mapa: un riesgo y recompensa opcional que hace la partida más difícil a cambio de progresar más rápido.

## ADDED Requirements

### Requirement: Calderos en el mapa
Desde el inicio de la partida SHALL haber 6 calderos malditos repartidos alrededor del jugador, fuera de la pantalla inicial y separados entre sí. Un caldero que queda muy lejos MUST reaparecer en otro punto alrededor del jugador, y al usar uno MUST aparecer otro.

#### Scenario: Aparecen los calderos
- **WHEN** empieza la partida
- **THEN** ya hay 6 calderos en el mapa, ninguno en la pantalla inicial, y los 6 se ven en el minimapa

#### Scenario: Calderos repartidos
- **WHEN** aparecen los calderos
- **THEN** no hay dos a menos de 450 unidades entre sí

#### Scenario: Siempre hay calderos
- **WHEN** el jugador usa un caldero
- **THEN** aparece otro en otro punto del mapa y vuelve a haber 6

### Requirement: Activar un caldero
Un caldero SHALL activarse cuando el jugador permanece 1,5 s encima de él. Un anillo MUST mostrar el progreso, y si el jugador se aparta antes de completarlo, el progreso baja.

#### Scenario: Pasar por encima
- **WHEN** el jugador cruza un caldero sin pararse
- **THEN** el caldero no se activa

#### Scenario: Quedarse encima
- **WHEN** el jugador se queda 1,5 s sobre un caldero
- **THEN** el anillo se completa, el caldero se activa y desaparece con un efecto y un aviso en pantalla

### Requirement: Efecto del caldero
Cada caldero activado SHALL subir la dificultad un 5 % para el resto de la partida (vida, daño y número máximo de enemigos a la vez) y MUST dar +10 % de experiencia y +10 % de oro. Los efectos se suman con cada caldero y el HUD MUST mostrar la dificultad extra acumulada.

#### Scenario: Un caldero
- **WHEN** el jugador activa su primer caldero
- **THEN** los enemigos que aparecen tienen un 5 % más de vida y de daño, pueden estar un 5 % más a la vez, el jugador gana un 10 % más de experiencia y de oro, y el HUD muestra "+5 %"

#### Scenario: Tres calderos
- **WHEN** el jugador ha activado 3 calderos
- **THEN** la dificultad es un 15 % mayor y el HUD muestra "+15 %"
