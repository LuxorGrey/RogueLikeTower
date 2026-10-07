# Glosario de Rogue Tower (nombre provisional)

| Término | Significado en el proyecto |
|---|---|
| Chunk | Unidad del mapa en `ChunkGrid`; contiene exactamente nueve celdas en una cuadrícula de 3×3. |
| `ChunkGrid` | Cuadrícula ortogonal que ubica los chunks del mundo. |
| `CellGrid` | Las nueve ubicaciones locales de terreno dentro de un chunk. |
| `CellData` | Estado lógico/runtime de una celda: coordenada, tipo, altura, reglas de paso/construcción y ocupación. |
| `ChunkDefinition` | Resource con ID, nueve definiciones de celda y puertos N/E/S/W. Es autoridad de datos, no una imagen ni prefab con lógica implícita. |
| Puerto | Conector de camino en el centro de un borde del chunk. Se valida contra el puerto opuesto de cada vecino. |
| `PATH` | Terreno transitable, no construible y de altura inicial 0; única clase que forma caminos de enemigos. |
| `GRASS` | Terreno construible si está libre, altura inicial 0. |
| `STONE` | Terreno construible si está libre, altura inicial 1 y multiplicador configurable de alcance (1.15 inicial). |
| `TileMapLayer` | Capa visual de Godot que dibuja el estado lógico. No es la base de datos ni decide reglas. |
| Variante visual | Textura que representa una celda. Se escoge determinísticamente por tipo, semilla y coordenada. |
| Celda construible | Celda GRASS o STONE libre; cada celda admite una ocupación. PATH está bloqueado para construir. |
| Proyección isométrica 2:1 | Presentación fija del juego. La geometría/retícula TileSet se separa de la semántica de terreno. |
| Preparación | Fase entre oleadas; permite colocar chunks y construir/mejorar según reglas del juego. |
| Enemigo filtrado | Enemigo que alcanza la base; el daño exacto depende de su tipo. |
| Rogue Tower | Juego de referencia principal para gameplay; las reglas adaptadas del proyecto se registran por separado. |
| Primera beta | Objetivo de veinte rondas con todas las familias de sistemas y un catálogo inicial compacto. |

La definición canónica del terreno está en [Sistema de losetas isométricas](sistemas/sistema-losetas-isometricas.md). Las decisiones previas de volumen CellTile 3×3×3, `path_variant_1`, terrenos dirt y escenas prefab se consideran históricas/sustituidas.
