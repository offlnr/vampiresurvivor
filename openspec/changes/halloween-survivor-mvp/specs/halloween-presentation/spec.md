# Spec Delta

## Purpose

Define la identidad visual y sonora provisional de Halloween del MVP, y garantiza que el arte y el audio se puedan sustituir más adelante por los definitivos sin cambiar el comportamiento del juego.

## ADDED Requirements

### Requirement: Paleta de Halloween
Todo el arte provisional SHALL usar una paleta limitada de Halloween: naranja calabaza, morado, verde ácido, negro/gris oscuro y blanco hueso. El jugador, los enemigos, los proyectiles y las almas MUST distinguirse entre sí a simple vista.

#### Scenario: Legibilidad en una horda
- **WHEN** hay más de 100 enemigos, proyectiles y almas en pantalla
- **THEN** el personaje del jugador se distingue claramente y las almas se distinguen de los enemigos

#### Scenario: Enemigos sobre el fondo
- **WHEN** un enemigo de cualquier tipo, incluido el murciélago, pasa sobre cualquier zona del suelo
- **THEN** se distingue claramente del fondo gracias a su color y a un contorno claro

### Requirement: Arte provisional identificable
Cada entidad SHALL tener un aspecto provisional que ya sugiera lo que es: silueta de murciélago, zombi, fantasma, calabaza y alma. Cada tipo de enemigo MUST distinguirse por su forma y no solo por el color.

#### Scenario: Distinguir sin color
- **WHEN** se ve la partida en escala de grises
- **THEN** los tres tipos de enemigo siguen distinguiéndose por su forma

### Requirement: Animaciones de personajes
El jugador y cada enemigo SHALL tener animación por fotogramas: caminar o aletear al moverse, y el jugador también en reposo. Los enemigos MUST tener una entrada al aparecer y una muerte visible con efecto.

#### Scenario: Caminar
- **WHEN** el jugador se mueve
- **THEN** se reproduce su ciclo de caminar, y al detenerse pasa a la animación de reposo

#### Scenario: Aparición de un zombi
- **WHEN** aparece un zombi
- **THEN** surge del suelo con una animación breve antes de perseguir al jugador

### Requirement: Interfaz pixel art
Toda la interfaz SHALL usar una fuente pixel art con licencia libre (Pixelify Sans, OFL), registrada en los créditos, y paneles y botones de esquinas rectas con borde y sombra en bloque. Las cartas de mejora, de la tienda y de los cofres MUST mostrarse en una lista vertical de cartas compactas (icono a la izquierda, texto a la derecha) en cualquier orientación de pantalla.

#### Scenario: Cartas en vertical
- **WHEN** se abre la selección de mejora en una pantalla horizontal
- **THEN** las 3 cartas aparecen una debajo de otra, compactas, con sus botones de volver a tirar y desterrar al lado

#### Scenario: Fuente pixel art
- **WHEN** se muestra cualquier texto del juego, con acentos y eñes
- **THEN** usa la fuente pixel art y todos los caracteres se ven bien

### Requirement: Escenario de fondo
El suelo del mapa SHALL ser un fondo temático, como un cementerio o un campo de noche, que se repite sin costuras visibles en todas direcciones.

#### Scenario: Fondo infinito
- **WHEN** el jugador camina varios minutos en una misma dirección
- **THEN** el fondo se sigue viendo continuo, sin cortes ni zonas vacías

### Requirement: Respuesta visual y sonora
El juego SHALL dar respuesta visual y sonora a los eventos clave: impacto en un enemigo, muerte de un enemigo, recoger un alma, subir de nivel y recibir daño. Además MUST sonar música de fondo de ambiente de Halloween.

#### Scenario: Subir de nivel
- **WHEN** el jugador sube de nivel
- **THEN** suena un efecto propio y se ve un destello o efecto en el personaje

### Requirement: Assets reemplazables
Cambiar el sprite, el sonido o la música de una entidad por otro archivo SHALL afectar solo a su aspecto o a su sonido. MUST NOT cambiar su tamaño de colisión, su velocidad, su daño ni otro comportamiento.

#### Scenario: Cambiar sprite del zombi
- **WHEN** se sustituye el sprite provisional del zombi por un sprite definitivo de otro tamaño en píxeles
- **THEN** el zombi conserva su tamaño de colisión, velocidad, vida y daño

### Requirement: Licencia de assets
Todo asset de terceros SHALL tener una licencia que permita el uso comercial, y MUST quedar registrado en un archivo de créditos del proyecto junto a su autor y su licencia.

#### Scenario: Añadir un asset externo
- **WHEN** se incorpora un sonido o un sprite descargado de internet
- **THEN** su autor, su origen y su licencia quedan anotados en el archivo de créditos
