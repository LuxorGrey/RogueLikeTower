# ADR-0029: Previsualización de spawns durante la expansión

- Estado: Aceptada para implementación; revisión visual manual pendiente.
- Fecha: 2026-10-08.
- Contexto: los marcadores permanentes mostraban los endpoints activos, pero el jugador no podía anticipar qué salidas PATH permanecerían, se cerrarían o aparecerían al colocar una pieza de terreno.

## Decisiones

1. Mientras haya un ghost geométricamente válido, `Main` construye un `PathGraph` candidato a partir del tablero actual, la pieza transformada y los huecos encerrados que se rellenarían al confirmar. Este grafo es temporal: no muta `HexGrid` ni reemplaza el grafo activo.
2. El candidato debe pasar las mismas validaciones que se aplican al confirmar la pieza, incluidas continuidad a la base y longitud mínima de las rutas. Si el grafo candidato es inválido, la colocación no se muestra como válida y el botón de confirmar permanece deshabilitado.
3. `TerrainPiecePreview` compara endpoints identificados por hex PATH y dirección de borde. Los endpoints futuros se dibujan `NUEVO` (verde) o `SIGUE` (cian); los actuales que desaparecerían se marcan `CIERRA` con una X roja. La etiqueta de estado comunica cantidad actual/futura y altas/cierres.
4. El tipo de relleno de un hueco encerrado no afecta al grafo: preview y confirmación lo consideran no PATH; la elección Grass/Montaña aleatoria sucede al confirmar y conserva exactamente los endpoints candidatos.
5. El snapshot activo y los spawns reales solo cambian después de confirmar la pieza. Las oleadas continúan usando el `PathGraph` confirmado.

## Consecuencias y aceptación

- El jugador ve el resultado de la expansión antes de colocar la pieza y puede cambiar su posición o rotación sin alterar el tablero.
- La aceptación manual debe verificar marcadores nuevos, conservados y cerrados, recuento actualizado, rechazo de grafos inválidos y coincidencia con los spawns tras confirmar. El procedimiento está en `10_ACCEPTANCE_TESTS.md`, apartado M10.
- Los colores y etiquetas son feedback visual; no modifican selección de rutas ni balance.

## Referencias

- [ADR-0007: grafo lógico de caminos](ADR-0007-grafo-logico-de-caminos.md).
- [ADR-0017: oferta de terreno y cierre de huecos](ADR-0017-oferta-de-terreno-y-cierre-de-huecos.md).
- [Roadmap M10](../design/02_IMPLEMENTATION_ROADMAP.md).
- [Pruebas de aceptación](../design/10_ACCEPTANCE_TESTS.md).
