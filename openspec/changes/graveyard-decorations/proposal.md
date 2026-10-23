# Proposal

## Why

El mapa se ve plano. El suelo era un mosaico de 512 px con las lápidas, cruces, huesos y setas dibujados dentro, así que se repetían en una cuadrícula perfecta, y no había nada con volumen ni nada que rodear. El cementerio no parecía un lugar, sino un fondo de pantalla.

## What Changes

- **Suelo nuevo**: un mosaico de 1024 px solo con manchas de tierra, hierba y guijarros, sin objetos dibujados, para que no se note la repetición. Lo genera un script guardado en el repo (`tools/generate_ground.gd`).
- **Decoración procedural por zonas**: el mundo infinito se divide en zonas de 800 × 800. Cada zona se genera a partir de una semilla de partida y de sus coordenadas, así que al volver a un sitio se ve igual. En cada partida el mapa es distinto. Cada zona tiene:
  - 0–2 **estructuras**: mausoleo, árbol muerto, obelisco, columna rota, farola con luz que parpadea, montón de calabazas y lápida grande;
  - a veces un **pequeño cementerio**: filas de lápidas y cruces;
  - **detalles** por el suelo: hierba alta, huesos, calaveras, setas y velas encendidas. Van algo oscurecidos para no competir con enemigos, almas y recogibles.
- **Estructuras sólidas**:
  - el jugador y los enemigos que caminan las rodean;
  - los murciélagos y los fantasmas vuelan por encima;
  - todo se ordena en profundidad: el jugador pasa por delante y por detrás.
- **Nada dentro de una estructura**: los calderos, los cofres de pago y el comerciante buscan un sitio libre, y los power-ups y cofres que suelta un enemigo volador sobre una estructura se colocan donde se pueden alcanzar.
- La zona de inicio queda libre de estructuras.

**Fuera de alcance:** marcar las estructuras en el minimapa, que los proyectiles choquen con ellas y biomas o zonas con tema distinto.

## Capabilities

### New Capabilities
- `map-decorations`: estructuras y detalles del mapa, su generación y sus colisiones.

### Modified Capabilities
- `halloween-presentation`: "Escenario de fondo" (sin repetición visible en cuadrícula, con estructuras y detalles).

## Impact

- **Código**:
  - Nuevo `Decorations` (`scenes/main/decorations.gd`).
  - `EnemyData.flying` (murciélago y fantasma).
  - `Player` y `EnemyManager` usan `push_out()`.
  - `PickupManager`, `MapChests`, `MerchantDirector` y `Cauldrons` evitan las estructuras.
  - `run.gd` y `run.tscn` lo conectan.
- **Arte**: `art/placeholder/props/` (7 estructuras y 7 detalles) y un `ground.svg` regenerado.
- **Herramientas**: `tools/generate_ground.gd` (con `.gdignore`, para que Godot no lo importe).
