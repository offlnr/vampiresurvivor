# Spec Delta

## Purpose

Oro que sueltan los enemigos y un comerciante que aparece por el mapa y vende objetos de una rareza concreta, para que el jugador tenga algo que buscar y decidir durante la partida.

## ADDED Requirements

### Requirement: Oro
Al morir, los enemigos SHALL soltar monedas de oro con cierta probabilidad (más los tipos más duros) y los élites MUST soltar siempre varias. Las monedas se atraen y se recogen como las almas, y el HUD muestra el oro acumulado.

#### Scenario: Recoger oro
- **WHEN** el jugador recoge una moneda
- **THEN** su oro sube en el HUD y suena una moneda

### Requirement: Aparición del comerciante
Un comerciante sombrío SHALL aparecer cada 80 segundos a partir del minuto 1:30, a cierta distancia del jugador, con un aviso en pantalla. Solo puede haber uno a la vez y MUST marcharse si pasan 60 segundos sin que nadie le compre.

#### Scenario: Llega un comerciante
- **WHEN** el temporizador llega a 1:30
- **THEN** aparece un comerciante fuera de la pantalla, el HUD avisa "¡Ha llegado un comerciante!" y el minimapa lo marca

### Requirement: Rareza del comerciante
Cada comerciante SHALL tener una rareza tirada al aparecer (con la suerte del jugador) y el color de su sombrero MUST indicarla. Vende 3 objetos de esa rareza, a un precio que sube con la rareza y con cada compra hecha en la partida.

#### Scenario: Sombrero dorado
- **WHEN** aparece un comerciante legendario
- **THEN** su sombrero es dorado y sus 3 objetos son legendarios

### Requirement: Comprar
Al acercarse al comerciante SHALL abrirse la tienda, que pausa la partida y muestra los 3 objetos con su precio y el oro del jugador. Comprar uno MUST descontar su precio, dárselo al jugador y hacer que el comerciante se marche. Salir sin comprar cierra la tienda y el comerciante sigue ahí.

#### Scenario: Comprar con oro suficiente
- **WHEN** el jugador tiene 40 de oro y compra un objeto de 30
- **THEN** le quedan 10 de oro, consigue el objeto y el comerciante desaparece

#### Scenario: Oro insuficiente
- **WHEN** un objeto cuesta más que el oro del jugador
- **THEN** su botón de compra está desactivado

#### Scenario: Volver a tirar o desterrar en la tienda
- **WHEN** el jugador pulsa volver a tirar o desterrar en un objeto del comerciante
- **THEN** ese objeto cambia por otro de la misma rareza, gastando una tirada o un destierro de la partida

#### Scenario: Salir sin comprar
- **WHEN** el jugador pulsa "Salir"
- **THEN** la tienda se cierra, la partida continúa y la tienda no vuelve a abrirse hasta que el jugador se aleja y se acerca de nuevo

### Requirement: Cofres en el mapa
Siempre SHALL haber varios cofres repartidos alrededor del jugador, fuera de la pantalla, marcados en el minimapa con su precio. Abrir uno MUST costar oro, y el precio sube con cada cofre abierto en la partida. Al abrirlo se muestran hasta 3 objetos (rareza tirada con la suerte para cada uno), de los que el jugador MUST poder tomar solo uno; cada uno se puede volver a tirar o desterrar.

#### Scenario: Abrir un cofre
- **WHEN** el jugador toca un cofre y tiene oro suficiente
- **THEN** paga el precio, la partida se pausa y se muestran 3 objetos con los botones de volver a tirar y desterrar

#### Scenario: Solo uno por cofre
- **WHEN** el jugador toma uno de los 3 objetos del cofre
- **THEN** recibe solo ese objeto y el cofre se cierra

#### Scenario: Cofre sin oro
- **WHEN** el jugador toca un cofre sin oro suficiente
- **THEN** el cofre no se abre y su precio se muestra en rojo

#### Scenario: Precio creciente
- **WHEN** el jugador abre un cofre
- **THEN** el siguiente cofre cuesta más que el anterior
