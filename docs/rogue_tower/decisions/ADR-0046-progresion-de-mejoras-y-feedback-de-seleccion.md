# ADR-0046: Progresión independiente de mejoras y feedback de selección

- **Fecha:** 2026-10-09
- **Estado:** código y documentación integrados; aceptación visual/manual pendiente
- **Decide:** petición explícita del usuario
- **Sustituye parcialmente:** el máximo de mejoras compartido y la presentación anterior de ADR-0023/0039/0045; la caja de obstáculos de ADR-0044 pasa de 104×104 a 86×86 px

## Contexto

La torre mantenía un único nivel compartido para Health, Armor y Shield y la interfaz daba a entender que subir una estadística elevaba las otras. Además, la colocación podía quedar detrás del terreno, el feedback de ubicación inválida usaba verde y las prioridades estaban agrupadas en un único control. La base también tenía elevaciones junto a su huella, lo que podía tapar su sprite.

El usuario pidió que cada capa de mejora progrese de manera independiente hasta 15 niveles (45 subidas posibles), que cada capa enseñe su XP y que el jugador pueda elegir tres prioridades en orden. También solicitó feedback visual inequívoco para torre seleccionada/preview inválido y una corona de seis celdas planas alrededor de la base.

## Decisiones

1. Health, Armor y Shield mantienen contadores de mejora independientes, cada uno de 0 a 15. El máximo total por torre es 45. Una mejora manual o automática incrementa únicamente la capa elegida/activa; las otras dos conservan nivel y XP.
2. Cada mejora válida añade **+1 daño base** y **+1 al multiplicador** de la capa que sube. Las mejoras no aumentan rango ni RPM. El total de daño base conserva un contador agregado separado de los niveles H/A/S.
3. El coste Gold de la capa `L` es `round(base_cost[L] × cost_factor^level[L])`. Los valores iniciales son Ballista/Mortar 10 Gold, Tesla Coil/Frost Keep 20 y Flame Thrower/Poison Sprayer/Shredder 30; los factores parten de 1,15 y son configurables por `TowerData`.
4. La XP por segundo mientras la torre mantiene un objetivo válido en alcance es `0,5 + 1 / (2 × alcance_en_hexes)`. Se asigna a la capa activa del enemigo. El requisito de la capa `L` es `base_xp × xp_factor^level[L]`; el valor base es 100 XP y el factor inicial 1,15. XP base, factores y costes son parámetros provisionales configurables, no una afirmación de paridad de balance con Rogue Tower. Cada botón H/A/S muestra nivel, barra de progreso teñida por capa, XP y coste.
5. La UI conserva tres opciones de prioridad numeradas. No repite criterios. Si el criterio repetido desplaza una opción ya elegida, intercambia las dos; si intenta duplicar un criterio en una opción vacía, revierte la selección para no dejar vacía la prioridad existente. La primera prioridad no se puede vaciar. La regla de desempate propia continúa siendo lexicográfica.
6. Durante build mode, un nodo de preview con `z_index` superior a los elementos del tablero dibuja torre, rango y contorno sobre terreno, props y entidades incluso cuando la ubicación no es legal. La colocación legal es verde y la no disponible es roja. El botón inferior del tipo seleccionado pulsa tanto durante la construcción como al seleccionar una torre colocada de ese tipo.
7. Los cinco obstáculos usan una caja de dibujo común de 86×86 px en el tablero y las cards; se centran con el offset artístico compartido de 6 px hacia abajo. La textura se estira. Esto reemplaza la caja de 104×104 px de ADR-0044 sin cambiar ocupación ni colisiones.
8. Las seis celdas axiales inmediatamente adyacentes a Main Tower quedan en elevación 0. PATH y Grass respetan esa altura; las dos antiguas celdas Mountain del anillo pasan a Grass para conservar la regla del proyecto de que Mountain tiene elevación 2. `StartingBoardData` valida la corona plana.

## Consecuencias

- La UI y `TowerData` comunican la progresión que realmente ejecuta `Tower`; se retiraron los campos de Resource de upgrades antiguos que ya no tenían efecto.
- 15 subidas por capa permiten 45 mejoras por torre. La subida por XP y la compra Gold tienen techos independientes por capa, pero ambas afectan el mismo contador de mejora de esa capa.
- Costes y XP crecen de forma exponencial para que el nivel 15 requiera progresión creciente. El factor 1,15 es una elección de balance provisional y debe ajustarse mediante pruebas de campaña.
- La caja visual uniforme nueva ocupa menos área; la aceptación visual debe comprobar que los obstáculos siguen destacando y se ven centrados.
- No se ejecutó Godot ni la comprobación en ventana durante esta revisión. El procedimiento está en M20 de `10_ACCEPTANCE_TESTS.md`.

## Fuentes

- Petición directa del usuario en la sesión del 2026-10-09.
- [Rogue Tower Wiki — Towers](https://rogue-tower.fandom.com/wiki/Towers), consultada el 2026-10-09; referencia comunitaria para comportamiento general y tasa de XP, no para los factores de balance propios.
- Código y Resources inspeccionados el 2026-10-09.

## Decisiones sustituidas

- ADR-0044 conserva el motivo de estandarizar sprites, pero su tamaño de 104×104 px queda sustituido por 86×86 px.
- ADR-0028/0039/0045 mantienen su alcance histórico de UX. Para progresión individual, selectores de prioridad, preview superior y estado actual del anillo base, manda este ADR y el diseño vigente.
