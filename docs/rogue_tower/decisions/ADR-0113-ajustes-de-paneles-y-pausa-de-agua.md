# ADR-0113 — Ajustes de paneles y pausa de agua

- Fecha: 2026-10-15
- Estado: Aceptado; implementación integrada; aceptación visual e interactiva pendiente.
- Decisiones relacionadas: refina ADR-0110 (fila H/A/S), ADR-0111 (precios de demolición), ADR-0112 (Tower Info, pausa y selección de portal) y ADR-0108/0109 (fondo de agua).

## Contexto

La escena `main.tscn` conservaba restos serializados de la ruta anterior de `RemovalCostLabel`, que provocaban un error al iniciar. La fila de mejoras H/A/S alineaba mal los iconos y algunos valores de layout se imponían desde código, dificultando ajustarlos en el Inspector. Los precios de demolición compartían el interior del botón. La selección de portal no siempre mantenía una referencia válida para abrir su información lateral. El shader de agua seguía avanzando mientras el árbol de juego estaba pausado.

## Decisiones

1. `RemovalCostBadge` y `TowerDemolitionRefundPanel` son hermanos de sus botones, colocados a su derecha. La escena contiene los nodos de fila, icono y cifra bajo su ruta vigente; no conserva nodos huérfanos en la raíz.
2. El icono H/A/S se centra mediante un `CenterContainer` y usa 64 × 64 px. El tamaño de los botones vuelve a depender de la escena reutilizable, sin asignaciones de tamaño desde `_configure_tower_upgrade_visuals()`.
3. Los parámetros responsivos de Tower Info (anchos, márgenes de posición, altura mínima y espacio inferior) se exponen en el Inspector del nodo `Main`. El código no resetea la escala ni el pivote de `TowerInfoContent`; los márgenes del `MarginContainer` se conservan como propiedades de escena.
4. `SpawnPortal` seleccionado se conserva como referencia explícita. La visibilidad de Tower Info no depende de una consulta global de cantidad de spawns; el panel muestra el detalle y reparto de esa salida.
5. El shader usa el uniforme `water_time`, actualizado con el delta de `Main`. Como `Main` no procesa durante pausa, el agua se congela y continúa al reanudar.

## Consecuencias

- Los cambios de layout de Tower Info se pueden ajustar desde el Inspector sin editar constantes de código.
- La escena vuelve a resolver `%RemovalCostLabel`; el precio y el reembolso quedan fuera del botón.
- No se ejecutó Godot; la carga de escena y la aceptación visual/interactiva quedan pendientes en [M62](../design/10_ACCEPTANCE_TESTS.md#m62--correcciones-de-paneles-y-pausa-del-agua).
