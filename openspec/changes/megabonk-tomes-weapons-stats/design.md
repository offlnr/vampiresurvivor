# Design

## Context

Fuentes sobre Megabonk:
- GuruGamer, *Complete weapon and tome upgrades guide* (v1.0.7): valores comunes de los libros y de las mejoras de arma, y factores de rareza ×1 / 1,2 / 1,4 / 1,6 / 2.
- KeenGamer y Destructoid: lista de libros y qué hace cada uno.
- GamerBlurb: descripción de las armas.

| Libro de Megabonk | Valor común | Aquí |
|---|---|---|
| Regen | +40 | Regeneración, +0,5 vida/s: la vida base es 100, no hay escala equivalente |
| Shield | +25 | Escudo, +15 |
| Evasion | +10 % | Evasión, +10 % |
| Thorns | +15 | Espinas, +15 (× multiplicador de daño) |
| Precision | +7 % crítico | Precisión, +7 % |
| Projectile Speed | +15 % | Vuelo, +15 % |
| Duration | +15 % | Duración, +15 % |
| Knockback | +20 % | Empuje, +20 % |
| Golden | +12 % | Codicia, +12 % |
| Cursed | +3,5 % dificultad | Maldito, +5 % (mismo paso que un caldero) |
| Chaos | estadística al azar | Caos, 50 % de un pergamino común por nivel |
| Quantity | +1 | Multiplicidad, +1 entero |

Silver no se incluye porque no hay plata ni progresión entre partidas.

## Decisions

### 1. Cantidades enteras
- La guía da +1 de cantidad común; un proyectil fraccionario no existe en pantalla.
- `UpgradeData.roll_amount()` y `WeaponData.upgrade_value()` redondean `amount` y `pierce`: `round(1 × factor)` da +1 / +1 / +1 / +2 / +2.
- `Player.extra_amount` pasa a `int`.
- `count_text()` escribe enteros.
- Se descarta el +1…+5 por rareza de una iteración anterior: con 5 un legendario rompía el equilibrio.

### 2. Formato de los pergaminos
- `UpgradeData.percent = false` para valores planos (vida/s, escudo, espinas).
- Las nuevas estadísticas se añaden **al final** del enum, porque los `.tres` guardan el índice.

### 3. Defensa en el jugador
- **Escudo**: absorbe antes que la vida y da invulnerabilidad. Tras `SHIELD_DELAY` = 4 s sin golpes se recarga un 25 % por segundo. Se dibuja como barra azul bajo la de vida.
- **Evasión**: la probabilidad de esquivar es `e / (1 + e)`: rendimiento decreciente y nunca el 100 %. Al esquivar hay 0,35 s de invulnerabilidad para que el contacto no vuelva a tirar cada frame.
- **Espinas**: al recibir un golpe, daño `thorns × damage_multiplier` a los enemigos a ≤ 28 u del cuerpo. Es daño de fuente objeto, así que no cura con robo de vida.
- **Regeneración**: `heal(regen × delta)` cada frame de física.

### 4. Multiplicadores de arma
- `Weapon.stat(&"speed")` multiplica por `projectile_speed_multiplier` y `stat(&"duration")` por `duration_multiplier`.
- El empuje multiplica `push_strength` solo para daño de armas.
- La precisión se suma al crítico de los objetos en `Inventory.crit_chance()`.

### 5. Maldito y caos
- `run._update_difficulty()` combina calderos y maldición: `1 + 0,05 × calderos + curse_difficulty`.
- El maldito da el doble de su dificultad en experiencia y oro, la misma relación que un caldero.
- El caos acumula `chaos_power`. En cada subida aplica un pergamino al azar (sin multiplicidad, maldito ni caos) con `amount_per_level × chaos_power`, y lo anuncia en el HUD.

### 6. Armas nuevas
Todas usan `Weapon` y sus estadísticas, así que los pergaminos y objetos les afectan igual que a las demás.

