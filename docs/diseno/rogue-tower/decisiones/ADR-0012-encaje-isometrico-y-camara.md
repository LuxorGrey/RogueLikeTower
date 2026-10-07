# ADR-0012: encaje CellTile y cámara (histórico)

- **Estado:** Sustituido para la creación de terreno por ADR-0013 (2026-10-07). La proyección fija 2:1 se conserva.
- **Fecha original:** 2026-10-07.

## Registro histórico

La fórmula de colocación por posiciones X/Y/Z, el lienzo común 128×128, el paso de 64×32, la profundidad `X+Y+Z` y la escena `scenes/tiles/main_tile.tscn` pertenecían a la propuesta visual anterior de volumen 3×3×3. La escena indicada nunca estaba presente en el checkout revisado.

## Estado actual

Los PNG disponibles tienen dimensiones y huellas distintas; no se deben estirar ciegamente a un lienzo común. La retícula y los orígenes se deben ajustar en el TileSet isométrico a las piezas que se usen. El orden de profundidad se configura y comprueba sobre las capas/chunks reales de Godot 4.7. Este ADR ya no prescribe transformación de terreno ni controles de cámara. Ver [Sistema de losetas isométricas](../sistemas/sistema-losetas-isometricas.md).
