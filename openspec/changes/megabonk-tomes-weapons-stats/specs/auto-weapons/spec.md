# Spec Delta

## MODIFIED Requirements

### Requirement: Catálogo de armas del MVP
El juego SHALL ofrecer 11 armas con patrones distintos:
- **orbe arcano**: proyectil mágico al enemigo más cercano; es el arma inicial;
- **calabaza**: proyectil al enemigo más cercano;
- **murciélagos**: orbitan al jugador;
- **niebla**: aura de daño;
- **guadaña**: barrido en arco;
- **hueso**: bumerán;
- **fuego fatuo**: zonas que queman;
- **rayo espectral**: rayos que caen sobre enemigos cercanos y saltan de uno a otro;
- **rastro de brasas**: brasas que quedan donde camina el jugador;
- **vórtice de almas**: remolino que atrae enemigos a su centro y los daña;
- **trabuco de plata**: abanico de perdigones de corto alcance.

#### Scenario: Rayo que salta
- **WHEN** ataca el rayo espectral con 2 saltos y hay enemigos cerca unos de otros
- **THEN** golpea a un enemigo cercano y después salta a hasta 2 enemigos distintos dentro de su alcance de salto

#### Scenario: Rastro de brasas
- **WHEN** el jugador camina con el rastro de brasas equipado
- **THEN** deja brasas que dañan a los enemigos que las pisan hasta que se apagan; quieto no deja brasas nuevas

#### Scenario: Vórtice
- **WHEN** se abre un vórtice
- **THEN** los enemigos normales dentro de su radio son arrastrados hacia su centro y reciben daño, y los élites no se mueven

#### Scenario: Trabuco
- **WHEN** ataca el trabuco con 4 perdigones y hay un enemigo en su alcance
- **THEN** salen 4 perdigones en abanico hacia él, y desaparecen al recorrer su alcance

### Requirement: Estadísticas del jugador en las armas
El daño, el tamaño, la recarga, la duración, la velocidad de los proyectiles y el empuje de todas las armas SHALL aplicar los multiplicadores pasivos del jugador. La cantidad de proyectiles MUST sumar los proyectiles extra del jugador y MUST ser siempre un número entero. Las mejoras de cantidad y de atravesar de las armas dan +1 en común, poco común y rara, y +2 en épica y legendaria.

#### Scenario: Pasiva de daño
- **WHEN** el jugador tiene +20 % de daño y una calabaza que hace 10 de daño impacta
- **THEN** el enemigo pierde 12 de vida

#### Scenario: Mejora de cantidad entera
- **WHEN** sale una mejora poco común del orbe arcano con cantidad
- **THEN** la carta dice "+1 orbe", no "+1,2 orbes"

#### Scenario: Proyectiles extra en armas nuevas
- **WHEN** el jugador tiene +1 proyectil y consigue el trabuco
- **THEN** el trabuco dispara un perdigón más que su cantidad base
