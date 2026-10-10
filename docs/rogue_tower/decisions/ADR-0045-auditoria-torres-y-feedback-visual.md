# ADR-0045: auditoría de torres, feedback de selección y texturas runtime

- **Fecha:** 2026-10-09
- **Estado:** cambios implementados; aceptación visual/manual pendiente
- **Decide:** solicita el usuario; se mantienen los valores de combate existentes salvo alinear metadata y UI con el runtime

## Contexto

El usuario pidió una revisión profunda de torres basada en la página Towers de Rogue Tower y mejoras visuales de selección, hover, flujo de Path, Gold, cofres y portales. También pidió ajustar cuatro PNG grandes y separar los atlas de terreno y obstáculos en objetos individuales.

La inspección confirmó que las mejoras de torre efectivas están codificadas como +1 de daño base y +1 al multiplicador H/A/S seleccionado; la elevación suma daño y rango; el XP usa tiempo con un objetivo en rango; el coste de Mana se cobra al intentar cada disparo; y los críticos ejecutan tiradas condicionales por banda. También encontró que Frost Keep usa una caja alineada a pantalla pero el Resource declaraba un radio de área de 1,2 hex, y la UI mostraba ese radio que no se ejecutaba.

## Decisiones

1. Registrar fórmulas, configuración cargada, diferencias con la wiki y preguntas de balance en [15 — Auditoría del sistema de torres](../design/15_AUDITORIA_SISTEMA_DE_TORRES.md). La página describe el runtime y no aprueba por sí sola mecánicas externas.
2. Configurar Frost Keep como `ALL_IN_RANGE` y mostrar que afecta a enemigos dentro de un cuadrado con semilado igual al alcance. Sus objetivos efectivos, coste y cifras no cambian. La aproximación a un radio circular queda fuera de este cambio.
3. Dejar `max_targets = 1` en Tesla Coil porque `ALL_IN_RANGE` alcanza a todos y ese campo no limita su ataque. `max_targets` sigue activo para `CHAIN`.
4. Al seleccionar una torre, hacer que su panel pulse, que su icono y radio tengan pulso y que el PNG reciba resplandor siguiendo su alfa. Elevar el `z_index` de la torre seleccionada para que su sprite no quede tapado por tapas elevadas.
5. Dibujar el contorno y los sockets de hover en un overlay independiente situado en la elevación lógica de cada celda, sobre las superficies Y-sorted. Las vecinas se desvanecen hasta dos anillos.
6. Hacer las flechas PATH más lentas, menos densas y tenues; ejecutar el pulso de portales con fase propia por instancia; pulsar el cofre al aparecer; exagerar el rebote de icono y cifra de Gold ganado y mantener una respuesta más discreta al gasto.
7. Mantener las texturas de los atlas originales como fuentes, pero separar el runtime en nueve PNG de tiles (180×208) y cinco PNG de obstáculos (208×208). Los cuatro PNG listados se reducen a dos píxeles de fuente por píxel de dibujo lógico: `main_tower` 352×352, `spawn_portal` 224×336, `treasure_chest` 168×168 y `tower_card_button` 288×296. Los destinos en pantalla no cambian.
8. Conectar el modificador de cadencia soportado por `RunCardService` a `Tower`; el pool actual no contiene una operación de ese tipo, así que no cambia el balance vigente.

## Consecuencias

- La cuadrícula y los sockets de hover no dependen del orden de las tapas por Y y se calculan con la elevación de la celda.
- Las texturas de terreno/props se pueden cambiar una por una sin editar un atlas runtime. Las cinco props mantienen una caja estirada idéntica.
- Los cuatro PNG revisados pasan de 6.805.626 a 433.294 bytes (−93,6 % combinado), conservando el destino lógico y dos píxeles fuente por píxel dibujado; sus dimensiones y pesos están en `assets/terrain/README.md`.
- Varias propiedades antiguas de `TowerData` son declarativas o históricas y no alteran los upgrades efectivos; el modelo de datos lo documenta.
- No se rebalancean daño, niveles, XP, coste ni XP de cartas. Las diferencias propias y decisiones pendientes se listan en la auditoría.
- No se ejecutó Godot ni se confirmó la percepción visual en una ventana; los criterios manuales de M19 deben pasar antes de marcar aceptación.

## Fuentes

- [Rogue Tower Wiki — Towers](https://rogue-tower.fandom.com/wiki/Towers), consultada 2026-10-09; referencia comunitaria indexada, revisión exacta no identificada.
- [Anuncios oficiales de Rogue Tower en Steam](https://steamcommunity.com/app/1843760/announcements/), incluidos Patch Notes 1.1.2.0 (2022-09-08).
- Código y Resources del proyecto inspeccionados 2026-10-09.

## Sustituye

Completa ADR-0041–0044 en feedback, assets compactos, división de atlas y render de selección/hover; no cambia el alcance de elevación de ADR-0043 ni la caja de props de ADR-0044.
