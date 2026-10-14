# ADR-0074: Vida inicial de base y derrota por llegada de boss

- Fecha: 2026-10-14
- Estado: Aceptado por petición explícita; datos y código integrados, aceptación manual pendiente.
- Actualiza la vida de `Main Tower` y la condición de derrota descritas en [ADR-0008](ADR-0008-base-y-enemigo.md) y [ADR-0022](ADR-0022-meta-progression-y-guardado.md).

## Contexto

La base configurada tenía 50 HP. El usuario fijó 10 HP base, diez niveles permanentes de Fortification y tres cards de Fortification por run; también pidió que tocar la base con un boss acabe la partida inmediatamente.

## Decisiones

1. `BaseData` inicia con 10/10 HP. Fortification permanente añade +1 al máximo por nivel, hasta +10 HP y 20/20 al nivel X. Los costes secuenciales I–X son 20, 40, 60, 80, 100, 120, 140, 160, 180 y 200 XP; el total es 1.100 XP.
2. Cada nivel superior de Fortification exige haber comprado el nivel anterior, como permite el catálogo por niveles. No se añaden gates de cantidad de cartas desbloqueadas.
3. Fortification I, II y III de run son independientes de la mejora permanente; cada una añade +3 HP máximos y se acumulan hasta +9 HP en esa run.
4. Si un enemigo con `boss_tier > 0` alcanza la base, `WaveDirector` termina la run en ese contacto incluso si queda Health. La llegada sigue aplicando el daño normal configurado antes de emitir la derrota. La regla solo se suprime para fixtures de diagnóstico.

## Consecuencias

- El máximo de base de una run normal es 10–20 HP según el nivel permanente. Las cards pueden aumentarlo en otros 3, 6 o 9 HP durante esa run.
- La derrota por llegada de boss se distingue de la destrucción por daño de enemigos normales.
- La inspección de los costes, HP, independencia de cards y llegada de jefe queda pendiente en M34 de `10_ACCEPTANCE_TESTS.md`.

## Referencias

- Petición explícita del usuario, 2026-10-14; valores de HP, beneficios y costes prevalecen sobre la wiki.
- [Fortification I–X — Permanent Upgrades, Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Permanent_Upgrades), wiki comunitaria consultada el 2026-10-14. Se registra solo como contexto de requisitos de niveles; el usuario indicó que en este proyecto basta exigir el nivel anterior.
- [Upgrade Cards — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Upgrade_Cards), wiki comunitaria consultada el 2026-10-14; referencia contextual para las cards separadas de la progresión permanente.
