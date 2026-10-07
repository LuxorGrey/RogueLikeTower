# ADR-0001: topología de chunks y rutas

- **Estado:** Confirmada; los detalles de terreno y representación siguen ADR-0013.
- **Fecha:** 2026-10-06, revisada el 2026-10-07.

## Contexto

El usuario quiere inspirarse en patrones de camino de Carcassonne (sin copiar ilustraciones) y expandir un tablero por sus cuatro lados. Solo se permiten giros de 90°, no reflejos. Los patrones A–Y son referencia para vectorización; sus frecuencias visibles suman 75 y no se corrigen silenciosamente frente a las 72 piezas descritas para una edición base.

## Decisión

- El mapa de campaña se organiza en cuadrícula ortogonal de chunks 3×3.
- Cada chunk codifica puertos cardinales y conectividad de camino en datos. Los puertos enfrentados a chunks existentes deben coincidir en todos los lados; bordes sin vecino pueden quedar abiertos para futuras expansiones.
- Una colocación que contenga PATH debe conectarse a la red existente y conservar la ruta exigida por la partida. Los enemigos se mueven por el grafo de PATH, nunca por proximidad gráfica.
- Giros de 90° transforman conjuntamente datos lógicos y puertos. No se refleja una definición ni su arte automáticamente.
- Patrones A–Y, campamentos/monasterios y reglas topológicas de referencia se implementarán solo cuando tengan definición propia compatible con los tres terrenos del sistema actual. No alteran PATH/GRASS/STONE ni sus reglas de construcción.

## Consecuencias

La lógica del chunk vive en `ChunkDefinition` y el grafo en el modelo del mapa. La vista no infiere rutas. El sistema de terreno, recursos, alturas y construcción está descrito en [Sistema de losetas isométricas](../sistemas/sistema-losetas-isometricas.md). El recuento de A–Y se mantiene como referencia, no como catálogo de reglas ya implementado.
