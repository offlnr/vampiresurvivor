# Design

## Context

- La interfaz usa dos `FontVariation` sobre el mismo archivo: una normal (por defecto en el tema y `Palette.FONT`) y otra en negrita (botones, títulos, HUD y `Palette.FONT_BOLD`). Antes eran los pesos 600 y 700 de la fuente variable Pixelify Sans.
- La importación de la fuente ya estaba pensada para pixel art: sin antialiasing, sin hinting y sin posicionamiento subpíxel.
- Las cartas calculan cuántas líneas ocupa la descripción con un ancho medio de carácter fijo (`UiCards.CHAR_WIDTH`).

## Goals / Non-Goals

**Goals:**
- Que cualquier número del juego (tiempo, oro, nivel, daño, precios) se lea sin dudas.
- Mantener el aspecto pixel art y el soporte completo del español.
- Que cambiar de fuente en el futuro solo toque `art/fonts/`.

**Non-Goals:**
- Rediseñar tamaños, el tema o el HUD.

## Decisions

### 1. Jersey 10
Se compararon, renderizadas con los mismos textos (dígitos, "12:58", "+38 %", y una frase con acentos, ñ, ¡ y ¿), Pixelify Sans, Jersey 10, Press Start 2P, Silkscreen, Micro 5, VT323 y Jacquard 12.
- **Jersey 10**: dígitos inconfundibles, estrecha (≈0,36 em por carácter frente a ≈0,50 de Pixelify), mayúsculas y minúsculas, español completo. Elegida.
- **Press Start 2P**: los números más claros, pero el doble de ancha; las descripciones de las cartas no caben.
- **Silkscreen**: clara, pero sin minúsculas reales; los textos largos se leen peor.
- **Micro 5**: demasiado pequeña a los tamaños del juego.
- **VT323** y **Jacquard 12**: estilo terminal y gótico, no encajan con el juego.

### 2. Recursos de fuente con nombre neutro
`ui_font.tres` y `ui_font_bold.tres` envuelven el archivo de fuente. Jersey 10 solo tiene un peso, así que hoy los dos apuntan al mismo archivo sin variación; se mantienen los dos para poder poner una fuente de títulos distinta sin tocar el código. Se descartó engrosar con `variation_embolden`, porque emborrona los píxeles.

### 3. Misma importación
El `.import` copia los parámetros del de Pixelify (antialiasing 0, hinting 0, subpíxel 0, sin mipmaps) para que la fuente siga viéndose nítida.

### 4. Ancho de carácter de las cartas
`CHAR_WIDTH` pasa a 0,4: el ancho medido de Jersey 10 (0,357) con el mismo margen (~11 %) que tenía el valor anterior sobre Pixelify (0,56 sobre 0,504).

## Risks / Trade-offs

- [Los textos de 14 px quedan pequeños en móvil] → Siguen siendo legibles; si hace falta, subirlos a 16 px.
- [Botones y títulos ya no se distinguen por el grosor] → Se distinguen por tamaño y contorno; la Decisión 2 permite añadir una fuente de títulos.
