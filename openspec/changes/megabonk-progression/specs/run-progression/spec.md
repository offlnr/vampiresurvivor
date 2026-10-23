# Spec Delta

## MODIFIED Requirements

### Requirement: Rareza de las mejoras
Cada opción SHALL salir con una rareza: común (gris), poco común (verde), rara (azul), épica (morada) o legendaria (dorada), con probabilidades base de 60, 25, 10, 4 y 1 %. Como en Megabonk, la rareza multiplica el efecto de cualquier mejora (arma o pergamino) por 1; 1,2; 1,4; 1,6 o 2. También en las cantidades, que se acumulan con decimales: "+1 proyectil" da +1,2 en poco común y +2 en legendaria. El valor de una mejora MUST depender solo de su rareza, nunca del nivel del jugador. La carta MUST mostrarse con el color de su rareza.

#### Scenario: Pasiva épica
- **WHEN** el jugador elige el pergamino de daño con rareza épica y el efecto base es +8 %
- **THEN** su daño sube un 12,8 %, tanto a nivel 2 como a nivel 40

#### Scenario: Arma rara
- **WHEN** el jugador elige una mejora de arma de rareza rara
- **THEN** el arma sube un nivel y gana 2 estadísticas con su valor común multiplicado por 1,4

#### Scenario: Arma nueva
- **WHEN** se ofrece un arma que el jugador aún no tiene
- **THEN** la carta es común y el arma empieza con sus estadísticas base

### Requirement: Suerte
La suerte del jugador SHALL aumentar la probabilidad de las rarezas altas como en Megabonk:
- se calcula un bonus = ln(suerte + 1) × 1,5;
- el peso base de cada rareza se multiplica por 1,5 elevado a −(escalones que le faltan hasta legendaria × bonus).

Así, la suerte MUST reducir sobre todo las comunes, con rendimientos decrecientes, y dejar intacto el peso de la legendaria.

#### Scenario: Sin suerte
- **WHEN** el jugador tiene suerte 0
- **THEN** las rarezas salen con 60, 25, 10, 4 y 1 % de probabilidad

#### Scenario: Más suerte, mejores cartas
- **WHEN** el jugador tiene suerte 1
- **THEN** salen aproximadamente un 43 % de comunes y un 4 % de legendarias

#### Scenario: Rendimientos decrecientes
- **WHEN** el jugador pasa de suerte 1 a suerte 3
- **THEN** sus cartas mejoran, pero el bonus de suerte crece menos que la suerte

### Requirement: Volver a tirar y desterrar
Cada carta de mejora, de cofre o del comerciante SHALL tener dos botones:
- volver a tirar: cambia solo esa carta por otra opción;
- desterrar: quita esa opción para el resto de la partida y la cambia por otra.

Lo desterrado (un arma con todas sus mejoras, un pergamino o un objeto) MUST NOT volver a salir en ningún sitio durante esa partida: cartas de nivel, cofres de élite, cofres de pago ni comerciantes. La pantalla de subida de nivel y de cofre MUST tener además un botón "Saltar" que, como en Megabonk, rechaza la elección sin coger nada y sin gastar un destierro. El jugador MUST tener 5 tiradas, 5 destierros y 5 saltos por partida, y la pantalla muestra cuántos le quedan.

#### Scenario: Volver a tirar una carta
- **WHEN** el jugador pulsa volver a tirar en la segunda de tres cartas
- **THEN** solo esa carta cambia por otra opción distinta de las otras dos, y le quedan 4 tiradas

#### Scenario: Desterrar
- **WHEN** el jugador destierra el pergamino de suerte
- **THEN** la carta se sustituye por otra opción y el pergamino de suerte no vuelve a ofrecerse en esa partida

#### Scenario: Desterrar un arma
- **WHEN** el jugador destierra la carta de un arma, nueva o de mejora
- **THEN** esa arma no vuelve a ofrecerse ni como arma nueva ni como mejora en toda la partida

#### Scenario: Desterrar sin sustituto
- **WHEN** el jugador destierra un objeto en una tienda y no queda ningún objeto con el que sustituirlo
- **THEN** la carta desaparece de la tienda; el objeto desterrado nunca sigue a la venta

#### Scenario: Comerciante que llegó antes
- **WHEN** el jugador destierra un objeto en un cofre y luego visita a un comerciante que ya lo ofrecía
- **THEN** la tienda no muestra ese objeto

