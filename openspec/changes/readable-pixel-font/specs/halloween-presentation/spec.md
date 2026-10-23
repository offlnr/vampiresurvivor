# Spec Delta

## MODIFIED Requirements

### Requirement: Interfaz pixel art
Toda la interfaz SHALL usar una fuente pixel art con licencia libre (Jersey 10, OFL), registrada en los créditos, cuyos dígitos MUST distinguirse entre sí sin ambigüedad, y paneles y botones de esquinas rectas con borde y sombra en bloque. Las cartas de mejora, de la tienda y de los cofres MUST mostrarse en una lista vertical de cartas compactas (icono a la izquierda, texto a la derecha) en cualquier orientación de pantalla.

#### Scenario: Cartas en vertical
- **WHEN** se abre la selección de mejora en una pantalla horizontal
- **THEN** las 3 cartas aparecen una debajo de otra, compactas, con sus botones de volver a tirar y desterrar al lado

#### Scenario: Fuente pixel art
- **WHEN** se muestra cualquier texto del juego, con acentos y eñes
- **THEN** usa la fuente pixel art y todos los caracteres se ven bien

#### Scenario: Números legibles
- **WHEN** el HUD muestra un tiempo como "12:58", oro como "250" o un número de daño
- **THEN** cada dígito se reconoce sin confundirlo con otro (5, 6, 8, 0 y 3 se ven distintos)
