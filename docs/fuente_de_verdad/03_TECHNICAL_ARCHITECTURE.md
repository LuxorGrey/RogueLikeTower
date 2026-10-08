# Technical Architecture — Godot 4.7

## Enfoque
**2D real con falsa elevación visual.** La elevación es un dato lógico (`0..2`), no una coordenada Z 3D.

Usar escenas para entidades y custom Resources para datos. Mantener los datos de contenido fuera de la lógica.

## Estructura propuesta

```text
res://
  autoload/
    game_state.gd
    run_manager.gd
    meta_progression.gd
    save_manager.gd
  core/
    hex/
      hex_coord.gd
      hex_math.gd
      hex_cell.gd
      hex_grid.gd
    modifiers/
      modifier.gd
      modifier_stack.gd
  data/
    terrain/
    towers/
    enemies/
    run/
      run_economy_data.gd
      run_economy_m9.tres
    status_effects/
    waves/
    cards/
    upgrades/
  game/
    main/
      main.tscn
      main.gd
    board/
      board.tscn
      board.gd
      terrain_renderer.gd
      terrain_piece_preview.gd
      path_graph.gd
    combat/
      damage_service.gd
      status_effect_controller.gd
    enemies/
      enemy.tscn
      enemy.gd
    towers/
      tower.tscn
      tower.gd
      projectile.tscn
      projectile.gd
    waves/
      wave_director.gd
    economy/
      run_economy_service.gd
    build/
      build_controller.gd
    cards/
      card_system.gd
    ui/
      hud.tscn
      terrain_choice.tscn
      card_offer.tscn
      shop.tscn
      run_end.tscn
  assets/
    terrain/
    towers/
    enemies/
    ui/
  tests/
  docs/
```

## Main scene
```text
Main (Node2D)
├── Board
│   ├── TerrainBack
│   ├── TerrainTop
│   ├── TerrainCliffs
│   ├── Decorations
│   ├── Entities (Y-sort)
│   │   ├── GameBase
│   │   ├── Tower instances (M6)
│   │   └── Enemy instances
│   ├── Projectiles
│   └── Effects
├── WaveDirector
├── BuildController
├── DamageService (escena-local; inyectado a las torres)
├── RunEconomyService (escena-local; oro/maná de esta run)
├── Camera2D
└── CanvasLayer
    └── HUD
```

## Estado de la run
`RunManager` controla una máquina de estados:

```text
RUN_SETUP
ROUND_PREP
COMBAT
ROUND_REWARD
TERRAIN_EXPANSION
CARD_OFFER
ROUND_TRANSITION
RUN_VICTORY
RUN_DEFEAT
```

Las UI reaccionan al estado. No permitir construcción/colocación cuando el estado no corresponda.

## Comunicación
Preferir señales para eventos:
- `round_started(round)`
- `round_completed(round)`
- `enemy_killed(enemy, reward)`
- `base_damaged(amount)`
- `terrain_piece_placed(piece)`
- `paths_changed()`
- `tower_built(tower)`
- `card_selected(card)`
- `run_ended(result)`

Evitar dependencias circulares.

## Datos
Custom Resources:
- TerrainPieceData
- TowerData
- EnemyData
- WaveData
- CardData
- PermanentUpgradeData
- StatusEffectData

Esto permite editar contenido desde Inspector sin cambiar scripts.

## Pathfinding
El mapa es discreto. No usar NavigationRegion2D como fuente primaria para el camino de enemigos. Mantener un **grafo lógico de celdas Path** y resolver rutas en ese grafo. Es más determinista para bifurcaciones, convergencias y colocación dinámica.

M4 implementa `PathGraph` como `RefCounted` y usa BFS propio porque todos los enlaces actuales tienen coste uniforme. Cada nodo representa el `HexCoord` axial de una celda PATH; una arista exige sockets complementarios recíprocos en `path_edges | flexible_path_edges`. Un socket flexible sin pareja no crea una arista. Las salidas exactas abiertas fuera del tablero son candidatos de spawn, mientras que la coordenada de base actual `(0,0)` es provisional. `PathGraph` produce una `PathRoute` determinista por candidato y preserva las bifurcaciones/convergencias en su adyacencia; no activa oleadas ni selecciona los spawns activos.

