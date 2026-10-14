# Technical Architecture — Godot 4.7

## Enfoque
**2D real con falsa elevación visual.** La elevación es un dato lógico (`0..3`), no una coordenada Z 3D.

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
    menu/
      main_menu.tscn
      pause_menu.tscn
    main/
      main.tscn
      main.gd
    progression/
      meta_shop_panel.tscn
      meta_progression_map.tscn
      meta_upgrade_node.tscn
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
│   ├── PiecePreview (suelo y caras superiores)
│   ├── PathFlowOverlay
│   ├── Entities (Y-sort)
│   │   ├── GameBase
│   │   ├── Tower instances (M6)
│   │   ├── Enemy instances
│   │   ├── Props and spawn portals
│   │   └── Terrain cliff occluders
│   ├── Projectiles
│   └── Effects
├── WaveDirector
├── BuildController
├── DamageService (escena-local; inyectado a las torres)
├── RunEconomyService (escena-local; Gold/Mana de esta run)
├── Camera2D
├── CanvasLayer
    └── HUD
└── BuildCursorLayer (CanvasLayer superior; cursor visual al construir)
```

`BuildController` configura cada torre en el centro axial de su celda; `Tower` dibuja el arte un 20 % mayor y el ghost usa la misma escala y ancla. El offset artístico de apoyo está emparejado en ambas presentaciones y no desplaza la posición de combate ni la celda ocupada.

`TerrainPiecePreview` y las miniaturas dibujan las fachadas delanteras y las tapas con la misma geometría axial. La elevación desplaza la superficie sin cambiar la prioridad de profundidad del grid. `HexMath` define una retícula entera de vértices pointy-top; tapas, fachadas, hover y copias Y-sorted derivan de sus claves axiales compartidas, sin repetir cálculos trigonométricos que puedan separar vértices contiguos. Solo las fachadas delanteras 1 y 2 generan paredes. Cada quad cubre la diferencia de altura con la celda vecina; si el borde no tiene vecino, llega al suelo. Ninguna pared invade una tapa hexagonal, y no se generan cierres de esquina, grosor radial ni caras laterales/traseras. Las fachadas usan las texturas Grass/Mountain y el degradado se limita a sus vértices, nunca a las tapas superiores. `TerrainPiecePreview` mantiene además una copia texturada por cada hex elevado como nodo hijo de `Entities`; su origen de Y-sort es el centro axial proyectado a la altura de la celda para interponerse entre objetos detrás y delante de esa superficie. Cada fachada se ordena desde su borde inferior para cubrir actores que pasan detrás y quedar detrás de los que pasan por delante. En empates entre copias elevadas, la Y de suelo y las coordenadas axiales resuelven el orden de forma estable; las copias permanecen antes que actores y props. Un preview válido de expansión deriva endpoints del `PathGraph` candidato y traslada los portales a sus coordenadas exteriores antes de confirmar. `Main` distribuye la composición de la `WaveData` por endpoint usando la misma política que `WaveDirector`; cada portal recibe sus tipos y cantidades para dibujar los retratos de la siguiente ronda y mostrar un tooltip con su conteo exacto al hover. Cada opción de terreno es una copia por oferta con obstáculos fijados; miniatura y ghost los muestran, pero el cofre solo se sortea al confirmar la pieza. La cuadrícula y los sockets PATH se dibujan bajo demanda al hacer hover (celda actual y dos anillos con opacidad decreciente); el `PathFlowOverlay` continúa mostrando el flujo de ruta. Si no hay torre ni pieza seleccionadas, `Main` presenta un tooltip compacto con terreno, estado de construcción, elevación y bonificación de las torres compatibles, calculada desde `TowerData`; desaparece al activar selecciones o paneles contextuales. Ver [ADR-0090](../decisions/ADR-0090-fachadas-limitadas-a-la-diferencia-de-elevacion.md).

Las tapas además dibujan contornos por región `(terrain_type, elevation)`: se omiten lados compartidos por celdas de la misma región y se incluyen los límites contra terreno distinto y vacío. Cada lado conserva el color de su propia región, y la misma geometría se usa en el tablero, las miniaturas y las superficies elevadas Y-sorted. El hover sigue usando su contorno de interacción independiente. Ver [ADR-0091](../decisions/ADR-0091-contornos-compartidos-por-region-de-terreno.md).

Las fachadas elevadas se dibujan como quads texturizados, con PNG intercambiables separados para roca y césped, usando los vértices exactos de la retícula axial. Solo las dos aristas delanteras generan paredes: cada una cubre el desnivel respecto a su vecina y llega al suelo si no hay celda vecina. No se calculan paredes en aristas laterales/traseras ni polígonos de cierre; ninguna pared invade las tapas hexagonales. El degradado oscuro se interpola por vértice exclusivamente en estos quads. El HUD mantiene salud y atajos en la esquina superior izquierda, Gold/Mana en la esquina superior derecha y el progreso de ronda centrado. `RoundProgressStrip` recibe los 45 `WaveData`, muestra una ventana fija de 15 rondas y construye tooltips con los retratos y conteos agrupados del `EnemyData` real; en el tramo final conserva visibles las rondas 31–45. Las cards de expansión resumen las cantidades de terreno por tipo y usan las mismas tapas hexagonales, fachadas texturadas y orden de celdas que el tablero.

El portal es una escena sustituible con un `AnimatedSprite2D` que recorre en bucle siete frames del atlas 4×2 `assets/sprites/terrain/spawn_portal_SpriteSheet.png` a 10 FPS; el octavo cuadro se omite porque duplica el primero. Se dibuja a 96×96 px. El inicio de cada portal se desfasa de manera determinista por endpoint; al cerrar o retirar un portal se limpia su hover y tooltip antes de mostrar otras ofertas. `assets/sprites/terrain/spawn_portal.png` queda como icono estático del panel de selección. El cursor pequeño usa una `TextureRect` sobre CanvasLayer, oculta temporalmente el puntero nativo solo durante la colocación y lo restaura al volver a la interfaz. Las flechas se dibujan por arista real de `PathGraph`, con fase de animación continua hacia la base; se descarta un shader espacial basado en UV de voxels porque no representa directamente las ramas axiales compartidas.

La tienda permanente vive en `MetaShopPanel` como escena superpuesta tanto al menú como al resultado de run. El mapa (`MetaProgressionMap`) es un `Control` de gran tamaño dentro de `ScrollContainer`; el panel gestiona el arrastre izquierdo/central y delega la selección de nodos a sus botones. La escena conserva únicamente encabezado, saldo, mapa y cierre fijo arriba a la derecha; el inicio de run pertenece al menú. Cada unlock de torre conecta con los tres nodos H/A/S en paralelo, colocados horizontalmente y con sus iconos del `IconCatalog`.

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

M4 implementa `PathGraph` como `RefCounted` y usa BFS propio porque todos los enlaces actuales tienen coste uniforme. Cada nodo representa el `HexCoord` axial de una celda PATH; una arista exige sockets complementarios recíprocos en `path_edges | flexible_path_edges`. Un socket flexible sin pareja no crea una arista. Las salidas exactas abiertas fuera del tablero son candidatos de spawn; el tablero de campaña define la base en `(-1,0)` y una ruta recta en `StartingBoardData`, según [ADR-0056](../decisions/ADR-0056-tablero-inicial-lineal.md). `PathGraph` produce una `PathRoute` determinista por candidato y preserva las bifurcaciones/convergencias en su adyacencia; no activa oleadas ni selecciona los spawns activos.

La escena conserva el snapshot activo del grafo al iniciar y al confirmar una pieza. Mientras se mueve un ghost geométricamente válido, `Main` crea un snapshot candidato separado que incluye los futuros hexes y los huecos que se cerrarían; `TerrainPiecePreview` lo compara con el grafo activo para marcar spawns que continúan, aparecen o se cierran. Esta vista previa no muta el tablero ni reemplaza el grafo activo. El botón de confirmar requiere que el candidato pase la misma validación de base, salidas emparejadas, rutas de spawn y conectividad PATH. El overlay debug de rutas lo dibuja `TerrainPiecePreview` al pulsar `Ctrl+D`; el grafo sigue siendo la autoridad lógica y el preview solo lo representa. La decisión base está en [ADR-0007](../decisions/ADR-0007-grafo-logico-de-caminos.md) y la vista previa de spawn en [ADR-0029](../decisions/ADR-0029-previsualizacion-de-spawns-en-expansion.md).

`PathGraph` conserva el conjunto runtime de endpoints retirados y expone `get_active_routes()`. El jugador puede quitar portales en preparación mientras queden más de tres; el coste es el doble del coste actual de obstáculo. `WaveDirector` y los previews usan solo las rutas activas y conservan el total de enemigos de `WaveData`, repartiéndolos round-robin entre esos endpoints. El estado de endpoints retirados y el contador de obstáculos limpiados duran solo una run.

AStar2D podría sustituir BFS si las rutas adquieren costes diferentes; si se usa, los IDs deben representar HexCoord. No incorporar NavigationRegion2D al modelo lógico.

## Rendering
No hacer que la lógica dependa de TileMapLayer. `HexGrid` es la autoridad.

TileMapLayer puede utilizarse como renderer/optimización más adelante, pero para el vertical slice es válido renderizar cada celda mediante nodos/sprites si facilita cliffs y elevación. Mantener una interfaz de renderer para poder optimizar sin reescribir gameplay.

El preview M2 actual dibuja polígonos vectoriales temporales desde `TerrainPieceCellData`: aplica offset por elevación, genera caras laterales en desniveles, ordena las caras superiores por profundidad lógica y detecta hover sobre esas caras. No depende de sprites finales. Las caras no dibujan iniciales ni coordenadas; el hover comunica tipo/altura/coordenada axial al HUD y cambia el color según terreno. Los clusters conectados de Grass/Mountain reciben feedback luminoso de combo 3/5 solo visual. La escena principal incluye un contenedor `Entities` con Y-sort habilitado para actores.

La separación visual de cada nivel lógico se fija en 28 px, compartida por terrenos, overlays, fantasmas y torres; se permiten alturas 0–3, con PATH 0, Grass 1–2 y Mountain 2–3. Cada terreno construible sortea su altura de forma reproducible por seed/identidad de oferta, y el preview conserva el dato al confirmar. Las torres reciben +1 daño base y +0.5 de alcance por nivel y dibujan encima de su sprite una insignia con el bonus de daño. El renderer activo solo dibuja las dos fachadas delanteras como quads verticales, sin cierres de vértice ni profundidad lateral; M38/ADR-0085 sustituye las cuñas de las iteraciones anteriores.

El ghost de una expansión se deriva del mismo `Dictionary[Vector2i, HexCell]` candidato que confirma `Main`: alturas, variantes, obstáculos, props, cofres y celdas auto-rellenadas se preparan de forma determinista y no se recalculan al confirmar. Esto hace que tapas y fachadas coincidan antes y después de colocar. Los contornos comparten vértices sin inset y usan un disco de unión redondo; Grass usa `#53B56F`, Mountain `#8A8B91` y Path mantiene amarillo. El sombreado direccional oscuro de las fachadas y el keyline del stroke siguen M45/ADR-0094.

