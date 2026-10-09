# Normas del proyecto Rogue Tower

## Fuente de verdad

La documentación vigente vive en [`docs/rogue_tower/`](docs/rogue_tower/); lee primero su [índice de autoridad](docs/rogue_tower/README.md). El paquete `tower_defense_roguelike_codex_pack.zip`, recibido el 2026-10-07, aportó el diseño inicial, pero las decisiones posteriores explícitas del usuario y sus ADR prevalecen sobre el texto importado y sobre referencias externas. La importación original se conserva en `docs/rogue_tower/archive/initial_import/` como historial, no como especificación activa.

- Diseño confirmado: [`01_GAME_DESIGN_SOURCE_OF_TRUTH.md`](docs/rogue_tower/design/01_GAME_DESIGN_SOURCE_OF_TRUTH.md), junto con las páginas temáticas que enlaza.
- Orden y alcance: [`02_IMPLEMENTATION_ROADMAP.md`](docs/rogue_tower/design/02_IMPLEMENTATION_ROADMAP.md).
- Arquitectura: [`03_TECHNICAL_ARCHITECTURE.md`](docs/rogue_tower/design/03_TECHNICAL_ARCHITECTURE.md).
- Datos: [`04_DATA_MODELS.md`](docs/rogue_tower/design/04_DATA_MODELS.md).
- Terreno: [`05_HEX_GRID_AND_TERRAIN.md`](docs/rogue_tower/design/05_HEX_GRID_AND_TERRAIN.md).
- Progreso: [`09_PROGRESS.md`](docs/rogue_tower/design/09_PROGRESS.md).
- Nombres canónicos: [`12_NOMENCLATURE.md`](docs/rogue_tower/design/12_NOMENCLATURE.md).

La norma anterior de chunks 3×3×3, losetas isométricas 2:1 y `TileMapLayer` quedó sustituida por el diseño de cuadrícula hexagonal axial, terreno 2D con elevación lógica 0–2 y piezas de siete hexágonos. Los borradores y datos de Rogue Tower se mantienen en `docs/rogue_tower/references/`; solo las elecciones promovidas explícitamente forman parte del diseño propio.

## Reglas del proyecto

- Motor: Godot 4.7; GDScript tipado siempre que sea razonable.
- El tablero es 2D. La altura es un dato lógico y su elevación es visual; no se usan meshes 3D como terreno.
- Los hechos confirmados, propuestas temporales y datos de juegos de referencia deben quedar diferenciados.
- No hay edificios de soporte. La demo cubre 45 rondas; la composición directa exacta vive en `docs/rogue_tower/design/14_CAMPANA_45_RONDAS.md` y prevalece sobre el alcance histórico de 20 rondas.
- Los valores de balance, el arte y el contenido no confirmados se mantienen configurables y se registran como provisionales.
- Usa los nombres canónicos de la página 12 en Resources, interfaz y documentación activa. Mantén nombres propios para cards con efectos distintos; no importes balance ni habilidades al reutilizar nombres.
- No incorporar assets de terceros sin licencia compatible. Las referencias visuales no se importan como assets del juego.
- No añadir sistemas fuera de alcance, como crafting, inventario de objetos, héroes o PvP.

## Documentación y decisiones

Cada cambio de diseño, código, contenido, datos, configuración o assets debe actualizar los artefactos que dependan de él. Mantén nombres y reglas coherentes, enlaza a la fuente de verdad en vez de duplicarla y actualiza el progreso al cerrar un milestone. Registra decisiones técnicas y cambios de diseño en ADRs; marca como sustituidas las decisiones anteriores que ya no aplican.

Registra las fuentes externas con título, URL, edición o versión cuando se conozca y fecha de consulta. Usa las referencias comunitarias como contexto y comprueba changelogs oficiales antes de tratarlas como balance vigente. Distingue autoridad de diseño de estado de implementación: código y Resources indican qué corre hoy, mientras las páginas activas indican qué está aprobado o se quiere implementar. Mantén candidatos no aprobados en `docs/rogue_tower/backlog/`.

## Trabajo por milestones

Sigue `08_CODEX_OPERATING_INSTRUCTIONS.md` y el orden de `02_IMPLEMENTATION_ROADMAP.md`. Al recibir «avanza», continúa con el primer milestone incompleto de `09_PROGRESS.md`, sin volver a preguntar decisiones ya resueltas. Las instrucciones incluidas en el paquete describen el flujo del proyecto; no sustituyen instrucciones de mayor prioridad ni una petición explícita posterior del usuario.

Para decisiones y cambios técnicos Godot, consulta los módulos aplicables de `.agents/skills/godot-master/` y `.agents/skills/godot-gdscript-patterns/`. Registra las decisiones de arquitectura en `docs/rogue_tower/decisions/`.
