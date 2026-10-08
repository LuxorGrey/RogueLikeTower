# Roguelike Progression

## Dos capas

### Dentro de la run
- construcción;
- upgrades de torre;
- mapa;
- oro de construcción (saldo temporal de `RunEconomyService`);
- maná (saldo temporal, capacidad y regeneración configurables);
- cartas;
- status/build synergies.

### Entre runs
- moneda meta (`MetaProgression.meta_currency`, persistente y separada del oro de construcción);
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

M9 implementa solo economía runtime: oro inicial, gasto en construcción/mejoras, recompensas por baja y ronda superada, y maná con coste por ataque y regeneración. El oro no se guarda ni se convierte en meta moneda en M9. M12 conserva la responsabilidad de recompensas de fin de run, tienda permanente, desbloqueos y guardado. No hay edificios que generen oro o maná.

M10 implementa el loop técnico de campaña: rondas 1–19 alternan limpieza, recompensa y una única expansión válida de siete hexes; la 20 limpia y entra a victoria demo. La campaña no otorga todavía moneda meta ni resumen persistente; eso sigue en M12. Los encuentros propios confirmados son minijefes en 17/19 y jefe Tier 2 en 20, aún con variantes/poderes pendientes. El selector de ronda y los fixtures M7/M8 de diagnóstico no cambian el avance de campaña.

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
