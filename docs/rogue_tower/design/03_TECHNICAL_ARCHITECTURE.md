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
    base/
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
├── RunEconomyService (escena-local; Gold/Mana de esta run)
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

La escena conserva el snapshot activo del grafo al iniciar y al confirmar una pieza. Mientras se mueve un ghost geométricamente válido, `Main` crea un snapshot candidato separado que incluye los futuros hexes y los huecos que se cerrarían; `TerrainPiecePreview` lo compara con el grafo activo para marcar spawns que continúan, aparecen o se cierran. Esta vista previa no muta el tablero ni reemplaza el grafo activo. El botón de confirmar requiere que el candidato pase la misma validación de base, salidas emparejadas, rutas de spawn y conectividad PATH. El overlay debug de rutas lo dibuja `TerrainPiecePreview` al pulsar `D`; el grafo sigue siendo la autoridad lógica y el preview solo lo representa. La decisión base está en [ADR-0007](../decisions/ADR-0007-grafo-logico-de-caminos.md) y la vista previa de spawn en [ADR-0029](../decisions/ADR-0029-previsualizacion-de-spawns-en-expansion.md).

AStar2D podría sustituir BFS si las rutas adquieren costes diferentes; si se usa, los IDs deben representar HexCoord. No incorporar NavigationRegion2D al modelo lógico.

## Rendering
No hacer que la lógica dependa de TileMapLayer. `HexGrid` es la autoridad.

TileMapLayer puede utilizarse como renderer/optimización más adelante, pero para el vertical slice es válido renderizar cada celda mediante nodos/sprites si facilita cliffs y elevación. Mantener una interfaz de renderer para poder optimizar sin reescribir gameplay.

El preview M2 actual dibuja polígonos vectoriales temporales desde `TerrainPieceCellData`: aplica offset por elevación, genera caras laterales en desniveles, ordena las caras superiores por profundidad lógica y detecta hover sobre esas caras. No depende de sprites finales. Las caras no dibujan iniciales ni coordenadas; el hover comunica tipo/altura/coordenada axial al HUD y cambia el color según terreno. Los clusters conectados de Grass/Mountain reciben feedback luminoso de combo 3/5 solo visual. La escena principal incluye un contenedor `Entities` con Y-sort habilitado para actores.

En M3, `HexGrid` es autoridad para las celdas confirmadas; `TerrainPlacementValidator` es un `RefCounted` puro que evalúa la candidata y devuelve `TerrainPlacementResult`; `Main` orquesta selección/confirmación y `TerrainPiecePreview` dibuja tablero y ghost, sin cambiar la autoridad lógica. Las conexiones internas usan los bordes PATH explícitos; las conexiones entre piezas también aceptan las aperturas laterales flexibles derivadas en cada salida de borde, según [ADR-0006](../decisions/ADR-0006-sockets-laterales-flexibles-de-camino.md). M4 ya incorpora la conectividad global mediante el snapshot `PathGraph` descrito arriba.

La navegación del mapa la controla un `Camera2D` en `Main`: el HUD vive en `CanvasLayer` y no se desplaza ni escala con la cámara. Mover la cámara mantiene el mapa dentro del mundo lógico; el zoom con rueda se centra en el cursor.

M5 añade `GameBase` y `WaveDirector` a la escena principal. `GameBase` posee un `HealthComponent` y dibuja una huella hexagonal completa del mismo radio que una celda; `Enemy` compone su propio `HealthComponent` y `PathFollowerComponent`. `WaveDirector` recibe la oleada, el snapshot M4, la base y el contenedor Y-sort; crea enemigos desde sus Resources y escucha sus señales de llegada o muerte. La UI de `Main` presenta Health, recuento y estado, y traduce las señales de oleada a fases de `RunManager`. Durante `COMBAT` se bloquean las entradas de colocación de terreno. El tablero semilla de campaña usa `StartingBoardData` con radio axial 2 (19 celdas) y configuración de camino mínima de cuatro celdas PATH por spawn; el grafo vuelve a aplicar ese límite tras cada expansión. Al iniciar cada run, el tablero entero y sus sockets PATH rotan un paso de 60°; el contador persistente avanza por seis orientaciones sin cambiar la coordenada de la base.

M6 añade `BuildController` a `Main`; recibe el `HexGrid`, `Entities`, el origen y el radio del mapa. El controlador valida fase, terreno construible y ocupación antes de instanciar una escena desde `TowerData`, y registra la torre en `HexCell.occupied/tower_id`. Solo Grass y Mountain permiten construir, así que las torres no cambian `PathGraph`. `Tower` es una escena Y-sorted con datos, nivel, selección, prioridad de objetivo, alcance y cadencia; consulta los nodos del grupo `enemies` cada 0.1 s y usa `PathFollowerComponent.get_progress_ratio()` para first/last progress. Su placeholder vectorial dibuja pedestal, orientación, anillo de alcance al seleccionarlo y un flash hitscan al atacar. `TerrainPiecePreview` representa el marcador/rango de colocación. La UI de `Main` alterna build mode, muestra errores, cambia la prioridad y mejora la torre. En M6 las mejoras no tenían coste; M9 incorpora costes configurables. ADR-0009 recoge las reglas temporales.