La escena reconstruye el snapshot del grafo al iniciar y al confirmar una pieza; no lo recalcula al mover el cursor ni por frame. Antes de insertar la pieza se valida el grafo candidato para impedir una base ausente, salidas sin pareja, spawns sin retorno o nodos PATH aislados. El overlay debug lo dibuja `TerrainPiecePreview` al pulsar `D`; el grafo sigue siendo la autoridad lógica y el preview solo lo representa. La decisión y las provisionalidades están en [ADR-0007](../decisiones/ADR-0007-grafo-logico-de-caminos.md).

AStar2D podría sustituir BFS si las rutas adquieren costes diferentes; si se usa, los IDs deben representar HexCoord. No incorporar NavigationRegion2D al modelo lógico.

## Rendering
No hacer que la lógica dependa de TileMapLayer. `HexGrid` es la autoridad.

TileMapLayer puede utilizarse como renderer/optimización más adelante, pero para el vertical slice es válido renderizar cada celda mediante nodos/sprites si facilita cliffs y elevación. Mantener una interfaz de renderer para poder optimizar sin reescribir gameplay.

El preview M2 actual dibuja polígonos vectoriales temporales desde `TerrainPieceCellData`: aplica offset por elevación, genera caras laterales en desniveles, ordena las caras superiores por profundidad lógica y detecta hover sobre esas caras. No depende de sprites finales. La escena principal incluye un contenedor `Entities` con Y-sort habilitado para actores.

En M3, `HexGrid` es autoridad para las celdas confirmadas; `TerrainPlacementValidator` es un `RefCounted` puro que evalúa la candidata y devuelve `TerrainPlacementResult`; `Main` orquesta selección/confirmación y `TerrainPiecePreview` dibuja tablero y ghost, sin cambiar la autoridad lógica. Las conexiones internas usan los bordes PATH explícitos; las conexiones entre piezas también aceptan las aperturas laterales flexibles derivadas en cada salida de borde, según [ADR-0006](../decisiones/ADR-0006-sockets-laterales-flexibles-de-camino.md). M4 ya incorpora la conectividad global mediante el snapshot `PathGraph` descrito arriba.

La navegación del mapa la controla un `Camera2D` en `Main`: el HUD vive en `CanvasLayer` y no se desplaza ni escala con la cámara. Mover la cámara mantiene el mapa dentro del mundo lógico; el zoom con rueda se centra en el cursor.

M5 añade `GameBase` y `WaveDirector` a la escena principal. `GameBase` posee un `HealthComponent`; `Enemy` compone su propio `HealthComponent` y `PathFollowerComponent`. `WaveDirector` recibe la oleada, el snapshot M4, la base y el contenedor Y-sort; crea enemigos desde sus Resources y escucha sus señales de llegada o muerte. La UI de `Main` presenta vida, recuento y estado, y traduce las señales de oleada a fases de `RunManager`. Durante `COMBAT` se bloquean las entradas de colocación de terreno.

M6 añade `BuildController` a `Main`; recibe el `HexGrid`, `Entities`, el origen y el radio del mapa. El controlador valida fase, terreno construible y ocupación antes de instanciar una escena desde `TowerData`, y registra la torre en `HexCell.occupied/tower_id`. Solo Grass y Mountain permiten construir, así que las torres no cambian `PathGraph`. `Tower` es una escena Y-sorted con datos, nivel, selección, prioridad de objetivo, alcance y cadencia; consulta los nodos del grupo `enemies` cada 0.1 s y usa `PathFollowerComponent.get_progress_ratio()` para first/last progress. Su placeholder vectorial dibuja pedestal, orientación, anillo de alcance al seleccionarlo y un flash hitscan al atacar. `TerrainPiecePreview` representa el marcador/rango de colocación. La UI de `Main` alterna build mode, muestra errores, cambia la prioridad y mejora la torre. En M6 las mejoras no tenían coste; M9 incorpora costes configurables. ADR-0009 recoge las reglas temporales.

