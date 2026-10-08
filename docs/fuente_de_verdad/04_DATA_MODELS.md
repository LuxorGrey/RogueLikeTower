# Data Models

Los nombres son guía de implementación. Codex puede ajustar sintaxis, no responsabilidades.

## HexCoord
```gdscript
class_name HexCoord
extends RefCounted

var q: int
var r: int

func s() -> int:
    return -q - r
```

Operaciones:
- add
- neighbor(direction)
- distance_to
- rotated60(steps)
- equality/hash/key

## HexCell
```text
coord: HexCoord
terrain_type: PATH | GRASS | MOUNTAIN
elevation: int 0..2
buildable: bool
occupied: bool
tower_id: optional
piece_instance_id
path_edges: bitmask/array[6]
flexible_path_edges: bitmask/array[6] derivada en runtime
visual_variant
```

Reglas:
- PATH: elevation 0; buildable false.
- GRASS: buildable true; elevation definida por pieza (por defecto 1).
- MOUNTAIN: elevation 2; buildable true.
- Elevation no cambia coordenada lógica.

## TerrainPieceCellData
```text
local_coord: Vector2i
terrain_type: PATH | GRASS | MOUNTAIN
elevation: int 0..2
path_edges: bitmask[6]
flexible_path_edges: bitmask[6] derivada de las salidas externas
visual_variant: StringName
```

Cada pieza de terreno contiene exactamente 7 celdas. La forma hexagonal centrada en `(0,0)` más sus seis vecinos es la plantilla de losetas; el tablero de inicio de 19 celdas es un Resource aparte. Las coordenadas exactas y la vista de colores están en [05_HEX_GRID_AND_TERRAIN.md](05_HEX_GRID_AND_TERRAIN.md). Cada celda conserva su tipo de terreno al rotar. La mezcla y paleta son placeholders editables, no balance ni arte final.

Validación vigente del Resource: ID y nombre no vacíos; peso no negativo; coordenadas únicas y conectadas; pivote `(0,0)`; tipos/elevaciones permitidos; PATH a altura 0, MOUNTAIN a altura 2; solo PATH declara `path_edges`; y toda conexión interna PATH es recíproca y llega a otra celda PATH. `requires_path_connection` exige al menos un socket PATH hacia fuera de la huella. `flexible_path_edges` se deriva al rotar la pieza a partir de las salidas externas y abre las dos caras laterales contiguas que también queden fuera de la huella; no se configura en el `.tres`. Las reglas completas de enlace están en [05_HEX_GRID_AND_TERRAIN.md](05_HEX_GRID_AND_TERRAIN.md).

## TerrainPieceData : Resource
```text
id
display_name
cells: Array[TerrainPieceCellData] # exactamente 7
weight
tags
requires_path_connection: bool
```

`weight` y `tags` quedan disponibles para el pool de contenido; M3 no selecciona piezas al azar. Las piezas expansivas activan `requires_path_connection`. El tablero semilla ya no se construye con `TerrainPieceData`.

## StartingBoardData : Resource
```text
id
display_name
base_coord: Vector2i
minimum_spawn_route_cells: int
cells: Array[TerrainPieceCellData] # exactamente 19 en la campaña
```

`data/terrain/starting_board.tres` define el hexágono axial de radio 2, la celda de base y el camino inicial. Valida coordenadas únicas, elevaciones/terrenos válidos y conectividad de la huella. `Main` instancia sus datos en `HexCell`; la ruta se valida con `PathGraph`, que exige como mínimo cuatro celdas PATH desde cada endpoint activo hasta la base durante la campaña.

Rotación:
- rotar coordenadas locales alrededor del origen.
- rotar `path_edges` el mismo número de pasos.
- derivar y rotar también `flexible_path_edges` sin modificar el Resource original.
- nunca editar el Resource original; generar transformación temporal.