M7 añade `DamageService` como hijo de `Main`, no como Autoload global. `BuildController` lo inyecta al configurar cada `Tower`, y cada disparo crea un `DamagePacket` con origen, tags y perfil desde `TowerData`. `DamageService.preview_damage()` calcula el resultado sin mutar al enemigo para el HUD; `apply_damage()` usa ese mismo cálculo, aplica daño y contrarregeneración y emite `damage_resolved`. `Enemy` mantiene su `HealthComponent`, regenera en `_process` con fracciones acumuladas y expone sus stats para targeting/debug. En M7 las respuestas de muerte seguían conectadas a las señales M5 y todavía no pagaban recompensa; M9 conecta ahora el evento al `RunEconomyService`. El HUD provisional de depuración conserva solo estado de base/oleada, torre seleccionada y daño estimado; la barra inferior vincula las torres de prueba a los atajos 1–3. M10 conserva M7/M8 como fixtures `DEBUG` y separa esas pruebas del avance de campaña. `F3` muestra los controles y datos técnicos de terreno; `H` oculta el HUD entero. Los scripts M7 cargan packet/result por rutas `preload` y exponen interfaces base `RefCounted`/`Node` en las fronteras, evitando referencias de tipo a clases globales recién creadas antes de que Godot refresque su caché. Los payloads de status quedan reservados para M8. ADR-0010 fija el contrato y la fórmula provisional; ADR-0011 registra este HUD temporal y sus atajos.

M8 añade `StatusEffectData` como Resource y `StatusEffectController` como hijo de cada `Enemy`; los Resources de configuración se comparten como datos, pero stacks, duración restante, temporizador de tick y origen activo pertenecen a cada enemigo. `TowerData.status_effects` proporciona los payloads del impacto; `DamageService` aplica el daño directo y, si el objetivo sigue vivo, aplica los estados. El controlador combina modificadores de velocidad tomando el mínimo multiplicador activo, ejecuta ticks periódicos llamando al mismo `DamageService` (sin payloads recursivos) y limpia al expirar el estado, morir el enemigo o llegar a la base. La instancia del servicio de combate continúa siendo local a `Main` e inyectada al enemigo por `WaveDirector`. Los tres Resources Slow/Burn/Bleed, el dummy, la torre y la oleada M8 son fixtures provisionales. La barra de prueba amplía los atajos a `1–4`; el panel compacto informa los estados y sus temporizadores en el objetivo de la torre seleccionada. Las reglas de acumulación y propiedad del tick están registradas en ADR-0012.

M9 añade `RunEconomyService` como nodo local de `Main`, configurado desde `RunEconomyData`; conserva Gold y Mana de la run sin mezclar la moneda meta. `BuildController` recibe el servicio y aplica compras atómicas de torres/mejoras con costes de `TowerData`. Cada `Tower` recibe la misma instancia: antes de un impacto con coste de Mana intenta gastar el recurso y no dispara si el saldo no alcanza. El servicio regenera Mana durante la run, acotado por su capacidad, y emite señales de saldo; el HUD refleja Gold, Mana, regeneración, costes de atajos y coste de mejora. `WaveDirector` guarda la recompensa de cada instancia enemiga, la paga una vez al derrotarla y descarta el pago al llegar a base; entrega la recompensa de ronda solo al limpiar todos los grupos. `Main` pasa brevemente a `ROUND_REWARD` antes de permitir la siguiente oleada. La remuneración por baja ya emitida se conserva aunque otro enemigo haga fallar esa oleada; no se paga el bonus de ronda fallida. Los valores de M9 son fixtures provisionales. ADR-0013 registra el contrato y las provisionalidades.

M9.5, adelantado por petición del usuario antes de la progresión completa M10 y las cartas M11, introduce siete `TowerData`: Ballista, Mortar, Tesla Coil, Frost Keep, Flame Thrower, Poison Sprayer y Shredder. Las decisiones posteriores M12A/ADR-0023 amplían el modelo a Shield/Armor/Health y sustituyen la afirmación histórica de que Shield faltaba. Ballista usa un proyectil dirigido; Mortar un proyectil con explosión al aterrizar; Tesla alcanza todos los enemigos en su rango circular; Frost cubre un área cuadrada; Flame y Poison usan cono; Shredder recorre PATH, daña y añade Bleed mientras pierde daño base por enemigo. Todos pasan por `DamageService`. El roster principal tiene atajos `1–7`; los perfiles M7/M8 siguen en `8`, `9` y `0`. Las cifras de sus Resources parten de la tabla compartida por el usuario, son configurables y no representan balance final.

