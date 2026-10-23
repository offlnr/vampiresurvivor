# Spec Delta

## Purpose

Define los enemigos de Halloween, cómo persiguen al jugador y cómo aparecen en oleadas que se vuelven más difíciles a medida que pasa la partida.

## ADDED Requirements

### Requirement: Tipos de enemigo del MVP
El juego SHALL incluir 7 tipos de enemigo con atributos distintos: murciélago (rápido, poca vida), zombi (lento, vida media), esqueleto (velocidad y vida medias), fantasma (más vida), calabaza explosiva (muy rápida, explota al llegar), bruja (ataca a distancia) y gólem de lápida (muy lento, muchísima vida). Los nuevos aparecen escalonados entre el minuto 2 y el 7.

#### Scenario: Calabaza explosiva
- **WHEN** una calabaza explosiva llega junto al jugador
- **THEN** explota, daña al jugador si está dentro de la explosión y desaparece

#### Scenario: Bruja a distancia
- **WHEN** una bruja está a la distancia de ataque del jugador
- **THEN** se detiene, le lanza una poción que viaja en línea recta y daña al jugador si le acierta

#### Scenario: Gólem
- **WHEN** un gólem de lápida recibe golpes
- **THEN** no retrocede por el empuje de las armas

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
El ritmo de aparición, la cantidad de enemigos a la vez y la mezcla de tipos SHALL seguir una tabla de oleadas según el tiempo de partida, y la dificultad MUST subir sin límite: pasado el último tramo de la tabla, la vida, el daño, la velocidad, el ritmo y el número de enemigos siguen creciendo cada minuto.

#### Scenario: Inicio tranquilo
- **WHEN** lleva menos de 1 minuto de partida
- **THEN** solo aparecen murciélagos y zombis, a ritmo bajo y como mucho 12 a la vez, y un zombi muere con 2 calabazas del arma inicial

#### Scenario: Enemigos lentos al principio
- **WHEN** lleva menos de 1 minuto de partida
- **THEN** los murciélagos se mueven como mucho a la mitad de la velocidad base del jugador, y su velocidad sube poco a poco hasta su valor completo en el minuto 5

#### Scenario: Cada vez más rápidos y fuertes
- **WHEN** pasa cada minuto de partida, desde el principio
- **THEN** los enemigos nuevos son un poco más rápidos y hacen más daño que los del minuto anterior, sin límite

#### Scenario: Después del minuto 10
- **WHEN** lleva 15 minutos de partida
- **THEN** los enemigos tienen más vida y hacen más daño que en el minuto 10, y aparecen más rápido

#### Scenario: Escalado
- **WHEN** lleva más de 5 minutos de partida
- **THEN** aparecen fantasmas y el ritmo de aparición es mayor que en el primer minuto

### Requirement: Hordas periódicas
A partir del minuto 3, cada 60 segundos SHALL anunciarse una horda con un aviso en pantalla y un sonido, y 3 segundos después MUST llegar. Antes del minuto 3 no hay hordas, para que el jugador pueda armarse. Las hordas se alternan entre anillo de zombis que se cierra, enjambre de murciélagos que cruza la pantalla y carga de fantasmas desde un lado, y crecen con el tiempo. Los enemigos de una horda no cuentan para el límite de la oleada normal.

#### Scenario: Aviso de horda
- **WHEN** el temporizador llega a 2:57
- **THEN** aparece el aviso "¡Se acerca una horda!" y suena una alerta

#### Scenario: Sin hordas al principio
- **WHEN** la partida está en sus 3 primeros minutos (antes de 2:57)
- **THEN** no aparece ningún aviso ni ninguna horda

#### Scenario: Anillo
- **WHEN** llega una horda de tipo anillo
- **THEN** aparece un círculo de zombis fuera de pantalla alrededor del jugador que se cierra sobre él

#### Scenario: Enjambre
- **WHEN** llega una horda de tipo enjambre
- **THEN** un grupo numeroso de murciélagos cruza la pantalla en línea recta desde un lado y desaparece al salir por el otro

### Requirement: Enemigo élite
Cada horda SHALL incluir un enemigo élite: una versión más grande del tipo de la horda, con mucha más vida, un contorno dorado y una barra de vida propia. Al morir MUST soltar un cofre.

#### Scenario: Élite derrotado
- **WHEN** el jugador mata al élite de una horda
- **THEN** aparece un cofre en su lugar

#### Scenario: Abrir el cofre
- **WHEN** el jugador toca el cofre
- **THEN** la partida se pausa y se le ofrece una selección de mejoras en la que todas son de rareza rara o superior

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