## TerrainPlacementResult / TerrainPlacementValidator
El validador de M3 recibe la pieza, el pivote axial, la rotación y las celdas actuales del `HexGrid`. Devuelve legalidad, errores, celdas instanciadas, si toca el tablero y cuántas conexiones compatibles tiene. Comprueba solapamiento, contacto por borde, sockets PATH explícitos/flexibles y una conexión a PATH existente cuando la pieza la requiere. Las conexiones internas usan exclusivamente `path_edges`; para conectar dos piezas se acepta una pareja complementaria en la unión de `path_edges` y `flexible_path_edges`. Una salida explícita no puede apuntar a terreno que no sea PATH. No busca rutas globales spawn-base; eso corresponde a `PathGraph` de M4.

## PathEndpoint / PathRoute / PathGraph
`PathEndpoint` identifica su rol (`SPAWN` o `BASE`), la celda PATH axial, la dirección de borde y la coordenada externa para un spawn. `PathRoute` contiene un candidato spawn, el objetivo base y la secuencia ordenada de celdas PATH que une ambos; M4 cachea una ruta mínima por candidato.

`PathGraph.rebuild(board_cells, base_coord, minimum_spawn_route_cells = 1)` deriva `nodes` y `adjacency` desde las celdas PATH. Solo crea adyacencia si ambos lados ofrecen un socket recíproco mediante `path_edges | flexible_path_edges`. Identifica como candidatos spawn las salidas `path_edges` que apuntan fuera del mapa; no convierte sockets solo flexibles en endpoints. `find_route(start, goal)` usa BFS de coste unitario con desempate estable por orden de las direcciones axiales; `get_branch_count()` cuenta nodos PATH con al menos tres vecinos conectados. El snapshot expone `spawn_endpoints`, `base_endpoint`, `routes`, `errors` e `is_valid`.

Un snapshot válido necesita que la base esté sobre PATH, que haya al menos un candidato spawn, que cada spawn tenga ruta a la base y que todos los nodos PATH pertenezcan a la red de la base; `Main` pasa el mínimo de cuatro celdas PATH para el tablero inicial y la campaña. La coordenada base provisional `(0,0)` pertenece a la muestra M4/M5; `GameBase` se instancia allí en M5, pero la ubicación final del objetivo sigue abierta. `Main` reconstruye al iniciar y al confirmar expansión, no en cada frame. `TerrainPiecePreview` representa las rutas/endpoints como debug y no modifica el grafo. El algoritmo y sus límites están registrados en [ADR-0007](../decisiones/ADR-0007-grafo-logico-de-caminos.md) y [ADR-0025](../decisiones/ADR-0025-tablero-inicial-y-ruta-minima.md).

## TowerData : Resource
```text
id
unlock_id
display_name
build_cost
meta_unlock_cost
upgrade_costs
base_damage
attack_rate
range_hexes
damage_profile
targeting_mode
status_to_apply
mana_cost_or_usage (si aplica)
attack_pattern + area/chain/cone parameters
visual_archetype + placeholder_color
allowed_terrain
height_rules
scene
```

M6 implementa en `data/towers/tower_data.gd`: identidad, daño base, RPM/cadencia, alcance, terrenos, prioridades, elevación, niveles, costes y escena. M12 agrega unlock/meta coste. M12A añade build-cost increment, mana por ataque/segundo y escalado, RPM de base, multiplicadores Health/Armor/Shield, chance crítica, bonus de elevación, threshold de XP y parámetros Frost. Los patrones soportan objetivo único, área, chain, cono, sawblade y todos-en-rango (Tesla). Los siete Resources empiezan con las estadísticas de la tabla que compartió el usuario; costes secundarios, umbrales, máximos, ataque y balance continúan configurables/provisionales. Comprar/mejorar no muta el Resource compartido.

