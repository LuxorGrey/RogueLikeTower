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

`BuildController` configura cada torre en el centro axial de su celda; `Tower` aplica la escala de mundo vigente `0,9504 × 1,12` y el ghost usa la misma escala y ancla. M55 la reduce un 10 % respecto a M54. El offset artístico de apoyo está emparejado en ambas presentaciones y no desplaza la posición de combate ni la celda ocupada.

`TerrainPiecePreview` y las miniaturas dibujan las fachadas delanteras y las tapas con la misma geometría axial. La elevación desplaza la superficie sin cambiar la prioridad de profundidad del grid. `HexMath` define una retícula entera de vértices pointy-top; tapas, fachadas, hover y copias Y-sorted derivan de sus claves axiales compartidas, sin repetir cálculos trigonométricos que puedan separar vértices contiguos. Solo las fachadas delanteras 1 y 2 generan paredes. Cada quad cubre la diferencia de altura con la celda vecina; si el borde no tiene vecino, llega al suelo. Ninguna pared invade una tapa hexagonal, y no se generan cierres de esquina, grosor radial ni caras laterales/traseras. Las fachadas usan las texturas Grass/Mountain y el degradado se limita a sus vértices, nunca a las tapas superiores. `TerrainPiecePreview` mantiene además una copia texturada por cada hex elevado como nodo hijo de `Entities`; su origen de Y-sort es el centro axial proyectado a la altura de la celda para interponerse entre objetos detrás y delante de esa superficie. Cada fachada se ordena desde su borde inferior para cubrir actores que pasan detrás y quedar detrás de los que pasan por delante. En empates entre copias elevadas, la Y de suelo y las coordenadas axiales resuelven el orden de forma estable; las copias permanecen antes que actores y props. Un preview válido de expansión deriva endpoints del `PathGraph` candidato y traslada los portales a sus coordenadas exteriores antes de confirmar. `Main` distribuye la composición de la `WaveData` por endpoint usando la misma política que `WaveDirector`; cada portal recibe sus tipos y cantidades para mostrar retratos, nombres y cantidades en un tooltip al hover; no dibuja iconos de enemigos sobre el portal. Cada opción de terreno es una copia por oferta con obstáculos fijados; miniatura y ghost los muestran, pero el cofre solo se sortea al confirmar la pieza. La cuadrícula y los sockets PATH se dibujan bajo demanda al hacer hover (celda actual y dos anillos con opacidad decreciente); el `PathFlowOverlay` continúa mostrando el flujo de ruta. Si no hay torre ni pieza seleccionadas, `Main` presenta un tooltip compacto con terreno, estado de construcción, elevación y bonificación de las torres compatibles, calculada desde `TowerData`; desaparece al activar selecciones o paneles contextuales. Ver [ADR-0090](../decisions/ADR-0090-fachadas-limitadas-a-la-diferencia-de-elevacion.md).

Las tapas además dibujan contornos por región `(terrain_type, elevation)`: se omiten lados compartidos por celdas de la misma región y se incluyen los límites contra terreno distinto y vacío. Cada lado conserva el color de su propia región, y la misma geometría se usa en el tablero, las miniaturas y las superficies elevadas Y-sorted. El hover sigue usando su contorno de interacción independiente. Ver [ADR-0091](../decisions/ADR-0091-contornos-compartidos-por-region-de-terreno.md).

Las fachadas elevadas se dibujan como quads texturizados, con PNG intercambiables separados para roca y césped, usando los vértices exactos de la retícula axial. Solo las dos aristas delanteras generan paredes: cada una cubre el desnivel respecto a su vecina y llega al suelo si no hay celda vecina. No se calculan paredes en aristas laterales/traseras ni polígonos de cierre; ninguna pared invade las tapas hexagonales. El degradado oscuro se interpola por vértice exclusivamente en estos quads. El HUD mantiene salud y atajos en la esquina superior izquierda, Gold/Mana en la esquina superior derecha y el progreso de ronda centrado. `RoundProgressStrip` recibe los 45 `WaveData`, muestra una ventana fija de 15 rondas y construye tooltips con los retratos y conteos agrupados del `EnemyData` real; en el tramo final conserva visibles las rondas 31–45. Las cards de expansión resumen las cantidades de terreno por tipo y usan las mismas tapas hexagonales, fachadas texturadas y orden de celdas que el tablero.

El portal es una escena sustituible con un `AnimatedSprite2D` que recorre en bucle siete frames del atlas 4×2 `assets/sprites/terrain/spawn_portal_SpriteSheet.png` a 10 FPS; el octavo cuadro se omite porque duplica el primero. Se dibuja a 96×96 px y lleva una capa outline-only blanca permanente mediante `interactable_outline.gdshader`, con `outline_size_px = 3`, igual que los obstáculos. La capa sigue el frame y la escala de pulso; el contorno/resplandor contextual de hover, candidato y cierre queda por encima. El inicio de cada portal se desfasa de manera determinista por endpoint; al cerrar o retirar un portal se limpia su hover y tooltip antes de mostrar otras ofertas. `assets/sprites/terrain/spawn_portal.png` queda como icono estático del panel de selección. El cursor pequeño usa una `TextureRect` sobre CanvasLayer, oculta temporalmente el puntero nativo solo durante la colocación y lo restaura al volver a la interfaz. Las flechas se dibujan por arista real de `PathGraph`, con fase de animación continua hacia la base; se descarta un shader espacial basado en UV de voxels porque no representa directamente las ramas axiales compartidas.

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
- `enemy_killed(enemy: Enemy)` — señal local `WaveDirector` → `Main`; la recompensa se emite aparte como `reward_earned(amount, reason)`.
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

