# ADR-0025 — Tablero inicial amplio y ruta mínima

- Estado: implementado en datos/código; aceptación visual pendiente.
- Fecha: 2026-10-08.
- Contexto: el usuario pide más terreno disponible al comenzar y que el camino de los enemigos hasta la base tenga al menos cuatro celdas PATH; la muestra previa tenía una única celda de camino antes de la base.

## Decisiones

1. La loseta de expansión sigue teniendo exactamente siete hexágonos. El tablero de partida es un concepto distinto: `StartingBoardData` configura una huella axial de radio 2, con 19 celdas conectadas, 15 construibles y 4 PATH.
2. La base permanece en `(0,0)`. El camino inicial sigue `(0,0) → (1,0) → (2,-1) → (2,-2)`; la salida de spawn abierta queda en la coordenada exterior `(3,-2)`. La ruta contiene cuatro celdas PATH, contando spawn y base.
3. `PathGraph.rebuild` acepta `minimum_spawn_route_cells`. `Main` lo configura como 4 para el tablero inicial y para validar cada expansión de campaña. Un endpoint con una ruta más corta se rechaza. Las llamadas genéricas/diagnósticas pueden usar el valor por defecto de una celda.
4. El resto de las celdas iniciales alterna Grass y Mountain y sigue siendo terreno construible. Su distribución es visual provisional; no crea caminos, bonificaciones ni restricciones de construcción adicionales.
5. La huella inicial completa rota alrededor de la celda de base en seis orientaciones axiales. Cada nueva run avanza un paso de 60° respecto a la anterior (contador persistente de runs módulo 6); coordenadas, sockets PATH exactos y sockets flexibles rotan juntos. La base conserva su coordenada `(0,0)`.

## Consecuencias y aceptación

- La configuración del tablero inicial vive en `data/terrain/starting_board.tres`; cada celda se instancia en `HexGrid`. El tamaño de las piezas de expansión no cambia.
- `docs/rogue_tower/design/05_HEX_GRID_AND_TERRAIN.md` y `project_spec.json` describen el tablero semilla y la ruta.
- Verificar la escena principal con la prueba manual M10: 19 celdas al iniciar, base completa en `(0,0)`, cuatro celdas PATH desde spawn hasta base, orientación inicial distinta por run y rechazo de cualquier expansión que genere un endpoint a menos de cuatro celdas PATH.
- Godot 4.7 headless verificó las seis rotaciones y que cada una conserva el grafo/ruta mínima; la inspección visual del tablero sigue pendiente.