M7 añade `DamageService` como hijo de `Main`, no como Autoload global. `BuildController` lo inyecta al configurar cada `Tower`, y cada disparo crea un `DamagePacket` con origen, tags y perfil desde `TowerData`. `DamageService.preview_damage()` calcula el resultado sin mutar al enemigo para el HUD; `apply_damage()` usa ese mismo cálculo, aplica daño y contrarregeneración y emite `damage_resolved`. `Enemy` mantiene su `HealthComponent`, regenera en `_process` con fracciones acumuladas y expone sus stats para targeting/debug. En M7 las respuestas de muerte seguían conectadas a las señales M5 y todavía no pagaban recompensa; M9 conecta ahora el evento al `RunEconomyService`. El HUD provisional de depuración conserva solo estado de base/oleada, torre seleccionada y daño estimado; la barra inferior vincula las torres de prueba a los atajos 1–3. La selección de oleada se libera en cada expansión para que la oleada básica y la diagnóstica puedan repetirse hasta que M10 defina la progresión real. `F3` muestra los controles y datos técnicos de terreno; `H` oculta el HUD entero. Los scripts M7 cargan packet/result por rutas `preload` y exponen interfaces base `RefCounted`/`Node` en las fronteras, evitando referencias de tipo a clases globales recién creadas antes de que Godot refresque su caché. Los payloads de status quedan reservados para M8. ADR-0010 fija el contrato y la fórmula provisional; ADR-0011 registra este HUD temporal y sus atajos.

M8 añade `StatusEffectData` como Resource y `StatusEffectController` como hijo de cada `Enemy`; los Resources de configuración se comparten como datos, pero stacks, duración restante, temporizador de tick y origen activo pertenecen a cada enemigo. `TowerData.status_effects` proporciona los payloads del impacto; `DamageService` aplica el daño directo y, si el objetivo sigue vivo, aplica los estados. El controlador combina modificadores de velocidad tomando el mínimo multiplicador activo, ejecuta ticks periódicos llamando al mismo `DamageService` (sin payloads recursivos) y limpia al expirar el estado, morir el enemigo o llegar a la base. La instancia del servicio de combate continúa siendo local a `Main` e inyectada al enemigo por `WaveDirector`. Los tres Resources Slow/Burn/Bleed, el dummy, la torre y la oleada M8 son fixtures provisionales. La barra de prueba amplía los atajos a `1–4`; el panel compacto informa los estados y sus temporizadores en el objetivo de la torre seleccionada. Las reglas de acumulación y propiedad del tick están registradas en ADR-0012.

M9 añade `RunEconomyService` como nodo local de `Main`, configurado desde `RunEconomyData`; conserva oro y maná de la run sin mezclar la moneda meta. `BuildController` recibe el servicio y aplica compras atómicas de torres/mejoras con costes de `TowerData`. Cada `Tower` recibe la misma instancia: antes de un impacto con coste de maná intenta gastar el recurso y no dispara si el saldo no alcanza. El servicio regenera maná durante la run, acotado por su capacidad, y emite señales de saldo; el HUD refleja oro, maná, regeneración, costes de atajos y coste de mejora. `WaveDirector` guarda la recompensa de cada instancia enemiga, la paga una vez al derrotarla y descarta el pago al llegar a base; entrega la recompensa de ronda solo al limpiar todos los grupos. `Main` pasa brevemente a `ROUND_REWARD` antes de permitir la siguiente oleada. La remuneración por baja ya emitida se conserva aunque otro enemigo haga fallar esa oleada; no se paga el bonus de ronda fallida. Los valores de M9 son fixtures provisionales. ADR-0013 registra el contrato y las provisionalidades.

## Save
Guardar solo datos estables:
- versión de save;
- moneda meta;
- IDs desbloqueados;
- niveles de permanentes;
- settings.

No serializar nodos/Resources completos.

## Determinismo
La run debe tener `run_seed`.
Toda selección aleatoria importante debe derivar de un RNG de run para poder reproducir bugs.
