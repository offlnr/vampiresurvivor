# Proposal

## Why

Tras jugar el MVP, el jugador quiere más decisiones durante la partida, al estilo de *Megabonk*: un comerciante que aparece por el mapa y vende objetos de distintas rarezas, y power-ups que sueltan los enemigos (detener el tiempo, imán de experiencia, bomba, etc.). Ahora mismo la única fuente de mejoras es subir de nivel, y el mapa no tiene nada que buscar.

## What Changes

- **Oro**: los enemigos sueltan monedas de oro de vez en cuando (los élites, muchas). El oro se recoge como las almas y se ve en el HUD.
- **Objetos**: 17 objetos con mecánicas inspiradas en Megabonk pero con nombre y dibujo propios de Halloween (veneno al golpear, congelar, muñeco vudú, daga del verdugo, cosechador de almas, imán succionador...). Cada objeto tiene una rareza fija (común, poco común, rara, épica, legendaria), se acumula si se compra varias veces y se ve en el HUD.
- **Comerciante sombrío**: aparece cada cierto tiempo en un punto del mapa. El color de su sombrero indica la rareza de lo que vende. Ofrece 3 objetos de esa rareza; se puede comprar uno con oro y luego se va. Si nadie le compra, se marcha al cabo de un rato.
- **Power-ups**: al morir, los enemigos sueltan a veces un power-up que se recoge al tocarlo: corazón (cura), reloj (detiene el tiempo), imán (atrae todas las almas y el oro), bomba de calabaza (mata a los enemigos en pantalla), escoba (velocidad), furia (recarga más rápida), lluvia de oro (doble de oro) y escudo (invulnerable). Los élites siempre sueltan uno.
- **Minimapa**: en una esquina del HUD, con el jugador, el comerciante (con el color de su rareza), los cofres, los power-ups y los élites. Lo que queda fuera se marca en el borde.

**Fuera de alcance:** moneda entre partidas (plata), desbloqueos permanentes, santuarios, microondas y vasijas del mapa, y copiar nombres o arte de Megabonk.

## Capabilities

### New Capabilities
- `run-items`: objetos que se consiguen durante la partida, sus rarezas, acumulación y efectos.
- `merchant-shop`: oro, comerciante sombrío y compra de objetos.
- `power-ups`: power-ups que sueltan los enemigos y sus efectos temporales.
- `minimap`: minimapa del HUD con los puntos de interés.

### Modified Capabilities
<!-- Ninguna: las capacidades del MVP siguen en el cambio halloween-survivor-mvp, sin archivar. Este cambio solo añade capacidades nuevas. -->

## Impact

- **Código**: nuevos `ItemData`, `Inventory`, comerciante, menú de tienda, minimapa y power-ups. Se tocan `EnemyManager` (estados veneno/congelado, detener el tiempo, ganchos al golpear y al matar), `PickupManager` (oro y power-ups), `Player` (buffs temporales), `Weapon` (multiplicadores de objetos y buffs) y el HUD.
- **Datos**: 15 `.tres` de objetos y la tabla de power-ups.
- **Arte y sonido**: iconos de objetos y power-ups, moneda, comerciante y sonidos nuevos, todo provisional y propio.
- **Depende de** `halloween-survivor-mvp` (rarezas, recogibles, élites).