`Tower` separa nivel/damage base, bonos de cada capa y tres criterios de objetivo únicos. Cada upgrade cuesta el `upgrade_costs[level-1]`, suma +1 daño base y +1 a la capa elegida; el XP runtime también sube nivel al alcanzar `targeting_xp_required_per_level`, asignando la capa del HP actual del enemigo que mantiene en rango. Elevación añade +1 daño base y +0.5 de rango por nivel. El RPM es fijo salvo Frost Keep, cuya cobertura suma 18 RPM por PATH cubierto. Build price escala como `build_cost + same_type_count × build_cost_increment`; demoler baja ese conteo. `TowerData` contiene ataque visual `SINGLE_TARGET`, `AREA`, `CHAIN`, `CONE` o `SAWBLADE`; Ballista/Mortar tienen proyectiles, Mortar hace splash al aterrizar, Frost usa cobertura cuadrada y Shredder sigue una ruta PATH. Ver [ADR-0023](../decisiones/ADR-0023-reglas-de-torres-y-capas-de-vida.md).

Las prioridades incluyen progreso, valores más altos/bajos de Health/Armor/Shield, capa actual menor y velocidad. `DamageService.apply_damage` centraliza daño directo, crítico, tags y las tres capas. Poison (bit 8), las resistencias de tags y Shield se configuran en `EnemyData`; los enemigos dibujan una barra segmentada con el total de HP máximos repartido entre escudo, armadura y salud. La política de overkill (exceso descartado al llegar a cero de la capa activa) es provisional por falta de regla explícita.

## EnemyData : Resource
```text
id
display_name
max_health
armor
shield
regen_per_second
armor_regen_per_second
shield_regen_per_second
move_speed
base_damage
reward
defense_tags
status_resistances
physical_damage_multiplier
fire_damage_multiplier
arcane_damage_multiplier
poison_damage_multiplier
placeholder_color
placeholder_radius
scene
```

M5 implementa Health; M7 añade Armor y regen de vida. M12A añade Shield y regeneración separada por capa. Bleed suprime la regeneración de Health; Burn la de Armor; Poison la de Shield. El orden activo es Shield→Armor→Health. Los multiplicadores recibidos por múltiples tags se multiplican. Los fixtures, resistencias, stats, colores y recompensas de enemigos siguen siendo configurables. La barra segmentada conserva la proporción de máximos combinados.

`defense_tags` y `status_resistances` permanecen conceptuales; los multiplicadores por tags y las resistencias futuras son mecanismos separados.

## BaseData / HealthComponent

`BaseData` configura el ID, nombre y vida máxima de la base. `HealthComponent` inicializa vida, aplica daño/curación acotados y emite `health_changed` y `health_depleted`; en M5 lo consumen `GameBase` y `Enemy`. El objetivo inicial `(0,0)` sigue siendo una decisión provisional del prototipo. `data/base/base_data.tres` define 50 de vida provisional.

## DamagePacket
```text
raw_damage
critical_multiplier
source_id
damage_tags
health_damage_multiplier
armor_damage_multiplier
shield_damage_multiplier
regen_counter_strength
regen_counter_duration
status_payloads
status_total_damage_overrides # presupuesto bruto total opcional por estado, distribuido entre sus ticks
legacy_health_multiplier/armor_multiplier # compatibilidad histórica M7
```

El contrato M7 de mitigación plana de Armor queda sustituido por M12A. `DamagePacket` es transitorio y `DamageResult` registra la capa activa y daño por cada HP. El daño es `floor(raw_damage × critical_multiplier × layer_multiplier × damage_tag_multiplier)` y se limita al valor actual de la capa activa: Shield antes que Armor, después Health. El excedente no desborda provisionalmente. Chance crítica produce ×1/×2/×3/×4 con bandas de 50%. Los multiplicadores de tag vienen de `EnemyData` y los tags simultáneos se multiplican. M8 consume payloads si el objetivo sigue vivo; cada tick de DoT vuelve al mismo servicio. Un override de total fija presupuesto bruto por aplicación de estado sin mutar Resources. Ver ADR-0010 para el contrato histórico y [ADR-0023](../decisiones/ADR-0023-reglas-de-torres-y-capas-de-vida.md) para la regla vigente.

## StatusEffectData
```text
id
display_name
duration
tick_interval
max_stacks
stack_rule: REFRESH | ADD_STACKS
speed_multiplier
damage_per_tick
damage_tags
health_layer_multiplier
armor_layer_multiplier
shield_layer_multiplier
```

