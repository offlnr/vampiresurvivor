# Spec Delta

## MODIFIED Requirements

### Requirement: Robo de vida
El robo de vida SHALL curar al jugador un porcentaje del daño que hacen sus armas, contando solo la vida que le quedaba al enemigo golpeado y sin superar la vida máxima del jugador. El daño de objetos y power-ups MUST NOT curar. La curación por robo de vida MUST NOT pasar del 2 % de la vida máxima por segundo.

#### Scenario: Curarse atacando
- **WHEN** el jugador tiene 2 % de robo de vida, le falta vida y sus armas hacen 100 de daño a enemigos con vida de sobra
- **THEN** recupera 2 de vida

#### Scenario: Sin daño sobrante
- **WHEN** el jugador tiene 10 % de robo de vida y un orbe de 11 de daño mata a un enemigo al que le quedaban 3 de vida
- **THEN** recupera 0,3 de vida, no 1,1

#### Scenario: Daño de objetos
- **WHEN** el veneno, el muñeco vudú, el espejo roto o la bomba de calabaza dañan a enemigos
- **THEN** el robo de vida no cura nada por ese daño

#### Scenario: Tope por segundo
- **WHEN** el jugador tiene 100 de vida máxima, mucho robo de vida y la niebla golpea a 50 enemigos a la vez
- **THEN** no recupera más de 2 de vida en ese segundo