`TerrainVisualCatalog.get_elevation_tint()` es la fuente común del tinte multiplicativo de las tapas: altura 0 conserva blanco y cada nivel reduce muy ligeramente rojo/verde, igual en el dibujo del tablero y en las copias elevadas Y-sorted. No modifica las UV, el polígono ni el orden de profundidad. `UpgradeOfferCard` usa una superficie plana común definida en la escena, sin sprite de marco ni variantes por rareza; el tier, icono, título y descripción están en el contenido, y un shader procedural dibuja detrás un aura radial con partículas cuyo color depende de la rareza. El hover refuerza el aura sin cambiar la superficie compartida. Ver ADR-0082, ADR-0088 y ADR-0080 para el historial de tier/ramas.

En M3, `HexGrid` es autoridad para las celdas confirmadas; `TerrainPlacementValidator` es un `RefCounted` puro que evalúa la candidata y devuelve `TerrainPlacementResult`; `Main` orquesta selección/confirmación y `TerrainPiecePreview` dibuja tablero y ghost, sin cambiar la autoridad lógica. Las conexiones internas usan los bordes PATH explícitos; las conexiones entre piezas también aceptan las aperturas laterales flexibles derivadas en cada salida de borde, según [ADR-0006](../decisions/ADR-0006-sockets-laterales-flexibles-de-camino.md). M4 ya incorpora la conectividad global mediante el snapshot `PathGraph` descrito arriba.

