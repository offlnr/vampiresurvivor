# Tasks

## 1. Arte

- [x] 1.1 Dibujar las 7 estructuras (mausoleo, árbol muerto, obelisco, columna rota, farola, montón de calabazas, lápida grande) y los 7 detalles (lápida, cruz, hierba alta, huesos, calavera, setas, velas) en `art/placeholder/props/`; comprobar con una hoja de contactos que encajan con el estilo
- [x] 1.2 Crear `tools/generate_ground.gd` y regenerar `ground.svg` (1024 px, sin objetos, sin costuras); verificar el escenario "Sin cuadrícula" con capturas

## 2. Decoración (specs/map-decorations)

- [x] 2.1 Crear `Decorations`: zonas deterministas por semilla, nodos solo cerca del jugador, estructuras, cementerios y detalles, sombras, luces que parpadean y tinte de los detalles; verificar con capturas "Mapa variado" e "Inicio despejado"
- [x] 2.2 Huellas elípticas y `push_out()`/`is_free()`; aplicarlas al jugador y a los enemigos que caminan, y añadir `EnemyData.flying` a murciélago y fantasma; verificar con prueba headless "Enemigos detrás de una estructura" y que nadie queda dentro de una estructura
- [x] 2.3 Que calderos, cofres de pago y comerciante busquen un sitio libre, y que los power-ups y cofres de élite se saquen de las estructuras; verificar que las pruebas de calderos, destierro y dificultad siguen pasando

## 3. Verificación jugando

- [ ] 3.1 Jugar y comprobar "Chocar con un mausoleo", "Voladores", "Pasar por detrás", "Volver a un sitio" y "Power-up sobre un mausoleo", en horizontal y en vertical
- [ ] 3.2 Comprobar el rendimiento en móvil con 400 enemigos y la decoración cargada

## 4. Segunda iteración

- [x] 4.1 Corregir el orden de profundidad: los objetos de pie se ordenan a la altura de los pies de los personajes (`SORT_OFFSET`) y los detalles planos van siempre debajo (`z_index = −1`); verificar con capturas "Pasar por detrás", "Pasar por delante" y "Pisar detalles del suelo" (árbol, lápida y hierba)
