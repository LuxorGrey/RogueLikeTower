# ADR-0009: presentación 2D isométrica y CellTile (histórico)

- **Estado:** La proyección 2D isométrica fija 2:1 sigue vigente. Las decisiones de creación de terreno de este ADR están **sustituidas** por ADR-0013 (2026-10-07).
- **Fecha original:** 2026-10-07.
- **Sustituye:** ADR-0002 para la presentación visual.

## Registro histórico

La decisión original combinó la proyección 2:1 con una loseta de volumen CellTile 3×3×3, una composición obligatoria de 27 sprites y reglas de camino/elevación basadas en nombres de PNG. El usuario entregó después una especificación detallada que define chunks de datos 3×3 y tres tipos de terreno.

## Estado actual

Se conserva únicamente la presentación 2D isométrica fija y el orden visual de profundidad. Para el tamaño del chunk, tipos de terreno, alturas, construcción, rutas, recursos Godot y assets vigentes, consultar [Sistema de losetas isométricas](../sistemas/sistema-losetas-isometricas.md) y [ADR-0013](ADR-0013-sistema-de-losetas-isometricas.md). Las referencias antiguas a `path_variant_1`, `dirt2/dirt3`, escenas de 27 Sprite2D y `scenes/tiles/main_tile.tscn` no son reglas actuales.
