# Roguelike Progression

## Dos capas

### Dentro de la run
- construcción;
- upgrades de torre;
- mapa;
- economía;
- maná;
- cartas;
- status/build synergies.

### Entre runs
- moneda meta;
- tienda;
- desbloqueo de torres;
- mejoras permanentes.

## Recompensa por derrota
El jugador debe recibir moneda aunque no llegue a ronda 20.

Crear fórmula configurable basada principalmente en progreso de ronda. Evitar que farmear ronda 1 sea óptimo.

## Permanent shop
Tipos iniciales:
- unlock tower;
- pequeño bonus global;
- mejora de economía inicial;
- mejora de maná;
- ampliar/alterar pool de cartas.

No introducir support buildings.

## Filosofía
Las permanentes facilitan progreso y variedad, pero no deben convertir el juego en "ganar por estadísticas" sin estrategia.

## Cards
Las cartas sustituyen parte del espacio sistémico que en Rogue Tower ocupan upgrades/support.

Categorías:
- tower-specific;
- tower-family;
- status;
- economy;
- mana;
- global utility.

Las cartas pueden aumentar:
- capacidad de maná;
- regeneración de maná;
- eficiencia;
- estadísticas de torre;
- status;
- economía.

## Desbloqueos
Una torre bloqueada no aparece en:
- build menu;
- pools de cartas específicos;
- recompensas que dependan de ella.

## Run seed
Guardar seed en resumen de run para reproducir:
- ofertas de cartas;
- selección de piezas;
- variaciones de wave que se autoricen.

## Victoria/derrota
- Base health <= 0 -> derrota.
- Completar ronda 20 -> victoria demo.
- Ambos casos calculan recompensa meta y muestran resumen.
