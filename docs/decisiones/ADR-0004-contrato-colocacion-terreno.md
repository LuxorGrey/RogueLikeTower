# ADR-0004: contrato de colocación de piezas de terreno

- Estado: Aceptada para M3; la reciprocidad exacta entre piezas quedó ampliada por ADR-0006. La semilla especial de siete celdas se conserva como antecedente M3; ADR-0025 define el tablero de campaña actual. La reciprocidad exacta dentro de una pieza sigue vigente.
- Fecha: 2026-10-07.

## Contexto

M3 necesita ampliar el tablero con piezas de siete celdas, conservar los datos del terreno al girar y prevenir empalmes ambiguos de PATH. M4 añade una validación del snapshot global PATH antes de confirmar una expansión; su algoritmo y la coordenada provisional de base están en ADR-0007.

## Decisión

- `TerrainPieceData` es una plantilla inmutable de contenido; el pivote local es `(0,0)`. La huella puede ser cualquier grupo conectado de siete celdas.
- `path_edges` es una máscara de seis bits, alineada con `HexCoord.DIRECTION_OFFSETS`. Las conexiones internas de una pieza requieren que dos celdas PATH vecinas marquen sus bordes recíprocos.
- Una pieza expansiva debe tener al menos un socket explícito hacia fuera y al colocarla debe unirlo con PATH del tablero mediante una cara explícita o flexible complementaria. Las aperturas laterales flexibles se describen en ADR-0006; las que queden abiertas pueden servir para expansión posterior.
- `TerrainPlacementValidator` calcula la legalidad sin modificar el tablero ni el Resource. Se rechazan solapamientos, falta de contacto, bordes PATH explícitos incompatibles, salidas explícitas hacia terreno que no sea PATH y piezas que no enlacen con PATH existente cuando lo requieren. Una oferta flexible no usada no invalida la colocación.
- Tras confirmar una evaluación legal, `HexGrid.add_cells` inserta todas las celdas de la pieza en una única operación, asignándoles un `piece_instance_id`.
- La semilla M3 de siete celdas no requería conexión entrante y exponía una salida hacia `(0,-2)`. Ese tablero queda sustituido para la campaña por el tablero de 19 celdas y la ruta de cuatro PATH de ADR-0025.
- La conectividad global spawn-base corresponde a `PathGraph` de M4 y se valida sobre las celdas existentes más la pieza candidata antes de insertarla en `HexGrid`.
- El preview combina tablero confirmado y fantasma; verde indica colocación legal y rojo indica que la evaluación actual tiene errores. La UI solo confirma una evaluación legal.

## Consecuencias

- Pueden coexistir adyacencias visuales entre dos celdas PATH sin conexión lógica cuando ninguno ofrezca un borde exacto ni flexible. Esto mantiene explícita la topología.
- La legalidad local de `TerrainPlacementValidator` no basta para confirmar una pieza: `Main` exige que el snapshot `PathGraph` resultante conserve rutas válidas hacia la base provisional.
- Las cinco piezas iniciales (`straight`, `gentle_turn`, `hard_turn`, `fork`, `convergence`) son composiciones y contenido provisionales, no decisiones de balance ni arte final.

## Fuentes

- `docs/fuente_de_verdad/02_IMPLEMENTATION_ROADMAP.md`, consultado el 2026-10-07.
- `docs/fuente_de_verdad/04_DATA_MODELS.md`, consultado el 2026-10-07.
- `docs/fuente_de_verdad/05_HEX_GRID_AND_TERRAIN.md`, consultado el 2026-10-07.
- Requerimiento explícito del usuario en esta conversación, 2026-10-07.