La separación visual de cada nivel lógico se fija en 28 px, compartida por terrenos, overlays, fantasmas y torres; se permiten alturas 0–3, con PATH 0, Grass 1–2 y Mountain 2–3. Cada terreno construible sortea su altura de forma reproducible por seed/identidad de oferta, y el preview conserva el dato al confirmar. Las torres reciben +1 daño base y +0.5 de alcance por nivel; su insignia numérica de bonus solo aparece al pasar el cursor sobre la torre. El renderer activo solo dibuja las dos fachadas delanteras como quads verticales, sin cierres de vértice ni profundidad lateral; M38/ADR-0085 sustituye las cuñas de las iteraciones anteriores.

El ghost de una expansión se deriva del mismo `Dictionary[Vector2i, HexCell]` candidato que confirma `Main`: alturas, variantes, obstáculos, props, cofres y celdas auto-rellenadas se preparan de forma determinista y no se recalculan al confirmar. Esto hace que tapas y fachadas coincidan antes y después de colocar. El contorno de región de terreno comparte vértices sin inset y usa un disco redondo en las uniones, con un solo color opaco por terreno: Grass `#406e4d`, Mountain `#646567` y Path amarillo; no tiene keyline ni relleno interior. El sombreado direccional oscuro de las fachadas sigue M45/ADR-0094 y el ajuste de contorno ADR-0095.

`TerrainVisualCatalog.get_elevation_tint()` es la fuente común del tinte multiplicativo neutro de las tapas: h0 usa 1,00; h1, 0,95; h2, 0,90; h3, 0,85 en RGB, igual en tablero, previews y copias elevadas Y-sorted. No modifica las UV, el polígono ni el orden de profundidad. `CloudShadowOverlay` aplica una sombra procedural de nubes en movimiento a los sprites del mundo desde un ColorRect full-screen en `CloudShadowLayer`, justo debajo del HUD. El shader recibe el centro/zoom de Camera2D para mantener el patrón anclado al terreno cuando la cámara se desplaza; la opacidad vigente es 0,20. La interfaz conserva su brillo normal y el efecto continúa si se oculta el HUD. `UpgradeOfferCard` usa una superficie plana común definida en la escena, sin sprite de marco ni variantes por rareza; el tier, icono, título y descripción están en el contenido, y un shader procedural dibuja detrás un aura radial con partículas cuyo color depende de la rareza. El hover refuerza el aura sin cambiar la superficie compartida. El tinte vigente está fijado por ADR-0100 y el efecto de nube por ADR-0109/0099; ADR-0082, ADR-0088 y ADR-0080 conservan el historial de altura y tier/ramas.

En M3, `HexGrid` es autoridad para las celdas confirmadas; `TerrainPlacementValidator` es un `RefCounted` puro que evalúa la candidata y devuelve `TerrainPlacementResult`; `Main` orquesta selección/confirmación y `TerrainPiecePreview` dibuja tablero y ghost, sin cambiar la autoridad lógica. Las conexiones internas usan los bordes PATH explícitos; las conexiones entre piezas también aceptan las aperturas laterales flexibles derivadas en cada salida de borde, según [ADR-0006](../decisions/ADR-0006-sockets-laterales-flexibles-de-camino.md). M4 ya incorpora la conectividad global mediante el snapshot `PathGraph` descrito arriba.

La navegación del mapa la controla un `Camera2D` en `Main`: `WASD` mueve la cámara de manera continua (diagonales normalizadas y velocidad compensada por zoom) y el botón central con arrastre panea; la rueda acerca/aleja alrededor del cursor, también mientras se coloca terreno; Ctrl+rueda gira la pieza en esa fase. `Ctrl+D` conserva el overlay diagnóstico de rutas sin ocupar la tecla `D`. El HUD vive en `CanvasLayer` y no se desplaza ni escala con la cámara. Las teclas mantenidas se limpian al perder el foco de la ventana.

M5 añade `GameBase` y `WaveDirector` a la escena principal. `GameBase` posee un `HealthComponent` y dibuja una huella hexagonal completa del mismo radio que una celda; `Enemy` compone su propio `HealthComponent` y `PathFollowerComponent`. `WaveDirector` recibe la oleada, el snapshot M4, la base y el contenedor Y-sort; crea enemigos desde sus Resources y escucha sus señales de llegada o muerte. La UI de `Main` presenta Health, recuento y estado, y traduce las señales de oleada a fases de `RunManager`. Durante `COMBAT` se bloquean las entradas de colocación de terreno. El tablero semilla de campaña usa `StartingBoardData` con radio axial 2 (19 celdas) y configuración de camino mínima de cuatro celdas PATH por spawn; el grafo vuelve a aplicar ese límite tras cada expansión. Al iniciar cada run, el tablero entero y sus sockets PATH rotan un paso de 60°; el contador persistente avanza por seis orientaciones sin cambiar la coordenada de la base.

M6 añade `BuildController` a `Main`; recibe el `HexGrid`, `Entities`, el origen y el radio del mapa. El controlador valida fase, terreno construible y ocupación antes de instanciar una escena desde `TowerData`, y registra la torre en `HexCell.occupied/tower_id`. Solo Grass y Mountain permiten construir, así que las torres no cambian `PathGraph`. `Tower` es una escena Y-sorted con datos, nivel, selección, prioridad de objetivo, alcance y cadencia; consulta los nodos del grupo `enemies` cada 0.1 s y usa `PathFollowerComponent.get_progress_ratio()` para first/last progress. Su placeholder vectorial dibuja pedestal, orientación, anillo de alcance al seleccionarlo y un flash hitscan al atacar. `TerrainPiecePreview` representa el marcador/rango de colocación. La UI de `Main` alterna build mode, muestra errores, cambia la prioridad y mejora la torre. En M6 las mejoras no tenían coste; M9 incorpora costes configurables. ADR-0009 recoge las reglas temporales.

