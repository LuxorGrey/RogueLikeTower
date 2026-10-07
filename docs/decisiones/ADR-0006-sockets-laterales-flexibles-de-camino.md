# ADR-0006: sockets laterales flexibles de camino

- Estado: Aceptada para M3.
- Fecha: 2026-10-08.

## Contexto

La rotación de piezas de seis lados estaba limitada por exigir coincidencia exacta de las caras de salida marcadas en los hexágonos PATH. El usuario pidió que los caminos de borde se abran hacia los lados contiguos, como en la referencia visual adjunta, para dar más opciones al encajar piezas. También reportó avisos repetidos de triangulación al dibujar los cliffs.

## Decisión

- Los `.tres` mantienen `path_edges` como topología explícita. Las conexiones internas de una pieza siguen requiriendo dos bordes exactos recíprocos entre celdas PATH.
- Cuando un borde `path_edges` apunta fuera de la huella de la pieza, `TerrainPieceData` deriva en runtime hasta dos `flexible_path_edges`: las direcciones contiguas `d-1` y `d+1` que también quedan fuera de la huella. Las direcciones se limitan a las caras exteriores del hexágono y rotan con la pieza.
- En el límite entre piezas, la validación y el futuro `PathGraph` pueden unir caras complementarias cuando cada lado ofrece el borde exacto o flexible recíproco. Una conexión explícita sin pareja frente a una celda existente sigue siendo inválida; las ofertas flexibles que no se usan pueden quedar abiertas y no fuerzan camino sobre terreno GRASS o MOUNTAIN.
- La vista muestra los bordes explícitos con trazo principal y los laterales flexibles con trazo más tenue. La geometría real del camino y sus bifurcaciones proviene de las conexiones que se confirmen.
- Los cliffs se dibujan como dos triángulos a partir de los extremos de la arista superior y el desplazamiento vertical del desnivel. Si la proyección los deja colineales, se añade un grosor lateral mínimo. No se triangula un cuadrilátero reconstruido desde el hexágono vecino.
- La cuadrícula mantiene seis orientaciones a 60°; la flexibilidad de los sockets amplía los encajes sin cambiar coordenadas axiales.

## Consecuencias

- Piezas que solo difieren en el lado por el que alcanzan el borde pueden conectarse sin cambiar el contenido exacto de su ruta interna.
- `HexCell` conserva tanto `path_edges` como `flexible_path_edges`; el grafo M4 debe comprobar la unión de ambas máscaras en sentidos opuestos.
- Las aperturas laterales no son conexiones confirmadas por sí solas. La conexión aparece cuando se coloca una pieza PATH adyacente y ofrece una cara compatible.
- La geometría de cliffs no depende de la triangulación de un polígono de cuatro puntos; la inspección visual en Godot sigue pendiente.

## Fuentes

- Requerimiento del usuario y captura adjunta en esta conversación, 2026-10-08.
- `docs/fuente_de_verdad/05_HEX_GRID_AND_TERRAIN.md`, consultado el 2026-10-08.
- `docs/decisiones/ADR-0004-contrato-colocacion-terreno.md`, consultado el 2026-10-08.
