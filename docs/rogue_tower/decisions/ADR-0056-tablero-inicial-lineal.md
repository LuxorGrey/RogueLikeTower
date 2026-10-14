# ADR-0056 — Tablero inicial sencillo con camino recto

> La elevación plana de las seis celdas vecinas que se decidió originalmente quedó sustituida por ADR-0073. El trazado lineal, la ubicación de base y el mínimo de ruta de este ADR siguen vigentes.

- Estado: datos y código integrados; aceptación visual pendiente.
- Fecha: 2026-10-13.
- Contexto: el usuario pide simplificar el terreno inicial de la base y que las celdas PATH formen una línea recta. El tablero ya exige cuatro celdas PATH por ruta y tiene exactamente 19 hexágonos.

## Decisiones

1. Se conserva la huella axial de radio 2 (19 celdas) y el mínimo de cuatro celdas PATH por ruta.
2. La base pasa a `(-1,0)`. El camino queda en línea recta por `(-1,0) → (0,0) → (1,0) → (2,0)` y la salida de spawn se abre en `(3,0)`.
3. Las seis celdas vecinas de la base permanecen a elevación 0. El anillo se simplifica usando solo PATH y GRASS bajo; las elevaciones de montaña quedan fuera de la vecindad inmediata.
4. La rotación persistente de seis orientaciones se mantiene alrededor de la base; la recta y sus sockets PATH rotan juntos. Las piezas expansivas no cambian.

## Consecuencias y aceptación

- `data/terrain/starting_board.tres` define el cambio y `Main` sigue obteniendo la posición lógica de base desde `StartingBoardData`.
- La ubicación `(-1,0)` permite mantener 19 celdas y cuatro PATH en recta; con la base en el centro, el radio 2 solo permite tres celdas alineadas dentro del tablero.
- ADR-0025 queda parcialmente sustituido solo en la coordenada de base y la geometría inicial de la ruta. El tamaño del tablero y la longitud mínima siguen vigentes.
- La aceptación manual inicial M10 debía comprobar 19 celdas, anillo plano, ruta recta, endpoint y seis rotaciones. La regla del anillo plano fue retirada por ADR-0073; el criterio vigente acepta elevaciones Grass/Mountain aleatorias alrededor de la base.
- En el mismo cambio, el preview omite polígonos triangulares degenerados en las uniones de fachadas, y `Main` vuelve a asignar los cuatro cursores catalogados al puntero del sistema cuando no se usa el overlay de construcción. Los criterios manuales están en `10_ACCEPTANCE_TESTS.md`.