M7 añade `DamageService` como hijo de `Main`, no como Autoload global. `BuildController` lo inyecta al configurar cada `Tower`, y cada disparo crea un `DamagePacket` con origen, tags y perfil desde `TowerData`. `DamageService.preview_damage()` calcula el resultado sin mutar al enemigo para el HUD; `apply_damage()` usa ese mismo cálculo, aplica daño y contrarregeneración y emite `damage_resolved`. `Enemy` mantiene su `HealthComponent` y regenera en `_process` con fracciones acumuladas. En M7 las respuestas de muerte seguían conectadas a las señales M5 y todavía no pagaban recompensa; M9 conecta ahora el evento al `RunEconomyService`. La fórmula plana y los HUD/fixtures de diagnóstico descritos por ADR-0010/0011 son históricos; M12A documenta el daño actual por capas. M61 retiró el panel F3 y el selector de oleadas DEBUG; M64 retiró las oleadas/dummies M7/M8 sin consumidor. Los perfiles de torre de diagnóstico `8`, `9` y `0` permanecen accesibles, pero no existe una oleada de entrenamiento seleccionable. `H` sigue ocultando el HUD entero. Los scripts de combate cargan packet/result por rutas `preload` y exponen interfaces base `RefCounted`/`Node` en las fronteras, evitando referencias de tipo a clases globales recién creadas antes de que Godot refresque su caché. ADR-0010 fija el contrato histórico y ADR-0011 registra el HUD temporal.

M8 añade `StatusEffectData` como Resource y `StatusEffectController` como hijo de cada `Enemy`; los Resources de configuración se comparten como datos, pero stacks, duración restante, temporizador de tick y origen activo pertenecen a cada enemigo. `TowerData.status_effects` proporciona los payloads del impacto; `DamageService` aplica el daño directo y, si el objetivo sigue vivo, aplica los estados. El controlador combina modificadores de velocidad tomando el mínimo multiplicador activo, ejecuta ticks periódicos llamando al mismo `DamageService` (sin payloads recursivos) y limpia al expirar el estado, morir el enemigo o llegar a la base. La instancia del servicio de combate continúa siendo local a `Main` e inyectada al enemigo por `WaveDirector`. Los Resources Slow/Burn/Bleed y la Status Probe son datos configurables provisionales; la oleada/dummy de entrenamiento se retiró en M64. No hay barra de prueba ni inspector F3 en runtime. Las reglas de acumulación y propiedad del tick están registradas en ADR-0012.

