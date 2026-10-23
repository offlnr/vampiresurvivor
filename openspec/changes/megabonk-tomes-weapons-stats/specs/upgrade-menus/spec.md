# Spec Delta

## ADDED Requirements

### Requirement: Panel de estadísticas
El menú de subida de nivel (también el de cofre) y el menú de la tienda o cofre de pago SHALL tener un botón "Estadísticas". El botón abre un panel con:
- todas las estadísticas actuales del personaje;
- cada arma equipada con su nivel, su daño por golpe, su recarga y su cantidad.

Abrir el panel MUST NOT gastar nada ni cerrar el menú. Mientras está abierto, MUST NOT poder elegirse ninguna carta.

#### Scenario: Ver estadísticas al subir de nivel
- **WHEN** el jugador pulsa "Estadísticas" en la pantalla de subida de nivel
- **THEN** ve sus estadísticas y armas, y al pulsar "Volver" (o Esc) vuelve a las mismas cartas, sin cambios

#### Scenario: Ver estadísticas en la tienda
- **WHEN** el jugador pulsa "Estadísticas" en la tienda
- **THEN** ve sus estadísticas; Esc cierra el panel pero no la tienda

#### Scenario: Pantalla ancha
- **WHEN** la pantalla mide 1000 px de ancho o más
- **THEN** las estadísticas del personaje se muestran en dos columnas y caben sin desplazar
