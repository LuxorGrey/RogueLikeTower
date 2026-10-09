# ADR-0013: Economía de run y maná M9

- Estado: aceptado para implementación; balance provisional. El valor inicial y la presentación de regeneración se actualizan parcialmente en ADR-0030.
- Fecha: 2026-10-08.
- Milestone: M9.

## Contexto

M9 necesita financiar construcción/mejoras, pagar bajas y oleadas, y habilitar ataques que consumen maná. La moneda meta y el guardado permanente pertenecen a M12. No hay edificios de soporte en el alcance. M6 dejó construcción/mejoras sin coste y M7/M8 usan perfiles de diagnóstico.

## Decisiones

1. `RunEconomyService` es hijo de `Main`, no Autoload. Su saldo runtime vive durante la escena/run actual; `RunEconomyData` configura el estado inicial y la regen.
2. Oro de construcción y maná son recursos runtime independientes de `MetaProgression.meta_currency`. M9 no los persiste ni los convierte.
3. `TowerData` posee `build_cost`, `upgrade_costs` por siguiente nivel y `mana_cost_per_attack`. La compra valida y cobra antes de ocupar el hex; la mejora cobra antes de cambiar nivel y devuelve el gasto si la mutación no pudiera completarse.
4. `EnemyData.kill_reward` se paga una vez al recibir muerte, incluida muerte por DoT. Llegar a base no paga recompensa. El pago de una baja resuelta se conserva si después se pierde la misma oleada.
5. `WaveData.round_reward` se paga una sola vez cuando acabaron los spawns y no queda enemigo activo. Una oleada fallida no paga el bonus de limpieza.
6. La torre consume maná antes de crear/aplicar el daño del ataque. Si el saldo no alcanza, el ataque y sus payloads de estado no se ejecutan; la torre vuelve a intentarlo tras una espera breve. El saldo no puede ser negativo.
7. La regen ocurre durante preparación, combate, recompensa y expansión; se limita a `maximum_mana` y no progresa en setup, derrota ni victoria.
8. Las pruebas de oleada M7/M8 pueden repetirse tras un intermedio `ROUND_REWARD` de 0.8 segundos. Este selector temporal no sustituye el loop secuencial de M10.

## Valores provisionales de los fixtures M9

| Dato | Valor de prueba |
|---|---:|
| Oro inicial | 150 |
| Maná inicial / máximo (valor original, sustituido por ADR-0030) | 30 / 100 |
| Regeneración | 1.5 maná/s |
| Basic Bolt / perfiles de diagnóstico | 30 / 40 oro |
| Mejoras (nivel 1→2 / 2→3) | 20 / 35 oro |
| Drenadora M7 | 4 maná por ataque |
| Kill básico / blindado / dummy M8 | 5 / 10 / 5 oro |
| Limpieza oleada básica / M7 / M8 | 20 / 10 / 10 oro |

Son números para verificar operaciones y no balance de la demo.

## Consecuencias

- La UI presenta saldos, regen, costes en atajos y coste de la siguiente mejora; el botón de compra/mejora refleja fondos insuficientes.
- `BuildController` y `Tower` aceptan un servicio opcional para mantener compatibilidad con callers/smokes de hitos anteriores; `Main` siempre inyecta el servicio configurado.
- La prueba manual de `10_ACCEPTANCE_TESTS.md` es el criterio de aceptación interactiva. Esta revisión deja dicha aceptación pendiente, no certifica arranque ni gameplay en Godot.
- M9 no añade Support Buildings ni desarrolla el roster de torres M14.

## Roster de demo — paralelo de roles, no de balance

Propuesta de seis perfiles para M14: Ballesta (Ballista), Mortero (Mortar), Bobina Tesla (Tesla Coil), Guardafría (Frost Keep), Lanzallamas (Flame Thrower) y Pulverizador venenoso (Poison Sprayer). Los nombres/roles son provisionales; ver [11_INITIAL_CONTENT_PLACEHOLDERS.md](../design/11_INITIAL_CONTENT_PLACEHOLDERS.md). Poison requerirá contenido/status posterior, porque el proyecto solo tiene Slow/Burn/Bleed en M8.

## Referencias externas consultadas el 2026-10-08

Wiki comunitaria; se usaron solamente para mapear arquetipos. No se importaron sus stats ni costes.

- [Towers — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Towers)
- [Ballista — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Ballista)
- [Mortar — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Mortar)
- [Tesla Coil — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Tesla_Coil)
- [Frost Keep — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Frost_Keep)
- [Flame Thrower — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Flame_Thrower)
- [Poison Sprayer — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Poison_Sprayer)

La edición de la wiki no está indicada en las páginas. Se consultaron resúmenes indexados porque el acceso directo respondió con bloqueo de robots.