M9 añade `RunEconomyService` como nodo local de `Main`, configurado desde `RunEconomyData`; conserva Gold y Mana de la run sin mezclar la moneda meta. `BuildController` recibe el servicio y aplica compras atómicas de torres/mejoras con costes de `TowerData`. TowerTower` recibe la misma instancia: antes de un impacto con coste de Mana intenta gastar el recurso y no dispara si el saldo no alcanza. El servicio regenera Mana durante la run, acotado por su capacidad, y emite señales de saldo; el HUD refleja Gold, Mana, regeneración, costes de atajos y coste de mejora. `WaveDirector` guarda la recompensa de cada instancia enemiga, la paga una vez al derrotarla y descarta el pago al llegar a base; entrega la recompensa de ronda solo al limpiar todos los grupos. `Main` pasa brevemente a `ROUND_REWARD` antes de permitir la siguiente oleada. La remuneración por baja ya emitida se conserva aunque otro enemigo haga fallar esa oleada; no se paga el bonus de ronda fallida. Los valores de M9 son fixtures provisionales. ADR-0013 registra el contrato y las provisionalidades.

M9.5, adelantado por petición del usuario antes de la progresión completa M10 y las cartas M11, introduce siete `TowerData`: Ballista, Mortar, Tesla Coil, Frost Keep, Flame Thrower, Poison Sprayer y Shredder. Las decisiones posteriores M12A/ADR-0023 amplían el modelo a Shield/Armor/Health y sustituyen la afirmación histórica de que Shield faltaba. Ballista usa un proyectil dirigido; Mortar un proyectil con explosión al aterrizar; Tesla alcanza todos los enemigos en su rango circular; Frost deja caer copos sobre PATH dentro de un cuadrado y aplica daño/Slow solo por contacto individual; Flame y Poison usan cono; Shredder recorre PATH, daña y añade Bleed mientras pierde daño base por enemigo. Todos pasan por `DamageService`. El roster principal tiene atajos `1–7`; los perfiles M7/M8 siguen en `8`, `9` y `0`. Las cifras de sus Resources parten de la tabla compartida por el usuario, son configurables y no representan balance final.

M10 carga y valida 45 WaveData ordenadas y un total fijo de 1.093 enemigos directos. WaveEnemyGroupData.count es la cantidad exacta por grupo; WaveDirector crea una unidad a la vez y la distribuye round-robin entre rutas alcanzables. Abrir varios endpoints no multiplica el total. El contador de spawns pendientes cubre el calendario directo; el contador de enemigos activos incluye invocaciones. Una transformación conserva la misma instancia activa y el pago de baja para que la ronda no se cierre hasta derrotar la fase final.

EnemyData contiene boss_tier y una lista tipada de EnemyAbilityData. WaveData deriva Standard, Boss o Tier 2 Boss del boss_tier presente; no asigna Miniboss a las rondas 17/19. WaveDirector ejecuta habilidades de aparición, proximidad, agotamiento de capas, muerte y temporizador, con radios configurables. Ooogie von Ooogovich (Haunted) usa un perfil propio provisional, invoca dos Bats cada 2 s y se transforma en Bat con 2.500 Health. Otros perfiles adoptan las habilidades individuales seleccionadas para el roster; las formas encadenadas de Ooogiehedron usan overrides de capas/speed sin mutar sus Resources base.

La campaña termina al limpiar la ronda 45 y solo expande el terreno después de limpiar las rondas 1–44. En cada victoria intermedia, TerrainPiecePreview conserva su comparación del grafo candidato; la siguiente ronda se habilita después de una colocación válida, y M11 puede intercalar su oferta de cartas. Los fixtures de diagnóstico M7/M8 se mantienen aislados de avance, pagos y daño a base. Las habilidades, los perfiles de enemigo y sus sprites se detallan en 13_CONTENT_ROSTER.md; la tabla exacta de cantidad/orden está en 14_CAMPANA_45_RONDAS.md. ADR-0037 sustituye el contrato de calendario y spawn de ADR-0016/0018 y las selecciones de contenido de ADR-0032/0033/0035/0036.
M11 usa `CardData`, `CardModifierOperation`, `CardPoolData`, `CardCatalogData` y `RunCardService`. El servicio es local a `Main`: combina el pool base con catálogos, resuelve prerequisitos entre catálogos y filtra por unlock, roster de run, selecciones y límite. El catálogo de mejora tiene 190 IDs únicos, que representan 173 entradas compatibles; M35 añade seis Resources de reclutamiento y el pool de run contiene 196 IDs. Tras colocar la expansión cada tres rondas entre la 3 y la 42, mantiene `CARD_OFFER` hasta elegir; luego habilita la ronda siguiente. `CardPoolData`, `RunCardService`, la escena y el panel comparten una oferta fija de tres opciones. Las cartas de reclutamiento elegibles se mezclan con las mejoras y las no elegidas permanecen elegibles en ofertas futuras. Torres, estados, base y economía consultan modificadores temporales sin mutar `.tres`. La frecuencia está confirmada; cifras y rarezas son configurables/provisionales. Ver ADR-0021/0062/0076/0093.

M12 extiende el Autoload `MetaProgression` para separar moneda/unlocks de `RunEconomyService` y mantenerlos entre escenas. `MetaProgressionData` combina su catálogo base con `PermanentUpgradeCatalogData`; hay 31 IDs en los Resources y 30 mejoras comprables en el mapa. `card_draw` se conserva como ID legado para perfiles guardados, pero queda retirado de la tienda porque la oferta siempre tiene tres opciones. Las mejoras disponibles tienen operaciones por nivel para economía, daño H/A/S, Gold por baja, vida/reparación de base y unlocks. La tienda terminal aparece al acabar por victoria o derrota, cobra y persiste, y sus efectos se activan en la siguiente run. La compra revierte si falla la persistencia. `BuildController` comprueba el unlock además de que el HUD oculte torres bloqueadas. JSON `SaveData` conserva versión, moneda, IDs, niveles, contadores y el último resumen; no guarda nodos ni Resources. La escritura usa `user://`, temporal, backup y rename. Un archivo corrupto o incompatible no se sobrescribe y deja la tienda en lectura segura. Importes y efectos siguen configurables; ver [ADR-0022](../decisions/ADR-0022-meta-progression-y-guardado.md) y [ADR-0062](../decisions/ADR-0062-catalogo-de-upgrade-cards-y-permanent-upgrades.md).
M12 extiende el Autoload `MetaProgression` para separar moneda/unlocks de `RunEconomyService` y mantenerlos entre escenas. `MetaProgressionData` combina su catálogo base con `PermanentUpgradeCatalogData`; 31 IDs persisten en los Resources, de los cuales 30 se ofrecen para compra y `card_draw` se conserva como ID legado oculto. La presentación terminal por pestañas de M12 es histórica y quedó sustituida por M35: la misma tienda se monta en el menú y tras Game Over, usando `MetaProgressionMap` con nodos/conexiones. Los efectos se activan en la run siguiente. La compra revierte si falla la persistencia. `BuildController` y el roster temporal distinguen unlock persistente de reclutamiento en run. JSON `SaveData` conserva versión, moneda, IDs, niveles, contadores y el último resumen; no guarda nodos ni Resources. La escritura usa `user://`, temporal, backup y rename. Un archivo corrupto o incompatible no se sobrescribe y deja la tienda en lectura segura. Importes y efectos siguen configurables; ver [ADR-0022](../decisions/ADR-0022-meta-progression-y-guardado.md), [ADR-0076](../decisions/ADR-0076-economia-inicial-roster-de-run-y-flujo-de-escenas.md) y [ADR-0077](../decisions/ADR-0077-mapa-de-mejoras-permanentes-con-nodos.md).

M12A completa la resolución de combate por capas. `EnemyData` y `Enemy` modelan Health, Armor y Shield con regeneración por capa; cada perfil configura los tres máximos y un máximo cero desactiva esa capa. Los estados suprimen la regeneración correspondiente y el dibujo renderiza en filas las capas presentes (fragmenta Health). `DamagePacket` lleva un multiplicador por capa y marca los ticks periódicos; `DamageService` resuelve la capa activa Shield→Armor→Health y añade +1 al multiplicador de ataque cuando Bleed/Burn/Poison coincide con Health/Armor/Shield. Los ticks no reciben el bonus y usan la relación de daño por capa 1.0/0.5. `Tower` mantiene un total de mejoras y tres contadores independientes de 0 a 15; cada subida manual o automática añade +1 de daño base y +1 solo a la capa afectada. El XP y los costes Gold crecen exponencialmente por nivel de esa capa según factores configurables del `TowerData`. `BuildController` cobra el coste de la capa seleccionada, calcula precio por torre del mismo tipo y permite demoler para reducir el precio futuro. La interfaz pone el nivel y la barra XP bajo cada mejora y ordena tres criterios de targeting en selectores numerados. Ballista y Mortar usan `TowerProjectile`; Mortar impacta un área, y Frost calcula cobertura cuadrada/PATH. El fixture DEBUG Health/Armor/Shield descrito en la aceptación histórica se retiró en M64; las capas actuales se verifican con perfiles de campaña que tengan esos máximos configurados. Los factores iniciales son provisionales; ver [ADR-0023](../decisions/ADR-0023-reglas-de-torres-y-capas-de-vida.md) y [ADR-0046](../decisions/ADR-0046-progresion-de-mejoras-y-feedback-de-seleccion.md).

