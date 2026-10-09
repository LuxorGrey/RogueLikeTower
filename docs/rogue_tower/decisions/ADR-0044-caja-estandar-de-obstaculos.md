# ADR-0044: Caja estándar para los sprites de obstáculos

- Fecha: 2026-10-09.
- Estado: implementado en el tablero y las cards; aceptación visual pendiente.
- Ámbito: tamaño de dibujo para roca, esquirla, hierba alta, tótem y piedras.
- Sustituye parcialmente: ADR-0041, punto 3, sobre conservar la proporción original de los obstáculos.

## Contexto

Los cinco obstáculos tenían formas fuente muy distintas y cada uno se ajustaba dentro de un máximo conservando su proporción. Eso producía tamaños aparentes diferentes y requería cálculos por asset. El usuario quiere que todos tengan una huella visual uniforme y acepta que el arte temporal se estire, ya que será reemplazado más adelante.

## Decisiones

1. Todos los obstáculos se dibujan en un rectángulo fijo de **104×104 px**. La textura fuente se estira para llenar la caja, aunque cambie su proporción.
2. `TerrainVisualCatalog.OBSTACLE_DISPLAY_SIZE` es la única constante para este tamaño. La usa tanto el tablero como `TerrainPieceCardPreview`, y así los nuevos tipos del pool quedan estandarizados al añadirse.
3. La caja coincide con la altura de un hexágono pointy-top de radio 52 px. El punto inferior de la imagen conserva el offset artístico de seis píxeles hacia abajo. Esto solo modifica dibujo; no cambia footprint, ocupación, validación, selección ni colisiones.
4. Los cofres conservan su tamaño separado de 84×84 px y no forman parte del pool de obstáculos.

## Consecuencias y estado

- Los cinco obstáculos comparten exactamente el mismo rectángulo de destino y el mismo tamaño en cards y mapa.
- Las siluetas temporales pueden verse comprimidas o ensanchadas. Esa distorsión es aceptada para simplificar extensión y será reemplazada con el arte final.
- La aceptación visual pendiente debe confirmar que el rectángulo común se lee bien sobre Grass/Mountain y no oculta elementos importantes del hex vecino.

## Referencias

- Petición directa del usuario en la sesión del 2026-10-09.
- [Modelo de datos de terreno](../design/04_DATA_MODELS.md).
- [Terreno hexagonal y elevación visual](../design/05_HEX_GRID_AND_TERRAIN.md).
