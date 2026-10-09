# ADR-0035: Parámetros del roster de Rogue Tower

- Fecha: 2026-10-09.
- Estado: ampliado y parcialmente sustituido por ADR-0037, que fija la campaña de 45 rondas, las habilidades y la selección de fichas individuales.
- Alcance histórico: primera promoción de perfiles normales hasta ronda 20.
- Fuentes base: [Monsters — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Monsters), tabla general e individual; Fandom comunitario consultado el 2026-10-09, edición/changelog no indicado.

## Contexto

El usuario pidió adoptar parámetros de referencia para los enemigos y la velocidad requería conversión al movimiento propio. La decisión inicial se limitó a los perfiles que aparecían antes de ronda 20; después, el prompt de 45 rondas seleccionó 26 perfiles y algunas páginas individuales.

## Decisiones vigentes que conserva esta ADR

1. La velocidad RT se convierte con velocidad RT × 45 = px/s, factor que conserva Goblin en 90 px/s.
2. Las tasas globales health_growth_per_round, base_damage_growth_per_round y reward_growth_per_round son cero. No se añade escalado por ronda a los perfiles adoptados.
3. Ooogie clásico usa 100.000 de daño a base como representación técnica de “mata la base de un golpe”; ese valor no es una cifra publicada.
4. Vampire adopta la ficha individual seleccionada en el prompt: 5.000 Health, sin Armor/Shield, +100 Health/s, velocidad 1,75 RT y 23 Gold. La tabla general Monsters difiere.
5. Los perfiles y habilidades actualmente promovidos se leen en 13_CONTENT_ROSTER.md. La tabla de composición/orden/cantidad es 14_CAMPANA_45_RONDAS.md, no la wiki ni este ADR.

## Decisiones sustituidas

- El roster de enemigos se amplía a 26 tipos y 45 rondas según ADR-0037.
- Cyclops y Werewolf no tienen asignaciones especiales de Miniboss en 17/19.
- Ooogie von Ooogovich conserva la identidad y el kit propio aprobados en ADR-0032; la tabla decide sus rondas.
- Las cantidades/grupos que antes estaban pendientes se copian de la tabla seleccionada por el usuario. No se atribuyen como conteos de la página general Monsters.
- La wiki aporta parámetros individuales seleccionados; cuando las fichas difieren, prevalece la elección registrada en el catálogo/ADR-0037.

## Consecuencias

Los perfiles ejecutables están en data/enemies/. Los cambios de velocidad, estadísticas elegidas, habilidades, overrides, sprites y discrepancias entre fichas quedan descritos por perfil en [13 — Catálogo y escalado](../design/13_CONTENT_ROSTER.md). La nomenclatura canónica está en [12_NOMENCLATURE.md](../design/12_NOMENCLATURE.md).

## Fuentes

- [Monsters — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Monsters), Fandom comunitario, consultada el 2026-10-09; edición/changelog no indicado.
- Solicitud y prompt de 45 rondas proporcionados por el usuario, consultados el 2026-10-09.
- [Parámetros activos del roster](../design/13_CONTENT_ROSTER.md) y [composición exacta](../design/14_CAMPANA_45_RONDAS.md).