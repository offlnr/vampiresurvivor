# Design

## Context

- **Autoridad**: el anfitrión simula todo, y el invitado envía su dirección 30 veces por segundo.
- **Réplica**: el invitado dibuja las instantáneas (20 por segundo) interpolando entre las dos últimas.
- **Resultado**: su propio personaje llegaba con el retraso de la ida al anfitrión, más la vuelta, más hasta 50 ms de interpolación.

## Decisions

### Predicción con reconciliación
Es la técnica clásica de los juegos en red con servidor autoritativo:
1. **Entradas numeradas**: cada entrada enviada lleva un número y se guarda junto al tiempo que ha estado activa en el invitado.
2. **Confirmación**: el anfitrión devuelve en cada instantánea el número de la última entrada recibida (`input`) y la posición del personaje.
3. **Predicción**: el invitado descarta las entradas confirmadas. La posición prevista es la del anfitrión más `dirección × velocidad × tiempo` de cada entrada pendiente, empujada fuera de las tumbas y los árboles con las mismas decoraciones que genera en local.
4. **Corrección**: la diferencia entre lo previsto y lo dibujado se corrige a razón de `CORRECTION_RATE` (8 por segundo). Así los pequeños errores (el anfitrión aplica cada entrada en sus propios fotogramas de física) no se ven como saltos.

### Qué no se predice
- **Solo se predice el movimiento**:
  - la vida, los golpes y la muerte siguen llegando del anfitrión;
  - si un golpe o una tumba lo desplaza de verdad, la corrección lo recoloca.
- **Saltos**: con una diferencia mayor que `PREDICTION_SNAP` (160) el personaje salta, por ejemplo al revivir.
- **Partida parada**: con la partida parada o el invitado caído (`moving = false`), el invitado usa la posición del anfitrión tal cual. Si no, seguiría moviéndose en su pantalla mientras el anfitrión está en un menú.

### Qué se dibuja en la posición prevista
El proxy de la unidad `self_unit` (el `Player` del invitado y sus hijos, como los murciélagos que orbitan) y la cámara. El resto de unidades sigue interpolando.

Por eso los proyectiles del invitado salen desde su posición en el anfitrión, unos píxeles por detrás de donde se le ve al correr. Se acepta: predecir proyectiles exigiría simular las armas en el invitado.

## Risks / Trade-offs

- **Velocidad**: viene en cada instantánea. Si cambia (escoba, pergamino), la predicción usa la nueva a partir de la siguiente, y la diferencia se corrige.
- **Conexión inestable**: con picos de latencia muy grandes, las correcciones son mayores y pueden notarse como un deslizamiento corto.
