# Spec Delta

## Purpose

Define cómo el jugador gana experiencia durante una partida, sube de nivel y elige mejoras de armas o pasivas que cambian su forma de jugar.

## ADDED Requirements

### Requirement: Recoger almas de experiencia
Las almas que sueltan los enemigos SHALL quedarse en el suelo. Cuando el jugador entra en su radio de atracción, MUST volar hacia él y sumarle experiencia al tocarlo.

#### Scenario: Atracción y recogida
- **WHEN** el personaje se acerca a un alma hasta su radio de atracción
- **THEN** el alma se mueve hacia el personaje y, al tocarlo, desaparece y suma su experiencia

#### Scenario: Fuera de radio
- **WHEN** un alma está fuera del radio de atracción
- **THEN** se queda quieta en el suelo

### Requirement: Curva de experiencia
Para subir cada nivel SHALL hacer falta más experiencia que para el anterior. La experiencia que sobra al subir MUST conservarse para el nivel siguiente. La curva MUST estar ajustada para que un jugador que recoge todas las almas llegue a un nivel entre 30 y 40 al minuto 10, a nivel 8 o más al minuto 1 y a nivel 12 o más al minuto 2.

#### Scenario: Primeros niveles rápidos
- **WHEN** el jugador empieza una partida
- **THEN** necesita como mucho 5 de experiencia para el nivel 2, 10 para el nivel 3 y 20 para el nivel 4, y cada murciélago da 2 de experiencia, cada zombi 3 y cada fantasma 6, de modo que 3 murciélagos bastan para el nivel 2

#### Scenario: Subida con excedente
- **WHEN** el jugador recoge más experiencia de la que le faltaba para subir de nivel
- **THEN** sube de nivel y la experiencia sobrante cuenta para el siguiente

### Requirement: Selección de mejora al subir de nivel
Al subir de nivel, la partida SHALL pausarse y mostrar 3 opciones de mejora distintas, sacadas al azar de las disponibles. La partida continúa cuando el jugador elige una.

#### Scenario: Elegir mejora
- **WHEN** el jugador sube de nivel
- **THEN** la partida se pausa, se muestran 3 mejoras distintas con nombre, icono, rareza y descripción con el valor final, y al elegir una se aplica y la partida continúa

#### Scenario: Sin descripciones vagas
- **WHEN** se muestra una mejora pasiva, una subida de nivel de un arma o un objeto
- **THEN** su descripción indica el valor exacto del efecto (porcentaje, cantidad, duración o intervalo); las armas nuevas solo llevan una frase corta que explica qué hacen

#### Scenario: Varias subidas seguidas
- **WHEN** una sola recogida da experiencia para subir 2 niveles
- **THEN** se muestran 2 selecciones de mejora, una detrás de otra

#### Scenario: Pocas mejoras disponibles
- **WHEN** quedan menos de 3 mejoras disponibles (por ejemplo, porque casi todo está desterrado)
- **THEN** se muestran solo las que quedan y, si no queda ninguna, se ofrece una recompensa de respaldo (curar vida u oro)

### Requirement: Mejoras que crecen con el nivel
El valor de las mejoras de arma y de los pergaminos (salvo cantidades como "+1 calabaza") SHALL escalar con el nivel del jugador: la mitad en la primera subida de nivel (nivel 2), el valor normal a nivel 22 y MUST seguir creciendo después, sin tope.

#### Scenario: Mejora pequeña al principio
- **WHEN** en la primera subida de nivel sale una mejora común de daño de la calabaza (valor normal +25 %)
- **THEN** la carta ofrece +13 %

#### Scenario: Mejora grande al final
- **WHEN** a nivel 42 sale esa misma mejora
- **THEN** la carta ofrece +38 %

### Requirement: Volver a tirar y desterrar
Cada carta de mejora, de cofre o del comerciante SHALL tener dos botones: volver a tirar (cambia solo esa carta por otra opción) y desterrar (quita esa opción para el resto de la partida y la cambia por otra). El jugador MUST tener 5 tiradas y 5 destierros por partida, y la pantalla muestra cuántos le quedan.

