# Tasks

## 1. Investigación

- [x] 1.1 Investigar el sistema de niveles de Megabonk (datamine `megabonk_research`, guías, foros de Steam) y anotar en el design qué está confirmado y qué no

## 2. Rarezas y suerte (specs/run-progression)

- [x] 2.1 Multiplicadores 1,0 / 1,2 / 1,4 / 1,6 / 2,0 compartidos por armas y pergaminos, manteniendo multiplicidad en +1…+5; verificar "Pasiva épica" (+19,2 %)
- [x] 2.2 Suerte logarítmica de Megabonk en `Rarity.roll()`; verificar con 40 000 tiradas "Sin suerte", "Más suerte, mejores cartas" y "Rendimientos decrecientes"

## 3. Armas (specs/auto-weapons)

- [x] 3.1 Mejoras comunes de 1 o 2 estadísticas al 50 %; verificar "Común con dos estadísticas" (50,4 %) y que las raras siempre dan 2

## 4. Saltar (specs/run-progression)

- [x] 4.1 Botón "Saltar" en la subida de nivel y cofres, 5 por partida, contador "Saltos N", bloqueado durante el retardo de entrada; verificar con prueba headless "Saltar" y "Sin saltos", y con captura

## 5. Dificultad por tiempo (specs/enemy-waves)

- [x] 5.1 Volver a vida por tramo y daño por minuto, quitar el escalado por nivel; verificar con prueba headless "Más fuertes con el tiempo" y "El nivel no los hace más fuertes", y que las pruebas de calderos, destierro y atascos siguen pasando

## 6. Verificación jugando

- [ ] 6.1 Jugar varias partidas y comprobar que la suerte y los pergaminos siguen mereciendo la pena con los multiplicadores nuevos
- [ ] 6.2 Medir con el bot el nivel en los minutos 1, 2 y 10 con la dificultad por tiempo

## 7. Segunda iteración: lo más parecido a Megabonk

- [x] 7.1 Cantidades con decimales en armas y multiplicidad (+1 / 1,2 / 1,4 / 1,6 / 2) y texto "+1,2"; verificar "Cantidad con decimales" y "Multiplicidad con decimales"
- [x] 7.2 Quitar el escalado de las mejoras por nivel (`upgrade_scale`); verificar "Pasiva épica" a nivel 1 y 30
- [x] 7.3 4 armas y 4 pergaminos; daño +8 %, velocidad de ataque +7,5 % y experiencia +7 %; verificar "Límite de pergaminos" y el HUD con 4 y 4 en captura
- [x] 7.4 Curva de experiencia rápida al principio, tope de experiencia ×10 y almas de 1 / 10 / 50; verificar "Primeros niveles rápidos" y "Tope de experiencia"
