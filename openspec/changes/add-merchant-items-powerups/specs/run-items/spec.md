# Spec Delta

## Purpose

Objetos que el jugador consigue durante la partida, con rareza fija y efectos que se acumulan, para dar más variedad a cada partida además de las mejoras de nivel.

## ADDED Requirements

### Requirement: Catálogo de objetos
El juego SHALL tener 17 objetos con nombre, icono, rareza fija y efecto: 4 comunes, 4 poco comunes, 3 raros, 3 épicos y 3 legendarios, para que todo comerciante pueda ofrecer 3 objetos de su rareza. La rareza MUST usar los mismos colores que las mejoras de nivel.

#### Scenario: Objeto con su rareza
- **WHEN** se muestra un objeto en la tienda o en el HUD
- **THEN** aparece con su icono y el color de su rareza

### Requirement: Acumulación
Comprar un objeto que ya se tiene SHALL añadirle una copia más (pila), y su efecto MUST crecer con cada copia según su descripción.

#### Scenario: Segunda copia
- **WHEN** el jugador tiene "Calabaza podrida" (15 % de envenenar) y compra otra
- **THEN** pasa a tener 2 copias y un 30 % de probabilidad de envenenar

### Requirement: Efectos al golpear
Los objetos de efecto al golpear (veneno, congelación, eco, nube venenosa, ejecución) SHALL activarse solo con los golpes de las armas, no con el daño que causan otros objetos.

#### Scenario: Veneno
- **WHEN** un arma golpea a un enemigo y se activa "Calabaza podrida"
- **THEN** el enemigo queda envenenado, se tiñe de verde y pierde vida durante 3 segundos

#### Scenario: Congelación
- **WHEN** se activa "Cristal de escarcha" sobre un enemigo
- **THEN** el enemigo se queda quieto, teñido de azul, durante 1,5 segundos y no hace daño por contacto

#### Scenario: Ejecución
- **WHEN** se activa "Daga del verdugo" sobre un enemigo que no es élite
- **THEN** el enemigo muere al instante y el daño del jugador sube un 1 % para el resto de la partida

### Requirement: Efectos al matar y al recibir daño
Los objetos de efecto al matar (caramelo curativo, curar al matar, cosechador de almas) SHALL activarse con cada enemigo muerto, y el de efecto al recibir daño (espejo) MUST activarse cada vez que el jugador pierde vida.

#### Scenario: Espejo roto
- **WHEN** un enemigo daña al jugador y este tiene "Espejo roto"
- **THEN** los enemigos cercanos reciben el doble del daño recibido

### Requirement: Objetos sin topes y en porcentaje
Ningún objeto SHALL tener máximo, y sus efectos MUST expresarse en porcentaje (de daño, de vida máxima o de velocidad) en lugar de puntos fijos.

#### Scenario: Reloj sin tope
- **WHEN** el jugador acumula 5 relojes de bolsillo malditos
- **THEN** sus armas tienen +75 % de velocidad de ataque, sin límite del 50 %

### Requirement: Objetos en el HUD
El HUD SHALL mostrar los objetos que tiene el jugador con su icono, el color de su rareza y el número de copias.

#### Scenario: Comprar un objeto
- **WHEN** el jugador compra un objeto nuevo
- **THEN** aparece en la fila de objetos del HUD con "1"
