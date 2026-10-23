# Tasks

## 1. Orbe arcano (specs/auto-weapons)

- [x] 1.1 Dibujar `magic_orb.svg` (bola morada con brillo y destellos) con la paleta del juego y comprobarla renderizada junto a la calabaza
- [x] 1.2 Exportar `projectile_scene` en `ProjectileWeapon` y `spin_speed` en el proyectil, sin cambiar el comportamiento de la calabaza
- [x] 1.3 Crear `magic_orb_projectile.tscn` (con halo), `magic_orb_weapon.tscn` y `data/weapons/orbe.tres`
- [x] 1.4 Hacer del orbe el arma inicial y añadir la calabaza a las armas que se ofrecen durante la partida

## 2. Pergamino de multiplicidad (specs/run-progression, specs/auto-weapons)

- [x] 2.1 Añadir `UpgradeData.Stat.AMOUNT` al final del enum, `is_count()` y `roll_amount()`, y usar `roll_amount()` en los tres sitios de `run.gd` que calculaban el valor de un pergamino
- [x] 2.2 Añadir `Player.extra_amount`, sumarlo en `Weapon.stat(&"amount")` y añadir `Weapon.refresh()`
- [x] 2.3 Crear `proyectiles.svg` y `data/scrolls/proyectiles.tres`, y aplicar el pergamino en `run.gd` refrescando todas las armas

## 3. Verificación

- [ ] 3.1 En Godot, verificar los escenarios "Inicio de partida", "Proyectil dirigido", "Enemigo fuera de alcance", "Proyectil que no acierta" y "Calabaza durante la partida", y que la calabaza se comporta igual que antes
- [ ] 3.2 Verificar los escenarios "Proyectiles extra", "Proyectiles extra en armas nuevas", "Guadaña con proyectiles extra", "Multiplicidad común" y "Multiplicidad por rareza"
- [ ] 3.3 Jugar partidas largas con murciélagos o guadaña y varios pergaminos de multiplicidad, y ajustar valores si alguna combinación rompe el equilibrio

## 4. Segunda iteración

- [x] 4.1 Que cada rareza del pergamino de multiplicidad dé un valor distinto (+1 a +5) en vez de los factores de arma, que daban +2 tanto en épica como en legendaria; actualizar el escenario "Multiplicidad por rareza"
- [x] 4.2 Subir el daño del orbe de 10 a 11 para que un zombi del primer minuto (22 de vida) muera con 2 orbes, como pide el escenario "Inicio tranquilo"
