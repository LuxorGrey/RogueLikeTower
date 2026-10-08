# ADR-0008: primera oleada y movimiento de enemigos M5

> Nota posterior: M9 implementa los campos de recompensa que quedaban pendientes en este prototipo. Sus valores de prueba y la propiedad del pago están en [ADR-0013](ADR-0013-economia-de-run-y-mana-m9.md).

- Estado: aceptada para el prototipo M5; contenido y parámetros provisionales.
- Fecha: 2026-10-08.

## Contexto

M5 debe cerrar el recorrido desde el grafo M4 hasta un objetivo con vida: generar enemigos, recorrer una ruta válida, dañar la base al llegar y terminar la primera oleada. El proyecto aún no tiene torres (M6), pipeline de daño (M7) ni ciclo completo de rondas (M10); esta etapa necesita datos mínimos para probar el flujo sin anticipar esos sistemas.

## Decisión

- `GameBase` es una escena con `BaseData` y `HealthComponent`. Para la muestra se dibuja sobre PATH axial `(0,0)`, que sigue siendo una coordenada de objetivo provisional y reemplazable.
- `Enemy` es una escena con `EnemyData`, `HealthComponent` y `PathFollowerComponent`. El director inyecta una `PathRoute` válida; el actor aparece en la coordenada exterior del endpoint y recorre los centros de los hexes en orden, usando movimiento determinista por distancia en `_physics_process`.
- `WaveDirector` recibe explícitamente la oleada, el snapshot `PathGraph`, la base, el contenedor de entidades, el origen del mapa y el radio hexagonal. El código de gameplay no hace una búsqueda espacial genérica ni reconstruye ruta por frame.
- `WaveData` y `WaveEnemyGroupData` declaran enemigos, cantidad, intervalo, demora y política de endpoint. `FIRST_SORTED` usa el primer candidato válido en orden estable para la oleada de prueba; `ROUND_ROBIN` queda disponible como opción configurable. El comportamiento de ronda final sigue abierto.
- La muestra usa base 50 HP, enemigo 20 HP, velocidad 90 px/s, daño de llegada 10 y tres enemigos espaciados 1 s. Son placeholders técnicos configurables, no valores de balance confirmados.
- `Main` bloquea la colocación mientras `RunManager` está en `COMBAT`; terminar la muestra entra en `TERRAIN_EXPANSION`, agotar la base entra en `RUN_DEFEAT`. No se inicia automáticamente otra ronda.

## Consecuencias

- El smoke de M5 puede demostrar ruta, daño, muerte, derrota y terminación sin implementar torres ni alterar el alcance de M6–M10.
- Al no haber defensa en esta fase, los tres enemigos llegan a la base y dejan la muestra con 20 de 50 HP. Esto es una comprobación del flujo, no una experiencia de juego balanceada.
- El `PathFollowerComponent` almacena waypoints, índice y progreso normalizado de tramo; mantiene la regla de que el mapa no se expande con enemigos vivos.
- Los stats completos (armor, regeneración, recompensas, tags/resistencias) y el pipeline central de daño siguen pendientes de M7/M9.

## Referencias

- `docs/fuente_de_verdad/02_IMPLEMENTATION_ROADMAP.md`, M5/M6/M7/M10, consultado el 2026-10-08.
- `docs/fuente_de_verdad/03_TECHNICAL_ARCHITECTURE.md`, escena principal y navegación lógica, consultado el 2026-10-08.
- `docs/fuente_de_verdad/04_DATA_MODELS.md`, modelos Enemy/Wave, consultado el 2026-10-08.
- `docs/fuente_de_verdad/05_HEX_GRID_AND_TERRAIN.md` y `06_COMBAT_SYSTEM.md`, objetivo y movimiento por `PathRoute`, consultados el 2026-10-08.
- `docs/decisiones/ADR-0007-grafo-logico-de-caminos.md`, consultado el 2026-10-08.
- `.agents/skills/godot-master/references/characterbody-2d-movement-recipes.md`, `composition.md`, `state-machine-advanced.md`, `signal-architecture.md` y `combat-system.md`, consultados el 2026-10-08. Para este movimiento sobre waypoints no se necesita cuerpo físico ni NavigationAgent; los hexes y `PathRoute` son la autoridad lógica.