M10 carga y valida 45 WaveData ordenadas y un total fijo de 1.093 enemigos directos. WaveEnemyGroupData.count es la cantidad exacta por grupo; WaveDirector crea una unidad a la vez y la distribuye round-robin entre rutas alcanzables. Abrir varios endpoints no multiplica el total. El contador de spawns pendientes cubre el calendario directo; el contador de enemigos activos incluye invocaciones. Una transformación conserva la misma instancia activa y el pago de baja para que la ronda no se cierre hasta derrotar la fase final.

EnemyData contiene boss_tier y una lista tipada de EnemyAbilityData. WaveData deriva Standard, Boss o Tier 2 Boss del boss_tier presente; no asigna Miniboss a las rondas 17/19. WaveDirector ejecuta habilidades de aparición, proximidad, agotamiento de capas, muerte y temporizador, con radios configurables. Ooogie von Ooogovich (Haunted) usa un perfil propio provisional, invoca dos Bats cada 2 s y se transforma en Bat con 2.500 Health. Otros perfiles adoptan las habilidades individuales seleccionadas para el roster; las formas encadenadas de Ooogiehedron usan overrides de capas/speed sin mutar sus Resources base.

La campaña termina al limpiar la ronda 45 y solo expande el terreno después de limpiar las rondas 1–44. En cada victoria intermedia, TerrainPiecePreview conserva su comparación del grafo candidato; la siguiente ronda se habilita después de una colocación válida, y M11 puede intercalar su oferta de cartas. Los fixtures de diagnóstico M7/M8 se mantienen aislados de avance, pagos y daño a base. Las habilidades, los perfiles de enemigo y sus sprites se detallan en 13_CONTENT_ROSTER.md; la tabla exacta de cantidad/orden está en 14_CAMPANA_45_RONDAS.md. ADR-0037 sustituye el contrato de calendario y spawn de ADR-0016/0018 y las selecciones de contenido de ADR-0032/0033/0035/0036.
M11 añade `CardData`, `CardModifierOperation`, `CardPoolData` y `RunCardService`. El servicio es local a `Main`: recibe el pool y los IDs desbloqueados actuales, construye ofertas ponderadas sin duplicados y registra una carta elegida por oferta. En las rondas de carta, la oferta se abre después de colocar terreno y mantiene `CARD_OFFER` hasta la selección; luego habilita la siguiente ronda. Torres y economía consultan los modificadores agregados durante la run sin mutar los `.tres`. El calendario demo y los valores de cartas son provisionales; se detallan en [ADR-0021](../decisions/ADR-0021-cartas-de-mejora-de-run.md).

M12 extiende el Autoload `MetaProgression` para separar moneda/unlocks de `RunEconomyService` y mantenerlos entre escenas. `MetaProgressionData` contiene la fórmula provisional de recompensa y el catálogo de `PermanentUpgradeData`; cada nivel referencia una operación typed que aplica un bono de economía, daño global o unlock de contenido. `Main` configura el catálogo de torres, crea un seed por run y se lo pasa al RNG de ofertas M11 y al RNG local de terreno; al entrar en `RUN_VICTORY`/`RUN_DEFEAT`, registra el resultado una sola vez y abre `MetaShopPanel`. La tienda confirma el pago antes de guardar y revierte si falla la persistencia. `BuildController` comprueba el unlock además de que el HUD oculte torres bloqueadas. JSON `SaveData` conserva versión, moneda, IDs, niveles, contadores y el último resumen; no guarda nodos ni Resources. La escritura usa `user://`, temporal, backup y rename. Un archivo corrupto o incompatible no se sobrescribe y deja la tienda en lectura segura. Los importes/efectos se mantienen configurables; ver [ADR-0022](../decisions/ADR-0022-meta-progression-y-guardado.md).

