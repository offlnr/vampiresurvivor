# Spec Delta

## Purpose

Define los personajes jugables, su arma inicial, su ventaja pasiva y la pantalla para elegirlos.

## ADDED Requirements

### Requirement: Personajes con arma inicial
El juego SHALL ofrecer 6 personajes: Bruja (orbe arcano), Fantasmita (rayo espectral), Esqueleto (hueso), Calabazín (calabaza), Vampiro (murciélagos) y Segador (guadaña). Cada partida MUST empezar con el aspecto y el arma inicial del personaje elegido, y su arma inicial SHALL poder mejorarse en las subidas de nivel aunque esté bloqueada.

#### Scenario: Empezar con el Fantasmita
- **WHEN** el jugador elige al Fantasmita y empieza la partida
- **THEN** su personaje es el fantasma y su única arma es el rayo espectral

#### Scenario: Mejorar un arma inicial bloqueada
- **WHEN** el jugador juega con el Fantasmita sin haber desbloqueado el rayo espectral
- **THEN** en las subidas de nivel pueden salir mejoras del rayo espectral

### Requirement: Ventaja pasiva
Cada personaje SHALL empezar la partida con una ventaja en una estadística: Bruja +10 % de experiencia, Fantasmita +15 % de evasión, Esqueleto +10 % de armadura, Calabazín +25 % de vida máxima, Vampiro +2 % de robo de vida y Segador +10 % de probabilidad de crítico. La ventaja NO MUST ocupar un hueco de pergamino.

#### Scenario: Vida del Calabazín
- **WHEN** empieza una partida con el Calabazín
- **THEN** su vida máxima es 125 y no lleva ningún pergamino

### Requirement: Pantalla de selección
Al pulsar "Jugar", el juego SHALL mostrar "Elige personaje", con una tarjeta por personaje: su dibujo animado, su nombre, su arma inicial con su icono, su ventaja y una frase. Elegir una tarjeta MUST empezar la partida con ese personaje. El juego SHALL recordar el último personaje elegido y empezar la pantalla en él.

#### Scenario: Elegir y jugar
- **WHEN** el jugador pulsa "Jugar" y después la tarjeta del Vampiro
- **THEN** empieza una partida con el Vampiro y sus murciélagos

#### Scenario: Volver
- **WHEN** el jugador pulsa "Volver" o Escape en la pantalla de selección
- **THEN** vuelve al menú principal sin empezar la partida

#### Scenario: Recordar la elección
- **WHEN** el jugador vuelve a pulsar "Jugar" otro día
- **THEN** la tarjeta del último personaje elegido aparece resaltada y con el foco