La navegación del mapa la controla un `Camera2D` en `Main`: `WASD` mueve la cámara de manera continua (diagonales normalizadas y velocidad compensada por zoom) y el botón central con arrastre panea; la rueda acerca/aleja alrededor del cursor. `Ctrl+D` conserva el overlay diagnóstico de rutas sin ocupar la tecla `D`. El HUD vive en `CanvasLayer` y no se desplaza ni escala con la cámara. Las teclas mantenidas se limpian al perder el foco de la ventana.

M5 añade `GameBase` y `WaveDirector` a la escena principal. `GameBase` posee un `HealthComponent` y dibuja una huella hexagonal completa del mismo radio que una celda; `Enemy` compone su propio `HealthComponent` y `PathFollowerComponent`. `WaveDirector` recibe la oleada, el snapshot M4, la base y el contenedor Y-sort; crea enemigos desde sus Resources y escucha sus señales de llegada o muerte. La UI de `Main` presenta Health, recuento y estado, y traduce las señales de oleada a fases de `RunManager`. Durante `COMBAT` se bloquean las entradas de colocación de terreno. El tablero semilla de campaña usa `StartingBoardData` con radio axial 2 (19 celdas) y configuración de camino mínima de cuatro celdas PATH por spawn; el grafo vuelve a aplicar ese límite tras cada expansión. Al iniciar cada run, el tablero entero y sus sockets PATH rotan un paso de 60°; el contador persistente avanza por seis orientaciones sin cambiar la coordenada de la base.

M6 añade `BuildController` a `Main`; recibe el `HexGrid`, `Entities`, el origen y el radio del mapa. El controlador valida fase, terreno construible y ocupación antes de instanciar una escena desde `TowerData`, y registra la torre en `HexCell.occupied/tower_id`. Solo Grass y Mountain permiten construir, así que las torres no cambian `PathGraph`. `Tower` es una escena Y-sorted con datos, nivel, selección, prioridad de objetivo, alcance y cadencia; consulta los nodos del grupo `enemies` cada 0.1 s y usa `PathFollowerComponent.get_progress_ratio()` para first/last progress. Su placeholder vectorial dibuja pedestal, orientación, anillo de alcance al seleccionarlo y un flash hitscan al atacar. `TerrainPiecePreview` representa el marcador/rango de colocación. La UI de `Main` alterna build mode, muestra errores, cambia la prioridad y mejora la torre. En M6 las mejoras no tenían coste; M9 incorpora costes configurables. ADR-0009 recoge las reglas temporales.

