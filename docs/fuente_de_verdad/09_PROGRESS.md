# Project Progress

## Estado
Última actualización: 2026-10-07

| Milestone | Estado | Notas |
|---|---|---|
| M0 Bootstrap | Implementado; pendiente de ejecutar en Godot | Configuración limpia, escena principal, autoloads mínimos, pantalla debug y `.gitignore` presentes. |
| M1 Hex Grid | Implementado; pendiente de verificar | Coordenadas axiales, seis vecinos, conversión pointy-top, rotación, distancia, diccionario de celdas y selección debug añadidos. |
| M2 Terrain Rendering | En progreso | Preview debug con colores distintos para PATH, GRASS y MOUNTAIN. Faltan elevación visual, cliffs y orden Y. |
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

## Bugs/deuda conocida
- M0 y M1 aún no se han abierto en Godot 4.7; faltan la comprobación de arranque y la verificación de aceptación.

## Última verificación manual
No realizada en esta tarea.

## Próximo paso
Abrir `project.godot` en Godot 4.7, comprobar que la escena inicia y que ambos controles recorren las seis orientaciones. Luego completar M2 (elevación, cliffs y orden Y) antes de cerrar M3 con validación y colocación de piezas.
