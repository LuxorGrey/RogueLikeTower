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

Cada pieza contiene exactamente 7 celdas. La huella inicial es el centro axial `(0,0)` más sus seis vecinos; las coordenadas exactas y la vista de colores están en [05_HEX_GRID_AND_TERRAIN.md](05_HEX_GRID_AND_TERRAIN.md). Cada celda conserva su tipo de terreno al rotar. La primera mezcla y la paleta de colores son placeholders editables, no balance ni arte final.

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

`weight` y `tags` quedan disponibles para el pool de contenido; M3 no selecciona piezas al azar. La pieza inicial desactiva `requires_path_connection` porque crea el tablero semilla; las piezas expansivas lo activan.

Rotación:
- rotar coordenadas locales alrededor del origen.
- rotar `path_edges` el mismo número de pasos.
- derivar y rotar también `flexible_path_edges` sin modificar el Resource original.
- nunca editar el Resource original; generar transformación temporal.

## TerrainPlacementResult / TerrainPlacementValidator
El validador de M3 recibe la pieza, el pivote axial, la rotación y las celdas actuales del `HexGrid`. Devuelve legalidad, errores, celdas instanciadas, si toca el tablero y cuántas conexiones compatibles tiene. Comprueba solapamiento, contacto por borde, sockets PATH explícitos/flexibles y una conexión a PATH existente cuando la pieza la requiere. Las conexiones internas usan exclusivamente `path_edges`; para conectar dos piezas se acepta una pareja complementaria en la unión de `path_edges` y `flexible_path_edges`. Una salida explícita no puede apuntar a terreno que no sea PATH. No busca rutas globales spawn-base; eso corresponde a `PathGraph` de M4.

## PathEndpoint / PathRoute / PathGraph
`PathEndpoint` identifica su rol (`SPAWN` o `BASE`), la celda PATH axial, la dirección de borde y la coordenada externa para un spawn. `PathRoute` contiene un candidato spawn, el objetivo base y la secuencia ordenada de celdas PATH que une ambos; M4 cachea una ruta mínima por candidato.

`PathGraph.rebuild(board_cells, base_coord)` deriva `nodes` y `adjacency` desde las celdas PATH. Solo crea adyacencia si ambos lados ofrecen un socket recíproco mediante `path_edges | flexible_path_edges`. Identifica como candidatos spawn las salidas `path_edges` que apuntan fuera del mapa; no convierte sockets solo flexibles en endpoints. `find_route(start, goal)` usa BFS de coste unitario con desempate estable por orden de las direcciones axiales; `get_branch_count()` cuenta nodos PATH con al menos tres vecinos conectados. El snapshot expone `spawn_endpoints`, `base_endpoint`, `routes`, `errors` e `is_valid`.

Un snapshot válido necesita que la base esté sobre PATH, que haya al menos un candidato spawn, que cada spawn tenga ruta a la base y que todos los nodos PATH pertenezcan a la red de la base. La coordenada base provisional `(0,0)` pertenece a la muestra M4/M5; `GameBase` se instancia allí en M5, pero la ubicación final del objetivo sigue abierta. `Main` reconstruye al iniciar y al confirmar expansión, no en cada frame. `TerrainPiecePreview` representa las rutas/endpoints como debug y no modifica el grafo. El algoritmo y sus límites están registrados en [ADR-0007](../decisiones/ADR-0007-grafo-logico-de-caminos.md).

## TowerData : Resource
```text
id
display_name
build_cost
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
unlock_id
scene
```

M6 implementa en `data/towers/tower_data.gd`: `id`, `display_name`, `base_damage`, `attack_rate`, `range_hexes`, `allowed_terrain_mask`, `targeting_mode`, `height_range_bonus_per_level`, `max_level`, los incrementos configurables de mejora y `scene`. M9 incorpora `build_cost`, `upgrade_costs` (un coste por cada nivel alcanzable) y `mana_cost_per_attack`; la compra y la mejora se verifican antes de cambiar ocupación o nivel. La instancia del Resource es configuración compartida y no se modifica al comprar/mejorar. M7 añade `damage_tags`, `armor_multiplier`, `health_multiplier`, `regen_counter_strength` y `regen_counter_duration`; los perfiles se copian a un `DamagePacket` por impacto, no se muta el Resource compartido. M9.5 añade `role_summary`, `attack_pattern` (`SINGLE_TARGET`, `AREA`, `CHAIN`, `CONE`, `SAWBLADE`), parámetros de radio/límite/ángulo, velocidad/radio de impacto/pérdida de daño de proyectil y `visual_archetype`/`visual_color`. `Tower` usa esos datos para impactos de objetivo único, área instantánea, cadena, cono o una hoja que recorre el PATH restante de su objetivo. Las cifras actuales de los siete Resources son placeholders de gameplay, no balance final.

Las prioridades implementadas son `FIRST_PROGRESS`, `LAST_PROGRESS`, `HIGHEST_HEALTH` y `HIGHEST_ARMOR`. El progreso sale del índice y avance normalizados de `PathFollowerComponent`. Todo daño directo llama a `DamageService.apply_damage`; `Tower` no contiene fórmulas de mitigación. Shredder usa el mismo servicio para cada enemigo que atraviesa y aplica su payload Bleed. El tipo Poison (bit 8) se añade en M9.5 con multiplicador recibido configurable en `EnemyData`; Shield queda fuera porque los enemigos no tienen ese stat/barra.

