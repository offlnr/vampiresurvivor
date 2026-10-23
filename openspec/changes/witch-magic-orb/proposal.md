# Proposal

## Why

El personaje del jugador es una bruja, pero empieza lanzando calabazas, que no encaja con ella. Además, no hay ninguna forma de aumentar la cantidad de proyectiles de todas las armas a la vez: solo se consigue mejorando cada arma por separado, y en Megabonk es uno de los libros más buscados.

## What Changes

- **Orbe arcano** (arma nueva, arma inicial): la bruja dispara bolas de magia morada al enemigo más cercano. Usa el mismo patrón de proyectil que la calabaza, pero es más rápida y ligera (11 de daño, recarga 0,85 s, velocidad 520, alcance 440), y su orbe gira despacio con un halo morado.
- **Calabaza**: deja de ser el arma inicial y pasa a ser una más de las que se ofrecen como "¡Nueva arma!" al subir de nivel. Sus estadísticas no cambian. El juego pasa de 6 a 7 armas; el límite sigue siendo 3 equipadas.
- **Pergamino de multiplicidad** (pergamino nuevo, el 11.º): da proyectiles extra a todas las armas, las que ya se tienen y las que se consigan después. Es el primer pergamino que da una cantidad entera en vez de un porcentaje: uno más por cada rareza (+1 común, +2 poco común, +3 rara, +4 épica, +5 legendaria), para que cada rareza se note. No crece con el nivel del jugador.

**Fuera de alcance:** rehacer el arte del personaje, cambiar las demás armas y reequilibrar la calabaza.

## Capabilities

### New Capabilities
<!-- Ninguna. -->

### Modified Capabilities
- `auto-weapons`: nueva arma inicial, catálogo de 7 armas, alcance del orbe y proyectiles extra del jugador.
- `run-progression`: 11 pergaminos, uno de ellos de cantidad.

## Impact

- **Código**:
  - `ProjectileWeapon` exporta `projectile_scene` (por defecto, la calabaza).
  - El proyectil de la calabaza exporta `spin_speed`.
  - `UpgradeData` añade el stat `AMOUNT`, `is_count()` y `roll_amount()`.
  - `Player` añade `extra_amount`.
  - `Weapon.stat(&"amount")` suma ese bono y hay un `Weapon.refresh()`.
  - `run.gd` cambia el arma inicial y las listas, y aplica el pergamino.
- **Datos**: `data/weapons/orbe.tres` y `data/scrolls/proyectiles.tres`.
- **Escenas**: `magic_orb_weapon.tscn` y `magic_orb_projectile.tscn`.
- **Arte**: `art/placeholder/magic_orb.svg` y `art/placeholder/scrolls/proyectiles.svg`.
