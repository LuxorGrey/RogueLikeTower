# Rogue Tower

Roguelite de defensa de torres en desarrollo con Godot 4.7 y tablero 2D isométrico. El terreno se organiza en chunks lógicos de 3×3. La fuente de verdad para crear terreno es la [especificación de losetas](docs/diseno/rogue-tower/sistemas/sistema-losetas-isometricas.md).

## Abrir el proyecto

Abre la carpeta del repositorio en Godot 4.7 y ejecuta la escena principal con **Play**. La escena de inicio está prevista para mostrar un chunk isométrico ya formado; consulta el plan para conocer el estado exacto de implementación.

## Modelo de terreno

- Cada chunk tiene nueve celdas lógicas exactas y cuatro puertos cardinales.
- PATH forma rutas, es transitable y no permite construcción.
- GRASS y STONE permiten construcción cuando la celda está libre. STONE comienza a altura 1 y aplica un multiplicador de alcance configurable (1.15 inicial).
- `ChunkDefinition` y `CellData` mantienen reglas; `TileMapLayer` presenta sus datos.
- Los PNG de [assets/CellTile](assets/CellTile/README.md) son fuentes visuales; el inventario documenta qué archivos existen y sus funciones. La licencia para distribución en builds aún debe confirmarse.

## Documentación

- [GDD](docs/GDD.md)
- [Sistema de losetas isométricas](docs/diseno/rogue-tower/sistemas/sistema-losetas-isometricas.md)
- [ADR-0013: chunks lógicos y terreno isométrico](docs/diseno/rogue-tower/decisiones/ADR-0013-sistema-de-losetas-isometricas.md)
- [Plan de implementación](docs/IMPLEMENTATION_PLAN.md)
- [Preguntas abiertas](docs/OPEN_QUESTIONS.md)
- [Formato de datos para oleadas y cartas](docs/DATA_FORMATS.md)

Proyección fija 2:1, sin giro de cámara.
