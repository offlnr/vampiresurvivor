# Spec Delta

## Purpose

Define los jefes que aparecen cada cinco minutos: cuándo llegan, cómo atacan, cómo se muestran y qué dan al derrotarlos.

## ADDED Requirements

### Requirement: Un jefe cada cinco minutos
Cada 5 minutos de partida (5:00, 10:00, 15:00…) SHALL aparecer un jefe, justo fuera de la pantalla, alternando entre el Gólem de la cripta, la Reina bruja y el Rey calabaza. Cinco segundos antes MUST mostrarse "¡Se acerca un jefe!" con su nombre. Si el jefe anterior sigue vivo, el siguiente SHALL esperar a que lo derroten. Su vida MUST crecer con el tiempo de partida, la dificultad y el cooperativo, como la del resto de enemigos, y cada vuelta completa de los tres jefes SHALL añadir un 50 % más.

#### Scenario: Primer jefe
- **WHEN** la partida llega a 4:55
- **THEN** aparece "¡Se acerca un jefe! Gólem de la cripta" y, a las 5:00, el gólem gigante entra en escena

#### Scenario: Jefe sin derrotar
- **WHEN** llegan las 10:00 y el jefe de las 5:00 sigue vivo
- **THEN** no aparece un segundo jefe hasta derrotar al primero

### Requirement: Ataques de los jefes
Cada jefe SHALL perseguir al jugador vivo más cercano y usar sus ataques por turnos, uno cada pocos segundos:
- **anillo**: 14 pociones en todas direcciones, cada una con el 40 % de su daño de ataque;
- **golpe**: un círculo rojo en el suelo avisa durante 1,2 s y, al terminar, daña a quien siga dentro; el jefe se queda quieto mientras lo carga;
- **esbirros**: aparecen 7 enemigos de la oleada actual a su alrededor.

El jefe NO MUST recibir empuje, y la bomba SHALL quitarle solo el 4 % de su vida.

#### Scenario: Esquivar el golpe
- **WHEN** aparece el círculo rojo bajo el jefe y el jugador sale de él antes de que termine
- **THEN** el golpe no le hace daño

#### Scenario: Anillo de pociones
- **WHEN** el jefe usa el anillo
- **THEN** salen 14 pociones en todas direcciones desde el jefe

### Requirement: Barra del jefe
Mientras haya un jefe, el HUD SHALL mostrar su nombre y su barra de vida bajo el tiempo, también al invitado en cooperativo. La barra MUST desaparecer al derrotarlo.

#### Scenario: Barra de vida
- **WHEN** el jefe pierde la mitad de su vida
- **THEN** la barra bajo el tiempo está a la mitad

### Requirement: Recompensa del jefe
Al derrotar a un jefe, cada jugador SHALL recibir su propia elección "¡Jefe derrotado!" de rareza épica o superior (las armas nuevas salen, como siempre, comunes). El jefe MUST soltar además un alma grande y 30 monedas.

#### Scenario: Derrotar al jefe en cooperativo
- **WHEN** los dos jugadores derrotan a un jefe
- **THEN** a cada uno le aparece "¡Jefe derrotado!" con mejoras épicas o legendarias, en su pantalla
