# ADR-0032: Ooogie von Ooogovich — identidad y fase adaptada

- Fecha: 2026-10-09.
- Estado: identidad, habilidades adaptadas y ciclo de transformación aceptados; colocación fija en ronda 20 sustituida por ADR-0037; balance propio provisional implementado.
- Sustituye parcialmente: la identidad antes abierta en ADR-0016.
- Autoridad activa: la tabla de [campaña de 45 rondas](../design/14_CAMPANA_45_RONDAS.md) decide en qué oleadas aparece.

## Contexto

El diseño anterior reservaba un Tier 2 Boss para la ronda 20. El usuario eligió Ooogie von Ooogovich (Haunted) y aprobó adaptar sus mecánicas de invocación y transformación con balance propio. Después, la tabla exacta del prompt extendió la demo a 45 rondas y ubicó el jefe en las rondas que esa tabla indica.

## Decisiones

1. El nombre canónico del perfil es **Ooogie von Ooogovich**; pertenece al roster Haunted.
2. Mientras su forma inicial está viva, invoca dos Bats cada 2 segundos.
3. Al morir la forma inicial, la misma instancia se transforma en Bat con 2.500 Health.
4. La transformación no termina la ronda ni concede la recompensa de baja. La ronda espera a que muera la forma Bat; entonces la instancia paga una vez con la recompensa del jefe original.
5. Health 8.000, Armor 1.500, Shield 2.000, regeneración de Health 25/s y Shield 10/s, velocidad 26 px/s, daño a base 50 y 200 Gold son parámetros propios provisionales. No se copian los valores de la wiki.
6. La campaña incluye el perfil donde aparezca en la tabla; ya no tiene una asignación obligatoria a ronda 20.

## Consecuencias

- El Resource activo es data/enemies/campaign_tier2_boss.tres y la tabla exacta vive únicamente en 14_CAMPANA_45_RONDAS.md.
- WaveDirector conserva el mismo enemigo activo durante la segunda fase; las invocaciones sí son enemigos adicionales.
- Los valores de balance pueden ajustarse sin cambiar el patrón aprobado.
- ADR-0037 registra la prioridad de la tabla y la implementación de habilidades.

## Referencia

[Ooogie von Ooogovich — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Ooogie_von_Oogovich), Fandom comunitario, consultada el 2026-10-09; edición/changelog no indicado. Se usan ideas de comportamiento, no su balance publicado.