# ADR-0003: renderizado provisional de elevación

- Estado: Aceptada como implementación placeholder de M2.
- Fecha: 2026-10-07.

## Contexto

El diseño requiere terreno 2D con alturas lógicas 0/1/2, desplazamiento visual, caras laterales para desniveles y una cuadrícula que siga siendo la autoridad lógica. La implementación actual necesita mostrar esas diferencias antes de disponer del arte final.

## Decisión

- El preview dibuja la cara superior de cada hexágono en `posición_lógica - altura × 18 px`.
- En cada borde que enfrenta una celda más baja se genera una cara lateral sombreada mediante dos triángulos construidos desde la arista superior y el desplazamiento vertical del desnivel. Si ambos vectores se proyectan en la misma dirección y la cara colapsaría, se añade un grosor visual lateral mínimo. En el preview aislado, una celda ausente equivale a altura 0.
- Las caras laterales se dibujan antes de las caras superiores; estas últimas se ordenan por Y de base y X como desempate.
- El hover solo selecciona polígonos de caras superiores. PATH se ilumina `#82BFE6`, GRASS `#80E085` y MOUNTAIN `#F5C25C`; el HUD superior muestra la coordenada axial local `(q,r)`, terreno y altura.
- Se usan polígonos y colores de depuración, no sprites temporales importados. El offset de 18 px y el sombreado pueden cambiar al integrar renderer, cámara y arte final.
- La escena principal mantiene un contenedor `Entities` con `y_sort_enabled` para actores que se añadan al tablero.

## Consecuencias

- La elevación visual no modifica `HexCoord`, conectividad, selección lógica ni `TerrainPieceCellData.elevation`.
- El preview puede representar PATH/GRASS/MOUNTAIN y sus niveles antes de producir assets.
- Al colocar el cursor sobre acantilados o fuera de las caras superiores no se selecciona ninguna celda.
- El contenedor de entidades está preparado, aunque la escena actual todavía no contiene torres, enemigos ni decoración.

## Fuentes

- Paquete de diseño del usuario: `05_HEX_GRID_AND_TERRAIN.md`, consultado el 2026-10-07.
- Requerimiento del usuario de usar placeholders sustituibles por arte final, conversación actual, 2026-10-07.