M13 organiza la presentación sin modificar las reglas de combate. M22 actualiza el layout del HUD normal en `CanvasLayer`: salud y atajos arriba a la izquierda, Gold/Mana arriba a la derecha, ronda centrada y datos/acciones de torre bajo los recursos a la derecha. Salud y ronda no tienen fondos de panel compartido. Gold y Mana comparten un panel horizontal 9-slice de 176 × 52 px, según M61/ADR-0112. La salud de base se dibuja cada 10 puntos y su texto queda superpuesto; `BaseData` expone el sprite RGBA y `GameBase` lo dibuja a escala nativa 1:1. `RunEconomyService` repone Mana al máximo efectivo en las rondas de campaña; la interfaz redondea su lectura a entero. Cada cambio de Gold anima en conjunto su icono y cifra con escala, rebote y destello. La fila muestra solo las torres reclutadas en la run: Ballista empieza disponible y las demás entran tras elegir su carta de reclutamiento. Las tarjetas numeran secuencialmente las torres visibles y las teclas 1, 2, 3… seleccionan ese orden, que se compacta al reclutar nuevas torres. El precio usa el mismo panel 9-slice que Iniciar ronda. El panel derecho se ajusta a su contenido sin scroll; si la ventana no alcanza su alto natural, escala verticalmente para mantener toda la información dentro de pantalla. El preview se dibuja por encima del tablero y señala con verde/rojo la validez de la colocación; al colocar cualquier torre, la ficha y el ghost calculan daño y alcance efectivos para la elevación bajo el cursor, incluyendo modificadores de run/permanentes (M63/ADR-0114). La distribución de selección, las mejoras H/A/S, targeting, debug, iconos de torre, estados y feedback de daño siguen los contratos de las versiones anteriores de M13. `MetaShopPanel` comparte una única tienda entre las escenas de menú y final de run; menú, partida y pausa son escenas separadas, Escape abre pausa y perder devuelve al menú con la tienda abierta. Game Over presenta cantidad y daño por tipo construido durante la run; omite los tipos desbloqueados pero no desplegados (M63/ADR-0114). La tienda permanente usa `MetaProgressionMap` y nodos de una escena común; conexiones muestran prerequisitos, iconos grandes identifican la mejora, tooltips describen bloqueos y partículas confirman la compra. El progreso de ronda usa una ventana móvil de 15 puntos, mantiene hover de enemigos y desvanece el extremo futuro. Ver [ADR-0076](../decisions/ADR-0076-economia-inicial-roster-de-run-y-flujo-de-escenas.md), [ADR-0077](../decisions/ADR-0077-mapa-de-mejoras-permanentes-con-nodos.md) y [ADR-0083](../decisions/ADR-0083-timeline-fijo-de-quince-rondas-y-preview-fiel.md), además de [ADR-0049](../decisions/ADR-0049-arquitectura-hibrida-ui-editable.md) y [ADR-0105](../decisions/ADR-0105-tooltip-de-spawn-atajos-oro-zoom-y-escala-de-torre.md).

Actualización de arquitectura (ADR-0049): el antiguo helper de estilos fue retirado en favor del Theme local `game/ui/themes/rogue_hud_theme.tres`, aplicado a raíces UI concretas y sin sobrescribir el Theme global. Los controles repetidos de torre/capa/mejora, oferta de cartas, tienda/mapa permanente, menús y filas del tooltip de ronda tienen escenas editables y scripts de presentación asociados; el mapa dibuja conexiones y crea su etiqueta central/partículas de feedback en runtime. El arranque de `project.godot` apunta al menú principal; menú, partida y pausa son escenas distintas. `Main` sigue coordinando partida, entradas y señales, mientras los sistemas existentes conservan la autoridad sobre progreso, compras, economía y reglas. La oferta presenta exactamente tres cards; las cartas de reclutamiento elegibles se mezclan con las mejoras. El dibujo de progreso de ronda sigue procedural, ahora sobre ventana móvil. La aceptación de la implementación actual queda pendiente en ventana. Ver ADR-0049, ADR-0076–0078 y ADR-0093.

Actualización histórica de recursos visuales (ADR-0050): 20 recursos Texture2D (16 iconos generales y cuatro cursores) viven como propiedades de `game/ui/resources/icon_catalog.tres`, referenciado también por el Inspector de la raíz `Main`. Las tarjetas de torre y capa exponen texturas por instancia y las sincronizan con sus `TextureRect` para previsualizarlas en el editor. Gold/Mana, el sprite 9-slice de iniciar ronda y los marcos de expansión permanecen asignados en sus escenas. Las upgrade cards ya no usan los marcos PNG de aquella etapa; M40 las define como una superficie plana común con aura procedural según ADR-0088. El Theme local es la autoridad editable para los paneles de fondo plano. Los Resources de gameplay no incorporan campos UI.

Históricamente M15 asignaba obstáculos y cofres por seed/coordenada, y refería los objetos decorativos como props; aquella selección de cinco imágenes y el desplazamiento vertical de 6 px quedaron sustituidos por M39. La asignación de cofres sigue al confirmar una expansión, con base de 1 % y el modificador persistente vigente hasta 20 %. El hover del cofre mantiene su salto y resplandor; el premio inicial de 25 Gold sigue configurable/provisional. Las flechas animadas muestran el flujo PATH y se actualizan con un grafo candidato legal. Ver ADR-0040, ADR-0041, ADR-0060 y ADR-0087.

