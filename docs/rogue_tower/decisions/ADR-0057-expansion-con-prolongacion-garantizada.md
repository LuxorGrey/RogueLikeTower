# ADR-0057 — Oferta de expansión con prolongación garantizada

- Estado: código integrado; aceptación interactiva pendiente.
- Fecha: 2026-10-13.
- Contexto: una expansión podía cerrar spawns y dejar solo una salida abierta, mientras la siguiente oferta aleatoria contenía tres piezas sin una colocación legal para continuar PATH. El cambio responde a la petición de que siempre exista una opción de alargar el camino y que el cierre de un spawn se entienda antes de confirmar.

## Decisiones

1. La oferta de expansión incluye una pieza `ALARGA CAMINO` elegida mediante una búsqueda de las salidas alcanzables, las rotaciones de las piezas y las ubicaciones válidas. La posición preseleccionada conecta con una ruta existente y produce una ruta de spawn más larga.
2. La oferta comprueba que la colocación recomendada deja una nueva opción de prolongación. Al previsualizar una colocación de campaña, se bloquea la confirmación si el grafo resultante no tiene ninguna pieza y posición legal para extender una ruta; se repite la validación antes de mutar el tablero.
3. Durante la previsualización se conservan los portales activos que desaparecerían. Se muestran en rojo con una X, el hover advierte que se cerrarán al confirmar y el texto de colocación cuenta los cierres. Al salir de la previsualización, vuelven al estado del grafo activo.
4. El generador sigue ofreciendo tres piezas distintas. Las otras dos se eligen aleatoriamente entre las restantes del pool; la card de prolongación no reemplaza reglas de terreno, de sockets o del mínimo de ruta.

## Consecuencias y aceptación

- `Main` busca una colocación real que conecte una pieza a la coordenada exterior de un spawn y genera el grafo candidato incluyendo los huecos que se rellenarían.
- Tanto la previsualización como la confirmación deben conservar una siguiente prolongación legal. El bloqueo evita repetir el estado de bloqueo ilustrado por el usuario.
- `TerrainPiecePreview` mantiene los portales del grafo activo mientras evalúa el candidato y distingue cierres de endpoints nuevos/activos.
- La aceptación manual se añade a M10 en `10_ACCEPTANCE_TESTS.md`: card marcada y preseleccionada, crecimiento de ruta, cierre visible, cancelación y bloqueo de posiciones sin continuación legal.
- Esta regla de gameplay está confirmada por la petición explícita; queda pendiente comprobar la legibilidad y usabilidad en ventana Godot. No se ejecutaron pruebas en este cambio.

## Fuentes

- Solicitud del usuario y captura del estado bloqueado, recibidas el 2026-10-13.
- Reglas de grafo y expansión vigentes en [diseño de terreno](../design/05_HEX_GRID_AND_TERRAIN.md) y [diseño principal](../design/01_GAME_DESIGN_SOURCE_OF_TRUTH.md).

## ADR relacionados y sustituciones

- No sustituye decisiones previas. Complementa [ADR-0007](ADR-0007-grafo-logico-de-caminos.md), [ADR-0025](ADR-0025-tablero-inicial-y-ruta-minima.md) y [ADR-0056](ADR-0056-tablero-inicial-lineal.md) con una garantía de UX/colocación para las expansiones de campaña.
