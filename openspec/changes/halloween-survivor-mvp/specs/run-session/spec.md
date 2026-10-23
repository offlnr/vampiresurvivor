# Spec Delta

## Purpose

Define el ciclo completo de una partida infinita (menú, juego, pausa, muerte, récord y reintento) y la información que el jugador ve en pantalla mientras juega.

## ADDED Requirements

### Requirement: Menú principal
Al abrir el juego SHALL mostrarse un menú principal con el título, un botón para jugar y un acceso a opciones de volumen.

#### Scenario: Empezar a jugar
- **WHEN** el jugador pulsa "Jugar" en el menú principal
- **THEN** empieza una partida nueva

### Requirement: Partida infinita
La partida SHALL no tener final: dura hasta que el jugador muere. El temporizador MUST contar hacia arriba sin límite, con horas cuando pase de 60 minutos.

#### Scenario: Pasar de los 10 minutos
- **WHEN** el temporizador llega a 10:00 y el jugador sigue vivo
- **THEN** la partida sigue, siguen apareciendo enemigos y hordas, y la dificultad sigue subiendo

#### Scenario: Más de una hora
- **WHEN** el jugador lleva 1 hora y 5 minutos
- **THEN** el temporizador muestra "1:05:00"

### Requirement: Récord
El juego SHALL guardar en el dispositivo el mayor tiempo sobrevivido y mostrarlo en el menú principal y en la pantalla de fin, avisando cuando se bate.

#### Scenario: Nuevo récord
- **WHEN** el jugador muere tras sobrevivir más que su récord anterior
- **THEN** la pantalla de fin muestra "¡Nuevo récord!" y el menú principal enseña el nuevo tiempo

### Requirement: Pantalla de fin de partida
Al morir el jugador SHALL mostrarse una pantalla con el tiempo sobrevivido, el récord, el nivel alcanzado y las muertes, con botones para reintentar y para volver al menú.

#### Scenario: Reintentar
- **WHEN** el jugador pulsa "Reintentar" en la pantalla de fin de partida
- **THEN** empieza una partida nueva desde cero

#### Scenario: Volver al menú
- **WHEN** el jugador pulsa "Menú"
- **THEN** se vuelve al menú principal

### Requirement: Pausa
El jugador SHALL poder pausar con Esc o P en PC, con un botón en pantalla en móvil o con Start en un mando. El juego MUST pausarse solo cuando la ventana o la pestaña pierden el foco, o la app pasa a segundo plano.

#### Scenario: Pausa manual
- **WHEN** el jugador pulsa el botón de pausa durante la partida
- **THEN** todo el juego se congela y se muestra un menú con "Continuar", "Volumen" y "Abandonar"

#### Scenario: Pausa automática
- **WHEN** la pestaña del navegador pierde el foco o la app móvil pasa a segundo plano durante la partida
- **THEN** la partida se pausa y se muestra el menú de pausa

### Requirement: HUD de partida
Durante la partida el HUD SHALL mostrar arriba a la izquierda la vida, las armas, los pergaminos y los efectos activos; arriba en el centro el temporizador; arriba a la derecha el minimapa con el oro y las muertes centrados debajo; abajo en el centro los objetos comprados; y la barra de experiencia con el nivel ocupando todo el borde inferior. MUST quedar legible y sin solaparse en pantallas de móvil verticales y horizontales.

#### Scenario: Actualización del HUD
- **WHEN** el jugador recibe daño, recoge experiencia o mata a un enemigo
- **THEN** la barra o el contador correspondiente se actualiza en el mismo frame

#### Scenario: Zonas seguras
- **WHEN** el juego corre en un móvil con notch o bordes redondeados
- **THEN** ningún elemento del HUD queda tapado por el notch ni fuera de la zona visible

### Requirement: Ajustes de volumen persistentes
El jugador SHALL poder ajustar por separado el volumen de la música y de los efectos. Los valores MUST guardarse en el dispositivo y aplicarse al volver a abrir el juego.

#### Scenario: Recordar volumen
- **WHEN** el jugador baja la música a 0, cierra el juego y lo vuelve a abrir
- **THEN** la música sigue a volumen 0