En el renderer vigente, `TerrainVisualCatalog` asigna determinísticamente elevación, obstáculos y decoración a partir de seed/coordenada o identidad de oferta. Cada uno de los 18 props compatibles con el terreno tiene un 10 % de probabilidad independiente por celda; se limita a dos props únicos, que se dibujan bajo el obstáculo y no tienen input ni hitbox. La oferta conserva los mismos IDs entre miniatura, ghost y tablero; si una celda vecina a la base se normaliza de Mountain a Grass, el ghost y la colocación regeneran juntos los props compatibles con Grass usando la coordenada global. Los PNG de props tienen 96×96 px y se muestran a 39,6×39,6 px con offsets que impiden que dos sprites se solapen. Los ocho obstáculos se generan con las tasas existentes (Grass 25 %, Mountain 15 %), usan PNG de 208×208 px, se muestran centrados a 94,6×94,6 px y se dibujan por delante de los props. Las celdas vecinas inmediatas a la base no superan altura 1: una Mountain se normaliza a Grass 1 y Path permanece 0. La base conserva su PNG fuente de 270×352 px y se dibuja estirado en una caja de 1,8 × el radio de huella de ancho por 2,8 × el radio de alto, con el borde inferior visual anclado y una huella lógica de un hexágono. Las fachadas se ordenan con `Entities.y_sort_enabled` desde el borde inferior expuesto, a la altura de la tapa vecina o del suelo; cubren actores detrás y quedan detrás de actores delante. Ver [ADR-0087](../decisions/ADR-0087-props-obstaculos-y-altura-junto-a-base.md), [ADR-0089](../decisions/ADR-0089-ajustes-escala-occlusion-portales-props.md), [ADR-0090](../decisions/ADR-0090-fachadas-limitadas-a-la-diferencia-de-elevacion.md) y [ADR-0096](../decisions/ADR-0096-base-mas-alta-y-visible.md).

Actualización de assets M15 (ADR-0058): se sustituyeron los 23 PNG de terreno, obstáculos, base, portal e iconos de torre en sus rutas runtime. Path_01/02/03 ahora muestran el arte Dirt_01/02/03 sin camino pintado. `TerrainVisualCatalog`, los sockets PATH, el `PathGraph` y el overlay de flechas no cambiaron; los originales están respaldados en `art_generation/originals_replaced/2026-10-13/`.

M16 conecta `Tower.impact_effect_requested` con `AnimatedImpactVfx`, que toma cada sprite sheet local y anima sus frames en el hex objetivo. `Main` aplica cuatro cursores locales por estado de interacción: normal, objeto/control interactivo, acción inválida o colocación. Todos los sprites se guardan bajo `assets/sprites/`; los PNG del pack Tiny Swords se mantienen como dependencia local ignorada por Git en `assets/sprites/third_party/tiny_swords/`, cuya README explica su instalación. La procedencia y licencia están en [Origen](../references/ORIGEN.md).

Cada torre se dibuja con un único Sprite2D que carga directamente el PNG completo de `assets/sprites/ui/icons/`, sin recortes ni composición por regiones. TowerBuildGhost, la card de construcción y el retrato de Tower Info reutilizan la misma textura cacheada. El centro coincide con el de la celda, el arte baja 8 px, y solo usa flip_h para seguir enemigos a la izquierda; no hay rotación visual. Mundo/ghost comparten escala 0,9504 × 1,12 para dejar margen al sprite completo, mientras las imágenes de cards y Tower Info mantienen su caja de UI. Las torres y los obstáculos interactuables usan `interactable_outline.gdshader` para dilatar alfa y producir el contorno blanco. `GameBase` reutiliza el shader con `outline_size_px = 6`; `SpawnPortal` lo usa en modo outline-only permanente con tamaño 3; los obstáculos también usan tamaño 3. `Enemy` crea una capa de sprite outline-only detrás de su dibujo manual, a tamaño 2, la sincroniza con textura, escala, orientación y salto, y obtiene un color claro por `EnemyData.id`; los perfiles sin asignación usan el tono de reserva. Las capas no agrupan actores en `CanvasGroup`, así cada sprite conserva su Y-sort; las barras y los estados se pintan encima del enemigo. El ghost de construcción mantiene su tinte verde/rojo de legalidad. No se generan sombras proyectadas individuales por terreno u obstáculo; el velo animado de nubes vive en una capa global bajo el HUD. El flujo PATH se oculta durante la previsualización/colocación de una expansión y el hover no dibuja los sockets sobre el camino. El Tower Info muestra la bonificación de daño y alcance de la elevación de la torre seleccionada. El XP de perfil existente financia tanto desbloqueos de torres como mejoras permanentes. Véanse [ADR-0069](../decisions/ADR-0069-desbloqueos-xp-y-feedback-de-altura.md), [ADR-0070](../decisions/ADR-0070-sin-sombras-y-rutas-limpias-en-expansion.md), [ADR-0093](../decisions/ADR-0093-preview-de-terreno-oferta-fija-y-torres-articuladas.md), [ADR-0097](../decisions/ADR-0097-outline-de-base-y-enemigos.md) y [ADR-0098](../decisions/ADR-0098-ajuste-de-outline-y-contorno-de-portales.md). La fuente Patrick Hand está asignada al tema predeterminado del proyecto, incluidos los contadores pintados en `_draw()`.

