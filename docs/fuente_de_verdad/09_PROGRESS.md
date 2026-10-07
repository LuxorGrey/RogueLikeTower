# Project Progress

## Estado
Última actualización: 2026-10-07

| Milestone | Estado | Notas |
|---|---|---|
| M0 Bootstrap | Implementado; arranque verificado | Configuración limpia, escena principal, autoloads mínimos, pantalla debug y `.gitignore` presentes. |
| M1 Hex Grid | Implementado; arranque verificado | Coordenadas axiales, seis vecinos, conversión pointy-top, rotación, distancia, diccionario de celdas y selección debug añadidos. |
| M2 Terrain Rendering | Implementado; corrección de cliffs pendiente de verificación | Preview PATH/GRASS/MOUNTAIN con alturas, caras laterales, orden por profundidad, hover por terreno, coordenada axial en HUD y contenedor de entidades con Y-sort. Se corrigieron caras laterales degeneradas por proyección; falta comprobar el renderer en Godot. |
| M3 7-Hex Pieces | Implementación en código; interacción por revisar | Cinco Resources de 7 hexes, rotación no destructiva a seis orientaciones, sockets explícitos con aperturas laterales flexibles, validador de solapamiento/adyacencia y conexión compatible, tablero persistente, ghost legal/ilegal, selección, hover global, confirmación/cancelación. La ruta global spawn-base permanece en M4; sockets y colocación necesitan inspección en Godot. |
| M4 Path Graph | TODO | |
| M5 Enemy + Base | TODO | |
| M6 Towers | TODO | |
| M7 Damage Model | TODO | |
| M8 Status Effects | TODO | |
| M9 Economy + Mana | TODO | |
| M10 Rounds 1-20 | TODO | |
| M11 Cards | TODO | |
| M12 Meta Progression | TODO | |
| M13 UX/UI | TODO | |
| M14 Vertical Slice | TODO | |
| M15 Art Pipeline | TODO | |
| M16 Polish | TODO | |

## Decisiones provisionales introducidas durante desarrollo
- M1 usa orientación pointy-top y radio visual de 38 px para el tablero debug. La orientación está registrada como provisional en `docs/decisiones/ADR-0001-cuadricula-axial-pointy-top.md`.
- La muestra M3 colorea 2 hexágonos PATH, 3 GRASS y 2 MOUNTAIN; es una composición visual provisional editable en `data/terrain/starting_terrain_piece.tres`. El preview usa radio de 52 px por hexágono.
- El preview M2 usa polígonos vectoriales de placeholder, sin sprites importados; cada nivel se eleva 18 px y los bordes enfrentados a terreno más bajo reciben una cara sombreada.
- El hover solo selecciona caras superiores; cambia a un color específico del terreno y el HUD presenta `(q,r)`, el tipo y la altura de la casilla.
- M3 define las cinco piezas `straight`, `gentle_turn`, `hard_turn`, `fork` y `convergence` como contenido visual provisional. `weight`/`tags` quedan reservados para el pool futuro y no alteran la selección en esta fase.
- Las conexiones PATH internas son sockets recíprocos exactos; los sockets de borde derivan aperturas laterales flexibles descritas en [ADR-0006](../decisiones/ADR-0006-sockets-laterales-flexibles-de-camino.md). Una pieza expansiva exige al menos un enlace compatible con PATH existente. El tablero inicial expone una salida abierta hacia `(0,-2)`.
- M3 dibuja el tablero con el renderer vectorial temporal y el ghost sobre las celdas confirmadas; confirmar añade siete `HexCell` de forma atómica y cierra el modo de colocación.
- La navegación M3 usa `Camera2D`: botón central + arrastre panea, rueda hace zoom centrado en cursor, `H` oculta/muestra HUD y `R` centra el tablero. El HUD permanece en `CanvasLayer`.

## Bugs/deuda conocida
- Falta comprobar manualmente con el puntero los colores y coordenadas del hover, además de la rotación. `run_project` confirmó que Godot 4.7 inicia la escena sin errores, pero no automatizó el movimiento del puntero.
- El usuario ejecutó M3 y reportó un error de triangulación en `_draw_cliffs()`. El código ahora añade grosor visual a las caras que colapsan en proyección y divide cada cara en dos triángulos; la escena no se ha vuelto a ejecutar tras el cambio.
- Las aperturas laterales flexibles de PATH, sus encajes por rotación y la colocación válida/ilegal aún requieren inspección visual e interacción en Godot. También falta revisar cancelación, cámara y continuidad fuera del área inicial.

## Última verificación
El usuario reportó en Godot un fallo repetido de triangulación desde `TerrainPiecePreview._draw_cliffs()` (2026-10-08). La corrección y los sockets flexibles se editaron después; no hay ejecución de Godot posterior. `git diff --check` y la lectura de `project_spec.json` no reportan errores.

## Próximo paso
Abrir el proyecto en Godot 4.7 y revisar la carga de las piezas M3, hover, coordenadas, cliffs, sockets, rotaciones, legalidad, confirmación/cancelación y navegación de mapa. Corregir cualquier error de parser o interacción; luego M3 podrá cerrarse. Después continuar con M4 (grafo y rutas globales).
