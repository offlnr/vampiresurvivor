# Spec Delta

## MODIFIED Requirements

### Requirement: Puntos de interés
El minimapa SHALL marcar el comerciante (con el color de su rareza), los cofres, los calderos malditos (en verde), los santuarios de poder (en dorado), los tótems imán (en rojo), los power-ups, los élites y los jefes (en rojo). Lo que quede fuera de su radio MUST dibujarse en el borde, en su dirección.

#### Scenario: Comerciante lejos
- **WHEN** el comerciante está más lejos que el radio del minimapa
- **THEN** su marca aparece en el borde del minimapa, en la dirección en la que está

#### Scenario: Jefe en el minimapa
- **WHEN** hay un jefe en el mapa
- **THEN** aparece como un punto rojo, o como una flecha roja en el borde si está fuera del radio

#### Scenario: Enemigos normales
- **WHEN** hay muchos enemigos normales cerca
- **THEN** el minimapa no los marca uno a uno, para no taparlo
