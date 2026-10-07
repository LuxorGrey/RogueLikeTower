# ADR-0002: presentación 2.5D y cámara

- **Estado:** Sustituida en presentación por ADR-0009 y en terreno por [ADR-0013](ADR-0013-sistema-de-losetas-isometricas.md).
- **Fecha:** 2026-10-06

## Decisión histórica

Se había propuesto una presentación 2.5D con cámara 3D ortográfica inclinada y terreno escalonado. El usuario pidió simplificar el juego a 2D isométrico, por lo que esa dirección queda descartada. Las reglas lógicas de altura de montaña y cuadrícula de construcción 3×3 siguen vigentes según sus ADR; se representan con sprites y datos 2D.

## Motivo de sustitución

El usuario aprobó después una proyección isométrica 2:1, sprites ordenados por profundidad y uso de los assets CellTile compatibles. La antigua escala CellTile 3×3×3 quedó posteriormente sustituida por ADR-0013; solo la proyección visual permanece vigente.
