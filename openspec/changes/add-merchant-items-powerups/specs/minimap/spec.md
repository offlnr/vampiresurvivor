# Spec Delta

## Purpose

Minimapa en el HUD que muestra al jugador dónde están el comerciante, los cofres, los power-ups y los élites, para que pueda decidir hacia dónde moverse.

## ADDED Requirements

### Requirement: Minimapa
El HUD SHALL mostrar un minimapa circular centrado en el jugador que cubre un radio fijo del mundo, con el norte siempre arriba.

#### Scenario: Ver el minimapa
- **WHEN** empieza la partida
- **THEN** aparece el minimapa en una esquina con el jugador en el centro

### Requirement: Puntos de interés
El minimapa SHALL marcar el comerciante (con el color de su rareza), los cofres, los power-ups y los élites. Lo que quede fuera de su radio MUST dibujarse en el borde, en su dirección.

#### Scenario: Comerciante lejos
- **WHEN** el comerciante está más lejos que el radio del minimapa
- **THEN** su marca aparece en el borde del minimapa, en la dirección en la que está

#### Scenario: Enemigos normales
- **WHEN** hay muchos enemigos normales cerca
- **THEN** el minimapa no los marca uno a uno, para no taparlo
