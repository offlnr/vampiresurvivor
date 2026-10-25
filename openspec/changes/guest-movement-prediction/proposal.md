# Proposal

## Why

En el cooperativo online, el personaje del invitado respondía a los controles con todo el retraso de ida y vuelta al servidor de salas, más la interpolación. Con un servidor en Render eso son fácilmente 250–400 ms: el personaje se siente pesado y es difícil esquivar. Era el siguiente paso previsto en `online-coop-multiplayer`.

## What Changes

- **Predicción local del personaje del invitado**:
  - el personaje del invitado se mueve en su pantalla en cuanto pulsa una dirección, sin esperar al anfitrión;
  - la cámara del invitado lo sigue igual.
- **Corrección suave**:
  - cada instantánea trae la posición del personaje en el anfitrión y el número de la última entrada que recibió;
  - el invitado calcula dónde debería estar (esa posición más las entradas que el anfitrión todavía no tenía) y corrige la diferencia poco a poco;
  - si la diferencia es grande (revivir, empujones), salta directamente.
- **Sin predicción cuando la partida está parada** (menús, pausa) o el invitado ha caído: se usa la posición del anfitrión tal cual.

Medido con 120 ms de retraso en cada sentido, el personaje del invitado empieza a moverse a los 19 ms de pulsar, en lugar de 329 ms. Al soltar, acaba exactamente donde lo tiene el anfitrión.

**Fuera de alcance**: predecir también los proyectiles del invitado. Siguen saliendo desde donde está su personaje en el anfitrión, con el retraso de la conexión.

## Capabilities

### Modified Capabilities
- `online-coop`: "Anfitrión con autoridad y réplica al invitado" (predicción del personaje del invitado).

## Impact

- **`net_guest.gd`**:
  - las entradas llevan número;
  - `_predict()` calcula la posición prevista;
  - el proxy del propio personaje y la cámara se dibujan en la posición prevista.
- **`net_host.gd`**: la cabecera de la instantánea añade:
  - `input`: la última entrada recibida;
  - `self_unit`: la unidad del personaje del invitado;
  - `speed`: su velocidad;
  - `moving`: si puede moverse.
- **Compatibilidad**: el formato de los mensajes cambia, así que los dos jugadores necesitan la misma versión.
