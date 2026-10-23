# Design

## Context

- `Audio` (autoload, `PROCESS_MODE_ALWAYS`) tenía un solo `AudioStreamPlayer` de música, con `play_music(stream)` en bucle y `stop_music()`. Lo usaban el menú y la partida, con la misma pista sintetizada.
- Al reintentar, la partida se recarga y vuelve a llamar a la música; no debe cortarla si ya está sonando.

## Goals / Non-Goals

**Goals:**
- Música épica y de Halloween con licencia libre para uso comercial, sin obligaciones.
- Varias pistas que se alternen sin repeticiones seguidas ni saltos de volumen.

**Non-Goals:**
- Música adaptativa (por horda, jefe o vida baja).

## Decisions

### 1. Selección de pistas
Se buscaron pistas CC0 en OpenGameArt (incluida la colección "CC0 - Cinematic Music") y se comprobó la licencia en la página de cada una. Se eligieron cuatro con tono oscuro o épico y ritmo de combate. Se descartaron:
- "Sinister Boss Appears" y "Dramatic Boss Encounter": son introducciones cortas de jefe;
- "The Dark Amulet": es CC-BY y su autor pide contacto previo;
- "Boss Battle (loop)": su tema es espacial.

Todos los archivos se descargaron a una carpeta aparte y se comprobó que son audio válido antes de copiarlos al proyecto.

### 2. Lista en `Audio`
- `play_playlist(tracks)` recibe `{stream, volume_db}` por pista.
- Al terminar una pista (`finished`), `_next_track()` pasa a la siguiente de un orden barajado. Al acabar el orden se vuelve a barajar, y si la primera coincide con la última que sonó se manda al final.
- Si se llama otra vez con la misma lista mientras suena, no hace nada; por eso reintentar no reinicia la música.
- `play_music()` (menú) vacía la lista y vuelve al bucle de una pista; `stop_music()` (fin de partida) para las dos.
- La música sigue sonando con la partida en pausa (menús de nivel, tienda), porque `Audio` siempre procesa.

### 3. Sin bucle propio
Para que `finished` llegue, ninguna pista puede repetirse sola:
- las OGG y MP3 se importan con `loop=false`;
- las WAV estaban en "detectar del archivo", y una de ellas está pensada como bucle, así que se fuerza `edit/loop_mode=1` (desactivado).

Las WAV usan compresión QOA (el modo por defecto): unos 3–4 MB cada una frente a 19 MB sin comprimir.

### 4. Volumen igualado
Se midió con Godot el volumen RMS real al reproducir 15 s de cada pista, a partir del segundo 20 o del primer cuarto. Para llevarlas a unos −16 dBFS:

| Pista | Medido | Ajuste |
|---|---|---|
| Battle Theme A | −13,3 dBFS | −2,7 dB |
| Determined Pursuit | −15,0 dBFS | −1,0 dB |
| Spooky loop | −16,4 dBFS | +0,4 dB |
| Evil Approach | −18,2 dBFS | +2,2 dB |

Cada pista entra con un fundido de 1,2 s desde −40 dB hasta su volumen.

## Risks / Trade-offs

- [La pista Spooky dura solo 32 s y suena a sintetizador, no a orquesta] → Da variedad; si desentona, se quita de `MUSIC_PLAYLIST`.
- [El exe crece unos 11 MB] → Asumible; se podrían pasar las WAV a OGG si hiciera falta.

## Verificación hecha

Prueba `music_test` (Godot 4.7.2 headless) con la partida real:
- al empezar suena una pista de la lista;
- ninguna pista tiene bucle propio;
- el fundido llega al volumen de la pista;
- en 8 cambios de pista (saltando al final de cada una) siempre empieza otra distinta;
- las 4 primeras son las 4 canciones;
- la música sigue con el menú de nivel abierto.

Siguen pasando las demás pruebas.
