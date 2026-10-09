# ADR-0043: Superficies de elevación, preview de spawns y obstáculos en cards

- Fecha: 2026-10-09.
- Estado: implementado en código; aceptación visual pendiente.
- Ámbito: oclusión de terreno elevado y presentación de previews de expansión.
- Sustituye parcialmente: ADR-0042, punto 1 sobre fachadas/cliffs ordenados como oclusores.

## Contexto

La corrección de profundidad de M18 hacía que las fachadas posteriores del terreno elevado aparecieran delante de enemigos y base. Además, al elegir una pieza el jugador necesita ver los spawns previstos en su ubicación candidata, y las cards de terreno deben mostrar cómo se integran los obstáculos con sus losetas. La generación real de props sigue dependiendo del seed y de la coordenada final, que todavía no se conocen al mostrar la oferta.

## Decisiones

1. Las fachadas traseras (bordes axiales 4 y 5) no se dibujan. Las fachadas laterales y frontales visibles siguen formando parte del render de terreno situado bajo las entidades.
2. Cada celda elevada coloca una sola copia texturada de su superficie superior en `Entities.y_sort_enabled`, ordenada por el centro elevado. Esa tapa es la única geometría de terreno que puede cubrir una entidad situada detrás por profundidad; una entidad situada delante se dibuja encima. Las paredes no se añaden a Y-sort. El recurso de terreno original y la cara copiada comparten región de atlas y footprint para que no haya un parche de color plano.
3. Durante una colocación activa y válida, `TerrainPiecePreview` sustituye los portales por los endpoints alcanzables del `PathGraph` candidato y los mueve a su coordenada exterior prevista. El tinte verde identifica este preview válido. Si la colocación deja de ser válida, se cancela o termina, se muestran los portales del grafo activo tras el siguiente refresco.
4. Las cards de terreno dibujan obstáculos representativos deterministas encima de Grass/Mountain, usando el atlas, el tamaño y las tasas configuradas (25 % Grass/15 % Mountain); si ninguna tirada ilustrativa produce un obstáculo, se elige uno para que la card con terreno construible enseñe el pool visual. Esta capa es solo ilustrativa: el preview no fija ni anticipa la tirada real. `TerrainVisualCatalog` vuelve a generar el contenido al confirmar la pieza según el seed de run y la coordenada axial definitiva. PATH no recibe obstáculos.

## Consecuencias y estado

- La tapa elevada puede ocultar entidades lejanas situadas detrás y deja visible el frente de unidades cercanas. El dibujo de fachadas ya no participa en Y-sort, por lo que no puede aparecer como un muro sobre la silueta de un enemigo.
- El jugador ve a qué posiciones exteriores se moverán los spawns antes de confirmar la ampliación y distingue ese estado con el tinte verde.
- Las cards muestran la combinación visual de terreno y props sin convertir su ilustración en una predicción de generación. La tabla de probabilidades de gameplay permanece sin cambios.
- No se ejecutó Godot ni se hizo inspección visual en esta revisión. Los casos de altura, preview/cancelación, solape de props sobre cards y reversión de portales quedan en la aceptación M18 de `design/10_ACCEPTANCE_TESTS.md`.

## Referencias

- Petición directa del usuario en la sesión del 2026-10-09.
- [ADR-0042: orden por elevación y feedback del tablero](ADR-0042-orden-por-elevacion-y-feedback-del-tablero.md).
- [Terreno hexagonal y elevación visual](../design/05_HEX_GRID_AND_TERRAIN.md).