M51/ADR-0101 define el feedback visual activo. `AnimatedImpact` recorta hojas en tira o cuadrícula; el overlay de evento `FeedbackVfxLayer` vive en CanvasLayer 130, sigue la transformación de viewport/cámara y usa `PROCESS_MODE_ALWAYS`. Los VFX de juego reciben y conservan su posición del mundo durante toda la animación: paneo y zoom los transforman junto al terreno y los actores, sin desplazarlos respecto del evento que los originó. Aun así, la capa se dibuja sobre HUD, cards y preview; los efectos de una sola vez se liberan al acabar, mientras los iconos de estado y el resplandor del cofre persisten con su condición. El marcador `ui_click` usa `CursorFeedbackVfxLayer` en viewport para permanecer sobre el cursor. Las siete torres disponen de hojas `shoot` e `impact`; M52 dosifica `shoot` en las torres de fuego continuo y mantiene un efecto por cada disparo de Ballista/Mortar, mientras `impact` se reproduce al aplicar daño. Mortar marca el objetivo previsto con `tap_ripple`. La muerte final de enemigo emite `enemy_killed`, y cada subida manual/automática emite `level_up_effect_requested`; las hojas de base, cofre, terreno y Game Over se lanzan desde sus eventos de dominio/UI. Ver [ADR-0106](../decisions/ADR-0106-vfx-de-evento-anclados-al-mundo-durante-el-paneo.md).

El antiguo uso de Tiny Swords para impactos de M16 se conserva solo como historial: M51/ADR-0101 lo sustituye por las hojas locales Cozy Chunky. M52/ADR-0102 reemplaza la composición por regiones de torre por los PNG completos; `Tower` y `TowerBuildGhost` usan el mismo recurso, centrado en la celda con un desplazamiento visual compartido de 8 px hacia abajo. Tesla Coil, Frost Keep, Flame Thrower, Poison Sprayer y Shredder limitan su VFX `shoot` con cooldown aleatorio individual de 2,0–2,5 s; Ballista y Mortar mantienen un efecto por proyectil. No se limitan impactos ni ataques. `pickup.png` se muestra al construir torres y retirar obstáculos.

Actualización visual (ADR-0053/0054): el panel de expansión y Tower Info usan superficies planas; se retiraron los marcos PNG y la placa oscura que se pintaba bajo las torres. `rogue_hud_theme.tres` es el tema global, y sus tamaños de texto existentes se conservan al establecer Patrick Hand como fuente predeterminada.

M32/M33 retiraron los fondos PNG por tier y las variantes por rareza. M36 introdujo un sprite vertical NinePatch, que M40 elimina: una card plana compartida, icono grande y datos legibles; la rareza solo controla el aura radial procedural y sus partículas. La oferta de mejoras tiene siempre tres opciones; el panel mantiene exactamente tres botones activos y Card Draw está retirado del mapa. Los reclutamientos se mezclan con las mejoras dentro de esos tres espacios. `TerrainPieceCardPreview` omite sockets/ramificaciones PATH, pero usa las mismas tapas hexagonales y fachadas delanteras que el tablero, ordenadas por el anclaje axial; las alturas mostradas son las de la oferta real. Durante la colocación, `Q` y `E` giran la pieza; Ctrl+rueda también la gira durante la colocación y la rueda sin Ctrl siempre conserva el zoom. `T` busca un ancla y rotación aleatorias, las valida con `TerrainPlacementValidator` y `PathGraph`, y confirma automáticamente si la expansión conserva una continuación futura. Si no hay candidata, no modifica el tablero. Sin torre ni pieza seleccionadas, el hover de celda presenta el tooltip compacto descrito arriba. Ver ADR-0071, ADR-0072, ADR-0075, ADR-0080, ADR-0083, ADR-0088 y [ADR-0093](../decisions/ADR-0093-preview-de-terreno-oferta-fija-y-torres-articuladas.md).

M56 añade `BalatroCardHover` como componente visual común para cards de mejora de run, selección de terreno y selección de torre: al pasar el cursor anima escala/inclinación y un brillo radial ligado a la posición del cursor, sin cambiar la lógica de botones. El brillo se adjunta diferido tras completar el montaje de la card, evitando modificar la lista de hijos durante `_ready()`. `WaterBackgroundLayer` dibuja agua procedural en CanvasLayer -10, detrás del tablero, partículas y HUD, y no forma parte de la simulación ni de los sprites del mundo. M57 reemplaza su paleta oscura por azul y espuma casi blanca, con manchas grandes y movimiento lento. Al emitir la baja final, `WaveDirector` envía el `Enemy` a `Main`; este toma una instantánea visual antes de que el actor salga del árbol y la envía a `EnemyDeathParticlePool`, que copia textura/frame/modulación/espejo y escala a un emisor GPU one-shot. Los emisores bajo `FeedbackVfxLayer` 130 conservan coordenadas locales al paneo/zoom y duplican su material para bajas simultáneas. La tienda permanente muestra iconos pertinentes en todos sus nodos y representa cada coste/saldo/recompensa con el icono local de perfil, sin imprimir el nombre de esa moneda. Ver [ADR-0107](../decisions/ADR-0107-feedback-de-progresion-y-presentacion-de-cards.md) y [ADR-0108](../decisions/ADR-0108-agua-wind-waker-y-explosion-pixel-de-enemigo.md).

M58 refuerza la sombra del shader de nubes a opacidad 0,20. El shader de `WaterBackgroundLayer` conserva el fondo a pantalla completa y convierte UV de pantalla en coordenadas del mundo con posición, viewport y zoom de `Camera2D`, de modo que el patrón acompañe el paneo sin mover el rectángulo. La actualización comparte el ciclo del sombreado; ver [ADR-0109](../decisions/ADR-0109-sombra-de-nubes-reforzada-y-agua-anclada-a-camara.md).

M59 dibuja `UpgradeHealth`, `UpgradeArmor` y `UpgradeShield` como controles cuadrados de 128 × 128 dentro de un `HBoxContainer` centrado; el importe y el icono se envuelven con el mismo `StyleBox` y dimensiones de precio que la tarjeta de atajo. Para la cámara, `Main` suma el offset base, el impulso de daño y una oscilación ambiental pequeña activa entre `wave_started` y `wave_completed`/`wave_failed`; así ambos shakes coexisten y el ambiental termina junto con la ronda. Ver [ADR-0110](../decisions/ADR-0110-mejoras-de-capa-en-fila-y-shake-de-ronda.md).