## EnemyData : Resource
```text
id
display_name
max_health
armor
regen_per_second
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

M5 implementó `id`, `display_name`, `max_health`, `move_speed`, `base_damage` y `scene`. M6 añadió `armor` para priorizar objetivos. M7 activa `armor`, `regen_per_second` y multiplicadores recibidos de daño Physical/Fire/Arcane; M9.5 añade `poison_damage_multiplier` para el tag Poison. Los valores recibidos por múltiples tags se multiplican. M9 añade `kill_reward`, que `WaveDirector` concede una vez tras la señal de derrota; llegar a base no paga la recompensa. M10 añade `placeholder_color`/`placeholder_radius` para distinguir visualmente tipos de enemigo mientras no haya arte final. Los stats, resistencias, colores y recompensas de fixtures son provisionales. Las reglas confirmadas de escudo → armadura → salud y counters por capa no equivalen a que el atributo Shield esté implementado; ver [ADR-0016](../decisiones/ADR-0016-campana-de-veinte-rondas.md) y el diseño fuente.

`defense_tags` y `status_resistances` del modelo conceptual siguen reservados para decisiones de contenido/status posteriores; no hay stat ni barra de escudo de enemigo implementada.

## BaseData / HealthComponent

`BaseData` configura el ID, nombre y vida máxima de la base. `HealthComponent` inicializa vida, aplica daño/curación acotados y emite `health_changed` y `health_depleted`; en M5 lo consumen `GameBase` y `Enemy`. El objetivo inicial `(0,0)` sigue siendo una decisión provisional del prototipo. `data/base/base_data.tres` define 50 de vida provisional.

## DamagePacket
```text
raw_damage
source_id
damage_tags
armor_multiplier
health_multiplier
regen_counter_strength
regen_counter_duration
status_payloads
status_total_damage_overrides # presupuesto bruto total opcional por estado, distribuido entre sus ticks
critical? # mantener desactivado si no se aprueba
```

M7 implementa `DamagePacket` como `RefCounted` transitorio y `DamageResult` como resultado auditable por HUD/señales. `DamageService` calcula `armor_absorbed = min(raw_damage, armor * armor_multiplier)`, luego `floor(max(raw_damage - armor_absorbed, 0) * damage_tag_multiplier * health_multiplier)`. El multiplicador por tag viene de `EnemyData`; si se combinan tags se multiplican sus valores. La vida aplicada queda limitada al HP actual. La contrarregeneración suprime la fracción configurada de `regen_per_second` durante `regen_counter_duration`; impactos sucesivos conservan la mayor fuerza y refrescan el tiempo restante con el máximo. Estos contratos son provisionales y están registrados en ADR-0010. M8 consume `status_payloads` después del daño directo y la contrarregeneración, solo si el objetivo sigue vivo. `status_total_damage_overrides` es opcional: establece un presupuesto bruto por aplicación de estado que el controlador distribuye entre sus ticks; cada tick sigue pasando por `DamageService` y sus defensas.

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

`PathFollowerComponent` conserva waypoints mundiales derivados de las coordenadas axiales de `PathRoute`, índice del waypoint y progreso normalizado del tramo. El movimiento ocurre en `_physics_process`; el mapa no cambia mientras la oleada está activa.

M9 implementa `round_reward` en `WaveData`; se concede una sola vez cuando terminan todos los spawns y no quedan enemigos activos. Los grupos pueden pagar bajas inmediatamente; un enemigo que llega a base no recibe recompensa. Si una oleada falla no se paga el bonus de ronda, aunque las bajas ya resueltas conservan su pago.

M10 implementa `WaveCampaignData` con 20 `WaveData` ordenados y validación de ronda; exige `MINIBOSS` en 17/19 y `TIER_2_BOSS` en 20. `health_growth_per_round`, `base_damage_growth_per_round` y `reward_growth_per_round` son modificadores globales configurables. `WaveDirector` conserva `pending_spawn_count` y enemigos vivos por separado, emite ambos valores, y solo completa si ambos son cero y el generador terminó. Para escalar, duplica el `EnemyData` por instancia y modifica el snapshot runtime; jamás altera la definición compartida. Un modo `diagnostic` para los fixtures M7/M8 suprime daño a base y recompensas. Las estadísticas de campaña y el jefe/minijefe genéricos son placeholders, no balance confirmado ni selección de una variante comunitaria.

## RunEconomyData / RunEconomyService
`RunEconomyData` es una configuración Resource de una run: `starting_gold`, `starting_mana`, `maximum_mana` y `mana_regen_per_second`. `RunEconomyService` es un Node hijo de `Main`, no Autoload: es dueño de los saldos runtime de esa escena, valida compras/gastos, limita el maná a la capacidad y emite `gold_changed`/`mana_changed`. La UI escucha esas señales, pero no modifica los saldos directamente. El oro de construcción se reinicia con el perfil de arranque de la run y no es `MetaProgression.meta_currency`; M12 será dueño de la moneda permanente y del guardado. Las cifras actuales (150 oro, 30/100 maná y 1.5 maná/s) son provisionales.

## CardData
```text
id
display_name
description
rarity
unlock_requirement
tags
modifier_operations[]
```

Ejemplos de operaciones:
- tower_damage_mult(tag, value)
- tower_range_add(tag, value)
- status_duration_mult(status, value)
- mana_max_add(value)
- mana_regen_add(value)
- unlock_run_modifier(...)

## PermanentUpgradeData
```text
id
display_name
max_level
cost_by_level[]
prerequisites[]
operations_by_level[]
```

## SaveData
```json
{
  "version": 1,
  "meta_currency": 0,
  "unlocked_towers": [],
  "permanent_upgrade_levels": {},
  "settings": {}
}
```
