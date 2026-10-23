# Spec Delta

## Purpose

Define cómo el jugador controla a su personaje en PC y en móvil, cómo lo sigue la cámara y cómo recibe daño y muere.

## ADDED Requirements

### Requirement: Movimiento con teclado
En PC el personaje SHALL moverse en 8 direcciones con WASD y con las flechas, a velocidad constante. El movimiento diagonal MUST tener la misma velocidad que el movimiento recto.

#### Scenario: Movimiento recto
- **WHEN** el jugador mantiene pulsada la tecla D
- **THEN** el personaje se desplaza hacia la derecha a su velocidad base

#### Scenario: Movimiento diagonal normalizado
- **WHEN** el jugador mantiene pulsadas W y D a la vez
- **THEN** el personaje se mueve en diagonal arriba-derecha a la misma velocidad que en línea recta

#### Scenario: Sin entrada
- **WHEN** el jugador no pulsa ninguna tecla de movimiento
- **THEN** el personaje se queda quieto

### Requirement: Movimiento con joystick virtual táctil
En pantallas táctiles el juego SHALL mostrar un joystick virtual que aparece donde el jugador toca la pantalla. La dirección y la intensidad del arrastre determinan el movimiento.

#### Scenario: Tocar y arrastrar
- **WHEN** el jugador toca la pantalla y arrastra el dedo hacia la izquierda
- **THEN** aparece el joystick en el punto de contacto y el personaje se mueve hacia la izquierda

#### Scenario: Soltar el dedo
- **WHEN** el jugador levanta el dedo
- **THEN** el joystick desaparece y el personaje se detiene

#### Scenario: Zona muerta
- **WHEN** el arrastre es menor que una zona muerta pequeña desde el punto de contacto
- **THEN** el personaje no se mueve

### Requirement: Mando de juego
El personaje SHALL poder moverse con el stick izquierdo de un mando conectado, con zona muerta.

#### Scenario: Stick analógico
- **WHEN** el jugador inclina el stick izquierdo hacia abajo
- **THEN** el personaje se mueve hacia abajo

### Requirement: Cámara que sigue al jugador
La cámara SHALL mantener al personaje centrado con un suavizado ligero. El mapa MUST ser abierto en todas direcciones, para que el jugador nunca choque con un borde.

#### Scenario: Seguimiento
- **WHEN** el personaje se desplaza en cualquier dirección
- **THEN** la cámara lo sigue y el suelo se sigue viendo sin huecos ni bordes

### Requirement: Vida y daño del jugador
El personaje SHALL tener vida máxima y vida actual. Al tocar a un enemigo pierde vida y queda invulnerable durante un breve tiempo, con un parpadeo visible.

#### Scenario: Recibir daño
- **WHEN** un enemigo toca al personaje y este no está invulnerable
- **THEN** la vida actual baja según el daño del enemigo menos la armadura del jugador, y el personaje parpadea durante el tiempo de invulnerabilidad

#### Scenario: Invulnerabilidad temporal
- **WHEN** un segundo enemigo lo toca durante el tiempo de invulnerabilidad
- **THEN** el personaje no pierde vida

### Requirement: Muerte del jugador
Cuando la vida actual llega a cero, el personaje SHALL morir y la partida MUST terminar en derrota.

#### Scenario: Vida a cero
- **WHEN** la vida actual del personaje llega a 0
- **THEN** el personaje deja de responder a la entrada y se muestra la pantalla de derrota
