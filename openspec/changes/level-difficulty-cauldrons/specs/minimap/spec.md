# Spec Delta

## MODIFIED Requirements

### Requirement: Puntos de interés
El minimapa SHALL marcar el comerciante (con el color de su rareza), los cofres, los calderos malditos (en verde), los power-ups y los élites. Lo que quede fuera de su radio MUST dibujarse en el borde, en su dirección.

#### Scenario: Comerciante lejos
- **WHEN** el comerciante está más lejos que el radio del minimapa
- **THEN** su marca aparece en el borde del minimapa, en la dirección en la que está

#### Scenario: Calderos en el minimapa
- **WHEN** hay calderos en el mapa
- **THEN** cada uno aparece como un punto verde, o como una flecha verde en el borde si está fuera del radio

#### Scenario: Enemigos normales
- **WHEN** hay muchos enemigos normales cerca
- **THEN** el minimapa no los marca uno a uno, para no taparlo
