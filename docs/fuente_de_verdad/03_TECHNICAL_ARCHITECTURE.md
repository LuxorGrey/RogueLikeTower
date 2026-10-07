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
│   │   ├── Towers
│   │   └── Enemies
│   ├── Projectiles
│   └── Effects
├── WaveDirector
├── BuildController
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

AStar2D puede usarse como implementación interna, pero los IDs representan HexCoord.

## Rendering
No hacer que la lógica dependa de TileMapLayer. `HexGrid` es la autoridad.

TileMapLayer puede utilizarse como renderer/optimización más adelante, pero para el vertical slice es válido renderizar cada celda mediante nodos/sprites si facilita cliffs y elevación. Mantener una interfaz de renderer para poder optimizar sin reescribir gameplay.

El preview M2 actual dibuja polígonos vectoriales temporales desde `TerrainPieceCellData`: aplica offset por elevación, genera caras laterales en desniveles, ordena las caras superiores por profundidad lógica y detecta hover sobre esas caras. No depende de sprites finales. La escena principal incluye un contenedor `Entities` con Y-sort habilitado para actores.

En M3, `HexGrid` es autoridad para las celdas confirmadas; `TerrainPlacementValidator` es un `RefCounted` puro que evalúa la candidata y devuelve `TerrainPlacementResult`; `Main` orquesta selección/confirmación y `TerrainPiecePreview` dibuja tablero y ghost, sin cambiar la autoridad lógica. Las conexiones internas usan los bordes PATH explícitos; las conexiones entre piezas también aceptan las aperturas laterales flexibles derivadas en cada salida de borde, según [ADR-0006](../decisiones/ADR-0006-sockets-laterales-flexibles-de-camino.md). `PathGraph` debe tratar ambas máscaras como ofertas de conexión y solo unir caras PATH complementarias; la conectividad global se incorpora en M4.

La navegación del mapa la controla un `Camera2D` en `Main`: el HUD vive en `CanvasLayer` y no se desplaza ni escala con la cámara. Mover la cámara mantiene el mapa dentro del mundo lógico; el zoom con rueda se centra en el cursor.

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
