# Tasks

## 1. Jefes (specs/bosses)

- [x] 1.1 `EnemyData.BossAttack` y `boss_attacks`; datos de los tres jefes
- [x] 1.2 `Enemy`: `is_boss` (élite especial, ×2,6, sin el ×12 de vida ni el ×2 de contacto de los élites, sin barra sobre la cabeza) y golpe con aviso (`Telegraph`)
- [x] 1.3 `EnemyManager`: calendario cada 5 min con aviso, espera si sigue vivo, `start_boss()`, ataques por turnos (anillo, golpe, esbirros), bomba al 4 %, 30 monedas y `boss_defeated`
- [x] 1.4 Corregir las armas de área contra enemigos grandes: la consulta de la rejilla solo miraba 40 unidades más allá del alcance, así que los jefes (radio 88) y los élites gólem (60) a menudo no recibían el golpe ni hacían daño por contacto. Ahora los enemigos de más de 40 de radio se comprueban siempre (`_big`)
- [x] 1.5 `run.gd`: avisos para los dos jugadores, elección "¡Jefe derrotado!" épica para cada asiento, barra del HUD y `debug_boss()`; botón "Jefe" en el panel de depuración

## 2. HUD y red (specs/bosses)

- [x] 2.1 `hud.set_boss()`: nombre y barra bajo el tiempo
- [x] 2.2 La barra en la cabecera de la instantánea para el invitado

## 3. Verificación

- [x] 3.1 Prueba headless: jefe en el HUD, 14 pociones, golpe con aviso, 7 esbirros, menú épico al derrotarlo, almas y oro, aviso y Reina bruja a las 5:00 del calendario
- [x] 3.2 Prueba de cooperativo: el invitado ve la barra (1,00 y 0,50) y recibe su propio "¡Jefe derrotado!"
- [x] 3.3 Captura del gólem cargando el golpe, con la barra en el HUD
- [x] 3.4 Bots de equilibrio hasta el jefe de las 5:00 (6 personajes, quietos y eligiendo la primera mejora): con 6.000 de vida base ninguno lo derrotó en 120 s; con 1.500 y el arreglo de 1.4, cinco de seis en 44–112 s. Se dejó en 1.100 / 950 / 1.050 (gólem, bruja y calabaza), unos 3.100 de vida a los 5:00
- [x] 3.5 Volver a pasar las pruebas de solitario y de personajes
- [ ] 3.6 Ajustar jugando la vida y el daño de los jefes de las 10:00 y las 15:00
