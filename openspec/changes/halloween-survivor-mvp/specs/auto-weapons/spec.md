# Spec Delta

## Purpose

Define las armas que atacan solas, sin que el jugador pulse nada, y cómo mejoran de nivel durante la partida. Es el núcleo del combate estilo Vampire Survivors.

## ADDED Requirements

### Requirement: Disparo automático
Cada arma equipada SHALL atacar sola, cada vez que pasa su tiempo de recarga, mientras la partida no esté en pausa. El jugador no pulsa nada para atacar.

#### Scenario: Ataque periódico
- **WHEN** pasa el tiempo de recarga de un arma equipada durante la partida
- **THEN** el arma ataca sin intervención del jugador

#### Scenario: Pausa detiene las armas
- **WHEN** la partida está en pausa o en la pantalla de elegir mejora
- **THEN** ninguna arma ataca y sus tiempos de recarga no avanzan

### Requirement: Arma inicial
El jugador SHALL empezar cada partida con un arma inicial, de nivel 1, equipada.

#### Scenario: Inicio de partida
- **WHEN** empieza una nueva partida
- **THEN** el personaje lleva equipada el arma inicial en nivel 1 y no tiene ninguna otra

### Requirement: Catálogo de armas del MVP
El juego SHALL ofrecer al menos 3 armas con patrones de ataque distintos: un proyectil dirigido al enemigo más cercano (calabaza), proyectiles que orbitan al jugador (murciélagos) y un área de daño continuo alrededor del jugador (niebla).

#### Scenario: Proyectil dirigido
- **WHEN** ataca el arma de proyectil y hay enemigos en su rango
- **THEN** lanza un proyectil hacia el enemigo más cercano

#### Scenario: Proyectil sin objetivo
- **WHEN** ataca el arma de proyectil y no hay enemigos en su rango
- **THEN** no lanza ningún proyectil en ese ciclo

#### Scenario: Orbitales
- **WHEN** el arma orbital está equipada
- **THEN** sus proyectiles giran alrededor del personaje y dañan a los enemigos que tocan

#### Scenario: Aura
- **WHEN** el arma de aura está equipada y hay enemigos dentro de su radio
- **THEN** esos enemigos reciben daño a intervalos regulares

### Requirement: Daño a enemigos
Cuando un ataque toca a un enemigo, este SHALL perder vida según el daño del arma, y MUST mostrarse un número de daño o un destello en el enemigo.

#### Scenario: Impacto
- **WHEN** un proyectil toca a un enemigo
- **THEN** el enemigo pierde vida igual al daño del arma y se ve una señal del impacto

### Requirement: Niveles de arma
Cada arma SHALL tener un máximo de 5 niveles, y cada nivel MUST mejorar al menos un atributo: daño, recarga, número de proyectiles, área o duración.

#### Scenario: Subir un arma de nivel
- **WHEN** el jugador elige la mejora de un arma que ya tiene
- **THEN** el arma sube un nivel y su atributo mejorado se nota en la partida

#### Scenario: Nivel máximo
- **WHEN** un arma llega al nivel 5
- **THEN** su mejora deja de ofrecerse en las selecciones de mejora

