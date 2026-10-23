# Spec Delta

## Purpose

Define las armas que atacan solas, sin que el jugador pulse nada, y cómo mejoran de nivel durante la partida. Es el núcleo del combate estilo Vampire Survivors.

## ADDED Requirements

### Requirement: Disparo automático
Cada arma equipada SHALL atacar sola, cada vez que pasa su tiempo de recarga, mientras la partida no esté en pausa. El jugador no pulsa nada para atacar.

#### Scenario: Ataque periódico
- **WHEN** pasa el tiempo de recarga de un arma equipada durante la partida
- **THEN** el arma ataca sin intervención del jugador

#### Scenario: Pausa detiene las armas
- **WHEN** la partida está en pausa o en la pantalla de elegir mejora
- **THEN** ninguna arma ataca y sus tiempos de recarga no avanzan

### Requirement: Arma inicial
El jugador SHALL empezar cada partida con un arma inicial, de nivel 1, equipada.

#### Scenario: Inicio de partida
- **WHEN** empieza una nueva partida
- **THEN** el personaje lleva equipada el arma inicial en nivel 1 y no tiene ninguna otra

### Requirement: Catálogo de armas del MVP
El juego SHALL ofrecer 6 armas con patrones distintos: calabaza (proyectil al enemigo más cercano), murciélagos (orbitan al jugador), niebla (aura de daño), guadaña (barrido en arco hacia el enemigo más cercano), hueso (bumerán que va y vuelve) y fuego fatuo (zonas que queman bajo enemigos al azar).

#### Scenario: Proyectil dirigido
- **WHEN** ataca el arma de proyectil y hay enemigos en su rango
- **THEN** lanza un proyectil hacia el enemigo más cercano

#### Scenario: Proyectil sin objetivo
- **WHEN** ataca el arma de proyectil y no hay enemigos en su rango
- **THEN** no lanza ningún proyectil en ese ciclo

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

### Requirement: Daño a enemigos
Cuando un ataque toca a un enemigo, este SHALL perder vida según el daño del arma, y MUST mostrarse un número de daño o un destello en el enemigo.

#### Scenario: Impacto
- **WHEN** un proyectil toca a un enemigo
- **THEN** el enemigo pierde vida igual al daño del arma y se ve una señal del impacto

### Requirement: Niveles de arma
Como en Megabonk, cada mejora de arma SHALL dar 1 estadística (común) o 2 (poco común o mejor), elegidas al azar de la lista propia de esa arma, y la rareza MUST multiplicar su valor (×1; ×1,2; ×1,4; ×1,6; ×2). Las armas no tienen nivel máximo ni topes. El daño MUST mejorar siempre en porcentaje ("+25 % de daño"), nunca en puntos.

#### Scenario: Solo mejoras
- **WHEN** un arma sube de nivel
- **THEN** ninguna de sus estadísticas empeora, y la carta solo enumera ganancias en positivo (una recarga más corta se muestra como "+X % de velocidad de ataque", nunca como una reducción)

#### Scenario: Valores exactos en la carta
- **WHEN** se ofrece una mejora común de la calabaza que sube su tamaño
- **THEN** la carta dice solo "+15 % de tamaño", nunca un texto vago como "más grande"

#### Scenario: Pocas estadísticas por carta
- **WHEN** se ofrece una mejora de arma
- **THEN** la carta muestra 1 estadística si es común y 2 si es de rareza superior, nunca más

#### Scenario: Subir un arma de nivel
- **WHEN** el jugador elige la mejora de un arma que ya tiene
- **THEN** el arma sube un nivel y su atributo mejorado se nota en la partida

#### Scenario: Daño en porcentaje
- **WHEN** se ofrece una mejora común de daño de la calabaza
- **THEN** la carta dice "+25 % de daño" y nunca un valor en puntos

#### Scenario: Sin topes
- **WHEN** la guadaña ya corta en 2 direcciones y sale otra mejora de cantidad
- **THEN** pasa a cortar en 3 direcciones repartidas alrededor del personaje

### Requirement: Alcance de las armas a distancia
La calabaza, el hueso y el fuego fatuo SHALL tener un alcance máximo: solo atacan a enemigos dentro de ese alcance y sus proyectiles MUST desaparecer al recorrerlo. Si no hay ningún enemigo dentro del alcance, el arma no ataca en ese ciclo.

#### Scenario: Enemigo fuera de alcance
- **WHEN** el único enemigo está más lejos que el alcance de la calabaza
- **THEN** la calabaza no lanza nada

#### Scenario: Proyectil que no acierta
- **WHEN** una calabaza no toca a ningún enemigo
- **THEN** desaparece al llegar a su alcance máximo

### Requirement: Límite de armas equipadas
El jugador SHALL poder llevar como máximo 3 armas a la vez, contando el arma inicial.

#### Scenario: Ranuras llenas
- **WHEN** el jugador ya tiene 3 armas equipadas
- **THEN** no se le ofrecen armas nuevas, solo mejoras de las que ya tiene o mejoras pasivas

### Requirement: Estadísticas del jugador en las armas
El daño, el tamaño y la recarga de todas las armas SHALL aplicar los multiplicadores pasivos del jugador (daño, área y recarga) y la bonificación de daño propia de cada arma ganada con mejoras raras.

#### Scenario: Pasiva de daño
- **WHEN** el jugador tiene +20 % de daño y una calabaza que hace 10 de daño impacta
- **THEN** el enemigo pierde 12 de vida

