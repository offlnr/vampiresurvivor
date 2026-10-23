# Design

## Context

- Parte del juego del cambio `halloween-survivor-mvp`: `EnemyManager` (rejilla espacial, élites, hordas), `PickupManager` (almas con pool y cofres), `Player` (estadísticas pasivas), `Weapon` (multiplicadores), `Rarity` (5 rarezas con colores) y la UI de cartas de `LevelUp`.
- Todo el daño de las armas pasa por `EnemyManager.damage()`, y todas las muertes por `_kill()`: son los puntos de enganche naturales para los objetos.
- Investigación de *Megabonk* (ver proposal.md): el "Shady Guy" aparece en el mapa, el color del sombrero indica la rareza, ofrece 3 objetos, se compra uno y se va. Los power-ups que sueltan los enemigos son corazón, agilidad, furia, moneda, escudo, imán, bomba y reloj. Copiamos las mecánicas, no los nombres ni el arte.

## Goals / Non-Goals

**Goals:**
- Objetos basados en datos (`ItemData` en `.tres`), como armas y mejoras.
- Un único punto de enganche para efectos al golpear, al matar y al recibir daño, sin repartir lógica de objetos por las armas.
- Que el comerciante, los power-ups y el minimapa funcionen igual con teclado y con pantalla táctil.

**Non-Goals:**
- Moneda permanente o desbloqueos entre partidas.
- Santuarios, microondas, vasijas u otros elementos del mapa de Megabonk.
- Un mapa con zonas fijas: el mundo sigue siendo el cementerio infinito.

## Decisions

### 1. `ItemData` + `Inventory`
`ItemData` (Resource): id, nombre, icono, rareza fija, `effect` (enum), `value` por copia, `description` con `{value}` y `percent`. Un nodo `Inventory` dentro de la partida guarda las copias (`Dictionary[ItemData, int]`) y expone tres ganchos: `on_weapon_hit(enemy, damage)`, `on_kill(enemy)` y `on_player_hurt(amount)`, más los efectos periódicos (muñeco vudú) en su `_physics_process`. `Player.item_damage_multiplier()` le pregunta al inventario los multiplicadores de daño (lentes de calavera, daga del verdugo).
- **Alternativa**: un script por objeto con herencia. Descartada para 17 objetos simples: un `match` por efecto es más fácil de leer y equilibrar.

### 2. Origen del daño
`EnemyManager.damage()` recibe un `source` (`WEAPON` o `ITEM`). Solo el daño de arma llama a `on_weapon_hit`, lo que evita cadenas infinitas (eco que provoca eco, veneno que provoca veneno). El robo de vida sigue contando todo el daño.

### 3. Estados en `Enemy`
`poison_left`/`poison_dps` y `frozen_left` en `Enemy`. `EnemyManager._move()` aplica el veneno cada 0,5 s (daño de origen `ITEM`, números verdes) y no mueve a los congelados ni les deja hacer daño por contacto. El tinte (verde o azul) se aplica en `animate()` por encima del destello de golpe.

### 4. Detener el tiempo
`EnemyManager.time_stop_left`: mientras es mayor que 0 no se mueve ningún enemigo, no aparecen enemigos ni hordas (el reloj de hordas se retrasa lo mismo), el daño por contacto es 0 y todos se tiñen de azul grisáceo. Las armas y el jugador siguen funcionando.

### 5. Oro y power-ups en `PickupManager`
Las monedas usan otro `ObjectPool` con la misma lógica de atracción que las almas, pero sin fusión. Los power-ups son nodos simples (máximo 12 en el suelo) que se recogen al tocarlos y caducan a los 30 s. La tabla de power-ups (tipo, peso, duración, icono) vive en `scripts/data/power_ups.gd` como constantes, porque son pocos y con lógica propia cada uno.

### 6. Buffs temporales en `Player`
`Player.buffs: Dictionary[StringName, float]` con el tiempo restante de escoba, furia, lluvia de oro y escudo. `move_speed()`, `Weapon.cooldown()`, la recogida de oro y `take_damage()` consultan los buffs. El HUD lee el mismo diccionario para dibujar los iconos con su cuenta atrás.

### 7. Comerciante
`MerchantDirector` (nodo de la partida): a las 1:30 y luego cada 80 s, si no hay comerciante, tira una rareza con `Rarity.roll(luck)` y coloca a `Merchant` a 700–1000 unidades del jugador, en una dirección al azar. `Merchant` dibuja el cuerpo y un sombrero aparte, teñido con el color de la rareza; flota, tiene una luz y un letrero de precio. Al entrar en un radio de 70 pide abrir la tienda; tras salir sin comprar, no se reabre hasta que el jugador se aleja más de 140. Elige 3 objetos distintos de su rareza; si hay menos, completa con la rareza inferior. Precio: `[15, 30, 50, 85, 140][rareza] × (1 + 0,25 × compras hechas)`.

### 8. Tienda
`ShopMenu` reutiliza el estilo de las cartas de `LevelUp` (borde del color de la rareza, icono, nombre y descripción) y añade el precio, el oro del jugador y un botón "Salir". Pausa la partida como el menú de mejoras.

### 9. Minimapa
`Minimap` (Control del HUD, abajo a la derecha en horizontal y arriba a la derecha en vertical) se dibuja con `_draw()` 10 veces por segundo: un círculo de 1600 unidades de radio de mundo, el jugador en el centro, y marcas para el comerciante (con su color), los cofres, los power-ups y los élites. Lo que queda fuera se dibuja como una flecha en el borde. Los enemigos normales no se dibujan.

### 10. Arte y sonido
Iconos de objetos y power-ups, moneda, comerciante (cuerpo y sombrero por separado) y caramelo curativo, generados con el mismo script de SVG del cambio anterior. Sonidos nuevos (moneda, compra, power-up, bomba, tic-tac del reloj) sintetizados como los demás.

### 11. Cofres de pago en el mapa
`MapChests` (nodo de la partida) mantiene 5 cofres entre 700 y 1500 unidades del jugador y recoloca los que quedan a más de 2500. Al tocar uno con oro suficiente se cobra `25 × 1,35^(cofres abiertos)` y se abre un menú de una carta (reutiliza el estilo de la tienda) con el objeto tirado por rareza con la suerte, y los botones tomar, volver a tirar y desterrar. Sin oro, el precio del cofre se pone en rojo. El minimapa los marca en bronce, distinto del cofre dorado de los élites.

### 12. Pausa tras la bomba
`EnemyManager.spawn_pause_left` (8 s tras la bomba): mientras dura no hay apariciones normales y el reloj de hordas se retrasa, igual que con el reloj.

## Risks / Trade-offs

- [Muchos objetos al golpear con cientos de enemigos encarecen cada impacto] → Las probabilidades se tiran una vez por impacto con `randf()`, sin búsquedas salvo en los efectos de área (espejo, guantes), que usan la rejilla espacial.
- [El oro puede no alcanzar o sobrar] → Probabilidades de moneda y precios en datos; se ajustan con el bot midiendo cuánto oro hay cuando llega cada comerciante.
- [La bomba vacía la pantalla y rompe el ritmo] → Probabilidad baja (peso 8 sobre 100) y no afecta a los élites más que un 25 %.
- [El minimapa tapa el juego en móviles] → Tamaño pequeño (150 px) y semitransparente.

## Open Questions

- Si más adelante se quiere un mapa con zonas fijas, el comerciante podría aparecer en claros concretos; el diseño actual no lo impide.
