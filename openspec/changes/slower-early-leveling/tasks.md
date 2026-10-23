# Tasks

## 1. Curva

- [x] 1.1 Añadir el extra de experiencia de los primeros niveles (`EARLY_XP_EXTRA` = 20, desaparece en `EARLY_LEVELS` = 15) en `xp_to_next_level()`; verificar el escenario "Primeros niveles más lentos" y "Niveles altos sin cambios" con los costes calculados
- [x] 1.2 Medir con el bot headless, en 6 partidas de 3 minutos por curva, el nivel en los minutos 1 a 3 antes y después; verificar el escenario "Primer minuto" (de 8,5 a 4,7 de media)

## 2. Verificación

- [ ] 2.1 Medir varias partidas de 10 minutos jugando (o con un bot que elija mejoras) y comprobar que se llega a nivel 30–40 en el minuto 10
- [ ] 2.2 Jugar el primer minuto y ajustar `EARLY_XP_EXTRA` si se hace demasiado lento