| Arma | Patrón | Cómo funciona | Mejoras (común) |
|---|---|---|---|
| Rayo espectral | CHAIN | Elige entre los 12 enemigos más cercanos; cada rayo cae del cielo y salta `pierce` veces al más cercano no golpeado dentro de `area`. Visual con dos `Line2D` que se desvanecen | daño 25 %, +1 rayo, vel. ataque 8 %, alcance 15 %, +1 salto |
| Rastro de brasas | TRAIL | Cada `cooldown` deja `amount` brasas en la posición del jugador si se ha movido ≥ 10 u. Un único nodo `EmberLayer` dibuja todas las brasas y hace tics de daño cada 0,4 s | daño 30 %, +1 brasa, tamaño 12 %, duración 15 % |
| Vórtice de almas | VORTEX | Se abre sobre un enemigo cercano y arrastra a 150 u/s a los no élite ni inmunes al empuje. Daño cada 0,45 s durante `duration` | daño 30 %, +1, vel. ataque 8 %, radio 13 %, duración 12 % |
| Trabuco de plata | SPREAD | Abanico de `amount` perdigones (base 4) al enemigo más cercano, separados 0,13 rad (máx. 1,3 rad). Reutiliza `pumpkin_projectile.gd` | daño 25 %, +1 perdigón, vel. ataque 8 %, tamaño 12 %, +1 atravesar |

`WeaponData.pierce_label` permite que el rayo diga "salta a 1 enemigo más".

### 7. Panel de estadísticas
- `StatsPanel` (código, sin escena) es un overlay a pantalla completa hijo de cada menú, así que hereda `PROCESS_MODE_ALWAYS`.
- `run.stats_sections()` devuelve las secciones "Personaje" y "Armas". Los menús la reciben como `stats_provider: Callable`.
- **En pantallas de 1000 px de ancho o más**, el personaje va en dos pares de columnas y cabe sin desplazar.
- **Foco**: queda bloqueado en "Volver" para que el teclado o el mando no elija una carta de detrás. Arriba y abajo desplazan la lista. Esc o cancelar cierra el panel y el foco vuelve a "Estadísticas".
- **Tienda**: "Estadísticas" va al lado de "Salir", en una fila que sigue visible en los cofres aunque "Salir" se oculte. Esc con el panel abierto cierra el panel, no la tienda.

## Risks / Trade-offs
- [Muchos pergaminos diluyen las ofertas] → Se mantiene el límite de 4 pergaminos; las tiradas y destierros siguen sirviendo para buscar los que se quieren.
- [El trabuco con muchos proyectiles extra dispara abanicos enormes] → El abanico se limita a 1,3 rad, así que los perdigones se apiñan en vez de cubrir 360°.
- [El vórtice amontona enemigos sobre el jugador] → Solo atrae hacia su propio centro, que está sobre un enemigo, no sobre el jugador.
- [La evasión y el escudo hacen demasiado fácil la partida] → Rendimiento decreciente en la evasión; el escudo no se recarga mientras se reciben golpes.

## Verificación hecha
Godot 4.7.2 headless (`content_test`, 32 comprobaciones, todas pasan):
- **Multiplicidad**: +1/+1/+1/+2/+2. La carta poco común dice "+1". Las mejoras de "+orbes" también son enteras. 5 pergaminos dan +7 y el orbe dispara 8.
- **Pergaminos nuevos**: cada uno cambia su estadística. El escudo absorbe y el resto pasa a la vida. Una evasión altísima esquiva. Subir de nivel con caos no da errores.
- **Armas nuevas**: con 12 zombis alrededor, cada una hace daño en 4 s. Las mejoras legendarias se describen bien ("+2 rayos", "atraviesa a 2 enemigos más").
- **Panel**: se abre desde la subida de nivel y la tienda, y al cerrarse vuelve al menú.

Capturas a 1280×720 de la partida (brasas, vórtice y barra de escudo), la subida de nivel con "Estadísticas", el panel y la tienda.

### 8. Sonidos
Cada arma nueva tiene su sonido, sacado de OpenGameArt y procesado con un script de Python sin dependencias: recorte del silencio inicial, capas, filtros, fundido y normalización.

| Arma | Origen | Proceso |
|---|---|---|
| Rayo espectral | faxcorp, "groundhit" + "hit" (CC0) | Chasquido filtrado por encima de 900 Hz, y descarga 15 ms después con cola de 0,35 s |
| Vórtice de almas | Ogrebane, "teleport" (CC0) | 1,3 s con el tono bajado un 18 % y filtro por debajo de 2,6 kHz, para que suene oscuro y no a power-up |
| Trabuco de plata | Vincent Sevedge, "shotty" (CC-BY 3.0) | Empieza en el estampido (sin el silencio previo) y lleva una capa grave por debajo de 400 Hz |
| Rastro de brasas | AntumDeluge, "fire-1" (CC0) | Los 0,7 s con más chasquidos agudos; suena como mucho cada ~1,4 s al caminar |

El zip de "gunshot sounds" trae una licencia CC-BY 3.0, aunque la página dice CC0. Se acredita como CC-BY.
