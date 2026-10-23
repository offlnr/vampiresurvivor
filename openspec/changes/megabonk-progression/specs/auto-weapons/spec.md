# Spec Delta

## MODIFIED Requirements

### Requirement: Niveles de arma
Como en Megabonk, cada mejora de arma SHALL dar 1 o 2 estadísticas si es común (al 50 %) y 2 si es poco común o mejor, elegidas al azar de la lista propia de esa arma, y la rareza MUST multiplicar su valor (×1; ×1,2; ×1,4; ×1,6; ×2). Las armas no tienen nivel máximo ni topes. El daño MUST mejorar siempre en porcentaje ("+25 % de daño"), nunca en puntos. Las cantidades (proyectiles, perforación) MUST guardar los decimales como en Megabonk: "+1 proyectil" raro da +1,4 y el arma usa la parte entera del total.

#### Scenario: Solo mejoras
- **WHEN** un arma sube de nivel
- **THEN** ninguna de sus estadísticas empeora, y la carta solo enumera ganancias en positivo (una recarga más corta se muestra como "+X % de velocidad de ataque", nunca como una reducción)

#### Scenario: Valores exactos en la carta
- **WHEN** se ofrece una mejora común de la calabaza que sube su tamaño
- **THEN** la carta dice solo "+15 % de tamaño", nunca un texto vago como "más grande"

#### Scenario: Pocas estadísticas por carta
- **WHEN** se ofrece una mejora de arma
- **THEN** la carta muestra 1 o 2 estadísticas si es común y 2 si es de rareza superior, nunca más

#### Scenario: Común con dos estadísticas
- **WHEN** salen muchas mejoras comunes de un arma
- **THEN** aproximadamente la mitad mejoran 1 estadística y la otra mitad 2

#### Scenario: Subir un arma de nivel
- **WHEN** el jugador elige la mejora de un arma que ya tiene
- **THEN** el arma sube un nivel y su atributo mejorado se nota en la partida

#### Scenario: Daño en porcentaje
- **WHEN** se ofrece una mejora común de daño de la calabaza
- **THEN** la carta dice "+25 % de daño" y nunca un valor en puntos

#### Scenario: Cantidad con decimales
- **WHEN** el orbe (1 proyectil) recibe una mejora de cantidad poco común (+1,2) y otra rara (+1,4)
- **THEN** la carta dice "+1,2 orbes" y "+1,4 orbes", y el orbe pasa a disparar 3 orbes (3,6 en total)

#### Scenario: Sin topes
- **WHEN** la guadaña ya corta en 2 direcciones y sale otra mejora de cantidad
- **THEN** pasa a cortar en 3 direcciones repartidas alrededor del personaje