M7 añade `DamageService` como hijo de `Main`, no como Autoload global. `BuildController` lo inyecta al configurar cada `Tower`, y cada disparo crea un `DamagePacket` con origen, tags y perfil desde `TowerData`. `DamageService.preview_damage()` calcula el resultado sin mutar al enemigo para el HUD; `apply_damage()` usa ese mismo cálculo, aplica daño y contrarregeneración y emite `damage_resolved`. `Enemy` mantiene su `HealthComponent`, regenera en `_process` con fracciones acumuladas y expone sus stats para targeting/debug. En M7 las respuestas de muerte seguían conectadas a las señales M5 y todavía no pagaban recompensa; M9 conecta ahora el evento al `RunEconomyService`. El HUD provisional de depuración conserva solo estado de base/oleada, torre seleccionada y daño estimado; la barra inferior vincula las torres de prueba a los atajos 1–3. M10 conserva M7/M8 como fixtures `DEBUG` y separa esas pruebas del avance de campaña. `F3` muestra los controles y datos técnicos de terreno; `H` oculta el HUD entero. Los scripts M7 cargan packet/result por rutas `preload` y exponen interfaces base `RefCounted`/`Node` en las fronteras, evitando referencias de tipo a clases globales recién creadas antes de que Godot refresque su caché. Los payloads de status quedan reservados para M8. ADR-0010 fija el contrato y la fórmula provisional; ADR-0011 registra este HUD temporal y sus atajos.

M8 añade `StatusEffectData` como Resource y `StatusEffectController` como hijo de cada `Enemy`; los Resources de configuración se comparten como datos, pero stacks, duración restante, temporizador de tick y origen activo pertenecen a cada enemigo. `TowerData.status_effects` proporciona los payloads del impacto; `DamageService` aplica el daño directo y, si el objetivo sigue vivo, aplica los estados. El controlador combina modificadores de velocidad tomando el mínimo multiplicador activo, ejecuta ticks periódicos llamando al mismo `DamageService` (sin payloads recursivos) y limpia al expirar el estado, morir el enemigo o llegar a la base. La instancia del servicio de combate continúa siendo local a `Main` e inyectada al enemigo por `WaveDirector`. Los tres Resources Slow/Burn/Bleed, el dummy, la torre y la oleada M8 son fixtures provisionales. La barra de prueba amplía los atajos a `1–4`; el panel compacto informa los estados y sus temporizadores en el objetivo de la torre seleccionada. Las reglas de acumulación y propiedad del tick están registradas en ADR-0012.

M9 añade `RunEconomyService` como nodo local de `Main`, configurado desde `RunEconomyData`; conserva Gold y Mana de la run sin mezclar la moneda meta. `BuildController` recibe el servicio y aplica compras atómicas de torres/mejoras con costes de `TowerData`. Cada `Tower` recibe la misma instancia: antes de un impacto con coste de Mana intenta gastar el recurso y no dispara si el saldo no alcanza. El servicio regenera Mana durante la run, acotado por su capacidad, y emite señales de saldo; el HUD refleja Gold, Mana, regeneración, costes de atajos y coste de mejora. `WaveDirector` guarda la recompensa de cada instancia enemiga, la paga una vez al derrotarla y descarta el pago al llegar a base; entrega la recompensa de ronda solo al limpiar todos los grupos. `Main` pasa brevemente a `ROUND_REWARD` antes de permitir la siguiente oleada. La remuneración por baja ya emitida se conserva aunque otro enemigo haga fallar esa oleada; no se paga el bonus de ronda fallida. Los valores de M9 son fixtures provisionales. ADR-0013 registra el contrato y las provisionalidades.

M9.5, adelantado por petición del usuario antes de la progresión completa M10 y las cartas M11, introduce siete `TowerData`: Ballista, Mortar, Tesla Coil, Frost Keep, Flame Thrower, Poison Sprayer y Shredder. Las decisiones posteriores M12A/ADR-0023 amplían el modelo a Shield/Armor/Health y sustituyen la afirmación histórica de que Shield faltaba. Ballista usa un proyectil dirigido; Mortar un proyectil con explosión al aterrizar; Tesla alcanza todos los enemigos en su rango circular; Frost deja caer copos sobre PATH dentro de un cuadrado y aplica daño/Slow solo por contacto individual; Flame y Poison usan cono; Shredder recorre PATH, daña y añade Bleed mientras pierde daño base por enemigo. Todos pasan por `DamageService`. El roster principal tiene atajos `1–7`; los perfiles M7/M8 siguen en `8`, `9` y `0`. Las cifras de sus Resources parten de la tabla compartida por el usuario, son configurables y no representan balance final.

