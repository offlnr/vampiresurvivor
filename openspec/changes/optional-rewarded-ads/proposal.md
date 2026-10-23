# Proposal

## Why
El juego necesita una forma de generar ingresos que no estropee la experiencia. Los anuncios con recompensa son opcionales: el jugador elige ver uno a cambio de algo útil. Son lo que mejor funciona en el género y no castigan a quien no quiere verlos.

## What Changes
- **Servicio `Ads`** (autoload) con `is_available()` y `await show_rewarded(lugar)`. Todavía no hay SDK:
  - en builds de depuración sale un anuncio de prueba de 3 s ("Cerrar" no da nada; "Recoger" da la recompensa);
  - en builds de publicación no hay anuncios y los botones no se muestran hasta conectar un SDK real.
- **Cuatro anuncios con recompensa**, todos con límite:
  1. **Revivir**: al morir, "¿Segunda oportunidad?". Se vuelve con la mitad de la vida, el escudo lleno, 3 s de invulnerabilidad y una onda que limpia la pantalla. Una vez por partida.
  2. **×2 de plata** en la pantalla de fin de partida, una vez.
  3. **+1 tirada** en la subida de nivel, como mucho 2 por partida.
  4. **Regalo diario**: +5 de plata desde el menú principal, una vez al día.
- **Preparado para un pase sin anuncios**: con `Ads.ad_free` las recompensas llegan sin ver anuncio. La compra en sí no está hecha.
- Ningún anuncio obligatorio ni a pantalla completa forzado. Solo aparecen en pausas naturales, y todos los botones dicen "(anuncio)".

## Capabilities

### New Capabilities
- `rewarded-ads`: anuncios opcionales con recompensa y sus límites.

## Impact
- **Nuevos**: `autoload/ads.gd` (autoload `Ads`) y `scenes/ui/revive_offer.gd`.
- **Modificados**:
  - `scenes/main/run.gd`: revivir, tirada extra y duplicar plata;
  - `scenes/player/player.gd`: `revive()`;
  - `autoload/progress.gd`: `add_silver()` y regalo diario;
  - `scenes/ui/level_up.gd`, `scenes/ui/game_over.gd` y `scenes/main/main_menu.gd`.