M12A completa la resolución de combate por capas. `EnemyData` y `Enemy` modelan Health, Armor y Shield con regeneración por capa; cada perfil configura los tres máximos y un máximo cero desactiva esa capa. Los estados suprimen la regeneración correspondiente y el dibujo renderiza en filas las capas presentes (fragmenta Health). `DamagePacket` lleva un multiplicador por capa y marca los ticks periódicos; `DamageService` resuelve la capa activa Shield→Armor→Health y añade +1 al multiplicador de ataque cuando Bleed/Burn/Poison coincide con Health/Armor/Shield. Los ticks no reciben el bonus y usan la relación de daño por capa 1.0/0.5. `TowerData` conserva RPM, H/A/S, precio incremental, umbral de XP y reglas de energía. `Tower` agrega XP mientras retiene objetivo y muestra cada pool; sus upgrades manuales/automáticos suman +1 daño base y +1 a la capa elegida/activa. El panel de torre permite elegir hasta tres prioridades y ofrece mejoras para las tres capas. `BuildController` calcula precio por torre del mismo tipo y permite demoler para reducir el precio futuro. Ballista y Mortar usan `TowerProjectile`; Mortar impacta un área, y Frost calcula cobertura cuadrada/PATH. El fixture DEBUG Health/Armor/Shield permite probar las tres barras sin entrar en la campaña; los perfiles activos muestran las capas que tengan configuradas. Stats y costos secundarios siguen configurables; ver [ADR-0023](../decisions/ADR-0023-reglas-de-torres-y-capas-de-vida.md).

M13 organiza la presentación sin modificar las reglas de combate. El HUD normal se reparte entre tres paneles en `CanvasLayer`: recursos arriba a la izquierda, ronda/progreso/acción arriba al centro y datos/acciones de la torre seleccionada a la derecha. La salud de base se dibuja cada 10 puntos y su texto queda superpuesto; el sprite RGBA de la base y su tamaño visual vienen de `BaseData`. `RunEconomyService` repone Mana al máximo efectivo en las rondas de campaña; la interfaz redondea su lectura a entero. Cada cambio de Gold anima su icono y cifra. La fila de torres usa botones con textura individual estilo carta en un contenedor transparente sin placa compartida. El panel derecho se ajusta a su contenido dentro del alto disponible y hace scroll si la ventana no alcanza; al construir muestra un retrato grande y datos de coste/ataque. La descripción retira instrucciones repetidas de selección de terreno y comunica el bonus real de Mountain respecto a Grass. Al seleccionar una torre, Health/Armor/Shield se diferencian en negrita y color. Tres botones casi cuadrados presentan icono, efecto y coste de mejora; Demoler queda en una fila inferior. El panel se oculta al deseleccionar o al abrir F3; sus prioridades se configuran en un único menú checkable limitado a tres criterios. El panel F3 conserva los fixtures e inspector técnicos de terreno y combate. `H` oculta el HUD completo. `IconCatalog` carga 16 PNG RGBA transparentes e independientes desde `game/ui/icons/`: recursos, capas de Health, torres y estados. No se usa atlas ni `AtlasTexture`. Los botones, el preview de construcción y las torres colocadas comparten el mismo sprite, con dimensiones visuales configurables por `TowerData`; sus siete perfiles visibles usan 62 px frente a 54 px previos. El resumen de torre presenta iconos de Health/Armor/Shield junto a multiplicadores y XP; las cards específicas muestran la torre afectada y los textos enriquecidos económicos/técnicos insertan los iconos de moneda/energía. `EnemyData` define el tamaño individual de cada sprite y las barras acompañan su radio visual; los perfiles de enemigos se ampliaron cerca del 15%. El sprite de base pasó de 112×112 a 129×129. Ninguna escala de arte cambia la huella axial, el movimiento o el alcance lógico. Los PNG de estados se dibujan transparentes, sin panel de fondo, y con mayor tamaño; reflejan acumulaciones. `DamageService.damage_resolved` activa destello, salto y daño flotante coloreado por capa sin transferir la propiedad del cálculo al HUD. `MetaShopPanel` usa una capa terminal con resultado y recompensa, moneda meta separada y pestañas para torres y mejoras permanentes. Un helper de estilo comparte placas, bordes, estados de botones y paleta entre HUD, overlay de cartas y tienda. El arte es original del proyecto y no depende de assets de terceros; su aceptación visual está pendiente. Ver [ADR-0026](../decisions/ADR-0026-jerarquia-ux-ui.md), [ADR-0027](../decisions/ADR-0027-hud-en-tres-paneles-e-iconos-vectoriales.md), [ADR-0028](../decisions/ADR-0028-iconos-png-y-feedback-visual.md), [ADR-0031](../decisions/ADR-0031-png-individuales-por-objeto.md), [ADR-0038](../decisions/ADR-0038-base-sprite-y-feedback-del-hud.md) y [ADR-0039](../decisions/ADR-0039-panel-torre-y-escalado-individual.md).

## Sprite presentation of campaign enemies

`EnemyData.sprite_texture` references an individual RGBA PNG per campaign profile. `Enemy._draw()` centers and scales the texture while keeping hit-point bars and status icons layered above it. If a diagnostic fixture has no texture, the vector placeholder remains the fallback. No runtime atlas is used; assets are listed in [the content roster](13_CONTENT_ROSTER.md) and the per-object PNG rule in [ADR-0031](../decisions/ADR-0031-png-individuales-por-objeto.md).

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