M10 carga y valida 45 WaveData ordenadas y un total fijo de 1.093 enemigos directos. WaveEnemyGroupData.count es la cantidad exacta por grupo; WaveDirector crea una unidad a la vez y la distribuye round-robin entre rutas alcanzables. Abrir varios endpoints no multiplica el total. El contador de spawns pendientes cubre el calendario directo; el contador de enemigos activos incluye invocaciones. Una transformación conserva la misma instancia activa y el pago de baja para que la ronda no se cierre hasta derrotar la fase final.

EnemyData contiene boss_tier y una lista tipada de EnemyAbilityData. WaveData deriva Standard, Boss o Tier 2 Boss del boss_tier presente; no asigna Miniboss a las rondas 17/19. WaveDirector ejecuta habilidades de aparición, proximidad, agotamiento de capas, muerte y temporizador, con radios configurables. Ooogie von Ooogovich (Haunted) usa un perfil propio provisional, invoca dos Bats cada 2 s y se transforma en Bat con 2.500 Health. Otros perfiles adoptan las habilidades individuales seleccionadas para el roster; las formas encadenadas de Ooogiehedron usan overrides de capas/speed sin mutar sus Resources base.

La campaña termina al limpiar la ronda 45 y solo expande el terreno después de limpiar las rondas 1–44. En cada victoria intermedia, TerrainPiecePreview conserva su comparación del grafo candidato; la siguiente ronda se habilita después de una colocación válida, y M11 puede intercalar su oferta de cartas. Los fixtures de diagnóstico M7/M8 se mantienen aislados de avance, pagos y daño a base. Las habilidades, los perfiles de enemigo y sus sprites se detallan en 13_CONTENT_ROSTER.md; la tabla exacta de cantidad/orden está en 14_CAMPANA_45_RONDAS.md. ADR-0037 sustituye el contrato de calendario y spawn de ADR-0016/0018 y las selecciones de contenido de ADR-0032/0033/0035/0036.
M11 usa `CardData`, `CardModifierOperation`, `CardPoolData`, `CardCatalogData` y `RunCardService`. El servicio es local a `Main`: combina el pool base con catálogos, resuelve prerequisitos entre catálogos y filtra por unlock, roster de run, selecciones y límite. El catálogo de mejora tiene 190 IDs únicos, que representan 173 entradas compatibles; M35 añade seis Resources de reclutamiento y el pool de run contiene 196 IDs. Tras colocar la expansión cada tres rondas entre la 3 y la 42, mantiene `CARD_OFFER` hasta elegir; luego habilita la ronda siguiente. `CardPoolData`, `RunCardService`, la escena y el panel comparten una oferta fija de tres opciones. Las cartas de reclutamiento elegibles se mezclan con las mejoras y las no elegidas permanecen elegibles en ofertas futuras. Torres, estados, base y economía consultan modificadores temporales sin mutar `.tres`. La frecuencia está confirmada; cifras y rarezas son configurables/provisionales. Ver ADR-0021/0062/0076/0093.

M12 extiende el Autoload `MetaProgression` para separar moneda/unlocks de `RunEconomyService` y mantenerlos entre escenas. `MetaProgressionData` combina su catálogo base con `PermanentUpgradeCatalogData`; hay 31 IDs en los Resources y 30 mejoras comprables en el mapa. `card_draw` se conserva como ID legado para perfiles guardados, pero queda retirado de la tienda porque la oferta siempre tiene tres opciones. Las mejoras disponibles tienen operaciones por nivel para economía, daño H/A/S, Gold por baja, vida/reparación de base y unlocks. La tienda terminal aparece al acabar por victoria o derrota, cobra y persiste, y sus efectos se activan en la siguiente run. La compra revierte si falla la persistencia. `BuildController` comprueba el unlock además de que el HUD oculte torres bloqueadas. JSON `SaveData` conserva versión, moneda, IDs, niveles, contadores y el último resumen; no guarda nodos ni Resources. La escritura usa `user://`, temporal, backup y rename. Un archivo corrupto o incompatible no se sobrescribe y deja la tienda en lectura segura. Importes y efectos siguen configurables; ver [ADR-0022](../decisions/ADR-0022-meta-progression-y-guardado.md) y [ADR-0062](../decisions/ADR-0062-catalogo-de-upgrade-cards-y-permanent-upgrades.md).
M12 extiende el Autoload `MetaProgression` para separar moneda/unlocks de `RunEconomyService` y mantenerlos entre escenas. `MetaProgressionData` combina su catálogo base con `PermanentUpgradeCatalogData`; 31 IDs persisten en los Resources, de los cuales 30 se ofrecen para compra y `card_draw` se conserva como ID legado oculto. La presentación terminal por pestañas de M12 es histórica y quedó sustituida por M35: la misma tienda se monta en el menú y tras Game Over, usando `MetaProgressionMap` con nodos/conexiones. Los efectos se activan en la run siguiente. La compra revierte si falla la persistencia. `BuildController` y el roster temporal distinguen unlock persistente de reclutamiento en run. JSON `SaveData` conserva versión, moneda, IDs, niveles, contadores y el último resumen; no guarda nodos ni Resources. La escritura usa `user://`, temporal, backup y rename. Un archivo corrupto o incompatible no se sobrescribe y deja la tienda en lectura segura. Importes y efectos siguen configurables; ver [ADR-0022](../decisions/ADR-0022-meta-progression-y-guardado.md), [ADR-0076](../decisions/ADR-0076-economia-inicial-roster-de-run-y-flujo-de-escenas.md) y [ADR-0077](../decisions/ADR-0077-mapa-de-mejoras-permanentes-con-nodos.md).

