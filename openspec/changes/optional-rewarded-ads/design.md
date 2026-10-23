# Design

## Decisions

### 1. Un solo punto de entrada
Todo el juego llama a `Ads.show_rewarded(lugar)` con `await` y recibe si hay recompensa. Mientras dura el anuncio, el juego está en pausa, y al cerrarse vuelve a como estaba. Cambiar de SDK solo toca `_real_available()` y `_show_real()`.

### 2. Anuncio de prueba solo en depuración
`is_available()` es verdadero en builds de depuración aunque no haya SDK. En publicación es falso hasta conectar uno, así que nunca se publica un "anuncio falso" y los botones simplemente no aparecen.

### 3. Límites
Viven en quien ofrece cada anuncio, no en `Ads`:
- revivir: `run.revive_used`, una vez por partida;
- tirada extra: `run.ad_rerolls_left`, 2 por partida;
- ×2 de plata: el botón desaparece al usarlo;
- regalo diario: `Progress.last_gift` guarda la fecha del sistema.

Un segundo anuncio no puede empezar mientras otro está en pantalla (`_busy`).

### 4. Revivir
Al morir, `run` espera 0,8 s (la animación de caída), pausa el juego y pregunta. Si el jugador acepta y termina el anuncio:
- `Player.revive(0,5)`: mitad de vida, escudo lleno y 3 s de invulnerabilidad;
- detonación como la de la bomba de calabaza;
- se muestran las subidas de nivel que quedaron pendientes.

Si el jugador rechaza o cierra el anuncio, la partida termina como siempre. La partida se guarda (plata y desafíos) solo al terminar de verdad, así que revivir no cuenta como dos partidas.

### 5. Siguiente paso: SDK real
- **Android**: AdMob con `godot-admob-plugin` (Poing Studios, Godot 4), anuncios *rewarded*. En la UE hace falta el consentimiento UMP. Configurar la audiencia (no dirigido a niños) en la consola de AdMob.
- **Web**: si se publica en CrazyGames o Poki, su SDK incluye anuncios con recompensa.
- **PC**: sin anuncios. Mejor un precio único o donaciones.

## Verificación hecha
Godot 4.7.2 headless (`ads_test`, 17 comprobaciones, todas pasan), con progreso en un archivo temporal y sin tocar `settings.cfg`:
- **Anuncio de prueba**: cerrarlo no da recompensa.
- **Revivir**: al morir sale la pregunta con el juego en pausa. Al revivir se vuelve con el 50 % de vida y la partida sigue. La segunda muerte va directa al fin de partida.
- **Tirada extra**: da +1 tirada. Tras 2 el botón desaparece, y el menú sigue abierto y en pausa.
- **×2 de plata**: duplica la plata de la partida.
- **Regalo diario**: da +5 una vez al día y el botón se oculta.
- **Pase sin anuncios**: con él la recompensa llega sin anuncio.

Las demás pruebas siguen pasando. Capturas: subida de nivel con "+1 tirada (anuncio)", la pregunta de revivir y la pantalla del anuncio de prueba.
