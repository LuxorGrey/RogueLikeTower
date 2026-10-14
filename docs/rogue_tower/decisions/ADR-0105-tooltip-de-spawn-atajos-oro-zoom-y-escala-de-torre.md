# ADR-0105: Tooltip de spawn, atajos de torre, panel de Gold, zoom y escala

- **Estado:** aceptado e implementado en código; aceptación visual/interactiva pendiente.
- **Fecha:** 2026-10-14.
- **Contexto:** la composición de enemigos sobre los portales cubría el tablero, los atajos de la barra no se compactaban al reclutar torres, la rueda quedaba reservada a rotación durante colocación y Gold/precios no compartían el panel horizontal del botón de ronda. También se solicita reducir otro 10 % el tamaño de las torres colocadas.

## Decisiones

1. Los portales dejan de dibujar retratos flotantes. Mantienen la distribución real de `WaveDirector`; el tooltip de hover muestra retrato, nombre y cantidad de cada tipo de enemigo, además del resumen de ronda.
2. Las torres disponibles en la run se enumeran en el orden del roster visible y reciben atajos consecutivos desde `1`. La tecla aparece como una insignia en cada card; al reclutar otra torre, el nuevo orden se recalcula.
3. La rueda sin modificadores siempre controla el zoom de cámara, también durante la colocación de terreno. `Ctrl+rueda` rota la pieza; Q/E siguen rotando sin usar el ratón.
4. Gold del HUD y el precio de las cards de torre usan un mismo StyleBoxTexture 9-slice, derivado de `start_round_button.png`, que también comparte el estado normal de Iniciar ronda. Mana conserva su presentación sin panel.
5. La escala de `Tower` y `TowerBuildGhost` pasa de 1,056 a 0,9504 (10 % menos), manteniendo escala vertical 1,12, el offset de +8 px, el PNG completo y los tamaños de los iconos UI.

## Consecuencias

- El hover del portal es la única presentación de los tipos y cantidades asignados a ese spawn; la lógica de distribución no cambia.
- La card visible y el número del teclado describen el mismo índice de torre reclutada.
- El usuario puede hacer zoom con la rueda durante la colocación sin girar por accidente la pieza; para girarla con la rueda debe mantener Ctrl.
- La lectura de Gold y del precio de construcción comparte el panel dorado horizontal, mientras Mana no ocupa ese tratamiento visual.
- La reducción afecta al sprite de mundo y al preview, no a retratos, alcance, daño, colisión ni celda ocupada. Los valores anteriores de M54 quedan como historial en [ADR-0104](ADR-0104-reduccion-del-20-por-ciento-de-escala-de-torre.md).

## Referencias

- Petición explícita del usuario, 2026-10-14.
- [Diseño del juego](../design/01_GAME_DESIGN_SOURCE_OF_TRUTH.md), [arquitectura](../design/03_TECHNICAL_ARCHITECTURE.md), [progreso](../design/09_PROGRESS.md) y [aceptación](../design/10_ACCEPTANCE_TESTS.md).

## Sustituye

- Sustituye la escala 1,056 × 1,12 de mundo/ghost establecida en [ADR-0104](ADR-0104-reduccion-del-20-por-ciento-de-escala-de-torre.md), los badges flotantes de portal descritos en [ADR-0051](ADR-0051-navegacion-prevision-portales-y-panel-torre.md) y el uso de la rueda de [ADR-0072](ADR-0072-controles-y-tooltip-de-celdas.md). Conserva los demás contratos de sprites y escala de M52–M54.
