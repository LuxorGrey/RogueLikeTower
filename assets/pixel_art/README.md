# Rogue Tower · pixel art activo

Esta carpeta contiene los 62 PNG propios activos de la rama `Pixel-Change`: 26 enemigos, 11 teselas/fachadas, 5 obstáculos, base, portal, cofre, 16 iconos y el icono de demolición. Las copias antiguas de los sprites y las alternativas visuales se retiraron tras comprobar que ningún Resource, escena o catálogo de runtime las usa. El estado queda registrado en [ADR-0057](../../docs/rogue_tower/decisions/ADR-0057-assets-pixel-art-activos-y-encaje-hexagonal.md).

## Pixel grid and canvas

The low-resolution artwork is authored inside the same PNG canvas dimensions as its source, so existing texture extents, anchors, gameplay sizing and UI layout remain valid. The visible shape keeps its source aspect ratio. Pixel-grid width by family:

| Family | Grid width | Files |
|---|---:|---|
| Enemy portraits | 32 px | 26 |
| Terrain tiles and cliff faces | 48 px | 11 |
| Terrain obstacles | 32 px | 5 |
| Main base | 64 px | 1 |
| Spawn portal and treasure chest | 32 px | 2 |
| HUD, status and tower icons | 32 px | 16 |
| Demolition icon | 24 px | 1 |

The art was converted into hard-edged, nearest-sampled pixel clusters and clipped to each original transparent silhouette. Four key assets (main base, Goblin, Grass 01 and Mortar) and the terrain set have dedicated pixel-art redraws; the remaining assets preserve their original drawing and palette on the same low-resolution grid for this reversible visual test.

## Runtime rules

- `project.godot` uses nearest texture sampling and snaps 2D transforms to pixels. Vertex snapping stays off so it does not combine with transform snapping.
- No full-screen pixelation shader or low-resolution viewport is active. Text, flat HUD shapes and panel layout keep their normal resolution.
- All seven tower portraits live once in `ui/icons/`; `IconCatalog` returns the same `Texture2D` for the HUD, placement preview, selected-tower panel, and placed world tower.
- Patrick Hand is the active UI font. Its TTF and OFL license are in `assets/fonts/Patrick_Hand/`.
- Enemy Resources continue to use one static PNG each. Sprite sheets are deferred until a later request.
- Existing Tiny Swords cursors and impact sprite sheets are already pixel assets; they remain at their licensed source paths.
- The inactive old proposals and decorative PNG frames were removed with the old sprites; the HUD remains flat and editable.

This experiment does not approve a final production palette or art direction. Replace a file in this folder with a manually authored sprite at the same canvas dimensions when production pixel art is ready.
