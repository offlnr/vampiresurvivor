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
Para subir cada nivel SHALL hacer falta más experiencia que para el anterior. La experiencia que sobra al subir MUST conservarse para el nivel siguiente.

#### Scenario: Subida con excedente
- **WHEN** el jugador recoge más experiencia de la que le faltaba para subir de nivel
- **THEN** sube de nivel y la experiencia sobrante cuenta para el siguiente

### Requirement: Selección de mejora al subir de nivel
Al subir de nivel, la partida SHALL pausarse y mostrar 3 opciones de mejora distintas, sacadas al azar de las disponibles. La partida continúa cuando el jugador elige una.

#### Scenario: Elegir mejora
- **WHEN** el jugador sube de nivel
- **THEN** la partida se pausa, se muestran 3 mejoras distintas con nombre, icono y descripción, y al elegir una se aplica y la partida continúa

#### Scenario: Varias subidas seguidas
- **WHEN** una sola recogida da experiencia para subir 2 niveles
- **THEN** se muestran 2 selecciones de mejora, una detrás de otra

#### Scenario: Pocas mejoras disponibles
- **WHEN** quedan menos de 3 mejoras disponibles
- **THEN** se muestran solo las que quedan y, si no queda ninguna, se ofrece una recompensa de respaldo (curar vida)

### Requirement: Tipos de mejora
Las opciones SHALL incluir armas nuevas, subidas de nivel de armas que ya se tienen y mejoras pasivas. El MVP MUST incluir al menos 4 pasivas: vida máxima, velocidad de movimiento, radio de atracción y reducción de recarga.

#### Scenario: Mejora pasiva
- **WHEN** el jugador elige la pasiva de velocidad de movimiento
- **THEN** el personaje se mueve más rápido durante el resto de la partida

### Requirement: Progresión limitada a la partida
Todas las mejoras y la experiencia SHALL reiniciarse al empezar una partida nueva.

#### Scenario: Nueva partida
- **WHEN** el jugador empieza otra partida tras terminar una
- **THEN** el personaje vuelve a nivel 1, sin experiencia, y solo con el arma inicial
