# Spec Delta

## MODIFIED Requirements

### Requirement: Tipos de mejora
Las opciones SHALL incluir armas nuevas, mejoras de las armas que ya se tienen y pergaminos (como los libros de Megabonk). Hay 11 pergaminos:
- 10 en porcentaje: vida máxima, velocidad, imán, velocidad de ataque, daño, suerte, robo de vida, armadura, tamaño y experiencia;
- 1 en cantidad: multiplicidad, que da proyectiles extra a todas las armas.

El jugador MUST poder tener como mucho 5 pergaminos distintos por partida, sin límite de niveles en cada uno, y ninguna mejora tiene máximo.

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

#### Scenario: Multiplicidad común
- **WHEN** en la primera subida de nivel sale el pergamino de multiplicidad con rareza común
- **THEN** la carta dice "+1 a la cantidad de proyectiles de todas las armas", sin porcentaje y sin reducirse a la mitad por ser el principio de la partida

#### Scenario: Multiplicidad por rareza
- **WHEN** sale el pergamino de multiplicidad con rareza poco común, rara, épica o legendaria
- **THEN** da +2, +3, +4 o +5 proyectiles a todas las armas, respectivamente: dos rarezas distintas nunca dan lo mismo
