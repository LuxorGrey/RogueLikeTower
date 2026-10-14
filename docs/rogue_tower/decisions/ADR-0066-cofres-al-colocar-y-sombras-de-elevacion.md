# ADR-0066: Cofres al confirmar terreno y sombras por elevación

- Fecha: 2026-10-13
- Estado: Aceptado para tirada de cofres; la parte de sombras fue sustituida por ADR-0070 y su código se eliminó.
- Actualiza: [ADR-0060](ADR-0060-ofertas-de-terreno-y-contenido-determinista.md) para el momento de la tirada de cofre y [ADR-0054](ADR-0054-tipografia-global-y-sin-sombras-de-codigo.md) para sombras de terreno.

## Contexto

El usuario pidió que las cards/selección de losas no anticipen cofres y que, si una casilla obtiene uno al colocarla, aparezca con animación de salto. También pidió sombras para las losas y los obstáculos que ayuden a leer altura, con dirección rotatoria lenta.

## Decisiones

1. Los obstáculos siguen fijados en la oferta y se conservan en su ghost. La casilla no contiene una tirada de cofre mientras aparece en la miniatura o se mueve como ghost.
2. Al confirmar la expansión, cada casilla Grass/Mountain sin obstáculo obtiene una tirada de cofre reproducible por seed y coordenada axial. PATH y las casillas con obstáculo no pueden contenerlo.
3. El cofre generado se muestra en el tablero con un salto único; el hover mantiene su animación y resplandor existentes.
4. El overlay generó sombras de terreno y obstáculos en la primera implementación; su geometría se refinó temporalmente mediante [ADR-0068](ADR-0068-sombras-recortadas-por-elevacion.md), y ambos sistemas fueron eliminados por [ADR-0070](ADR-0070-sin-sombras-y-rutas-limpias-en-expansion.md).
5. La regla vigente desactiva todas las sombras generadas por código. ADR-0054 vuelve a ser la referencia para esta decisión visual.

## Consecuencias

- La política anterior de mostrar una asignación fija de cofre en card/ghost queda sustituida; ADR-0060 sigue vigente para los obstáculos y la reproducibilidad.
- La regla de no usar sombra procedural queda restaurada para todo el tablero; no quedan scripts ni shaders del overlay.
- Falta inspeccionar visualmente el salto del cofre, la ausencia de sombras y la colocación PATH en ventana.
