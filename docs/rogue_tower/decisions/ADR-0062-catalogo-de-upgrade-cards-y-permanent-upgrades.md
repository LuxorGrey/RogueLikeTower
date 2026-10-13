# ADR-0062 — Catálogo de Upgrade Cards y Permanent Upgrades

- Estado: decisión aprobada por petición del usuario; datos y efectos integrados; aceptación manual pendiente.
- Fecha: 2026-10-13.
- Contexto: el pool M11 tenía 18 cards propias y una frecuencia de oferta provisional hasta la ronda 18. La tienda M12 permitía comprar mejoras permanentes propias, pero no contenía la mayoría de las ramas de Upgrade Cards y Permanent Upgrades de Rogue Tower.

## Decisiones

1. Se representan las 173 Upgrade Cards compatibles con el roster actual de siete torres: Ballista (24), Mortar (25), Tesla Coil (16), Frost Keep (19), Flame Thrower (14), Poison Sprayer (14), Shredder (15) y efectos generales/de estado (46). Se añaden 172 Resources; Advanced Circuits ya existe con la misma operación en `tesla_overcharge.tres`, así que se conserva esa card y se le aplica la rama de prerequisitos de referencia en vez de ofrecer un duplicado. Esa equivalencia ya forma parte de las 18 cards propias previas: 18 + 172 = 190 IDs únicos, que representan las 173 entradas compatibles de referencia más 17 cards propias sin equivalente. Las cartas específicas requieren que la torre esté desbloqueada; las cadenas y alternativas se filtran por las cards seleccionadas. Cada carta tiene máximo una copia por run.
2. Las mejoras temporales aparecen después de colocar la expansión al cerrar las rondas 3, 6, 9, …, 42, antes de la ronda siguiente. La cadencia cada tres rondas queda confirmada. La oferta base tiene tres opciones y Card Draw I–III, comprable en la tienda meta, la amplía a cuatro, cinco y seis. La victoria en 45/45 finaliza la run y abre la tienda sin una oferta temporal adicional.
3. La tienda que aparece tras victoria o derrota incluye 25 mejoras permanentes adicionales; junto con las seis propias, el catálogo contiene 31. Se incorporan Card Draw, Gold Drop, Repair, Fortification de base y las ramas Better para Health/Armor/Shield de cada una de las siete torres. Cada rama de torre requiere el unlock persistente de esa torre. Las compras se persisten y se aplican desde la siguiente run.
4. No se copian las condiciones de XP ni el árbol de desbloqueo de cartas del juego de referencia: el proyecto usa Meta Currency, unlocks persistentes y prerequisitos por carta durante la run. Nombres y efectos de referencia se conservan donde encajan, pero las cantidades, rarezas y costes del proyecto quedan configurables/provisionales.
5. Se excluyen mejoras que requieren torres o sistemas ausentes (Cannon, Encampment, Lookout, Radar, Obelisk, Particle Cannon, Monument, University, Mine, Mana Siphon/Bank y otros edificios), Freeze, Gold Rush que exige Mine, Treasure! que concede draws desde cofres de cartas y Draw Frequency I–II, que alteraría la cadencia confirmada. Las cartas de cofres de jefe tampoco se incorporan: los cofres actuales son de terreno y solo conceden Gold. No se añaden assets de terceros.
6. Se mantienen sin cambios las decisiones propias de tablero, combate, torres y campaña que no forman parte de estas mejoras. Los efectos sin equivalencia directa se resuelven mediante operaciones de datos runtime y no mutan Resources compartidos.

## Consecuencias y aceptación

- `CardPoolData` combina el pool propio y `CardCatalogData`; `RunCardService` valida IDs/prerrequisitos, filtra por unlock, copia y requisitos seleccionados, y aplica efectos temporales.
- `MetaProgressionData` combina catálogos `PermanentUpgradeCatalogData`; la tienda presenta y persiste los 31 upgrades. Las mejoras de torre permanecen bloqueadas hasta desbloquear su torre.
- Aceptación manual pendiente en M11/M12 de `10_ACCEPTANCE_TESTS.md`: revisar oferta en rondas 3, 6, 9 y 42; estados/caps/daño condicionado y efectos generales; Card Draw; compra y persistencia post-run; ramas por torre; exclusión de una oferta al concluir la 45.
- Los valores comunitarios se tratan como punto de partida, no como balance final aprobado.

## Fuentes y ADR relacionados

- Petición del usuario de 2026-10-13: usar las Upgrade Cards compatibles y las mejoras permanentes, con oferta temporal cada tres waves y compras generales al acabar la run.
- [Upgrade Cards — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Upgrade_Cards), consulta 2026-10-13.
- [Permanent Upgrades — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Permanent_Upgrades), consulta 2026-10-13.
- Fandom bloqueó la consulta web directa durante esta revisión; se cotejaron los extractos indexados. Las fuentes y limitaciones están anotadas en [Origen y referencias](../references/ORIGEN.md).
- Continúa [ADR-0021](ADR-0021-cartas-de-mejora-de-run.md) y [ADR-0022](ADR-0022-meta-progression-y-guardado.md) en el nuevo alcance de contenido; no altera sus reglas de aislamiento temporal ni guardado.
