# Project Progress

## Estado
Última actualización: 2026-10-08

| Milestone | Estado | Notas |
|---|---|---|
| M0 Bootstrap | Implementado; arranque verificado | Configuración limpia, escena principal, autoloads mínimos, pantalla debug y `.gitignore` presentes. |
| M1 Hex Grid | Implementado; arranque verificado | Coordenadas axiales, seis vecinos, conversión pointy-top, rotación, distancia, diccionario de celdas y selección debug añadidos. |
| M2 Terrain Rendering | Implementado; corrección de cliffs pendiente de verificación | Preview PATH/GRASS/MOUNTAIN con alturas, caras laterales, orden por profundidad, hover por terreno, coordenada axial en HUD y contenedor de entidades con Y-sort. Se corrigieron caras laterales degeneradas por proyección; falta comprobar el renderer en Godot. |
| M3 7-Hex Pieces | Implementación en código; interacción por revisar | Cinco Resources de 7 hexes, rotación no destructiva a seis orientaciones, sockets explícitos con aperturas laterales flexibles, validador de solapamiento/adyacencia y conexión compatible, tablero persistente, ghost legal/ilegal, selección, hover global, confirmación/cancelación. Sockets y colocación aún necesitan inspección en Godot. |
| M4 Path Graph | Implementado; 7 escenarios smoke correctos | `PathGraph` axial con sockets exactos/flexibles complementarios, endpoints spawn/base, BFS de coste unitario determinista, rutas mínimas cacheadas por spawn, bifurcaciones, rechazo de subredes/salidas sin ruta, recalculo solo al iniciar y confirmar pieza, overlay `D`. La escena principal y `tests/path_graph_smoke.tscn` cargan en Godot 4.7; las siete pruebas lógicas pasan. Falta inspección visual manual del overlay. Provisionalidades en ADR-0007. |
| M5 Enemy + Base | Implementado; smoke de oleada correcto | Base con vida, `Enemy` data-driven, movimiento sobre `PathRoute`, `WaveDirector`, daño por llegada, derrota y fases `COMBAT`/`RUN_DEFEAT`/`TERRAIN_EXPANSION`. La primera oleada configurable completa sus spawns y termina con base en 20/50 HP. Falta revisar visualmente la integración en ventana. Valores/política provisionales en ADR-0008. |
| M6 Towers | Implementación; smoke correcto; aceptación manual pendiente | `TowerData`/Basic Bolt, `BuildController`, colocación sobre Grass/Mountain, selección de prioridad, rango/cadencia, hitscan, mejoras hasta nivel 3 y UI de preview/selección implementados. `tests/m6_tower_smoke.tscn` valida fases, construcción, rechazo, upgrades, altura, prioridades, rango, cooldown/cadencia, daño y descarte seguro de objetivos eliminados. Falta seguir la prueba manual M6 de `10_ACCEPTANCE_TESTS.md` para confirmar lectura visual y clics en ventana. Provisionalidades en ADR-0009. |
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
- M4 deriva una ruta mínima en BFS por cada salida exacta externa abierta y conserva la topología de ramas en el grafo. M5 activa el primer candidato en orden determinista solo para la muestra; base `(0,0)` sigue como anclaje provisional.
- M5 usa una base de 50 HP, enemigos con 20 HP, velocidad 90 px/s y 10 de daño de llegada, tres enemigos con 1 s de separación y selección `FIRST_SORTED`. Son valores de prueba configurables, no balance final; están registrados en ADR-0008.
- M6 añade Basic Bolt con 10 de daño, 1 ataque/s, rango base 3 hexes, mejoras +5 daño/+0.25 hex hasta nivel 3 y alcance +0.25 hex por nivel de elevación. Son cifras provisionales configurables, no balance final. Las mejoras son gratis hasta M9 y el ataque usa daño directo hasta M7; ADR-0009 registra el límite.

## Bugs/deuda conocida
- Falta comprobar manualmente con el puntero los colores y coordenadas del hover, además de la rotación. `run_project` confirmó que Godot 4.7 inicia la escena sin errores, pero no automatizó el movimiento del puntero.
- El usuario ejecutó M3 y reportó un error de triangulación en `_draw_cliffs()`. El código ahora añade grosor visual a las caras que colapsan en proyección y divide cada cara en dos triángulos; la escena no se ha vuelto a ejecutar tras el cambio.
- Las aperturas laterales flexibles de PATH, sus encajes por rotación y la colocación válida/ilegal aún requieren inspección visual e interacción en Godot. También falta revisar cancelación, cámara y continuidad fuera del área inicial.

## Última verificación
- Godot 4.7 ejecutó `tests/path_graph_smoke.tscn`: pasan siete escenarios M4 (ruta inicial, pareja exacta/flexible, flexible que no crea spawn, salida inválida hacia GRASS, socket exacto sin pareja, PATH desconectado y bifurcación/convergencia con BFS determinista).
- Godot 4.7 ejecutó `tests/m5_wave_smoke.tscn`: ruta M4, muerte de enemigo, derrota de base y oleada completa correctos; la base queda en 20/50 HP y no hay enemigos activos.
- Godot 4.7 ejecutó `tests/m6_tower_smoke.tscn`: fases `RUN_SETUP`/prep/combat/expansión/derrota; construcción en Grass/Mountain; rechazo de PATH/ocupado; ocupación axial; mejoras y límite; bonus de elevación; prioridades first/last/highest health/highest armor; filtro de rango, cadencia, daño hitscan y descarte seguro de una referencia tras liberar el objetivo.
- Godot 4.7 arrancó `game/main/main.tscn` durante tres frames headless sin errores de escena ni GDScript. El host reportó que no pudo leer su almacén de certificados raíz, sin afectar el arranque o smoke.
- Los smokes M5/M6 pasan usando `--log-file` dentro del workspace. Sin esa opción, este host intentó escribir en un `user://logs` no disponible y Godot falló antes de imprimir el resultado; no es un fallo reproducible con la ruta de log explícita.
- `game/main/main.tscn` arranca sin errores de carga ni de GDScript en ejecución headless. El host imprime un error al leer su almacén de certificados raíz; no afecta al código del proyecto ni al resultado de las pruebas.
- Las pruebas no sustituyen la inspección visual con ratón: quedan por revisar el hover/cliffs, rotación/colocación y overlay `D` en ventana Godot.

## Próximo paso
Seguir la prueba manual M6 de `10_ACCEPTANCE_TESTS.md` en una ventana de Godot: feedback rojo/verde de construcción, selección y anillo de alcance, HUD de prioridad/mejora y disparos durante la oleada. Cerrar M6 cuando esa inspección visual/interactiva pase; después avanzar a M7 (Damage model). Siguen pendientes las inspecciones visuales históricas de M2–M5 anotadas arriba. La gestión completa de rondas corresponde a M10.
