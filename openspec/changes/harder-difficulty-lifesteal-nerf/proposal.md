# Proposal

## Why

Jugando, la partida resulta demasiado fácil, y el robo de vida es en gran parte el motivo: con armas de área cura en cada golpe a decenas de enemigos, también cura con el daño de objetos (veneno, vudú, espejo, eco, bomba) y con el daño que sobrepasa la vida del enemigo. La bomba de calabaza llegaba a curar casi entera la vida del jugador. Además, curar con el daño de objetos ni siquiera cumplía el spec, que habla solo del daño de las armas.

## What Changes

- **Más dificultad desde el minuto 1**. El primer minuto sigue siendo un inicio tranquilo, aunque algo más intenso: hasta 15 enemigos en vez de 12, y aparecen más rápido. A partir de ahí:
  - los enemigos tienen ≈20–25 % más vida;
  - aparecen ≈15–20 % más rápido;
  - caben ≈20 % más enemigos a la vez;
  - el daño de los enemigos crece un 8 % por minuto en vez de un 5 %;
  - las hordas traen ≈25–30 % más enemigos.
- **Robo de vida más débil**:
  - solo cura con el daño de las armas, como dice el spec;
  - solo cuenta el daño que el enemigo tenía de vida, no lo que sobra;
  - cura como mucho el 2 % de la vida máxima por segundo, golpee a cuantos enemigos golpee.

  El valor del pergamino de vampirismo no cambia.

**Fuera de alcance:**
- la velocidad de los enemigos, porque el spec fija que al principio los murciélagos vayan como mucho a la mitad de la velocidad del jugador;
- el momento de las hordas, que siguen empezando en el minuto 3;
- el escalado infinito a partir del minuto 10;
- el diente de vampiro, que cura al matar y no es robo de vida.

## Capabilities

### New Capabilities
<!-- Ninguna. -->

### Modified Capabilities
- `enemy-waves`: "Dificultad creciente" (el inicio tranquilo pasa a 15 enemigos y a "2 orbes del arma inicial").
- `run-progression`: "Robo de vida" (solo daño de armas, sin daño sobrante, con tope por segundo).

## Impact

- **Datos**: `data/waves/noche.tres` (ritmo, máximo de enemigos y vida de cada tramo).
- **Código**:
  - `EnemyManager`: daño por minuto, tamaño de las hordas, y llamada al robo de vida solo con daño de arma y sin el daño sobrante.
  - `Player`: tope de robo de vida por segundo.
- **Depende de** `witch-magic-orb`: el arma inicial es el orbe, con 11 de daño, para que el escenario del inicio tranquilo se siga cumpliendo.
