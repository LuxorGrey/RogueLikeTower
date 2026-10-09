# ADR-0036: Parámetros de torres según changelog oficial

- **Fecha:** 2026-10-09
- **Estado:** Implementado históricamente; los valores de Frost Keep y Tesla Coil fueron sustituidos por el balance propio provisional ADR-0037.
- **Alcance:** stats base de las torres de la demo donde la wiki comunitaria contradice las notas oficiales.
- **Fuentes:** [anuncios y changelogs oficiales de Rogue Tower en Steam](https://steamcommunity.com/app/1843760/announcements/) y fichas de [Tesla Coil](https://rogue-tower.fandom.com/wiki/Tesla_Coil), [Flame Thrower](https://rogue-tower.fandom.com/wiki/Flame_Thrower) y [Frost Keep](https://rogue-tower.fandom.com/wiki/Frost_Keep), consultados el 2026-10-09.

## Contexto

El usuario pidió respetar los parámetros de Rogue Tower. La ficha comunitaria actual de Flame Thrower conserva daño base 5, pero el parche oficial 1.1.2.0 aumentó ese daño a 6. Las notas oficiales también subieron el alcance de Tesla Coil de 1,5 a 2 y su multiplicador Shield de 9 a 10. La ficha comunitaria de Tesla ya refleja los últimos valores; la tabla general de Towers puede conservar datos antiguos.

## Decisiones

1. Ante una cifra contradictoria, la nota oficial de balance prevalece sobre la wiki comunitaria.
2. `Tesla Coil` usa `range_hexes = 2.0`. Su daño base 10, multiplicadores 6/3/10 y 30 RPM ya estaban correctos.
3. `Flame Thrower` usa daño base 6. Sus multiplicadores 6/9/3, alcance 4 y 60 RPM ya estaban correctos.
4. `Frost Keep` conserva daño base 6: el mismo parche oficial lo había subido de 5 a 6 y el perfil ya estaba actualizado.
5. Las demás cifras de torre no cambian por esta decisión.

## Consecuencias

- `data/towers/tesla_coil.tres` y `data/towers/flame_thrower.tres` reflejan las notas oficiales.
- El roster legible y los placeholders de contenido muestran los mismos valores que los Resources.
- El resto de la información comunitaria sigue identificada como referencia; las cifras sin changelog encontrado no se califican como verificadas oficialmente.

## Fuentes

- Steam, [Rogue Tower — announcements](https://steamcommunity.com/app/1843760/announcements/), parche 1.1.2.0 (2022-09-08): Tesla Coil alcance 1,5→2 y Shield 9→10; Flame Thrower daño 5→6; Frost Tower daño 5→6.
- Rogue Tower Wiki, fichas individuales enlazadas arriba; edición comunitaria consultada el 2026-10-09.
- [Catálogo activo](../design/13_CONTENT_ROSTER.md) y [resources de torres](../../../data/towers/).
