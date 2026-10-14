# ADR-0063 — Selección y retirada de objetos del terreno

- Estado: decisión aprobada por petición del usuario; código integrado; aceptación visual/interactiva pendiente. El rango lógico 0–2 de la decisión 6 fue ampliado a 0–3 por ADR-0073.
- Fecha: 2026-10-13.
- Contexto: los obstáculos no se podían inspeccionar ni retirar y los portales eran solo indicadores de rutas. Las capturas del usuario mostraron vértices de fachadas que parecen abiertos; además, el offset de elevación de 18 px por nivel ofrecía poca separación visual.

## Decisiones

1. En `ROUND_PREP`, seleccionar un obstáculo muestra su nombre en el panel de información: Roca, Cristal, Hierba alta, Tótem o Montón de piedra, con su retrato, terreno y elevación. Los nombres se fijan en `12_NOMENCLATURE.md` y corresponden al orden de `HexCell.ObstacleType`.
2. Se puede pagar para quitar obstáculos. La retirada número `n` cuesta `25 × n²` Gold: 25, 100, 225, 400… `n` es el ordinal de la retirada actual, equivalente a uno más la cantidad de obstáculos que ya retiró el jugador; no es el número de obstáculo generado ni incluye portales.
3. Al hacer clic en un portal, el panel muestra la composición que tiene asignada en la ronda seleccionada como lista con sprite, nombre y cantidad de cada tipo. Se conserva el tooltip de hover existente.
4. Se puede retirar un portal solo cuando quedan más de tres spawns activos. Su coste es dos veces el siguiente coste de retirada de obstáculo. Retirar portales no incrementa el contador de obstáculos retirados.
5. `PathGraph` conserva los endpoints retirados durante la run y expone únicamente rutas activas al `WaveDirector`, el overlay de flujo y la previsión. Las cantidades de `WaveData` permanecen iguales; el round-robin redistribuye los enemigos entre los endpoints activos.
6. El desplazamiento visual de cada nivel pasa de 18 a 28 px en terrenos, hover, fantasmas y torres. En esta decisión se conservaba el rango lógico 0–2, ampliado a 0–3 por ADR-0073. Las uniones de fachadas se rellenan con una cuña única sin descartar wedges por un umbral de área.
7. Las compras ocurren solo en preparación de ronda. No alteran el grafo PATH, las coordenadas, el terreno, los sockets ni el contenido guardado entre runs.

## Consecuencias y aceptación

- La interfaz reutiliza `TowerInfoPanel` y el coste se paga con `RunEconomyService`.
- `WaveDirector` no genera menos enemigos cuando desaparece un portal; selecciona desde `PathGraph.get_active_routes()`.
- La verificación manual pendiente está en M26 de `10_ACCEPTANCE_TESTS.md`: selección de los cinco obstáculos, secuencia de precios, restricción de tres portales, consistencia entre preview y wave real, juntas de fachadas y lectura de alturas a varios zooms.
- La altura extra es un parámetro visual confirmado por el usuario; no constituye una redefinición de gameplay ni cambia bonus de alcance/daño.

## Fuentes y ADR relacionados

- Petición del usuario del 2026-10-13: selección/retirada de obstáculos y portales, coste de Gold, revisión de vértices y mayor separación visual de alturas.
- Capturas adjuntas del usuario del 2026-10-13: juntas de fachadas Grass y Mountain.
- Continúa [ADR-0043](ADR-0043-superficies-de-elevacion-y-preview-de-spawns.md) para la oclusión 2D y el orden visual; precisa la selección de spawns de [ADR-0051](ADR-0051-navegacion-prevision-portales-y-panel-torre.md).
- Sustituye únicamente el offset visual de altura documentado en ADR-0048; conserva el rango lógico de elevación y las demás decisiones de esos ADR.
