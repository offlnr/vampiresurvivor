# Spec Delta

## Purpose

Power-ups que sueltan los enemigos al morir y que dan efectos breves y fuertes, para crear momentos de respiro y de remontada en mitad de las hordas.

## ADDED Requirements

### Requirement: Soltar power-ups
Cada enemigo normal SHALL tener una probabilidad pequeña de soltar un power-up al morir, y cada élite MUST soltar uno siempre. El tipo se elige al azar con pesos. El power-up se queda en el suelo hasta que el jugador lo toca o pasan 30 segundos, parpadeando al final.

#### Scenario: Élite derrotado
- **WHEN** muere un élite
- **THEN** suelta un cofre y además un power-up

#### Scenario: Caducar
- **WHEN** un power-up lleva 30 segundos en el suelo sin que nadie lo recoja
- **THEN** desaparece

### Requirement: Efectos de los power-ups
Al tocar un power-up SHALL aplicarse su efecto: corazón (cura el 30 % de la vida máxima), reloj (detiene a todos los enemigos y la aparición de nuevos durante 6 s, sin daño por contacto), imán (atrae todas las almas y el oro del mapa), bomba de calabaza (mata a los enemigos normales en pantalla y quita un 25 % de vida a los élites), escoba (+40 % de velocidad 10 s), furia (−40 % de recarga 10 s), lluvia de oro (doble de oro 20 s) y escudo (invulnerable 6 s).

#### Scenario: Detener el tiempo
- **WHEN** el jugador recoge el reloj
- **THEN** todos los enemigos se quedan quietos y teñidos de azul durante 6 segundos, no hacen daño por contacto y las armas siguen atacando

#### Scenario: Imán
- **WHEN** el jugador recoge el imán
- **THEN** todas las almas y monedas del mapa vuelan hacia él

#### Scenario: Bomba de calabaza
- **WHEN** el jugador recoge la bomba
- **THEN** mueren todos los enemigos normales visibles, los élites pierden un 25 % de su vida máxima y durante 8 segundos no aparecen enemigos nuevos (las hordas se retrasan lo mismo)

### Requirement: Efectos activos en el HUD
Los power-ups con duración SHALL mostrarse en el HUD con su icono y el tiempo que les queda. Recoger uno que ya está activo MUST renovar su duración.

#### Scenario: Escoba activa
- **WHEN** el jugador recoge la escoba
- **THEN** aparece su icono en el HUD con una cuenta atrás de 10 segundos