#### Scenario: Cofre con comunes desterrados
- **WHEN** el jugador ha desterrado todos los objetos comunes y abre un cofre de pago
- **THEN** el cofre muestra 3 objetos, ninguno desterrado, aunque tengan que ser de otra rareza

#### Scenario: Saltar
- **WHEN** el jugador pulsa "Saltar" al subir de nivel
- **THEN** no coge ninguna mejora, le quedan 4 saltos y la partida sigue (o se muestra la siguiente elección pendiente)

#### Scenario: Sin saltos
- **WHEN** el jugador ya usó sus 5 saltos
- **THEN** el botón "Saltar" está desactivado

#### Scenario: Sin tiradas
- **WHEN** el jugador ya usó sus 5 tiradas
- **THEN** el botón de volver a tirar está desactivado

### Requirement: Tipos de mejora
Las opciones SHALL incluir armas nuevas, mejoras de las armas que ya se tienen y pergaminos (como los libros de Megabonk). Hay 11 pergaminos:
- 10 en porcentaje: vida máxima, velocidad, imán, velocidad de ataque, daño, suerte, robo de vida, armadura, tamaño y experiencia;
- 1 en cantidad: multiplicidad, que da proyectiles extra a todas las armas: +1 por nivel común, multiplicado por la rareza y con decimales.

Como en Megabonk con todos los huecos desbloqueados, el jugador MUST poder llevar como mucho 4 armas y 4 pergaminos distintos por partida, sin límite de niveles en cada uno, y ninguna mejora tiene máximo. Los valores comunes de los pergaminos que se conocen de Megabonk son: daño +8 %, velocidad de ataque +7,5 % y experiencia +7 %.

#### Scenario: Límite de pergaminos
- **WHEN** el jugador ya tiene 4 pergaminos distintos
- **THEN** solo se le ofrecen mejoras de esos 4, nunca un pergamino nuevo

#### Scenario: Multiplicidad con decimales
- **WHEN** el jugador coge un pergamino de multiplicidad poco común (+1,2) y otro raro (+1,4)
- **THEN** tiene +2,6 proyectiles, y un arma de 1 proyectil dispara 3 (se cuenta la parte entera)

#### Scenario: Experiencia
- **WHEN** el jugador tiene +20 % de experiencia y recoge un alma de 10
- **THEN** gana 12 de experiencia

#### Scenario: Mejora pasiva
- **WHEN** el jugador elige la pasiva de velocidad de movimiento
- **THEN** el personaje se mueve más rápido durante el resto de la partida

#### Scenario: Armadura
- **WHEN** el jugador tiene dos niveles de armadura de +10 % y un enemigo que hace 100 de daño lo toca
- **THEN** el jugador pierde 81 de vida (cada nivel reduce el daño restante, así que nunca llega al 100 %)

### Requirement: Curva de experiencia
Para subir cada nivel SHALL hacer falta más experiencia que para el anterior, como en Megabonk: los primeros niveles llegan rápido y los altos cuestan cada vez más. La experiencia que sobra al subir MUST conservarse para el nivel siguiente. La ganancia de experiencia MUST tener un tope de ×10. Las almas MUST verse de tres tipos según su valor, como las gemas de Megabonk: menos de 10, 10 o más, y 50 o más.

#### Scenario: Primeros niveles rápidos
- **WHEN** el jugador empieza una partida
- **THEN** necesita 3 de experiencia para el nivel 2, 5 para el nivel 3 y 9 para el nivel 4

#### Scenario: Tope de experiencia
- **WHEN** el jugador acumula más de +900 % de experiencia
- **THEN** gana como mucho 10 veces la experiencia de cada alma

#### Scenario: Subida con excedente
- **WHEN** el jugador recoge más experiencia de la que le faltaba para subir de nivel
- **THEN** sube de nivel y la experiencia sobrante cuenta para el siguiente

## REMOVED Requirements

### Requirement: Mejoras que crecen con el nivel
**Reason**: En Megabonk el valor de una mejora depende solo de su rareza; no hay mejoras más débiles al principio ni más fuertes al final.
**Migration**: `run.upgrade_scale()` desaparece; `Weapon.roll_upgrade()` y `UpgradeData.roll_amount()` ya no reciben `strength`.
