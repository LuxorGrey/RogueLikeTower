# Diseño activo

Este directorio define el diseño propio vigente de Rogue Tower. El índice de autoridad común está en [la raíz de la documentación](../README.md).

| Documento | Propósito |
|---|---|
| [01 — Diseño del juego](01_GAME_DESIGN_SOURCE_OF_TRUTH.md) | Reglas propias aprobadas, alcance de la demo y decisiones de diseño abiertas. |
| [02 — Roadmap](02_IMPLEMENTATION_ROADMAP.md) | Hitos y alcance de implementación; el orden no cambia las reglas de diseño. |
| [03 — Arquitectura técnica](03_TECHNICAL_ARCHITECTURE.md) | Organización técnica y responsabilidades de sistemas. |
| [04 — Modelos de datos](04_DATA_MODELS.md) | Contratos de Resources y datos runtime. |
| [05 — Terreno hexagonal](05_HEX_GRID_AND_TERRAIN.md) | Tablero, topología y piezas de siete hexágonos. |
| [06 — Combate](06_COMBAT_SYSTEM.md) | Daño, torres, enemigos, oleadas y estados. |
| [07 — Progresión](07_ROGUELIKE_PROGRESSION.md) | Economía, cartas, campaña y meta-progresión. |
| [08 — Instrucciones operativas](08_CODEX_OPERATING_INSTRUCTIONS.md) | Convenciones del flujo de trabajo del paquete, subordinadas a instrucciones actuales. |
| [09 — Progreso](09_PROGRESS.md) | Estado de implementación y verificaciones pendientes. |
| [10 — Aceptación](10_ACCEPTANCE_TESTS.md) | Criterios de aceptación manual/técnica por hito. |
| [11 — Contenido inicial](11_INITIAL_CONTENT_PLACEHOLDERS.md) | Perfil actual de contenido provisional y su configuración. |
| [12 — Nomenclatura](12_NOMENCLATURE.md) | Nombres canónicos y límites de las equivalencias con Rogue Tower. |
| [13 — Catálogo y escalado](13_CONTENT_ROSTER.md) | Lista legible de torres, cards, mejoras permanentes, enemigos, estados y fórmulas de escalado actuales. |
| [14 — Campaña de 45 rondas](14_CAMPANA_45_RONDAS.md) | Tabla única de cantidades directas, orden, ritmo y clasificación de las rondas. |

## Interpretación

- `01` manda sobre el diseño aprobado. Las páginas 03–07 y 11 explican dominios concretos y deben enlazar a `01` cuando una regla cambie.
- `02`, `09` y `10` describen ejecución, implementación y comprobación; no convierten los placeholders en balance final.
- `12` es el glosario vigente de nombres visibles y términos; las páginas temáticas deben seguirlo.
- `13` es el índice legible de los Resources activos; los valores numéricos ejecutables siguen viviendo en esos Resources. Sus valores base de torres y enemigos normales promovidos por el usuario se consideran parámetros adoptados; los valores propios aún no aprobados se etiquetan **provisionales**.
- `14` es la autoridad única para composición directa de oleadas. Las habilidades pueden añadir invocaciones y fases por encima del conteo de la tabla.
- La autoridad de nombres, parámetros promovidos, excepciones propias y backlog de candidatos se resume en la raíz de documentación. La referencia Rogue Tower no autoriza por sí sola mecánicas, árboles de cartas ni conteos de oleadas que no hayan sido seleccionados.
- Ooogie von Ooogovich (Haunted) mantiene su identidad y habilidades adaptadas aprobadas en ADR-0032, con balance propio provisional. La tabla exacta de 45 rondas, incluida la ausencia de Minibosses propios en 17/19, prevalece según [ADR-0037](../decisions/ADR-0037-campana-de-45-rondas-y-habilidades.md).
