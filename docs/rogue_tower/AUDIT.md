# Auditoría comparativa de documentación

- Fecha: 2026-10-09.
- Alcance: cuatro borradores personales, paquete de diseño importado, ADR existentes y comprobaciones dirigidas a los datos actuales de campaña, roster y desbloqueos.
- Resultado: los materiales quedaron bajo `docs/rogue_tower/`. El índice [README](README.md) fija cómo resolver discrepancias y qué autoridad tienen sus subcarpetas.

> **Auditoría histórica:** este informe describe el estado documental previo a la campaña de 45 rondas y queda sustituido en reglas activas por ADR-0037. Para los criterios vigentes, sigue design/README.md y los documentos enlazados allí.
## Comparación por fuente

| Fuente anterior | Qué aporta | Resultado de la comparación |
|---|---|---|
| `borradores_personales/01_torres.md` | Arquetipos, sinergias, multiplicadores y progreso de torres de Rogue Tower. | Conservado como [referencia](references/01_torres.md). Los siete perfiles usan nombres canónicos y adoptan los parámetros base de la referencia, con cambios oficiales en ADR-0036. Los árboles completos y reglas de progreso propias no se importan. |
| `borradores_personales/02_monstruos.md` | Tablas de aparición, atributos y poderes, incluidos tres jefes Tier 2. | Conservado como [referencia](references/02_monstruos.md). La campaña prepara el roster normal publicado hasta ronda 20, incluyendo Vampire desde la 20. Cyclops 17, Werewolf 19 y Ooogie von Ooogovich 20 conservan encuentros propios. Los conteos/grupos de cada oleada no aparecen en la fuente consultada; quedan pendientes, no inventados. |
| `borradores_personales/03_upgrades.md` | XP, mejoras permanentes y árboles de cartas del juego de referencia. | Conservado como [referencia](references/03_upgrades.md). La meta-progresión propia usa moneda persistente, tienda y cinco upgrades actuales; las cartas de run tienen pool propio de 18 Resources. Los árboles, XP, costes y cifras externos no se han promovido. |
| `borradores_personales/04_status_effects.md` | Bleed, Burn, Poison, Slow, Freeze, Haste, Fortification y sinergias. | Conservado como [referencia](references/04_status_effects.md). El juego propio maneja Slow, Burn, Bleed y Poison. Freeze, Haste y Fortification siguen como candidatos, no parte del catálogo aprobado. Las reglas propias de capa y bonus están en ADR-0023. |
| `fuente_de_verdad/` | Diseño inicial, contratos técnicos, roadmap, progreso, aceptación y un JSON duplicado. | Sus documentos activos pasaron a [design](design/README.md), con actualizaciones para incorporar decisiones posteriores. `project_spec.json` y los auxiliares importados están en `archive/initial_import/`; el JSON no es una especificación activa ni una fuente runtime. |
| `decisiones/` | Historial técnico y de diseño desde ADR-0001. | ADR-0001 a ADR-0031 se conservaron en [decisions](decisions/README.md); ADR-0032 incorpora la identidad y fase del jefe y ADR-0033 la nomenclatura canónica. Los ADR históricos siguen explicando su contexto, y los reemplazos parciales quedan enlazados. |

## Discrepancias encontradas y tratamiento

1. **Identidad y ciclo del jefe final:** diseño inicial y ADR-0016 mantenían abierta la variante, mientras el perfil activo conserva estadísticas genéricas provisionales. La elección del usuario resuelve la identidad y las mecánicas adaptadas: Ooogie invoca Bats y, al perder su forma inicial, pasa a Bat como fase dos. No se copia la frecuencia/cantidad de invocación ni los 10 000 Health de la referencia. La recompensa espera la derrota final. Diseño aprobado; balance propio, Resource de dos fases e implementación siguen pendientes.
2. **Torres desbloqueadas:** el cierre de `11_INITIAL_CONTENT_PLACEHOLDERS.md` afirmaba que los siete perfiles ya estaban desbloqueados. `data/meta/demo_meta_progression.tres`, los Resources de torre y el contrato de tienda indican que Ballista comienza desbloqueada y las otras seis se compran. Se corrigió el documento para distinguir “siete perfiles en el roster” de “siete disponibles al empezar”.
3. **Jefe aprobado frente a perfil ejecutable:** `data/enemies/campaign_tier2_boss.tres` aún contiene estadísticas provisionales de M10 y no demuestra invocación ni fase Bat. El nombre visible ya es Ooogie von Ooogovich; su Resource de dos fases y balance propios siguen siendo bloqueadores de M10.
4. **Progreso frente a alcance de diseño:** varias páginas describían como pendiente la identidad de variante aunque M10 ya estaba implementado con un placeholder. Se actualizó la distinción: identidad y patrón del jefe aprobados; balance e integración pendientes. El estado “implementado” no implica aceptación visual ni balance final.
5. **Borradores frente a fuentes aprobadas:** los cuatro textos personales contenían reglas confirmadas propias mezcladas con tablas comunitarias. Permanecen disponibles con atribución bajo `references`; las elecciones explícitas (incluidos los parámetros base de torres y enemigos hasta la ronda 20) enlazan al diseño activo. Árboles completos, poderes no elegidos y contenido fuera del alcance están en el [backlog](backlog/CONTENT_CANDIDATES.md).
6. **Jerarquía antigua:** `AGENTS.md` daba precedencia general al paquete importado. Se actualizó para que decidan las elecciones posteriores del usuario, que el paquete sea el punto de partida y que el código/Resources indiquen implementación, no autoridad de diseño.

## Pendientes que siguen siendo decisiones reales

- Habilidades detalladas e implementación de Cyclops y Werewolf como Minibosses; la selección de sus nombres por rol está resuelta por ADR-0033.
- Atributos y balance propio de Ooogie y sus Bats, incluido número/frecuencia de invocación, estadísticas por fase, recompensa y reglas de spawn/muerte.
- Roster de enemigos y sistemas de progresión posteriores a la demo.
- Composición y totales exactos de cada oleada; la página Monsters consultada publica cuándo empiezan a aparecer los tipos, pero no enumera cantidades por oleada. Hace falta otra fuente verificable o aprobar una curva propia.
- Si el juego propio incorporará Freeze, Haste o Fortification y qué contrato tendrían.
- Aceptación manual de los milestones que `09_PROGRESS.md` marca pendientes.

El material de referencia que podría informar estas elecciones, con sus preguntas pendientes, se concentra en [Content Candidates](backlog/CONTENT_CANDIDATES.md); no se presupone que haya que adoptarlo.
