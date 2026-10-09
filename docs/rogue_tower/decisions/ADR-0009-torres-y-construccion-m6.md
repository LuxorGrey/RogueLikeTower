# ADR-0009: construcción y primera torre M6

- Estado: aceptada para el prototipo; el camino temporal de daño directo quedó sustituido por ADR-0010 y el coste gratuito de M6 quedó sustituido por ADR-0013. Contenido, números y regla de altura siguen provisionales.
- Fecha: 2026-10-08.

## Contexto

M6 debe convertir la ruta y la oleada de M4/M5 en un prototipo de Tower Defense comprobable. La economía está planificada en M9 y el cálculo central de daño en M7. El tablero aún es una autoridad axial 2D con altura lógica y las celdas PATH deben seguir formando una ruta válida hasta la base.

## Decisión

- `BuildController` es dueño del build mode, la selección y la lista de torres por coordenada. Consulta `HexGrid` y exige una celda existente, `buildable`, sin ocupación, y terreno permitido por `TowerData`.
- M6 solo habilita construcción sobre GRASS o MOUNTAIN. Las torres no pueden ocupar PATH; por eso su colocación no muta `PathGraph` ni puede sellar una ruta.
- Se permite construir/mejorar durante `ROUND_PREP`, `COMBAT` y `TERRAIN_EXPANSION`; no durante `RUN_SETUP` ni `RUN_DEFEAT`. El terreno permanece bloqueado en `COMBAT`.
- `Basic Bolt` es la única torre inicial. `TowerData` almacena daño, ataques por segundo, alcance en hexes, máscara de terrenos, prioridad, bonus de altura, límite e incrementos de mejora y escena.
- La torre busca enemigos vivos en alcance cada 0.1 segundos, una frecuencia suficiente para la muestra pequeña. First/last usan el progreso normalizado de ruta; highest health compara vida actual y highest armor consulta el campo configurado en `EnemyData`. Los empates se resuelven por ID de instancia estable durante la vida del nodo.
- El ataque M6 es hitscan directo y llama `Enemy.apply_damage`. No se añade un `Area2D`, búsqueda física ni escena de proyectil, porque el prototipo no requiere colisiones y el daño central pertenece a M7. El director sigue administrando las señales de muerte y llegada existentes.
- El placeholder vectorial dibuja base, orientación, alcance al seleccionar y flash de disparo. El preview del tablero muestra marcador y radio de colocación legal/ilegal.
- Valores provisionales de Basic Bolt: daño 10, 1 ataque/s, rango base 3 hexes, máximo nivel 3, +5 daño y +0.25 hex de rango por mejora. Cada nivel de elevación de la torre añade +0.25 hex de alcance. Esta fórmula usa la altura del terreno de construcción; los enemigos de la demo recorren PATH a elevación 0.
- Las mejoras no cuestan nada en M6 para probar progresión local; M9 agregará coste, moneda y recompensas. No se implementa venta en este milestone. El armor se usa para ordenar objetivos, no para mitigar daño; M7 añadirá el pipeline y la mitigación.

## Consecuencias

- Se puede defender la primera oleada y comprobar colocación, targeting, rango, cadencia y mejoras sin anticipar economía o arquitectura final de daño.
- Los números, el bonus de altura, los colores del preview y el arte de torre permanecen configurables y no son reglas de balance confirmadas.
- Si más adelante se permiten torres sobre PATH o terreno que altere topología, habrá que revalidar rutas antes de confirmar la construcción.
- M6 smoke prueba el contrato de datos/lógica. El render del HUD, la lectura del alcance y el input de ratón requieren además la prueba manual documentada en `10_ACCEPTANCE_TESTS.md`.

## Referencias

- `docs/rogue_tower/design/02_IMPLEMENTATION_ROADMAP.md`, secciones M5–M9, consultado el 2026-10-08.
- `docs/rogue_tower/design/04_DATA_MODELS.md`, `06_COMBAT_SYSTEM.md` y `10_ACCEPTANCE_TESTS.md`, consultados el 2026-10-08.
- `.agents/skills/godot-master/references/combat-system.md`, `resource-data-patterns.md`, `signal-architecture.md` y `2d-physics-area2d-and-queries.md`, consultados el 2026-10-08.

## Cambio posterior en M9

La decisión histórica de que las mejoras fueran gratuitas solo aplicaba al prototipo M6 y queda reemplazada por los costes configurables `TowerData.upgrade_costs`, el coste de construcción y la integración de oro/maná descritos en [ADR-0013](ADR-0013-economia-de-run-y-mana-m9.md). El resto de este ADR conserva los contratos de construcción y targeting de M6.
