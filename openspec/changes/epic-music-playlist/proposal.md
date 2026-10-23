# Proposal

## Why

La única música del juego era una pista provisional sintetizada por código, que sonaba en bucle tanto en el menú como en la partida. El jugador quiere música épica que encaje con la temática de Halloween, y que haya varias pistas que se vayan alternando durante la partida.

## What Changes

- **Cuatro pistas de partida**, todas CC0 (dominio público, uso comercial permitido, sin atribución obligatoria), descargadas de OpenGameArt:
  - "Determined Pursuit (epic orchestra loop)", de Emma_MA: orquestal frenética, 1:48;
  - "Battle Theme A", de cynicmusic: batalla épica con cuerdas y metales, 1:36;
  - "Evil Approach", de nene: oscura y de batalla, 1:08;
  - "Spooky loop & bomba32", de wipics y StumpyStrust: oscura, con sintetizadores y etiquetada como Halloween, 0:32.
- **Lista de reproducción**:
  - las pistas suenan enteras, una tras otra, en orden aleatorio;
  - cada pista entra con un fundido breve;
  - al acabar la lista se vuelve a barajar, sin repetir seguida la última pista;
  - el volumen de cada pista se iguala a unos −16 dBFS (medido), para que ninguna destaque al cambiar.
- **El menú principal** conserva la música ambiental tranquila, en bucle.
- **Créditos**: las cuatro pistas quedan en `CREDITS.md`, aunque CC0 no lo exige.

**Fuera de alcance:**
- música distinta para hordas o jefes;
- "The Dark Amulet" (Matthew Pablo), que encaja muy bien pero es CC-BY y su autor pide que le contacten antes de usarla.

## Capabilities

### New Capabilities
<!-- Ninguna. -->

### Modified Capabilities
- `halloween-presentation`: "Respuesta visual y sonora" (música de partida épica en lista, música de menú aparte).

## Impact

- **Audio**: `art/music/` (4 pistas, unos 11 MB una vez importadas); las WAV con bucle desactivado y compresión QOA.
- **Código**:
  - `Audio`: `play_playlist()`, `_next_track()`, fundido y `current_music()`;
  - `play_music()` sigue para el menú;
  - `run.gd`: `MUSIC_PLAYLIST` en lugar de `MUSIC`.
- **Créditos**: `CREDITS.md`.
