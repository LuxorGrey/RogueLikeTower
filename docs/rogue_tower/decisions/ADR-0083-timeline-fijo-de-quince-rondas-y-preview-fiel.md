# ADR-0083: Timeline fijo de quince rondas y preview fiel de terreno

- Fecha: 2026-10-14
- Estado: Aceptado por petición explícita; código integrado, aceptación visual pendiente.
- Sustituye la elección del tamaño de ventana de [ADR-0078](ADR-0078-ventana-zoom-del-timeline-de-rondas.md). Amplía la presentación de terreno de [ADR-0079](ADR-0079-limites-de-obstaculos-y-cierre-visual-del-terreno.md).

## Contexto

El selector 10/15 ocupa espacio y la vista de ofertas de terreno no comunica con fidelidad la forma, altura ni orden frontal de las piezas que se colocarán. El efecto es especialmente visible en la pieza `Camino serpenteante`, donde la variación de elevación puede cambiar incorrectamente qué hexágono tapa a otro.

## Decisiones

1. El timeline muestra siempre 15 de las 45 rondas y elimina el selector 10/15. La ronda actual queda al inicio de la ventana mientras haya espacio; al final de la campaña, el tramo visible se fija en 31–45 para conservar los 15 marcadores.
2. El timeline conserva sus tooltips, tamaños, colores, fade y datos de campaña. La cámara y el orden de las rondas no cambian.
3. Las cards de terreno representan la pieza de siete hexes con las mismas texturas superiores, UV hexagonales y fachadas texturadas cerradas que el tablero. Se conservan los obstáculos que ya pertenecen a la oferta.
4. El orden de las celdas del preview sigue la profundidad Y de su anclaje axial en el suelo. La elevación únicamente desplaza la superficie y determina el desnivel de la fachada; no altera la prioridad frontal.
5. Las alturas que se ven en la card son las de la copia de oferta que se coloca en el tablero. PATH permanece en altura 0; Grass y Mountain conservan los rangos vigentes de ADR-0073.

## Consecuencias

- `RoundProgressStrip` representa una ventana invariable de 15 puntos; entre las rondas 31 y 45 mantiene visible el tramo final completo.
- `TerrainPieceCardPreview` usa tapas hexagonales texturadas y fachadas con UV de escala estable y cierre de vértices, alineadas con el orden del renderer del tablero.
- La aceptación visual manual de timeline, alturas, solapamiento y continuidad de fachadas queda pendiente en M35.

## Referencias

- Petición explícita del usuario y captura de ofertas de terreno, 2026-10-14.
- [Diseño activo](../design/01_GAME_DESIGN_SOURCE_OF_TRUTH.md), [terreno](../design/05_HEX_GRID_AND_TERRAIN.md), [arquitectura](../design/03_TECHNICAL_ARCHITECTURE.md) y [aceptación](../design/10_ACCEPTANCE_TESTS.md), consultados el 2026-10-14.
