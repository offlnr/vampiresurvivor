# Spec Delta

## MODIFIED Requirements

### Requirement: Escenario de fondo
El suelo del mapa SHALL ser un fondo temático de cementerio de noche que se repite sin costuras visibles en todas direcciones. El suelo MUST llevar solo textura (tierra, hierba y piedras), sin objetos dibujados, para que no se vea un patrón en cuadrícula. Las lápidas, árboles y demás objetos los coloca la decoración del mapa.

#### Scenario: Fondo infinito
- **WHEN** el jugador camina varios minutos en una misma dirección
- **THEN** el fondo se sigue viendo continuo, sin cortes ni zonas vacías

#### Scenario: Sin cuadrícula
- **WHEN** se mira cualquier parte del mapa
- **THEN** no hay lápidas, cruces ni otros objetos repetidos a distancias regulares
