# ADR-0008: economía con oro y maná

- **Estado:** Confirmada
- **Fecha:** 2026-10-06
- **Sustituye:** ADR-0003 (economía de un recurso)

## Contexto

El proyecto decidió importar temporalmente el catálogo completo de *Rogue Tower*, incluidas torres y Support Buildings con consumo/producción de maná. Mantener un solo recurso habría requerido rediseñar partes de ese catálogo, pese a la prioridad explícita de conservar el gameplay de referencia salvo adaptaciones expresas.

## Decisión

La economía de una run tendrá dos recursos diferenciados, como en *Rogue Tower*:

- **Oro:** construcción y mejoras que tengan coste monetario.
- **Maná:** operación de torres/edificios que lo consumen y sistemas/mejoras que lo requieran.

Se conserva además **XP de metaprogresión** entre partidas para desbloqueos permanentes, de acuerdo con el baseline. XP no es un tercer recurso de gasto durante el combate.

Esta decisión reemplaza la elección anterior de un único recurso. Se mantiene el esquema de ingresos ya acordado: recompensa fija por oleada más bonus por bajas y regiones. Falta fijar cantidades y decidir si cada ingreso afecta al oro, al maná o a ambos. También quedan por balancear los costes de la run de 20 rondas, límites/regeneración de maná y economía de cartas. Las cifras publicadas por la wiki son referencia y no pasan automáticamente a ser valores finales de la campaña.

## Consecuencias

- Los datos importados de torres y Support Buildings pueden conservar sus costes y dependencias de maná como punto de partida.
- Recursos, recompensas y gastos deben mostrarse claramente durante la preparación; el estado de maná debe mantenerse legible en combate.
- Se conserva la estructura de recompensa fija por oleada más bonus por bajas/regiones; falta decidir a qué recurso(s) se aplica y fijar cantidades.
- Los upgrades que producen o aumentan maná (Sourcery, Mana Capacity, Mana Bank y cartas relacionadas) permanecen en el catálogo temporal.
- ADR-0003 se conserva solo como historial de la decisión sustituida.

## Fuentes y decisiones relacionadas

- [ADR-0003: economía inicial de un recurso, sustituida](ADR-0003-economia-de-un-recurso.md)
- [ADR-0006: Rogue Tower como baseline de gameplay](ADR-0006-rogue-tower-como-baseline-de-gameplay.md)
- [Rogue Tower Wiki: Gold](https://rogue-tower.fandom.com/wiki/Gold)
- [Rogue Tower Wiki: Mana](https://rogue-tower.fandom.com/wiki/Mana)
- [Rogue Tower Wiki: Upgrades](https://rogue-tower.fandom.com/wiki/Upgrades)
