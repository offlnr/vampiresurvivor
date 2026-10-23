# Spec Delta

## Purpose

Estructuras y detalles que dan forma al cementerio infinito, para que el mapa tenga variedad, puntos de referencia y obstáculos.

## ADDED Requirements

### Requirement: Decoración del mapa
El mapa SHALL estar decorado con estructuras (mausoleos, árboles muertos, obeliscos, columnas rotas, farolas, montones de calabazas y lápidas grandes), pequeños cementerios en filas y detalles por el suelo (hierba alta, huesos, calaveras, setas y velas). Su colocación MUST variar de una partida a otra y MUST ser la misma al volver a un lugar dentro de la misma partida. La zona de inicio MUST quedar libre de estructuras.

#### Scenario: Mapa variado
- **WHEN** el jugador camina un minuto en cualquier dirección
- **THEN** encuentra estructuras y detalles distintos, sin un patrón que se repita en cuadrícula

#### Scenario: Volver a un sitio
- **WHEN** el jugador vuelve a un lugar por el que ya pasó
- **THEN** las estructuras y los detalles están en el mismo sitio que antes

#### Scenario: Inicio despejado
- **WHEN** empieza la partida
- **THEN** no hay ninguna estructura cerca del jugador

### Requirement: Estructuras sólidas
El jugador y los enemigos que caminan SHALL NOT atravesar las estructuras: chocan con su base y se deslizan alrededor. Los enemigos voladores (murciélagos y fantasmas) MUST pasar por encima. Los detalles pequeños y los cementerios MUST poder atravesarse. Los personajes MUST dibujarse delante o detrás de una estructura, lápida o cruz según sus pies estén por debajo o por encima de su base, y los detalles planos del suelo MUST dibujarse siempre debajo de los personajes.

#### Scenario: Chocar con un mausoleo
- **WHEN** el jugador camina hacia un mausoleo
- **THEN** se detiene en su base y puede rodearlo, sin entrar en él

#### Scenario: Enemigos detrás de una estructura
- **WHEN** varios zombis persiguen al jugador justo desde detrás de una estructura
- **THEN** la rodean y llegan hasta el jugador en pocos segundos

#### Scenario: Voladores
- **WHEN** un murciélago o un fantasma persigue al jugador a través de un mausoleo
- **THEN** pasa por encima sin desviarse

#### Scenario: Pasar por detrás
- **WHEN** el jugador camina por detrás de un árbol muerto
- **THEN** el árbol se dibuja delante del jugador

#### Scenario: Pasar por delante
- **WHEN** los pies del jugador están por delante de la base de un árbol, una lápida o una cruz
- **THEN** el jugador se dibuja delante de él

#### Scenario: Pisar detalles del suelo
- **WHEN** el jugador o un enemigo pisa hierba, huesos, calaveras, setas o velas
- **THEN** se dibujan siempre debajo del personaje

### Requirement: Nada inalcanzable
Ningún caldero, cofre, comerciante ni power-up SHALL aparecer dentro de una estructura.

#### Scenario: Calderos, cofres y comerciante
- **WHEN** aparece un caldero, un cofre de pago o un comerciante
- **THEN** está en un sitio libre, fuera de cualquier estructura

#### Scenario: Power-up sobre un mausoleo
- **WHEN** un murciélago muere sobre un mausoleo y suelta un power-up
- **THEN** el power-up aparece en el borde del mausoleo, donde el jugador puede cogerlo
