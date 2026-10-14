# ADR-0100: Sprite único de torre y tinte de altura

- **Estado:** aceptado; el montaje por regiones quedó sustituido por ADR-0102. Sprite único, espejo horizontal y tinte siguen vigentes.
- **Fecha:** 2026-10-14.
- **Contexto:** la presentación anterior montaba base y cabeza como Sprite2D distintos y rotaba la cabeza. La composición y el apuntado se sentían articulados, mientras las mismas ilustraciones se veían diferentes en el mundo, la barra de construcción y el panel de información. También se solicita reforzar ligeramente la lectura de las elevaciones.

## Decisiones

1. En M50, `TowerArtCatalog` combinaba las regiones de base y parte superior de cada lámina en una textura cacheada. M52 sustituyó ese montaje por los siete PNG completos entregados en `assets/sprites/ui/icons/`; ya no se recortan rectángulos ni se calculan pivotes.
2. `Tower` y `TowerBuildGhost` dibujan esa textura con un solo `Sprite2D`. Se elimina el pivote de rotación y la torre no inclina el sprite: mira a la derecha por defecto y usa `flip_h` cuando el objetivo está a su izquierda. Los proyectiles mantienen su lógica de combate actual.
3. La misma textura compuesta se usa en la colocación, la card de construcción y el retrato del panel de información. La card mide `148×178 px`, el retrato `104×104 px`, el nombre usa 16 px y el precio en Gold 22 px. Tower Info amplía el retrato a `128×156 px`, el nombre a 28 px y permite hasta 460 px de ancho; el coste visible en la barra de construcción recibe más jerarquía tipográfica.
4. El multiplicador neutro de las tapas del terreno pasa de 4 % a 5 % por nivel: h0 `1,00`, h1 `0,95`, h2 `0,90`, h3 `0,85`. Tablero, previews y copias Y-sorted comparten `TerrainVisualCatalog.get_elevation_tint()`; no cambia la geometría ni el sombreado propio de las fachadas.

## Consecuencias

- Cada torre mantiene un único sprite visible, un outline y el crecimiento de tamaño por nivel ya aprobado. El montaje por regiones descrito aquí es histórico; véase ADR-0102.
- El retrato del mundo y el de UI usan la misma composición, aunque su tamaño de presentación y material de outline/ghost sean distintos.
- La tapa de elevación 3 queda con un 15 % de oscurecimiento acumulado, manteniendo la progresión por altura simple y uniforme.
- La aceptación visual de orientación, escala de cards/panel e intensidad de tinte queda pendiente de revisión en Godot.

## Referencias

- Petición explícita del usuario, 2026-10-14.
- [Diseño del juego](../design/01_GAME_DESIGN_SOURCE_OF_TRUTH.md), [arquitectura](../design/03_TECHNICAL_ARCHITECTURE.md), [terreno](../design/05_HEX_GRID_AND_TERRAIN.md) y [aceptación](../design/10_ACCEPTANCE_TESTS.md).

## Sustituye

- Sustituye únicamente el montaje visual articulado de base/cabeza decidido en [ADR-0093](ADR-0093-preview-de-terreno-oferta-fija-y-torres-articuladas.md); preview determinista, oferta fija, contornos y outline siguen vigentes.
- La mecánica de composición por regiones de este ADR queda sustituida por [ADR-0102](ADR-0102-sprites-completos-de-torre-escala-y-feedback.md).
- Actualiza la intensidad del tinte introducida en [ADR-0099](ADR-0099-tinte-de-altura-y-sombra-animada-de-nubes.md). El badge de hover, el tooltip y el velo de nubes de ADR-0099 siguen vigentes.
