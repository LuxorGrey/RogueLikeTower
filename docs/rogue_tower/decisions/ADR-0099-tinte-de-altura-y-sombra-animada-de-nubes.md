# ADR-0099: Tinte de altura y sombra animada de nubes

- Fecha: 2026-10-14
- Estado: Implementado en código; ADR-0100 actualiza parcialmente la intensidad del tinte y ADR-0109 refina la opacidad de nubes. Aceptación visual pendiente.
- Sustituye: la intensidad/fórmula del tinte de [ADR-0082](ADR-0082-tinte-multiplicativo-por-elevacion.md), actualizada después por ADR-0100, y la prohibición general de cualquier sombra generada de [ADR-0070](ADR-0070-sin-sombras-y-rutas-limpias-en-expansion.md) y [ADR-0054](ADR-0054-tipografia-global-y-sin-sombras-de-codigo.md). Se mantiene la prohibición de sombras proyectadas por sprite.

## Contexto

La diferencia visual entre niveles altos todavía cuesta leerse. También se pide una sombra móvil de nubes que cubra el mundo y todos sus sprites, con formas irregulares de aspecto dibujado, sin tapar los controles de interfaz. La insignia de bonus de elevación de una torre debe quedar disponible solo al pasar el cursor; el ghost de colocación mantiene la información contextual que ya mostraba.

## Decisiones

1. `TerrainVisualCatalog.get_elevation_tint()` usa un multiplicador neutro igual en RGB: altura 0 = `1,00`, altura 1 = `0,96`, altura 2 = `0,92` y altura 3 = `0,88`. Aplica el mismo valor a la tapa del tablero, previews y copias elevadas Y-sorted.
2. La insignia numérica de bonus en una torre construida se dibuja solo cuando `Tower._is_hovered` es verdadero. El indicador del ghost sigue visible durante la previsualización de colocación bajo el cursor.
3. `CloudShadowOverlay` usa un ColorRect de pantalla completa con un shader CanvasItem procedural, ruido deformado de varios tamaños y deriva lenta. El patrón toma la posición/zoom de `Camera2D` para permanecer anclado al terreno al mover la cámara. La sombra se implementó inicialmente con una opacidad de `0,16`; ADR-0109 la actualiza a `0,20`, manteniendo el tono azul-negro y los bordes irregulares suaves.
4. El ColorRect vive en `CloudShadowLayer`, un CanvasLayer justo antes del HUD en el árbol de la escena. Cubre el mundo dibujado detrás y queda debajo de los controles del HUD; sigue activo aunque se oculte el HUD. Afecta de manera uniforme a terreno, fachadas, base, torres, enemigos, obstáculos, props y portales, sin cambiar la iluminación individual, las texturas, el orden Y-sort, la geometría ni el gameplay.
5. El tooltip de celda se coloca a 24 px del cursor en horizontal y conserva 14 px en vertical; si no hay espacio a la derecha, se ubica al lado opuesto con el mismo margen.

## Consecuencias

- En la versión M49, la tapa llegaba a 12 % de oscurecimiento en altura 3. M50/ADR-0100 actualiza el máximo vigente a 15 %. Las fachadas conservan su propio sombreado direccional y el degradado inferior.
- No se añaden imágenes de nubes ni assets externos; el shader crea las masas animadas durante la partida.
- La uniformidad del velo evita diferencias entre sprites animados, torres y terreno. Los elementos de interfaz conservan sus colores.
- La forma, contraste, velocidad y visibilidad del efecto deben revisarse en ventana Godot; no se verificaron visualmente en esta implementación.

## Referencias

- Petición explícita del usuario, 2026-10-14.
- [Diseño del terreno](../design/05_HEX_GRID_AND_TERRAIN.md) y [criterios de aceptación](../design/10_ACCEPTANCE_TESTS.md).
