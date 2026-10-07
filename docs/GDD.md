# Rogue Tower — documento de diseño del juego

Este GDD resume el juego y enlaza a las especificaciones de cada sistema. El nombre comercial sigue pendiente; «Rogue Tower» es el nombre de trabajo. Las reglas del sistema de terreno de [losetas isométricas](diseno/rogue-tower/sistemas/sistema-losetas-isometricas.md) tienen prioridad sobre las decisiones históricas de terreno que siguen marcadas como sustituidas.

## Resumen

Roguelite de defensa de torres: el jugador amplía el mapa con chunks de terreno, decide por dónde avanzan los enemigos y prepara defensas entre oleadas. El baseline de gameplay es *Rogue Tower*, con las adaptaciones propias registradas en ADRs. Se desarrolla para Godot 4.7 como juego 2D isométrico con proyección fija 2:1.

## Bucle de partida

1. Durante la preparación se ofrece una loseta, se valida una posición legal y se amplía el mapa.
2. El jugador construye o mejora defensas, administra oro/maná e inicia la oleada.
3. Los enemigos siguen rutas calculadas por los datos lógicos del camino; las defensas actúan automáticamente.
4. Al concluir, se liquidan recompensas y elecciones de mejora antes de la preparación siguiente.

La campaña objetivo tiene veinte rondas; los mini-jefes aparecen en 5, 10 y 15, y el jefe final en 20. La duración objetivo es de 30–45 minutos.

## Mapa, chunks y terreno

La autoridad completa para creación, composición, conectividad, reglas de terreno, construcción y presentación de chunks está en [Sistema de losetas isométricas](diseno/rogue-tower/sistemas/sistema-losetas-isometricas.md). Resumen vigente:

- El mapa es una cuadrícula de chunks; cada chunk contiene exactamente una cuadrícula de 3×3 celdas (`CHUNK_SIZE = 3`). No se apila un volumen de 3×3×3 celdas.
- Cada celda tiene un tipo lógico `PATH`, `GRASS` o `STONE`, una altura y los datos de construcción/ocupación que requiera el runtime. `PATH` es transitable y no construible; `GRASS` es construible a nivel 0; `STONE` es construible y tiene altura 1 con multiplicador inicial/configurable de alcance 1.15.
- El terreno lógico es la fuente de verdad. `TileMapLayer` y las variantes PNG solo dibujan ese estado; cambiar o sustituir arte no modifica caminos ni reglas.
- `ChunkDefinition` es un recurso de datos con nueve celdas y puertos cardinales Norte/Este/Sur/Oeste. La colocación valida compatibilidad con todos los vecinos existentes y la legalidad de la ruta antes de confirmarse.
- La ruta y los conectores no se deducen de los píxeles. Variantes visuales se eligen de forma determinista usando semilla y coordenadas.
- La cuadrícula 3×3 de cada chunk aporta nueve posibles posiciones de construcción, sujetas al tipo de celda y su ocupación.

La referencia anterior de 27 posiciones CellTile, la torre de terreno en 3 alturas, la escena prefab como base de datos y las reglas antiguas de montaña/monasterio están sustituidas para la creación de terreno. Los patrones A–Y permanecen como referencia topológica/visual mientras se autoran definiciones propias.

## Construcción y economía

- Construir y mejorar solo está permitido durante preparación.
- Cada celda construible admite una ocupación; PATH no permite construir.
- STONE aplica su multiplicador configurable de alcance. El valor 1.15 es inicial y debe balancearse; no se suma la regla histórica de daño por niveles de montaña.
- Oro y maná son recursos distintos. XP persiste entre runs. Recompensas, costes y regeneración quedan por balancear.
- Torretas, edificios de apoyo, mejoras, efectos de estado, cartas, enemigos y jefes se desarrollan con un catálogo inicial compacto, conservando todas las familias de sistemas previstas para la beta.

## Enemigos y victoria

Los enemigos avanzan de forma determinista por PATH conectado. La propuesta inicial de balance favorece rutas cortas para unidades rápidas y largas para pesadas/jefes. La base empieza con 20 de integridad; un enemigo normal filtrado causa 1 de daño y un jefe filtrado es letal. Llegar a cero termina la run.

## Cartas y metaprogresión

Las elecciones de mejora entre oleadas y las recompensas de jefe toman como base el sistema de *Rogue Tower*. Frecuencia, pools, rarezas y calendario se adaptarán a veinte rondas. La progresión entre runs está confirmada; sus desbloqueos y ritmo siguen pendientes.

## Primera beta

La beta objetivo recorre veinte rondas e incluye chunks/rutas, construcción, oleadas, torres/mejoras, economía, cartas, edificios de apoyo, efectos de estado, jefes y metaprogresión. Se reducirá el catálogo inicial, no se eliminará una familia entera.

## Interfaz y lectura del tablero

El tablero es el foco visual. La UI debe distinguir celda enfocada, ocupada, construible y bloqueada; indicar tipo y altura; y explicar por qué una colocación de chunk o torre no es válida. Al rotar una definición se transforman juntos los datos de las celdas y sus puertos. Los chunks y torres se ordenan visualmente por profundidad según la configuración isométrica de Godot.

## Especificaciones relacionadas

- [Sistema de losetas isométricas](diseno/rogue-tower/sistemas/sistema-losetas-isometricas.md) — fuente de verdad del terreno.
- [ADR-0013](diseno/rogue-tower/decisiones/ADR-0013-sistema-de-losetas-isometricas.md) — decisión de arquitectura que adopta la especificación.
- [Plan de implementación](IMPLEMENTATION_PLAN.md) y [preguntas abiertas](OPEN_QUESTIONS.md).
