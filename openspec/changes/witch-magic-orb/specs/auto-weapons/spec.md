# Spec Delta

## MODIFIED Requirements

### Requirement: Arma inicial
El jugador SHALL empezar cada partida con el orbe arcano, de nivel 1, equipado: la bruja dispara bolas de magia morada.

#### Scenario: Inicio de partida
- **WHEN** empieza una nueva partida
- **THEN** el personaje lleva equipado el orbe arcano en nivel 1 y no tiene ninguna otra arma

### Requirement: Catálogo de armas del MVP
El juego SHALL ofrecer 7 armas con patrones distintos:
- orbe arcano: proyectil mágico al enemigo más cercano; es el arma inicial;
- calabaza: proyectil al enemigo más cercano; se consigue durante la partida;
- murciélagos: orbitan al jugador;
- niebla: aura de daño;
- guadaña: barrido en arco hacia el enemigo más cercano;
- hueso: bumerán que va y vuelve;
- fuego fatuo: zonas que queman bajo enemigos al azar.

#### Scenario: Proyectil dirigido
- **WHEN** ataca un arma de proyectil y hay enemigos en su rango
- **THEN** lanza un proyectil hacia el enemigo más cercano

#### Scenario: Proyectil sin objetivo
- **WHEN** ataca un arma de proyectil y no hay enemigos en su rango
- **THEN** no lanza ningún proyectil en ese ciclo

#### Scenario: Calabaza durante la partida
- **WHEN** el jugador sube de nivel, tiene menos de 3 armas y no tiene la calabaza
- **THEN** la calabaza puede salir como carta de "¡Nueva arma!"

#### Scenario: Orbitales
- **WHEN** el arma orbital está equipada
- **THEN** sus proyectiles giran alrededor del personaje y dañan a los enemigos que tocan

#### Scenario: Aura
- **WHEN** el arma de aura está equipada y hay enemigos dentro de su radio
- **THEN** esos enemigos reciben daño a intervalos regulares

#### Scenario: Guadaña
- **WHEN** ataca la guadaña
- **THEN** daña a todos los enemigos dentro de un arco orientado hacia el enemigo más cercano, sin importar hacia dónde se mueve el personaje

#### Scenario: Bumerán
- **WHEN** ataca el hueso
- **THEN** sale hacia el enemigo más cercano, se frena, vuelve hacia el personaje y daña a los enemigos que cruza a la ida y a la vuelta

#### Scenario: Zona de fuego
- **WHEN** ataca el fuego fatuo y hay enemigos en pantalla
- **THEN** cae una llama sobre enemigos al azar y deja una zona que daña durante unos segundos a quien la pisa

### Requirement: Alcance de las armas a distancia
El orbe arcano, la calabaza, el hueso y el fuego fatuo SHALL tener un alcance máximo: solo atacan a enemigos dentro de ese alcance y sus proyectiles MUST desaparecer al recorrerlo. Si no hay ningún enemigo dentro del alcance, el arma no ataca en ese ciclo.

#### Scenario: Enemigo fuera de alcance
- **WHEN** el único enemigo está más lejos que el alcance del orbe arcano
- **THEN** el orbe no dispara

#### Scenario: Proyectil que no acierta
- **WHEN** un orbe o una calabaza no toca a ningún enemigo
- **THEN** desaparece al llegar a su alcance máximo

### Requirement: Estadísticas del jugador en las armas
El daño, el tamaño y la recarga de todas las armas SHALL aplicar los multiplicadores pasivos del jugador (daño, área y recarga) y la bonificación de daño propia de cada arma ganada con mejoras raras. La cantidad de proyectiles de todas las armas MUST sumar los proyectiles extra del jugador, también en las armas conseguidas después.

#### Scenario: Pasiva de daño
- **WHEN** el jugador tiene +20 % de daño y una calabaza que hace 10 de daño impacta
- **THEN** el enemigo pierde 12 de vida

#### Scenario: Proyectiles extra
- **WHEN** el jugador tiene +1 proyectil del pergamino de multiplicidad y dispara el orbe arcano en nivel 1
- **THEN** salen 2 orbes

#### Scenario: Proyectiles extra en armas nuevas
- **WHEN** el jugador tiene +1 proyectil y consigue los murciélagos
- **THEN** los murciélagos empiezan con un murciélago más que su cantidad base

#### Scenario: Guadaña con proyectiles extra
- **WHEN** el jugador ya lleva la guadaña y coge el pergamino de multiplicidad
- **THEN** la guadaña corta en una dirección más desde su siguiente ataque, sin errores
