# ADR-0024 — Ballista elimina al enemigo básico

- Estado: aplicado en datos; aceptación en gameplay pendiente.
- Fecha: 2026-10-08.
- Contexto: el usuario indica que la Ballista debe eliminar de un disparo al enemigo básico, como en Rogue Tower, sin reducir artificialmente el daño de las torres ni ignorar Health/Armor/Shield de los enemigos.

## Decisiones

1. El Asaltante básico de la primera ronda usa 100 Health, 0 Armor y 0 Shield. Estos son los valores del Goblin básico de la referencia que el usuario incluyó en `docs/rogue_tower/references/02_monstruos.md`; se conservan el nombre y los demás parámetros propios del proyecto.
2. La Ballista conserva sus datos ya aprobados: daño base 10 y multiplicadores H/A/S 10/5/5. Por tanto, contra el enemigo básico sin capas defensivas, su daño es 10 × 10 = 100 y un impacto lo derrota.
3. La cadencia de Ballista queda en 20 RPM (un disparo cada 3 s); `rounds_per_minute` es el dato runtime canónico y `attack_rate` conserva el equivalente de 1/3 disparos por segundo como fallback de compatibilidad.
4. `DamageService` sigue resolviendo únicamente la capa activa en orden Shield → Armor → Health, usando el multiplicador correspondiente a torre y capa. No se reduce la salud de enemigos acorazados ni se modifica el daño base para simular el resultado.
5. Los otros perfiles de enemigos y su escalado por ronda quedan configurables. Este ajuste puntual no convierte todas las cifras comunitarias en balance confirmado.

## Referencias y verificación

- [Goblin — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Goblin), consultada el 2026-10-08. La entrada indica 100 Health y que una Ballista lo derrota de un impacto.
- [Towers — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Towers), consultada el 2026-10-08. La tabla usada por el usuario fija Ballista en 10 de daño y multiplicador Health 10.
- [Hit Points — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Hit_Points), consultada el 2026-10-08. El daño a cada capa es daño base × multiplicador de esa capa; solo se puede dañar Health tras agotar Armor y Shield.
- [Ballista — Rogue Tower Wiki](https://rogue-tower.fandom.com/wiki/Ballista), consultada el 2026-10-08. La ficha indica 20 disparos por minuto y describe un disparo cada 3 segundos; el cooldown del proyecto se calcula como `60 / 20 = 3` segundos.
- Añadir/ejecutar la comprobación de la ronda 1 descrita en [10_ACCEPTANCE_TESTS.md](../design/10_ACCEPTANCE_TESTS.md#prueba-manual-m12a-en-el-juego): una Ballista sin mejoras elimina un enemigo de 100 Health de un impacto, y las capas defensivas siguen recibiendo su daño de capa.
