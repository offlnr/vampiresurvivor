# Proposal

## Why

Con Pixelify Sans algunos números se confunden: el 5, el 6 y el 8 se parecen tanto que "12:58" se lee como "12:88" y "250" como "280". En un juego donde el tiempo, el oro, el nivel y los números de daño se leen de un vistazo y en movimiento, eso es un problema de legibilidad, sobre todo en móvil.

## What Changes

- La fuente de toda la interfaz pasa de **Pixelify Sans** a **Jersey 10** (Google Fonts, SIL OFL 1.1), también pixel art, con dígitos claramente distintos y soporte para acentos, ñ, ¡ y ¿.
- Los recursos de fuente dejan de llamarse por la fuente concreta: `pixelify_semibold.tres` y `pixelify_bold.tres` pasan a `ui_font.tres` y `ui_font_bold.tres`.
- Se quitan `PixelifySans.ttf` y su licencia; `OFL.txt` y `CREDITS.md` pasan a Jersey 10.
- Jersey 10 es un 30 % más estrecha, así que se ajusta la estimación de ancho de carácter de las cartas (`UiCards.CHAR_WIDTH`, de 0,56 a 0,4).

**Fuera de alcance:** cambiar tamaños de letra (Jersey 10 tiene la misma altura de mayúsculas) y añadir una segunda fuente para títulos.

## Capabilities

### New Capabilities
<!-- Ninguna. -->

### Modified Capabilities
- `halloween-presentation`: el requisito "Interfaz pixel art" cambia de fuente y añade un escenario de legibilidad de números.

## Impact

- **Arte**: `art/fonts/` (fuente, `.import`, licencia y recursos de fuente).
- **Código**: `scripts/palette.gd` y `scenes/ui/theme.tres` (rutas de las fuentes) y `scripts/ui_cards.gd` (`CHAR_WIDTH`).
- **Créditos**: `CREDITS.md`.
- Los builds ya exportados en `builds/` siguen llevando la fuente anterior hasta que se vuelvan a exportar.
