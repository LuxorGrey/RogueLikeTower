# Project Progress

## Estado
Última actualización: 2026-10-07

| Milestone | Estado | Notas |
|---|---|---|
| M0 Bootstrap | Implementado; arranque verificado | Configuración limpia, escena principal, autoloads mínimos, pantalla debug y `.gitignore` presentes. |
| M1 Hex Grid | Implementado; arranque verificado | Coordenadas axiales, seis vecinos, conversión pointy-top, rotación, distancia, diccionario de celdas y selección debug añadidos. |
| M2 Terrain Rendering | Implementado; interacción visual pendiente de revisión manual | Preview PATH/GRASS/MOUNTAIN con alturas, cliffs, orden por profundidad, hover por terreno, coordenada axial en HUD y contenedor de entidades con Y-sort. Godot inicia sin errores. |
| M3 7-Hex Pieces | En progreso | Una plantilla Resource conectada de 7 celdas con huella central+6 vecinos, preview y seis orientaciones. Faltan colocación, overlap/adyacencia/conexiones, confirmación y el conjunto de piezas placeholder. |
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

## Bugs/deuda conocida
- Falta comprobar manualmente con el puntero los colores y coordenadas del hover, además de la rotación. `run_project` confirmó que Godot 4.7 inicia la escena sin errores, pero no automatizó el movimiento del puntero.

## Última verificación
Godot 4.7 abrió `game/main/main.tscn` en modo debug sin errores de carga o ejecución (2026-10-07). La inspección interactiva del hover queda pendiente.

## Próximo paso
Revisar visualmente hover, coordenadas, cliffs, orden de dibujo y rotaciones con el puntero en Godot. Después continuar M3 con validación y colocación de piezas.