M12A completa la resolución de combate por capas. `EnemyData` y `Enemy` modelan Health, Armor y Shield con regeneración por capa; cada perfil configura los tres máximos y un máximo cero desactiva esa capa. Los estados suprimen la regeneración correspondiente y el dibujo renderiza en filas las capas presentes (fragmenta Health). `DamagePacket` lleva un multiplicador por capa y marca los ticks periódicos; `DamageService` resuelve la capa activa Shield→Armor→Health y añade +1 al multiplicador de ataque cuando Bleed/Burn/Poison coincide con Health/Armor/Shield. Los ticks no reciben el bonus y usan la relación de daño por capa 1.0/0.5. `Tower` mantiene un total de mejoras y tres contadores independientes de 0 a 15; cada subida manual o automática añade +1 de daño base y +1 solo a la capa afectada. El XP y los costes Gold crecen exponencialmente por nivel de esa capa según factores configurables del `TowerData`. `BuildController` cobra el coste de la capa seleccionada. La interfaz pone el nivel y la barra XP bajo cada mejora y ordena tres criterios de targeting en selectores numerados. `BuildController` calcula precio por torre del mismo tipo y permite demoler para reducir el precio futuro. Ballista y Mortar usan `TowerProjectile`; Mortar impacta un área, y Frost calcula cobertura cuadrada/PATH. El fixture DEBUG Health/Armor/Shield permite probar las tres barras sin entrar en la campaña; los perfiles activos muestran las capas que tengan configuradas. Los factores iniciales son provisionales; ver [ADR-0023](../decisions/ADR-0023-reglas-de-torres-y-capas-de-vida.md) y [ADR-0046](../decisions/ADR-0046-progresion-de-mejoras-y-feedback-de-seleccion.md).

M13 organiza la presentación sin modificar las reglas de combate. M22 actualiza el layout del HUD normal en `CanvasLayer`: salud y atajos arriba a la izquierda, Gold/Mana arriba a la derecha, ronda centrada y datos/acciones de torre bajo los recursos a la derecha. Salud, recursos y ronda no tienen fondos de panel compartido. La salud de base se dibuja cada 10 puntos y su texto queda superpuesto; `BaseData` expone el sprite RGBA y `GameBase` lo dibuja a escala nativa 1:1. `RunEconomyService` repone Mana al máximo efectivo en las rondas de campaña; la interfaz redondea su lectura a entero. Cada cambio de Gold anima en conjunto su icono y cifra con escala, rebote y destello. La fila muestra solo las torres reclutadas en la run: Ballista empieza disponible y las demás entran tras elegir su carta de reclutamiento. El panel derecho se ajusta a su contenido sin scroll; si la ventana no alcanza su alto natural, escala verticalmente para mantener toda la información dentro de pantalla. El preview se dibuja por encima del tablero y señala con verde/rojo la validez de la colocación; al colocar Ballista también indica el bonus de daño de altura. La distribución de selección, las mejoras H/A/S, targeting, debug, iconos de torre, estados y feedback de daño siguen los contratos de las versiones anteriores de M13. `MetaShopPanel` comparte una única tienda entre las escenas de menú y final de run; menú, partida y pausa son escenas separadas, Escape abre pausa y perder devuelve al menú con la tienda abierta. Game Over presenta recuentos y daño por tipo de torre desbloqueado. La tienda permanente usa `MetaProgressionMap` y nodos de una escena común; conexiones muestran prerequisitos, iconos grandes identifican la mejora, tooltips describen bloqueos y partículas confirman la compra. El progreso de ronda usa una ventana móvil de 15 puntos, mantiene hover de enemigos y desvanece el extremo futuro. Ver [ADR-0076](../decisions/ADR-0076-economia-inicial-roster-de-run-y-flujo-de-escenas.md), [ADR-0077](../decisions/ADR-0077-mapa-de-mejoras-permanentes-con-nodos.md) y [ADR-0083](../decisions/ADR-0083-timeline-fijo-de-quince-rondas-y-preview-fiel.md), además de [ADR-0049](../decisions/ADR-0049-arquitectura-hibrida-ui-editable.md).

