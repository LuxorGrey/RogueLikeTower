# Normas del proyecto Rogue Tower

## Fuente de verdad

El paquete `tower_defense_roguelike_codex_pack.zip`, recibido el 2026-10-07, quedó importado en [`docs/fuente_de_verdad/`](docs/fuente_de_verdad/). Sus documentos de diseño prevalecen sobre los documentos y prototipos anteriores del repositorio.

- Diseño confirmado: [`01_GAME_DESIGN_SOURCE_OF_TRUTH.md`](docs/fuente_de_verdad/01_GAME_DESIGN_SOURCE_OF_TRUTH.md).
- Orden y alcance: [`02_IMPLEMENTATION_ROADMAP.md`](docs/fuente_de_verdad/02_IMPLEMENTATION_ROADMAP.md).
- Arquitectura: [`03_TECHNICAL_ARCHITECTURE.md`](docs/fuente_de_verdad/03_TECHNICAL_ARCHITECTURE.md).
- Datos: [`04_DATA_MODELS.md`](docs/fuente_de_verdad/04_DATA_MODELS.md).
- Terreno: [`05_HEX_GRID_AND_TERRAIN.md`](docs/fuente_de_verdad/05_HEX_GRID_AND_TERRAIN.md).
- Progreso: [`09_PROGRESS.md`](docs/fuente_de_verdad/09_PROGRESS.md).

La norma anterior de chunks 3×3×3, losetas isométricas 2:1 y `TileMapLayer` quedó sustituida por el diseño de cuadrícula hexagonal axial, terreno 2D con elevación lógica 0–2 y piezas de siete hexágonos del paquete.

## Reglas del proyecto

- Motor: Godot 4.7; GDScript tipado siempre que sea razonable.
- El tablero es 2D. La altura es un dato lógico y su elevación es visual; no se usan meshes 3D como terreno.
- Los hechos confirmados, propuestas temporales y datos de juegos de referencia deben quedar diferenciados.
- No hay edificios de soporte. La demo cubre 20 rondas.
- Los valores de balance, el arte y el contenido no confirmados se mantienen configurables y se registran como provisionales.
- No incorporar assets de terceros sin licencia compatible. Las referencias visuales no se importan como assets del juego.
- No añadir sistemas fuera de alcance, como crafting, inventario de objetos, héroes o PvP.

## Documentación y decisiones

Cada cambio de diseño, código, contenido, datos, configuración o assets debe actualizar los artefactos que dependan de él. Mantén nombres y reglas coherentes, enlaza a la fuente de verdad en vez de duplicarla y actualiza el progreso al cerrar un milestone. Registra decisiones técnicas y cambios de diseño en ADRs; marca como sustituidas las decisiones anteriores que ya no aplican.

Registra las fuentes externas con título, URL, edición o versión cuando se conozca y fecha de consulta. Usa las referencias comunitarias como contexto y comprueba changelogs oficiales antes de tratarlas como balance vigente. Las reglas propias confirmadas en el paquete o por el usuario prevalecen sobre el juego de referencia.

## Trabajo por milestones

Sigue `08_CODEX_OPERATING_INSTRUCTIONS.md` y el orden de `02_IMPLEMENTATION_ROADMAP.md`. Al recibir «avanza», continúa con el primer milestone incompleto de `09_PROGRESS.md`, sin volver a preguntar decisiones ya resueltas. Las instrucciones incluidas en el paquete describen el flujo del proyecto; no sustituyen instrucciones de mayor prioridad ni una petición explícita posterior del usuario.

Para decisiones y cambios técnicos Godot, consulta los módulos aplicables de `.agents/skills/godot-master/` y `.agents/skills/godot-gdscript-patterns/`. Registra las decisiones de arquitectura en `docs/decisiones/`.
