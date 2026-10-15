# Rogue Tower

Tower Defense roguelike de tablero hexagonal: el jugador amplía el terreno, construye la ruta y la defiende con torres reclutadas y mejoradas. El proyecto usa Godot 4.7, GDScript y terreno 2D con elevación visual.

## Documentación

Empieza en el [índice de documentación](docs/rogue_tower/README.md). La especificación activa, los contenidos y assets, el estado de implementación, el historial de decisiones y las propuestas están separados por autoridad, no duplicados en numerosos archivos.

## Ejecutar

Abre el proyecto con Godot 4.7 y ejecuta `game/main/main.tscn`. La demo aprobada tiene 45 rondas. Consulta el [diseño de campaña](docs/rogue_tower/CONTENT_AND_ASSETS.md#campaign) y el [estado de implementación](docs/rogue_tower/IMPLEMENTATION_AND_QA.md#progress).

## Controles de partida

- `P` o `Esc`: pausar/reanudar; el botón junto a Pausa cambia entre velocidad ×1, ×2 y ×3.
- `1–7`: seleccionar torres reclutadas, según el orden visible; `8`, `9` y `0` seleccionan perfiles de diagnóstico.
- `Q/E`: rotar la pieza de terreno; `T`: colocarla automáticamente en una posición válida.
- Rueda: zoom; `Ctrl` + rueda: rotar la pieza durante la colocación.
- Botón central + arrastre: desplazar el tablero; `R`: centrar la cámara; `H`: ocultar/mostrar el HUD.
- `Ctrl+D`: mostrar/ocultar el overlay de rutas. El antiguo panel de diagnóstico `F3` fue retirado.
