# Tasks

## 1. Música

- [x] 1.1 Buscar pistas épicas y de Halloween con licencia CC0, comprobar la licencia en cada página, descargarlas a una carpeta aparte y comprobar que son audio válido
- [x] 1.2 Medir la duración y el volumen RMS de cada pista y calcular el ajuste a −16 dBFS
- [x] 1.3 Copiarlas a `art/music/`, desactivar el bucle de las WAV y añadirlas a `CREDITS.md`

## 2. Lista de reproducción (specs/halloween-presentation)

- [x] 2.1 Añadir `play_playlist()` a `Audio` (orden barajado, sin repetición seguida, fundido de entrada, volumen por pista) y usarla en la partida; mantener `play_music()` para el menú
- [x] 2.2 Verificar con prueba headless "Varias pistas en la partida", "Sin repeticiones seguidas" y "Música en pausa"

## 3. Verificación jugando

- [ ] 3.1 Escuchar las cuatro pistas en partida y quitar o ajustar las que desentonen o suenen fuera de volumen
- [ ] 3.2 Comprobar "Reintentar" y que el menú vuelve a su música ambiental al salir de la partida