M8 implementa estos campos en `game/combat/status_effect_data.gd`. `duration` siempre es positiva; `tick_interval` puede ser cero si el efecto no hace daño periódico. `REFRESH` deja una acumulación y reinicia la duración; `ADD_STACKS` suma una acumulación hasta `max_stacks` y también reinicia la duración. Reaplicar no reinicia el reloj del próximo tick. El daño por tick se multiplica por las acumulaciones y pasa por `DamageService` con los `damage_tags` configurados. Si una torre reaplica el mismo ID, la definición y el `source_id` activos pasan a ser los de la aplicación más reciente. Cada enemigo guarda sus propias instancias runtime y no modifica los Resources compartidos. Los efectos de velocidad se combinan usando el menor `speed_multiplier`; al quitar el último efecto se restaura `1.0`. Muerte y llegada a la base limpian todos los estados. El campo de resistencias queda fuera mientras el diseño no lo necesite. Slow, Burn, Bleed y el Poison de M9.5 son datos configurables provisionales; Bleed mantiene el fixture M8 y también se usa en Shredder.

`TowerData.status_effects` es una lista de estos Resources, sin IDs repetidos dentro de una torre. `DamagePacket.status_payloads` transporta esa lista del impacto al `DamageService`, y `DamageResult.applied_status_ids` permite auditar qué se aplicó. El override de presupuesto no modifica el Resource compartido: el controlador guarda el total y los ticks restantes en la instancia del estado de cada enemigo.

## WaveData
```text
round_number
encounter_type: STANDARD | MINIBOSS | TIER_2_BOSS
groups[]
  enemy_data
  count
  spawn_interval
  spawn_endpoint_policy
  delay_before_group
round_reward
```

M5 implementa `WaveData` y `WaveEnemyGroupData` como Resources validados: datos de enemigo, cantidad, intervalo, política de endpoint y demora de grupo. La oleada de demostración `data/waves/round_01.tres` genera tres enemigos con intervalo de 1 segundo. `FIRST_SORTED` selecciona siempre el primer `PathRoute` válido en orden determinista; `ROUND_ROBIN` también está disponible. Esta selección se limita a la muestra M5 y no confirma una política de balance para las rondas definitivas.

En M10, para grupos de campaña, `count` significa número de pulsos por endpoint: cada pulso crea en el mismo frame un enemigo por cada ruta alcanzable del `PathGraph`, y `spawn_interval` separa pulsos, no enemigos de endpoints distintos. Así todos los finales PATH abiertos participan y los contadores se inicializan con `count × rutas`. Las políticas `FIRST_SORTED`/`ROUND_ROBIN` permanecen para las oleadas de diagnóstico M5/M7/M8.

`PathFollowerComponent` conserva waypoints mundiales derivados de las coordenadas axiales de `PathRoute`, índice del waypoint y progreso normalizado del tramo. El movimiento ocurre en `_physics_process`; el mapa no cambia mientras la oleada está activa.

M9 implementa `round_reward` en `WaveData`; se concede una sola vez cuando terminan todos los spawns y no quedan enemigos activos. Los grupos pueden pagar bajas inmediatamente; un enemigo que llega a base no recibe recompensa. Si una oleada falla no se paga el bonus de ronda, aunque las bajas ya resueltas conservan su pago.

M10 implementa `WaveCampaignData` con 20 `WaveData` ordenados y validación de ronda; exige `MINIBOSS` en 17/19 y `TIER_2_BOSS` en 20. `health_growth_per_round`, `base_damage_growth_per_round` y `reward_growth_per_round` son modificadores globales configurables. `WaveDirector` conserva `pending_spawn_count` y enemigos vivos por separado, emite ambos valores, y solo completa si ambos son cero y el generador terminó. Para escalar, duplica el `EnemyData` por instancia y modifica el snapshot runtime; jamás altera la definición compartida. Un modo `diagnostic` para los fixtures M7/M8 suprime daño a base y recompensas. Las estadísticas de campaña y el jefe/minijefe genéricos son placeholders, no balance confirmado ni selección de una variante comunitaria.