Actualización de arquitectura (ADR-0049): el antiguo helper de estilos fue retirado en favor del Theme local `game/ui/themes/rogue_hud_theme.tres`, aplicado a raíces UI concretas y sin sobrescribir el Theme global. Los controles repetidos de torre/capa/mejora, oferta de cartas, tienda/mapa permanente, menús y filas del tooltip de ronda tienen escenas editables y scripts de presentación asociados; el mapa dibuja conexiones y crea su etiqueta central/partículas de feedback en runtime. El arranque de `project.godot` apunta al menú principal; menú, partida y pausa son escenas distintas. `Main` sigue coordinando partida, entradas y señales, mientras los sistemas existentes conservan la autoridad sobre progreso, compras, economía y reglas. La oferta presenta exactamente tres cards; las cartas de reclutamiento elegibles se mezclan con las mejoras. El dibujo de progreso de ronda sigue procedural, ahora sobre ventana móvil. La aceptación de la implementación actual queda pendiente en ventana. Ver ADR-0049, ADR-0076–0078 y ADR-0093.

Actualización histórica de recursos visuales (ADR-0050): 20 recursos Texture2D (16 iconos generales y cuatro cursores) viven como propiedades de `game/ui/resources/icon_catalog.tres`, referenciado también por el Inspector de la raíz `Main`. Las tarjetas de torre y capa exponen texturas por instancia y las sincronizan con sus `TextureRect` para previsualizarlas en el editor. Gold/Mana, el sprite 9-slice de iniciar ronda y los marcos de expansión permanecen asignados en sus escenas. Las upgrade cards ya no usan los marcos PNG de aquella etapa; M40 las define como una superficie plana común con aura procedural según ADR-0088. El Theme local es la autoridad editable para los paneles de fondo plano. Los Resources de gameplay no incorporan campos UI.

Históricamente M15 asignaba obstáculos y cofres por seed/coordenada, y refería los objetos decorativos como props; aquella selección de cinco imágenes y el desplazamiento vertical de 6 px quedaron sustituidos por M39. La asignación de cofres sigue al confirmar una expansión, con base de 1 % y el modificador persistente vigente hasta 20 %. El hover del cofre mantiene su salto y resplandor; el premio inicial de 25 Gold sigue configurable/provisional. Las flechas animadas muestran el flujo PATH y se actualizan con un grafo candidato legal. Ver ADR-0040, ADR-0041, ADR-0060 y ADR-0087.

En el renderer vigente, `TerrainVisualCatalog` asigna determinísticamente elevación, obstáculos y decoración a partir de seed/coordenada o identidad de oferta. Cada uno de los 18 props compatibles con el terreno tiene un 10 % de probabilidad independiente por celda; se limita a dos props únicos, que se dibujan bajo el obstáculo y no tienen input ni hitbox. La oferta conserva los mismos IDs entre miniatura, ghost y tablero; si una celda vecina a la base se normaliza de Mountain a Grass, el ghost y la colocación regeneran juntos los props compatibles con Grass usando la coordenada global. Los PNG de props tienen 96×96 px y se muestran a 39,6×39,6 px con offsets que impiden que dos sprites se solapen. Los ocho obstáculos se generan con las tasas existentes (Grass 25 %, Mountain 15 %), usan PNG de 208×208 px, se muestran centrados a 94,6×94,6 px y se dibujan por delante de los props. Las celdas vecinas inmediatas a la base no superan altura 1: una Mountain se normaliza a Grass 1 y Path permanece 0. La base conserva el PNG fuente 270×352 px y se escala uniformemente hasta una caja visual máxima de 86×86 px. Las fachadas se ordenan con `Entities.y_sort_enabled` desde el borde inferior expuesto, a la altura de la tapa vecina o del suelo; cubren actores detrás y quedan detrás de actores delante. Ver [ADR-0087](../decisions/ADR-0087-props-obstaculos-y-altura-junto-a-base.md), [ADR-0089](../decisions/ADR-0089-ajustes-escala-occlusion-portales-props.md), [ADR-0090](../decisions/ADR-0090-fachadas-limitadas-a-la-diferencia-de-elevacion.md) y [ADR-0092](../decisions/ADR-0092-pulido-visual-y-raiz-comun-de-sprites.md).

Actualización de assets M15 (ADR-0058): se sustituyeron los 23 PNG de terreno, obstáculos, base, portal e iconos de torre en sus rutas runtime. Path_01/02/03 ahora muestran el arte Dirt_01/02/03 sin camino pintado. `TerrainVisualCatalog`, los sockets PATH, el `PathGraph` y el overlay de flechas no cambiaron; los originales están respaldados en `art_generation/originals_replaced/2026-10-13/`.

M16 conecta `Tower.impact_effect_requested` con `AnimatedImpactVfx`, que toma cada sprite sheet local y anima sus frames en el hex objetivo. `Main` aplica cuatro cursores locales por estado de interacción: normal, objeto/control interactivo, acción inválida o colocación. Todos los sprites se guardan bajo `assets/sprites/`; los PNG del pack Tiny Swords se mantienen como dependencia local ignorada por Git en `assets/sprites/third_party/tiny_swords/`, cuya README explica su instalación. La procedencia y licencia están en [Origen](../references/ORIGEN.md).

