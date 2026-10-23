# Spec Delta

## MODIFIED Requirements

### Requirement: Volver a tirar y desterrar
Cada carta de mejora, de cofre o del comerciante SHALL tener dos botones:
- volver a tirar: cambia solo esa carta por otra opción;
- desterrar: quita esa opción para el resto de la partida y la cambia por otra.

Lo desterrado (un arma con todas sus mejoras, un pergamino o un objeto) MUST NOT volver a salir en ningún sitio durante esa partida: cartas de nivel, cofres de élite, cofres de pago ni comerciantes. El jugador MUST tener 5 tiradas y 5 destierros por partida, y la pantalla muestra cuántos le quedan.

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

#### Scenario: Sin tiradas
- **WHEN** el jugador ya usó sus 5 tiradas
- **THEN** el botón de volver a tirar está desactivado