#### Scenario: Volver a tirar una carta
- **WHEN** el jugador pulsa volver a tirar en la segunda de tres cartas
- **THEN** solo esa carta cambia por otra opción distinta de las otras dos, y le quedan 4 tiradas

#### Scenario: Desterrar
- **WHEN** el jugador destierra el pergamino de suerte
- **THEN** la carta se sustituye por otra opción y el pergamino de suerte no vuelve a ofrecerse en esa partida

#### Scenario: Sin tiradas
- **WHEN** el jugador ya usó sus 5 tiradas
- **THEN** el botón de volver a tirar está desactivado

### Requirement: Tipos de mejora
Las opciones SHALL incluir armas nuevas, mejoras de las armas que ya se tienen y pergaminos (como los libros de Megabonk). Hay 10 pergaminos, todos en porcentaje: vida máxima, velocidad, imán, velocidad de ataque, daño, suerte, robo de vida, armadura, tamaño y experiencia. El jugador MUST poder tener como mucho 5 pergaminos distintos por partida, sin límite de niveles en cada uno, y ninguna mejora tiene máximo.

#### Scenario: Límite de pergaminos
- **WHEN** el jugador ya tiene 5 pergaminos distintos
- **THEN** solo se le ofrecen mejoras de esos 5, nunca un pergamino nuevo

#### Scenario: Experiencia
- **WHEN** el jugador tiene +20 % de experiencia y recoge un alma de 10
- **THEN** gana 12 de experiencia

#### Scenario: Mejora pasiva
- **WHEN** el jugador elige la pasiva de velocidad de movimiento
- **THEN** el personaje se mueve más rápido durante el resto de la partida

#### Scenario: Armadura
- **WHEN** el jugador tiene dos niveles de armadura de +10 % y un enemigo que hace 100 de daño lo toca
- **THEN** el jugador pierde 81 de vida (cada nivel reduce el daño restante, así que nunca llega al 100 %)

### Requirement: Rareza de las mejoras
Cada opción SHALL salir con una rareza: común (gris), poco común (verde), rara (azul), épica (morada) o legendaria (dorada), con probabilidades base de 60, 25, 10, 4 y 1 %. La rareza multiplica el efecto de la mejora por 1; 1,5; 2; 3 o 4, y la carta MUST mostrarse con el color de su rareza.

#### Scenario: Pasiva épica
- **WHEN** el jugador elige el pergamino de daño con rareza épica y el efecto base es +12 %
- **THEN** su daño sube un 36 %

#### Scenario: Arma rara
- **WHEN** el jugador elige una mejora de arma de rareza rara
- **THEN** el arma sube un nivel y gana 2 estadísticas con su valor común multiplicado por 1,4

#### Scenario: Arma nueva
- **WHEN** se ofrece un arma que el jugador aún no tiene
- **THEN** la carta es común y el arma empieza con sus estadísticas base

### Requirement: Suerte
La suerte del jugador SHALL aumentar la probabilidad de las rarezas poco común, rara, épica y legendaria a costa de la común.

#### Scenario: Más suerte, mejores cartas
- **WHEN** el jugador tiene suerte alta y sube de nivel muchas veces
- **THEN** salen cartas de rareza rara o superior con más frecuencia que con suerte 0

### Requirement: Robo de vida
El robo de vida SHALL curar al jugador un porcentaje del daño que hacen sus armas, sin superar su vida máxima y sin otro límite.

#### Scenario: Curarse atacando
- **WHEN** el jugador tiene 2 % de robo de vida, le falta vida y sus armas hacen 100 de daño
- **THEN** recupera 2 de vida

### Requirement: Progresión limitada a la partida
Todas las mejoras y la experiencia SHALL reiniciarse al empezar una partida nueva.

#### Scenario: Nueva partida
- **WHEN** el jugador empieza otra partida tras terminar una
- **THEN** el personaje vuelve a nivel 1, sin experiencia, y solo con el arma inicial
