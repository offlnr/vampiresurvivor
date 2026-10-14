# Spec Delta

## Purpose

Define los enemigos de Halloween, cómo persiguen al jugador y cómo aparecen en oleadas que se vuelven más difíciles a medida que pasa la partida.

## ADDED Requirements

### Requirement: Tipos de enemigo del MVP
El juego SHALL incluir al menos 3 tipos de enemigo con atributos distintos: murciélago (rápido, poca vida), zombi (lento, vida media) y fantasma (velocidad media, más vida, aparece más tarde).

#### Scenario: Atributos diferenciados
- **WHEN** aparecen a la vez un murciélago y un zombi
- **THEN** el murciélago se mueve visiblemente más rápido que el zombi y muere con menos daño

### Requirement: Persecución
Cada enemigo SHALL moverse continuamente hacia la posición actual del jugador. Los enemigos MUST separarse entre sí lo suficiente para no amontonarse en un único punto.

#### Scenario: Seguir al jugador
- **WHEN** el jugador se desplaza
- **THEN** los enemigos cambian de dirección para seguir acercándose a él

#### Scenario: Sin superposición total
- **WHEN** muchos enemigos llegan a la vez hasta el jugador
- **THEN** forman un grupo repartido a su alrededor, no una sola pila

### Requirement: Aparición fuera de pantalla
Los enemigos SHALL aparecer justo fuera del área visible de la cámara, alrededor del jugador, para que nunca aparezcan encima de él.

#### Scenario: Punto de aparición
- **WHEN** aparece un enemigo nuevo
- **THEN** su posición está fuera de la pantalla pero lo bastante cerca para entrar en ella en pocos segundos

### Requirement: Dificultad creciente
El ritmo de aparición, la cantidad de enemigos a la vez y la mezcla de tipos SHALL seguir una tabla de oleadas según el tiempo de partida, y la dificultad MUST subir a lo largo de los 10 minutos.

#### Scenario: Inicio tranquilo
- **WHEN** lleva menos de 1 minuto de partida
- **THEN** solo aparecen murciélagos y zombis, a ritmo bajo

#### Scenario: Escalado
- **WHEN** lleva más de 5 minutos de partida
- **THEN** aparecen fantasmas y el ritmo de aparición es mayor que en el primer minuto

### Requirement: Límite de enemigos simultáneos
El juego SHALL limitar cuántos enemigos hay vivos a la vez, para mantener el rendimiento. Mientras se esté en el límite, MUST NOT aparecer ninguno nuevo.

#### Scenario: Límite alcanzado
- **WHEN** el número de enemigos vivos llega al límite configurado
- **THEN** no aparecen enemigos nuevos hasta que muera alguno

### Requirement: Recolocación de enemigos lejanos
Un enemigo que queda muy lejos del jugador SHALL reaparecer al otro lado, fuera de pantalla y en la dirección hacia la que va el jugador, para que la presión no desaparezca.

#### Scenario: Jugador escapa
- **WHEN** un enemigo queda a más del doble del tamaño de la pantalla de distancia del jugador
- **THEN** se recoloca fuera de pantalla, cerca del jugador

### Requirement: Muerte del enemigo
Cuando la vida de un enemigo llega a cero, este SHALL desaparecer, soltar una recompensa de experiencia y contar en el marcador de muertes.

#### Scenario: Enemigo derrotado
- **WHEN** la vida de un enemigo llega a 0
- **THEN** el enemigo desaparece con un efecto breve, deja un alma de experiencia y el marcador de muertes sube en 1