M60 fija `XPBar` de `TowerLayerUpgradeButton` en 88 × 8 px y la centra dentro de la card. La acción de demoler torre es un botón horizontal con icono, texto `DEMOLER` y un panel de Gold que muestra `+<reembolso>`; el cálculo sigue viniendo de `BuildController.get_demolition_refund()`. La acción sobre obstáculos muestra `DEMOLER` más el coste calculado por `Main` con signo `−`; la acción sobre portales muestra `RETIRAR` más su coste, también con signo `−`. Las tres presentan el icono de Gold dentro del panel. Ver [ADR-0111](../decisions/ADR-0111-barra-de-xp-y-precios-de-demolicion.md).

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

## Interfaz actualizada en M61

`Main` centraliza el color de los valores numéricos de efectos para que las cards de run y los nodos permanentes compartan verde para mejoras y rojo para perjuicios. Tower Info compara los stats efectivos de `Tower` con `TowerData`, marca sus aumentos/disminuciones y presenta por separado el bonus de elevación; el coste efectivo de Mana usa el criterio inverso, verde si baja y rojo si sube. El botón compacto de pausa es un `PauseToggleButton` junto a la vida: el script dibuja glyph de pausa/play y `P`, mantiene su propio proceso durante pausa y conserva la acción de teclado. El panel técnico de terreno y los fixtures de oleada desaparecen del árbol runtime; la campaña sigue inicializando su lista de 45 `WaveData` para `RoundProgressStrip` y avanza en secuencia. `TerrainPlacementPrompt` aparece solo con una pieza seleccionada, encima de la barra inferior, y comparte su estado de validación con `TerrainPlacementPreview`. La selección de portal oculta el tooltip de hover, reproduce el efecto `ui_click` y rellena `WorldObjectEnemyList` dentro de Tower Info con el reparto asignado. `GoldPanel` y `ManaPanel` comparten `gold_panel_style.tres`, dimensiones 176 × 52, iconos 32 × 32 y cifra de 23 px. Ver [ADR-0112](../decisions/ADR-0112-legibilidad-de-mejoras-hud-y-colocacion.md).

## Correcciones de interfaz en M62

`Main` exporta los límites y márgenes responsivos del panel Tower Info para editarlos desde el Inspector; el ajuste automático no toca la escala del contenedor interno ni los márgenes de escena. `TowerLayerUpgradeButton` coloca su icono bajo un `CenterContainer` y declara el tamaño en `tower_layer_upgrade_button.tscn`. Los badges de demolición están fuera de los botones y la escena mantiene toda la jerarquía de coste bajo `RemoveWorldObjectRow`, incluido el nodo único `%RemovalCostLabel`. La selección de portal retiene su `SpawnPortal` mientras muestra el reparto en `WorldObjectEnemyList`. El shader de agua sustituye el reloj global `TIME` por el uniforme `water_time`, que solo avanza desde el proceso pausable de `Main`. Ver [ADR-0113](../decisions/ADR-0113-ajustes-de-paneles-y-pausa-de-agua.md).

## Preview de torre y progresión en M63

`Tower.get_damage_for`, `Tower.get_range_hexes_for` y `Tower.get_cell_world_position` son las funciones compartidas por la torre construida, el panel de selección y el ghost de colocación. La elevación, las cartas activas y la progresión permanente se incluyen antes de construir, de modo que la cifra y el círculo de alcance previstos coinciden con el estado efectivo al confirmar. El radio de ataque se muestra con un anillo de alto contraste mientras la torre esté bajo el cursor o seleccionada. La colocación de terreno usa verde lima para una oferta válida y rojo intenso para una inválida, con relleno y contorno reforzados.

`RunManager` registra las instancias construidas y agrega daño por ID de torre; el resumen final omite los tipos cuyo contador de construcción sea cero y no filtra por desbloqueo permanente. `MetaProgressionMap` alinea los siete nodos de desbloqueo de torre en la misma fila y coloca sus mejoras Health/Armor/Shield como tres opciones horizontales independientes. Cada `MetaUpgradeNode` asigna el icono del catálogo con fallback de perfil y, en última instancia, de daño; su precio queda centrado y grande con el icono de perfil (`exp.png`) a su derecha. La aceptación visual e interactiva queda pendiente según M63 de `10_ACCEPTANCE_TESTS.md`; ver [ADR-0114](../decisions/ADR-0114-preview-de-torre-resumen-y-mapa-permanente.md).

## Interfaz editable y recursos en M64

Los valores persistentes de UI se guardan en escenas, Themes, StyleBoxes y propiedades `@export`: fuentes, tamaños, separaciones, márgenes, estilos, geometría y estados semánticos. Los scripts de controles actualizan estado/contenido, pero no reinstalan estilos o tamaños al iniciar. `Main` expone configuración de Tower Info, filas/tooltip de enemigo y portal, inventario/ofertas de terreno, colores HUD, botón de ronda, cursor y tamaños de VFX; las escenas de mejora, mapa permanente, timeline, portal y H/A/S exponen sus propios parámetros. `Enemy` declara fuente/tamaño de iconos de estado y números flotantes, junto a sus barras H/A/S. El número flotante sigue siendo un control creado en runtime, pero obtiene aspecto del Inspector de Enemy. El mapa expone sus partículas de desbloqueo y el resumen de menú el tamaño del confeti. Los iconos de estado se dibujan a 28×28 px; límites de importación (iconos 256, portal 768 y cofre 168) reducen textura cargada sin alterar archivos fuente. M64 también retiró el script no instanciado de preview de portal y los Resources de demo M7/M8 sin consumidores. Ver [ADR-0115](../decisions/ADR-0115-ui-inspector-y-limpieza-de-recursos.md).

## Determinismo
La run debe tener `run_seed`.
Toda selección aleatoria importante debe derivar de un RNG de run para poder reproducir bugs.
