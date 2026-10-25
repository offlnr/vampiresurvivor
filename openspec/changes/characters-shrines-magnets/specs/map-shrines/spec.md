# Spec Delta

## Purpose

Define las estructuras del mapa al estilo de Megabonk: los santuarios de poder, que mejoran las estadísticas del personaje sin pergaminos, y los tótems imán, que atraen la experiencia.

## ADDED Requirements

### Requirement: Santuarios de poder
El mapa SHALL tener 2 santuarios de poder alrededor de los jugadores, con un círculo dorado en el suelo. Quedarse 4 s dentro MUST cargarlo; un anillo SHALL mostrar la carga, que baja poco a poco al salir. Un santuario usado MUST volver a aparecer en otro sitio a los 50 s.

#### Scenario: Cargar un santuario
- **WHEN** el jugador se queda 4 segundos dentro del círculo de un santuario
- **THEN** la partida se para y aparece "Santuario de poder"

#### Scenario: Salir del círculo
- **WHEN** el jugador sale del círculo antes de completar la carga
- **THEN** el anillo se vacía poco a poco y, si vuelve, sigue cargando desde donde se quedó

### Requirement: Mejoras del santuario
Al cargarse un santuario, el jugador que lo cargó SHALL elegir 1 de 3 mejoras de estadística con rareza. Cada una MUST valer lo mismo que un pergamino de esa rareza y subir la estadística directamente, sin ocupar hueco de pergamino.

#### Scenario: Elegir una mejora
- **WHEN** aparece "Santuario de poder"
- **THEN** muestra 3 mejoras como "Escudo: +15 de escudo" o "Velocidad: +8 % de velocidad"

#### Scenario: Sin hueco de pergamino
- **WHEN** el jugador tiene 4 pergaminos y elige una mejora de un santuario
- **THEN** la estadística sube y el jugador sigue con los mismos 4 pergaminos

#### Scenario: Volver a tirar y saltar
- **WHEN** el jugador está en el menú de un santuario
- **THEN** puede volver a tirar una carta o saltar la elección, pero no desterrar

### Requirement: Tótems imán
El mapa SHALL tener 1 tótem imán alrededor de los jugadores, con un círculo rojo. Quedarse 1 s encima MUST atraer todas las almas y monedas del mapa y mostrar "¡Imán!". El tótem usado SHALL volver a aparecer en otro sitio a los 70 s.

#### Scenario: Usar un imán
- **WHEN** el jugador se queda un segundo encima de un tótem imán
- **THEN** todas las almas y monedas del mapa vuelan hacia los jugadores

### Requirement: Estructuras en cooperativo
En cooperativo, cualquiera de los dos jugadores SHALL poder usar los santuarios y los imanes, y el invitado MUST verlos con su círculo y su carga. El menú de un santuario SHALL abrirse solo en la pantalla de quien lo cargó, y la partida MUST seguir parada hasta que elija.

#### Scenario: El invitado carga un santuario
- **WHEN** el personaje del invitado carga un santuario
- **THEN** solo el invitado ve "Santuario de poder" y la mejora elegida sube las estadísticas de su personaje
