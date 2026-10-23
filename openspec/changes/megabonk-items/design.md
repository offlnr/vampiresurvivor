# Design

## Context
Fuente: GamerBlurb, *MegaBonk All Items List & Guide*. Las rarezas varían entre fuentes, así que se ajustan a la escala de este juego. Algunos objetos de Megabonk no se adaptan porque dependen de cosas que este juego no tiene: el salto (Feathers, Scarf, Eagle Claws), los santuarios de carga (Wrench, Beacon), los misiles y el aturdimiento.

## Decisions

### 1. Objetos de estadística aplicados al comprar
Suerte, experiencia, vida, regeneración, daño, evasión, imán, proyectil extra y libro sagrado cambian directamente las variables del jugador en `Inventory._apply_stats()`. Así el panel de estadísticas los muestra sin código extra. `remove_one()` aplica el signo contrario.

### 2. Multiplicadores por golpe
`EnemyManager.damage()` pide a `Inventory.hit_multiplier(enemy)` la bonificación del golpe:
- +monóculo si el enemigo tiene ≥ 90 % de vida;
- +estaca si es élite;
- +nudilleras si está a ≤ 150;
- ×20 si sale el mazo.

Después tira el crítico. `crit_multiplier()` da ×2, o ×4 con el tridente, y aplica la curación de la daga sedienta. Un mazazo se muestra como crítico. Solo cuenta el daño de armas: los objetos no se encadenan entre sí.

### 3. Daño que crece durante la partida
`damage_multiplier()` suma tres bonificaciones:
- `chest_bonus` (moneda maldita);
- `kill_bonus` (alma demoníaca, con tope de +100 %);
- la poción de quietud, que sube durante 3 s quieto (`idle_time`).

### 4. Al recibir daño y al esquivar
- `on_player_hurt()`: capa (efecto de 2 s), hucha (oro vía `gold_gained`), farol (descarga en 160) y miasma (veneno en 220).
- `Player` avisa al esquivar (`on_player_dodged`): sudario (efecto de 2 s).
- La capa y el sudario se registran en `PowerUps.TABLE` con peso 0, igual que el caramelo, para que el HUD los muestre con su icono y su cuenta atrás.

### 5. Reloj de arena detenido
Si un golpe dejaría la vida a 0, `try_last_stand()` gasta una copia y para el tiempo 4 s, igual que el power-up del reloj. El golpe no llega a hacer daño.

### 6. Llave oxidada
La tirada de cofre gratis se hace una vez por cofre (meta `free`). Si se hiciera en cada contacto, quedarse encima del cofre acabaría abriéndolo gratis.

### 7. Desbloqueos de objetos nuevos

| Objeto | Desafío | Precio |
|---|---|---|
| Tridente del diablo | Pergamino de precisión a nivel 5 | 25 |
| Morral de bruja | Un arma a nivel 12 | 30 |
| Campana fúnebre | Sobrevive 8:00 | 30 |
| Petardo de calabaza | 1.000 enemigos en una partida | 30 |
| Alma demoníaca | Derrota a 10.000 enemigos | 35 |
| Orbe de tormenta | Rayo espectral a nivel 8 | 40 |
| Llama infernal | Rastro de brasas a nivel 8 | 40 |
| Reloj de arena detenido | Juega 15 partidas | 40 |
| Libro sagrado | 2:00 sin recibir daño (en Megabonk: matar a un jefe sin recibir daño) | 45 |
| Yunque maldito | Un arma a nivel 15 | 45 |

### 8. Plata
Bajan las tres fuentes de plata: 1/min, 0,2/nivel y 0,5 cada 100 enemigos. Hay 30 desbloqueos y suman 845 de plata, así que harían falta unas 30 partidas de 10 minutos para tenerlo todo.

## Verificación hecha
Godot 4.7.2 headless (`items_test`, 30 comprobaciones, todas pasan):
- **Estadísticas directas**: la suerte, la vida, la regeneración, el daño, la evasión, el imán y el morral cambian lo esperado.
- **Golpes**: monóculo + nudilleras dan ×1,4, y lejos y herido ×1. El tridente da un ~20 % de megacríticos (408 de 2.000) y el mazo un ~2 % (118 de 5.000).
- **Progreso**: la moneda da +5 % con 2 cofres, el alma tiene tope de +100 % y la poción da +50 % tras 3 s quieto.
- **Al recibir daño**: la hucha da +3 de oro, el farol daña, el miasma envenena y la capa acelera.
- **Legendarios**: el reloj salva de un golpe mortal, para el tiempo y se rompe. Con el yunque, una mejora rara mejora 3 estadísticas. La campana congela.
- **Otros**: con dos llaves sale un ~20 % de cofres gratis, y el sudario se activa al esquivar.

Las pruebas `content_test` y `unlock_test` siguen pasando. La de desbloqueos da ahora 16 de plata para una partida de 5:30. Capturas: hoja con los 51 iconos, la tienda con objetos nuevos y el HUD con los 51 objetos en dos filas.