## RunEconomyData / RunEconomyService
`RunEconomyData` es una configuración Resource de una run: `starting_gold`, `starting_mana`, `maximum_mana` y `mana_regen_per_second`. `RunEconomyService` es un Node hijo de `Main`, no Autoload: es dueño de los saldos runtime de esa escena, valida compras/gastos, limita el maná a la capacidad y emite `gold_changed`/`mana_changed`. La UI escucha esas señales, pero no modifica los saldos directamente. El oro de construcción se reinicia con el perfil de arranque de la run y no es `MetaProgression.meta_currency`; M12 conserva la moneda permanente por separado y pasa los bonuses de upgrades al configurar la economía de la siguiente run. El perfil provisional actual empieza con 150 oro y 100/100 maná, con una tasa interna de 1.5 maná/s. Las tasas fraccionarias se describen al jugador como equivalencias de cantidades enteras por intervalos enteros, sin cambiar el valor runtime.

## CardModifierOperation
```text
type
affected_tower_id: optional
affected_damage_tags: optional bitmask
affected_status_id: optional
value
```

Tipos disponibles: daño plano/multiplicador, alcance, radio de área, coste de maná, duración de estado, maná máximo/regeneración, crítico y suma al multiplicador de una capa H/A/E. La cadencia ya no se modifica mediante cartas; se mantiene fija salvo Frost Keep por cobertura PATH.

## CardData
```text
id
display_name
description
rarity
unlock_requirement: optional content ID
tags[]
modifier_operations: Array[CardModifierOperation]
offer_weight
max_per_run
```

Una carta describe una elección permanente solo durante la run; sus operaciones no modifican el `TowerData` ni otros `.tres` compartidos. Las operaciones aditivas se suman y los multiplicadores se combinan multiplicando. `unlock_requirement` vacío indica una carta global; los IDs de torre usan `tower:<TowerData.id>`.

## CardPoolData / RunCardService
`CardPoolData` mantiene cartas, tamaño de oferta, primera ronda e intervalo. `RunCardService` filtra por unlocks de la run, peso y límite de copias; construye una oferta sin duplicados y agrega los modificadores de cartas elegidas. El calendario y la cantidad actuales son placeholders configurables, no reglas definitivas. `RunCardService` es local a `Main`; M12 alimenta sus filtros con los IDs persistentes de torres y upgrades de contenido.

## PermanentUpgradeData
```text
id
display_name
description
max_level
cost_by_level[]
prerequisites[]
operations_by_level[]: PermanentUpgradeOperation
```

`PermanentUpgradeOperation` expresa una sola operación por nivel: sumar oro/maná inicial, capacidad/regeneración de maná, multiplicar el daño de torres o desbloquear un ID de contenido. La tienda lee el nivel persistido, valida prerrequisitos y saldo, cobra y persiste; el Resource de definición no se modifica. `MetaProgressionData` configura las torres iniciales, catálogo, base/per-round/bonus de victoria y máximo de recompensa. La demo inicia con Ballista y ofrece cuatro upgrades de stats más el Archivo de cartas; estos datos/costes son provisionales.

## SaveData
```json
{
  "version": 1,
  "meta_currency": 0,
  "unlocked_towers": ["tower:ballista_demo"],
  "permanent_upgrade_levels": {},
  "settings": {},
  "total_runs_started": 0,
  "total_runs_completed": 0,
  "total_victories": 0,
  "best_round_reached": 0,
  "total_meta_earned": 0,
  "last_run_summary": {}
}
```

`SaveData` convierte a/desde primitivas JSON y valida tipos/rangos. La ruta es `user://rogue_tower_meta.json`; se escribe un temporal, conserva el anterior como `.bak` y reemplaza el archivo. Versiones distintas y JSON inválido no se cargan ni se sobrescriben automáticamente. El resumen almacena outcome, ronda alcanzada/completada, recompensa, saldo, número y seed; no se serializa el estado temporal de una run.
