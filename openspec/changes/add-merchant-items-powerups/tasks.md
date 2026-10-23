# Tasks

## 1. Datos y arte

- [x] 1.1 Crear `ItemData`, la tabla de power-ups y los 17 objetos en `.tres` (4 comunes, 4 poco comunes, 3 raros, 3 épicos, 3 legendarios); verificar que se cargan y que cada rareza tiene su número de objetos
- [x] 1.2 Generar los iconos de objetos y power-ups, la moneda, el caramelo y el comerciante, y sintetizar los sonidos nuevos; verificar con una hoja de contactos que todos se distinguen

## 2. Objetos (specs/run-items)

- [x] 2.1 Añadir el origen del daño, los estados veneno y congelado en `Enemy` y el nodo `Inventory` con sus ganchos; verificar los escenarios "Veneno", "Congelación", "Ejecución" y "Espejo roto"
- [x] 2.2 Implementar los 17 efectos y la acumulación; verificar el escenario "Segunda copia" y que ningún efecto de objeto vuelve a disparar efectos al golpear
- [x] 2.3 Mostrar los objetos en el HUD con rareza y copias; verificar el escenario "Comprar un objeto"

## 3. Oro y comerciante (specs/merchant-shop)

- [x] 3.1 Hacer que los enemigos suelten oro, recogerlo y mostrarlo en el HUD; verificar el escenario "Recoger oro"
- [x] 3.2 Crear el comerciante y su director (aparición, rareza, sombrero, marcharse); verificar los escenarios "Llega un comerciante" y "Sombrero dorado"
- [x] 3.3 Crear el menú de tienda (precios, compra, salir, reabrir solo tras alejarse); verificar los escenarios "Comprar con oro suficiente", "Oro insuficiente" y "Salir sin comprar"

## 4. Power-ups (specs/power-ups)

- [x] 4.1 Hacer que los enemigos y los élites suelten power-ups que caducan; verificar los escenarios "Élite derrotado" y "Caducar"
- [x] 4.2 Implementar los 8 efectos, detener el tiempo y los buffs del jugador; verificar los escenarios "Detener el tiempo", "Imán" y "Bomba de calabaza"
- [x] 4.3 Mostrar los efectos activos en el HUD con su cuenta atrás; verificar el escenario "Escoba activa"

## 5. Minimapa (specs/minimap)

- [x] 5.1 Crear el minimapa con jugador, comerciante, cofres, power-ups y élites, y flechas en el borde; verificar con capturas los escenarios "Ver el minimapa", "Comerciante lejos" y "Enemigos normales", en horizontal y en vertical

## 6. Integración

- [x] 6.1 Ajustar con el bot las probabilidades de oro y power-ups y los precios para que el jugador pueda comprar al menos un objeto a casi todos los comerciantes; verificar que las pruebas de reglas del cambio anterior siguen pasando y que hay partidas completas sin errores

## 7. Segunda iteración

- [x] 7.1 Cofres de pago repartidos por el mapa con precio creciente, en el minimapa, que dan un objeto con tomar, volver a tirar y desterrar; verificar los escenarios "Abrir un cofre", "Cofre sin oro" y "Precio creciente"
- [x] 7.2 Volver a tirar y desterrar en la tienda del comerciante; verificar el escenario "Volver a tirar o desterrar en la tienda"
- [x] 7.3 Quitar los topes de los objetos y pasar sus efectos a porcentaje; verificar el escenario "Reloj sin tope"
- [x] 7.4 Pausa de aparición de 8 s tras la bomba de calabaza; verificar el escenario "Bomba de calabaza"
- [x] 7.5 Que los cofres de pago muestren hasta 3 objetos y solo se pueda tomar uno; verificar los escenarios "Abrir un cofre" y "Solo uno por cofre"
