# ADR-0121 — Color y gradiente de fachadas de elevación

- Fecha: 2026-10-15.
- Estado: código y documentación integrados; aceptación visual pendiente.
- Decisiones relacionadas: ADR-0085 limita el dibujo a las dos fachadas delanteras; ADR-0092/0094 definen el estilo previo de sombreado.
- Sustituye parcialmente: los tintes multiplicativos oscuros y la diferencia de brillo por dirección de ADR-0094.

## Contexto

Las fachadas verticales de los hexágonos se veían casi negras en gran parte de su superficie. El usuario pidió aclararlas con colores concretos y conservar un gradiente negro que desaparezca desde la base hacia la parte superior.

## Decisiones

1. Mostrar en la parte superior de las fachadas Grass el color `#407850` y en las de Mountain `#3b3c41`. Los PNG de fachada actuales son rellenos planos `#406e4d` y `#646567`; el renderer los modula para alcanzar los nuevos tonos sin cambiar las texturas fuente.
2. Dibujar sobre cada quad de fachada un gradiente negro alfa: opaco en los vértices inferiores y completamente transparente en los superiores. El gradiente no se aplica a las tapas hexagonales.
3. Compartir los colores y el gradiente entre el tablero, `TerrainPiecePreview` y `TerrainPieceCardPreview`. Conservar geometría axial, dos caras delanteras, recorte de desnivel y orden Y-sort.

## Consecuencias

- La parte superior de cada cara elevada tiene el color especificado; el sombreado oscuro queda concentrado abajo y se desvanece suavemente hacia arriba.
- La diferencia de tinte superior entre las dos direcciones se retira; ambas caras usan el mismo color de terreno y gradiente vertical.
- Falta inspección visual de tablero, previews y miniaturas en Godot; no se ejecutó el motor.

## Implementación

- `game/board/terrain_visual_catalog.gd`
- `game/board/terrain_cliff_occluder.gd`
- `game/board/terrain_piece_preview.gd`
- `game/board/terrain_piece_card_preview.gd`
- `docs/rogue_tower/design/01_GAME_DESIGN_SOURCE_OF_TRUTH.md`
- `docs/rogue_tower/design/03_TECHNICAL_ARCHITECTURE.md`
- `docs/rogue_tower/design/05_HEX_GRID_AND_TERRAIN.md`
- `docs/rogue_tower/design/09_PROGRESS.md`
- `docs/rogue_tower/design/10_ACCEPTANCE_TESTS.md`
