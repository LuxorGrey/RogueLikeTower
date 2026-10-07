# ADR-0011: losetas prefabricadas como escenas Godot (histórico)

- **Estado:** Sustituida para la arquitectura de terreno por ADR-0013 (2026-10-07).
- **Fecha original:** 2026-10-07.

## Registro histórico

Este ADR respondió a una preferencia anterior por editar cada pieza como escena `.tscn` con una instancia de `Sprite2D` por CellTile. Incluía un volumen visual 3×3×3 y ubicaba la lógica de pieza dentro de prefabs.

## Decisión vigente

Los chunks se definen como recursos de datos con nueve celdas lógicas y cuatro puertos. TileMapLayer presenta el estado. Un `.tscn` de demostración puede contener la vista inicial, pero no reemplaza `ChunkDefinition` ni constituye la base de datos de terreno. No es necesario crear una instancia Sprite2D por celda. Consultar [Sistema de losetas isométricas](../sistemas/sistema-losetas-isometricas.md).
