# ADR-0004: contrato de colocación de piezas de terreno

- Estado: Aceptada para M3; la reciprocidad exacta entre piezas quedó ampliada por ADR-0006. La reciprocidad exacta dentro de una pieza sigue vigente.
- Fecha: 2026-10-07.

## Contexto

M3 necesita ampliar el tablero con piezas de siete celdas, conservar los datos del terreno al girar y prevenir empalmes ambiguos de PATH. M4 todavía no implementa el grafo que permite verificar rutas completas desde spawn hasta base.

## Decisión

- `TerrainPieceData` es una plantilla inmutable de contenido; el pivote local es `(0,0)`. La huella puede ser cualquier grupo conectado de siete celdas.
- `path_edges` es una máscara de seis bits, alineada con `HexCoord.DIRECTION_OFFSETS`. Las conexiones internas de una pieza requieren que dos celdas PATH vecinas marquen sus bordes recíprocos.
- Una pieza expansiva debe tener al menos un socket explícito hacia fuera y al colocarla debe unirlo con PATH del tablero mediante una cara explícita o flexible complementaria. Las aperturas laterales flexibles se describen en ADR-0006; las que queden abiertas pueden servir para expansión posterior.
- `TerrainPlacementValidator` calcula la legalidad sin modificar el tablero ni el Resource. Se rechazan solapamientos, falta de contacto, bordes PATH explícitos incompatibles, salidas explícitas hacia terreno que no sea PATH y piezas que no enlacen con PATH existente cuando lo requieren. Una oferta flexible no usada no invalida la colocación.
- Tras confirmar una evaluación legal, `HexGrid.add_cells` inserta todas las celdas de la pieza en una única operación, asignándoles un `piece_instance_id`.
- La pieza inicial es una semilla especial que no requiere conexión entrante y expone una salida inicial hacia `(0,-2)`.
- La conectividad global spawn-base no se intenta inferir en M3; queda a cargo de `PathGraph` y M4.
- El preview combina tablero confirmado y fantasma; verde indica colocación legal y rojo indica que la evaluación actual tiene errores. La UI solo confirma una evaluación legal.

## Consecuencias

- Pueden coexistir adyacencias visuales entre dos celdas PATH sin conexión lógica cuando ninguno ofrezca un borde exacto ni flexible. Esto mantiene explícita la topología.
- El usuario puede construir una pieza legal localmente que todavía no preserve todas las rutas globales; M4 debe volver a validar el grafo antes de habilitar una expansión jugable.
- Las cinco piezas iniciales (`straight`, `gentle_turn`, `hard_turn`, `fork`, `convergence`) son composiciones y contenido provisionales, no decisiones de balance ni arte final.

## Fuentes

- `docs/fuente_de_verdad/02_IMPLEMENTATION_ROADMAP.md`, consultado el 2026-10-07.
- `docs/fuente_de_verdad/04_DATA_MODELS.md`, consultado el 2026-10-07.
- `docs/fuente_de_verdad/05_HEX_GRID_AND_TERRAIN.md`, consultado el 2026-10-07.
- Requerimiento explícito del usuario en esta conversación, 2026-10-07.
