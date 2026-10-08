# ADR-0020 — Cards visuales e inventario de terreno

- Estado: aceptado, 2026-10-08.
- Contexto: la oferta de expansión mostraba una lista textual de composición y escondía las otras opciones tras elegir una. El usuario pidió cards legibles como terreno y posibilidad de cambiar la pieza seleccionada sin reabrir la oferta.

## Decisiones

1. Cada una de las tres opciones es una card clicable que muestra únicamente el nombre de la pieza y una previsualización dibujada de sus siete hexes, colores, alturas y conexiones PATH. No muestra conteos, coordenadas, estadísticas, descripciones ni tooltip.
2. La oferta inicial se centra y da espacio a las previsualizaciones. Tras elegir una pieza, las mismas tres cards se reducen y se mantienen juntas en el inventario inferior, encima de la barra de atajos de torres. La card activa queda resaltada.
3. Mientras no se confirme terreno, elegir otra card cambia la pieza del ghost y conserva la misma oferta. `Esc`, clic derecho o «Volver a cartas» cancelan la selección de colocación y regresan a la oferta centrada sin cambiar las opciones.
4. Confirmar una colocación válida elimina el inventario, limpia las opciones y habilita la ronda siguiente según ADR-0017. El inventario no es el sistema de cartas de mejora M11.

## Consecuencias

- La identidad de una pieza se reconoce por nombre y composición visual; el mapa y el HUD conservan su lectura/diagnóstico independiente.
- La selección/cambio de card es una acción visual durante la expansión; no modifica la oferta hasta la colocación válida.
- Ver criterios manuales en [M10 de aceptación](../fuente_de_verdad/10_ACCEPTANCE_TESTS.md#prueba-manual-m10-en-el-juego).
