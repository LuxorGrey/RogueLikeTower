# ADR-0007: grafo lógico de caminos y rutas M4

- Estado: aceptada para la implementación M4; la coordenada de base sigue siendo provisional.
- Fecha: 2026-10-08.

## Contexto

M4 debe derivar conectividad desde las celdas PATH, distinguir la base de los posibles spawns, encontrar rutas reproducibles, conservar bifurcaciones/convergencias y recalcular al confirmar una expansión. El mapa es axial y discreto. ADR-0006 ya establece que una conexión entre piezas puede usar sockets PATH exactos y laterales flexibles complementarios, y que una oferta flexible sin pareja no confirma por sí sola un camino. El diseño deja la selección de spawns activos para el `WaveDirector`.

La documentación aún no sitúa la base en una coordenada. Para completar el grafo inicial sin convertir esa suposición en una regla de diseño, se necesita un anclaje temporal sobre el PATH de la loseta inicial.

## Decisión

- `PathGraph` mantiene un nodo por celda PATH y une dos nodos adyacentes solo cuando ambas caras ofrecen una conexión recíproca en la unión de `path_edges` y `flexible_path_edges`. Una salida exacta enfrentada a una celda existente sin oferta complementaria es un error; una flexible no emparejada permanece opcional.
- Una salida exacta que apunta fuera de todas las celdas del tablero crea un `PathEndpoint` candidato a spawn. Un socket exclusivamente flexible no crea un endpoint. Los candidatos se exponen; M4 no activa oleadas ni selecciona cuáles usa el `WaveDirector`.
- La coordenada de base provisional es el PATH axial `(0,0)`, centro de la pieza inicial. `Main` concentra esta configuración y la pasa al grafo. M5 instancia allí la escena `GameBase`, pero no confirma que esa coordenada sea la ubicación de diseño final; queda editable para una decisión futura.
- Cada spawn candidato obtiene una ruta mínima en número de enlaces mediante búsqueda en anchura (BFS). Los vecinos se recorren según el orden estable de las seis direcciones de `HexCoord`, por lo que los empates devuelven la misma ruta para el mismo grafo. No hay costes de terreno ni pesos de balance en M4.
- El grafo se reconstruye al iniciar la escena y al confirmar una pieza, nunca por frame ni al mover el ghost. La nueva pieza solo se confirma si el snapshot resultante tiene base PATH, al menos un candidato spawn y conectividad entre la base y todos los PATH/endpoints.
- El preview ofrece un overlay temporal de rutas, candidatos spawn y base con `D`; esta capa no es autoridad del tablero.

## Consecuencias

- Las bifurcaciones y convergencias permanecen en la adyacencia del grafo. El BFS elige una ruta determinista por endpoint para depuración y el movimiento M5; no elimina otras ramas. M5 configura la selección de endpoints en `WaveEnemyGroupData` (`FIRST_SORTED` o `ROUND_ROBIN`), y la selección definitiva por ronda queda abierta.
- `PathRoute` almacena la secuencia ordenada de coordenadas PATH de spawn a base. M5 consume esa secuencia en el enemigo para mantener sus waypoints, índice y progreso durante la oleada.
- Se rechazan snapshots con subredes PATH aisladas o extremos sin retorno a base; activar un subconjunto de candidatos sigue siendo responsabilidad del sistema de oleadas.
- La base `(0,0)`, el algoritmo sin pesos y la tecla `D` son decisiones técnicas/provisionales. El sistema de datos y APIs permiten cambiar la base y el control visual sin alterar las coordenadas del tablero.

## Referencias

- `docs/fuente_de_verdad/02_IMPLEMENTATION_ROADMAP.md`, alcance M4, consultado el 2026-10-08.
- `docs/fuente_de_verdad/03_TECHNICAL_ARCHITECTURE.md`, arquitectura de navegación lógica, consultado el 2026-10-08.
- `docs/fuente_de_verdad/04_DATA_MODELS.md`, modelos de mapa/oleadas, consultado el 2026-10-08.
- `docs/fuente_de_verdad/05_HEX_GRID_AND_TERRAIN.md`, sockets, endpoints y rutas, consultado el 2026-10-08.
- `docs/fuente_de_verdad/06_COMBAT_SYSTEM.md`, movimiento de enemigos por una ruta, consultado el 2026-10-08.
- `docs/decisiones/ADR-0006-sockets-laterales-flexibles-de-camino.md`, consultado el 2026-10-08.
- `.agents/skills/godot-master/references/navigation-pathfinding.md` y `resource-data-patterns.md`, consultados el 2026-10-08; la autoridad lógica hexagonal del proyecto prevalece sobre las APIs de navegación genérica.
