# Spec Delta

## MODIFIED Requirements

### Requirement: Tipos de mejora
Las opciones SHALL incluir armas nuevas, mejoras de las armas que ya se tienen y pergaminos (como los libros de Megabonk). Hay 22 pergaminos:
- **en porcentaje**: vida máxima, velocidad, imán, velocidad de ataque, daño, suerte, robo de vida, armadura, tamaño, experiencia, evasión, precisión (crítico), vuelo (velocidad de proyectiles), duración, empuje, codicia (oro), maldito (dificultad a cambio del doble en experiencia y oro) y caos (cada subida de nivel mejora una estadística al azar);
- **en valor fijo**: regeneración (vida por segundo), escudo y espinas;
- **en cantidad entera**: multiplicidad, que da proyectiles extra a todas las armas: el valor común (+1) por el multiplicador de rareza, redondeado.

Como en Megabonk con todos los huecos desbloqueados, el jugador MUST poder llevar como mucho 4 armas y 4 pergaminos distintos por partida, sin límite de niveles en cada uno, y ninguna mejora tiene máximo.

#### Scenario: Límite de pergaminos
- **WHEN** el jugador ya tiene 4 pergaminos distintos
- **THEN** solo se le ofrecen mejoras de esos 4, nunca un pergamino nuevo

#### Scenario: Multiplicidad entera
- **WHEN** sale el pergamino de multiplicidad
- **THEN** la carta dice "+1" si es común, poco común o rara, y "+2" si es épica o legendaria, nunca un número con decimales

#### Scenario: Multiplicidad acumulada
- **WHEN** el jugador coge un pergamino de multiplicidad poco común y otro épico
- **THEN** tiene +3 proyectiles, y un arma de 1 proyectil dispara 4

#### Scenario: Escudo
- **WHEN** el jugador tiene 15 de escudo y recibe un golpe de 10
- **THEN** su vida no baja y le quedan 5 de escudo; tras 4 segundos sin golpes, el escudo empieza a recargarse

#### Scenario: Evasión
- **WHEN** el jugador tiene evasión
- **THEN** cada golpe tiene una probabilidad de `e / (1 + e)` de no hacerle daño, que nunca llega al 100 %

#### Scenario: Espinas
- **WHEN** el jugador tiene espinas y un enemigo lo golpea
- **THEN** los enemigos que lo tocan reciben el daño de las espinas

#### Scenario: Maldito
- **WHEN** el jugador coge un pergamino maldito común
- **THEN** la dificultad sube un 5 %, y la experiencia y el oro un 10 %, sumándose a los calderos

#### Scenario: Caos
- **WHEN** el jugador tiene el pergamino del caos y sube de nivel
- **THEN** una estadística al azar mejora, y el HUD lo anuncia. Nunca es la de multiplicidad, maldito, caos ni la de un pergamino desterrado

#### Scenario: Experiencia
- **WHEN** el jugador tiene +20 % de experiencia y recoge un alma de 10
- **THEN** gana 12 de experiencia

#### Scenario: Armadura
- **WHEN** el jugador tiene dos niveles de armadura de +10 % y un enemigo que hace 100 de daño lo toca
- **THEN** el jugador pierde 81 de vida