Cada `Tower` compone una base inmóvil y una cabeza en `Node2D` de pivote colocada en la unión de la base; solo la cabeza rota hacia el objetivo. `TowerArtCatalog` crea `AtlasTexture` de las imágenes por torre y ofrece el mismo montaje al ghost. La base, la cabeza y los obstáculos interactuables usan un shader `CanvasItem` de dilatación alfa para un contorno blanco fino; no se agrupan en `CanvasGroup`, así cada sprite conserva su Y-sort. El ghost de construcción mantiene su tinte verde/rojo de legalidad. No hay capas de sombras en el tablero. El flujo PATH se oculta durante la previsualización/colocación de una expansión y el hover no dibuja los sockets sobre el camino. El Tower Info muestra la bonificación de daño y alcance de la elevación de la torre seleccionada. El XP de perfil existente financia tanto desbloqueos de torres como mejoras permanentes. Véanse [ADR-0069](../decisions/ADR-0069-desbloqueos-xp-y-feedback-de-altura.md), [ADR-0070](../decisions/ADR-0070-sin-sombras-y-rutas-limpias-en-expansion.md) y [ADR-0093](../decisions/ADR-0093-preview-de-terreno-oferta-fija-y-torres-articuladas.md). La fuente Patrick Hand está asignada al tema predeterminado del proyecto, incluidos los contadores pintados en `_draw()`.

Actualización visual (ADR-0053/0054): el panel de expansión y Tower Info usan superficies planas; se retiraron los marcos PNG y la placa oscura que se pintaba bajo las torres. `rogue_hud_theme.tres` es el tema global, y sus tamaños de texto existentes se conservan al establecer Patrick Hand como fuente predeterminada.

M32/M33 retiraron los fondos PNG por tier y las variantes por rareza. M36 introdujo un sprite vertical NinePatch, que M40 elimina: una card plana compartida, icono grande y datos legibles; la rareza solo controla el aura radial procedural y sus partículas. La oferta de mejoras tiene siempre tres opciones; el panel mantiene exactamente tres botones activos y Card Draw está retirado del mapa. Los reclutamientos se mezclan con las mejoras dentro de esos tres espacios. `TerrainPieceCardPreview` omite sockets/ramificaciones PATH, pero usa las mismas tapas hexagonales y fachadas delanteras que el tablero, ordenadas por el anclaje axial; las alturas mostradas son las de la oferta real. Durante la colocación, `Q` y `E` giran la pieza; la rueda también la gira y, fuera de colocación, conserva el zoom. `T` busca un ancla y rotación aleatorias, las valida con `TerrainPlacementValidator` y `PathGraph`, y confirma automáticamente si la expansión conserva una continuación futura. Si no hay candidata, no modifica el tablero. Sin torre ni pieza seleccionadas, el hover de celda presenta el tooltip compacto descrito arriba. Ver ADR-0071, ADR-0072, ADR-0075, ADR-0080, ADR-0083, ADR-0088 y [ADR-0093](../decisions/ADR-0093-preview-de-terreno-oferta-fija-y-torres-articuladas.md).

## Sprite presentation of campaign enemies

Actualización de feedback (ADR-0055): al recibir daño, la base pulsa en rojo y la cámara aplica una sacudida breve mediante `Camera2D.offset`, sin cambiar posición ni zoom. Gold anima el grupo de icono y cifra con rebote, destello e inclinación; el cofre llama al mismo feedback incluso si el saldo ya alcanzó su límite. Una capa negra translúcida de `CanvasLayer` queda debajo de las cards durante las ofertas de terreno/mejoras, se oculta al elegir una pieza para colocar y vuelve al cancelar. M41 sustituye parcialmente el portal de 64×96 px por el atlas animado de 96×96 px; conserva la interacción y el preview. El juego se pausa mediante la acción `toggle_pause` (P) o el botón `PauseButton`, cuyo proceso continúa durante la pausa; `StartWave` también procesa la entrada y despeja la pausa al iniciar desde `ROUND_PREP`. Durante `TERRAIN_EXPANSION` y `CARD_OFFER`, `Main` y `BuildController` impiden selección/construcción de torres y apertura de cofres. Véase [ADR-0061](../decisions/ADR-0061-pausa-y-fases-de-expansion.md) y [ADR-0089](../decisions/ADR-0089-ajustes-escala-occlusion-portales-props.md).

`EnemyData.sprite_texture` references an individual RGBA PNG per campaign profile. `Enemy._draw()` centers and scales the texture while keeping hit-point bars and status icons layered above it. If a diagnostic fixture has no texture, the vector placeholder remains the fallback. No runtime atlas is used; assets are listed in [the content roster](13_CONTENT_ROSTER.md) and the per-object PNG rule in [ADR-0031](../decisions/ADR-0031-png-individuales-por-objeto.md).

## Save
Guardar solo datos estables:
- versión de save;
- XP de perfil (`meta_currency` en el formato de guardado para mantener compatibilidad);
- IDs desbloqueados;
- niveles de permanentes;
- settings.

No serializar nodos/Resources completos.

## Determinismo
La run debe tener `run_seed`.
Toda selección aleatoria importante debe derivar de un RNG de run para poder reproducir bugs.
