# Spec Delta

## ADDED Requirements

### Requirement: Catálogo ampliado de objetos
El juego SHALL tener 51 objetos repartidos entre las cinco rarezas. Cada copia de un objeto MUST sumar su efecto. Los objetos bloqueados MUST NOT salir en el comerciante ni en los cofres.

#### Scenario: Objeto de estadística
- **WHEN** el jugador compra la sopa de murciélago
- **THEN** su vida máxima sube 25, y el panel de estadísticas lo refleja

#### Scenario: Daño condicional
- **WHEN** el jugador tiene el monóculo de búho y las nudilleras de hueso, y golpea a un enemigo cercano con toda la vida
- **THEN** el golpe hace un 40 % más de daño

#### Scenario: Megacrítico
- **WHEN** el jugador tiene el tridente del diablo y hace un crítico
- **THEN** ese crítico tiene un 20 % de probabilidad de hacer ×4 en vez de ×2

#### Scenario: Golpe mortal evitado
- **WHEN** el jugador tiene el reloj de arena detenido y recibe un golpe que lo mataría
- **THEN** no pierde vida, el tiempo se detiene 4 s y el reloj desaparece del inventario

#### Scenario: Cofre gratis
- **WHEN** el jugador tiene la llave oxidada y toca un cofre de pago
- **THEN** la probabilidad de que se abra gratis se tira una sola vez para ese cofre

#### Scenario: Muchos objetos
- **WHEN** el jugador tiene más objetos distintos de los que caben en una fila del HUD
- **THEN** los iconos ocupan una segunda fila, encima de la primera, sin salirse de la pantalla
