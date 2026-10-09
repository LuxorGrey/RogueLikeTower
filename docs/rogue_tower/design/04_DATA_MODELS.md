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

Un snapshot válido necesita que la base esté sobre PATH, que haya al menos un candidato spawn, que cada spawn tenga ruta a la base y que todos los nodos PATH pertenezcan a la red de la base; `Main` pasa el mínimo de cuatro celdas PATH para el tablero inicial y la campaña. La coordenada base provisional `(0,0)` pertenece a la muestra M4/M5; `GameBase` se instancia allí en M5, pero la ubicación final del objetivo sigue abierta. El snapshot activo se reconstruye al iniciar o confirmar expansión. Mientras se mueve un ghost legal, `Main` construye aparte un snapshot candidato para actualizar en vivo la vista previa de rutas, spawns y cambios de recorrido; ese cálculo no sustituye ni muta el grafo activo. `TerrainPiecePreview` dibuja ese candidato y la información de debug. El algoritmo y sus límites están registrados en [ADR-0007](../decisions/ADR-0007-grafo-logico-de-caminos.md) y [ADR-0025](../decisions/ADR-0025-tablero-inicial-y-ruta-minima.md).

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
visual_icon_size
allowed_terrain
height_rules
scene
```

M6 implementa en `data/towers/tower_data.gd`: identidad, daño base, RPM/cadencia, alcance, terrenos, prioridades, elevación, niveles, costes y escena. M12 agrega unlock/meta coste. M12A añade build-cost increment, mana por ataque/segundo y escalado, RPM de base, multiplicadores Health/Armor/Shield, chance crítica, bonus de elevación, threshold de XP y parámetros Frost. M13 añade `visual_icon_size`, que dimensiona por Resource el sprite y el pedestal de cada torre. Los perfiles actuales usan 62 px frente a los 54 px anteriores (aprox. +15%); el icono de preview usa el mismo tamaño. Los patrones soportan objetivo único, área, chain, cono, sawblade y todos-en-rango (Tesla). Los siete Resources adoptan los parámetros base de Rogue Tower seleccionados por el usuario; Tesla Coil y Flame Thrower siguen los ajustes del changelog oficial en ADR-0036. Reglas propias de niveles, XP, altura, áreas/patrones adaptados y mejora manual siguen configurables. Comprar/mejorar no muta el Resource compartido.

`Tower` separa nivel/damage base, bonos de cada capa y tres criterios de objetivo únicos. Cada upgrade cuesta el `upgrade_costs[level-1]`, suma +1 daño base y +1 a la capa elegida; el XP runtime también sube nivel al alcanzar `targeting_xp_required_per_level`, asignando la capa del HP actual del enemigo que mantiene en rango. Elevación añade +1 daño base y +0.5 de rango por nivel. El RPM es fijo salvo Frost Keep, cuya cobertura suma 18 RPM por PATH cubierto. Build price escala como `build_cost + same_type_count × build_cost_increment`; demoler baja ese conteo. `TowerData` contiene ataque visual `SINGLE_TARGET`, `AREA`, `CHAIN`, `CONE` o `SAWBLADE`; Ballista/Mortar tienen proyectiles, Mortar hace splash al aterrizar, Frost usa cobertura cuadrada y Shredder sigue una ruta PATH. Ver [ADR-0023](../decisions/ADR-0023-reglas-de-torres-y-capas-de-vida.md).

Las prioridades incluyen progreso, valores más altos/bajos de Health/Armor/Shield, capa actual menor y velocidad. `DamageService.apply_damage` centraliza daño directo, crítico, tags y las tres capas. El modelo de cada enemigo contiene Health, Armor y Shield; cada perfil configura los tres máximos y cero desactiva una capa para esa unidad. Los ataques directos solo afectan a la capa activa en orden Shield→Armor→Health y usan su multiplicador. Si el objetivo tiene Bleed, Burn o Poison, los ataques directos suman +1 al multiplicador de Health, Armor o Shield, respectivamente; es un bonus único por estado activo y no escala con sus acumulaciones. Los ticks de estado usan los multiplicadores por capa del efecto: 1.0 en la capa asociada y 0.5 en las otras. `Enemy` dibuja una fila por cada capa con máximo positivo, y segmenta Health. La demo incluye el dummy DEBUG y los 45 perfiles de campaña; los perfiles que tengan Shield muestran esa capa en juego. El exceso al vaciar una capa se descarta en el mismo impacto; el artículo de referencia confirma el orden y el acceso solo a la capa activa, pero no especifica expresamente el destino del exceso, así que esta política sigue marcada como provisional.

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
kill_reward
boss_tier
abilities: Array[EnemyAbilityData]
physical_damage_multiplier
fire_damage_multiplier
arcane_damage_multiplier
poison_damage_multiplier
placeholder_color
placeholder_radius
sprite_texture: Texture2D opcional
sprite_extent
scene
```

Históricamente M5 introdujo Health, M7 Armor/regen y M12A completó Shield con regeneración separada; el modelo vigente de cada enemigo contiene los tres pools. Cada perfil configura los máximos, y un máximo cero omite esa capa en el juego. El orden activo es Shield→Armor→Health. Bleed/Burn/Poison detienen la regeneración de Health/Armor/Shield y aumentan en +1 el multiplicador de ataque de esa capa; sus ticks aplican el daño por capa 1.0/0.5/0.5 según la capa activa. Los multiplicadores recibidos por múltiples tags se multiplican. `sprite_texture` referencia el PNG individual del perfil; si no hay textura, `Enemy` conserva el dibujo vectorial placeholder. La barra dibuja las capas con máximo positivo en filas diferenciadas y fragmenta Health.

`EnemyData.sprite_extent` configura individualmente el lado del PNG de cada enemigo en juego; sus perfiles activos aumentaron el tamaño de sprite alrededor de 15%. `placeholder_radius` también creció por perfil y se usa para la sombra, el placeholder vectorial y la colocación de barras/estados; no representa una hitbox ni cambia movimiento, selección, ocupación o colisión lógica. Si no hay textura se conserva el dibujo vectorial. `EnemyData` no exporta `defense_tags` ni `status_resistances`: los tags del paquete se definen en `DamagePacket` y el Resource sí configura multiplicadores recibidos por cada tag. Las resistencias de estado no están implementadas.

## BaseData / HealthComponent

`BaseData` configura el ID, nombre, Health máxima, `sprite_texture` y `sprite_size` de la base. La textura RGBA es un PNG individual que se puede sustituir desde el Resource sin cambiar `GameBase`; el tamaño define su escala visual y no altera la huella lógica hexagonal. El sprite vigente se amplió de 112×112 a 129×129 (aprox. +15%). `HealthComponent` inicializa Health, aplica daño/curación acotados y emite `health_changed` y `health_depleted`; en M5 lo consumen `GameBase` y `Enemy`. La barra del HUD divide Health en segmentos de 10 (el último puede ser parcial). El objetivo inicial `(0,0)` sigue siendo una decisión provisional del prototipo. `data/base/base_data.tres` define 50 de Health provisional.

## DamagePacket
```text
raw_damage
critical_multiplier
source_id
damage_tags
armor_multiplier # compatibilidad histórica M7
health_multiplier # compatibilidad histórica M7
health_damage_multiplier
armor_damage_multiplier
shield_damage_multiplier
is_status_damage # marca los ticks para no aplicarles el bonus de ataque directo
regen_counter_strength
regen_counter_duration
status_payloads
status_total_damage_overrides # presupuesto bruto total opcional por estado, distribuido entre sus ticks
```

El contrato M7 de mitigación plana de Armor queda sustituido por M12A. `DamagePacket` es transitorio y `DamageResult` registra la capa activa y daño por cada HP. Para un ataque directo, el daño es `floor(raw_damage × critical_multiplier × (layer_multiplier + status_bonus) × damage_tag_multiplier)`, limitado a la capa activa: Shield antes que Armor, después Health. `status_bonus` es +1 si Bleed/Health, Burn/Armor o Poison/Shield coincide con la capa activa. Los ticks llevan `is_status_damage` y no reciben ese bonus: sus multiplicadores propios determinan daño completo en su capa asociada y mitad en las otras. El excedente no desborda provisionalmente. Chance crítica produce ×1/×2/×3/×4 con bandas de 50%. Los multiplicadores de tag vienen de `EnemyData` y los tags simultáneos se multiplican. M8 consume payloads si el objetivo sigue vivo; cada tick de DoT vuelve al mismo servicio. Un override de total fija presupuesto bruto por aplicación de estado sin mutar Resources. Ver ADR-0010 para el contrato histórico y [ADR-0023](../decisions/ADR-0023-reglas-de-torres-y-capas-de-vida.md) para la regla vigente.

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

## EnemyAbilityData

EnemyData incluye boss_tier y abilities: Array[EnemyAbilityData]. Cada habilidad declara un trigger (aparición, cerca de la base, armor agotado, shield agotado, muerte o periódica), un efecto (Haste, Fortification, invocar, transformar o teletransportar), política de objetivo, fuerza/intervalo/radio y los datos u overrides del enemigo afectado. Los radios de juego aprobados son cinco hexágonos para cercanía a la base y dos hexágonos para auras. Haste/Fortification tienen fuerza máxima 60 y decaen 6 puntos por segundo; Haste suma su porcentaje a la velocidad y Fortification resta cinco al daño base recibido por golpe. Los parámetros de invocación y transformación pertenecen a cada perfil.

## WaveData

Campos: round_number, encounter_type STANDARD/BOSS/TIER_2_BOSS, groups, round_reward. Cada grupo declara enemy_data, count, spawn_interval, spawn_endpoint_policy y delay_before_group.

M5 implementa WaveData y WaveEnemyGroupData como Resources validados. Los fixtures de diagnóstico conservan FIRST_SORTED/ROUND_ROBIN como políticas configurables.

En la campaña, count es la cantidad directa de enemigos del grupo. WaveDirector crea un enemigo por intervalo y rota las rutas alcanzables round-robin; la cantidad no depende del número de endpoints abiertos. Los grupos se ejecutan en el orden de la tabla, que define [14 — Campaña de 45 rondas](14_CAMPANA_45_RONDAS.md). Los enemigos invocados cuentan como apariciones adicionales y permanecen dentro de la misma oleada. Una transformación conserva la instancia, progreso y recompensa de la baja original.

WaveCampaignData exige 45 WaveData consecutivas y 1.093 enemigos directos. Valida el número de ronda, el tipo de encuentro calculado desde boss_tier y el total fijo. Las tasas globales de Health, daño a base y recompensa por baja están en cero; no se cambia EnemyData al escalar la ronda. Las recompensas de limpieza y cadencias se especifican en ADR-0037 y se mantienen provisionales donde se indica. El juego termina al limpiar la ronda 45; tras las rondas 1–44 hay una expansión. No existen designaciones Miniboss propias en 17/19. Los diagnósticos siguen aislados de la campaña.

## RunEconomyData / RunEconomyService
`RunEconomyData` es una configuración Resource de una run: `starting_gold`, `starting_mana`, `maximum_mana` y `mana_regen_per_second`. `RunEconomyService` es un Node hijo de `Main`, no Autoload: es dueño de los saldos runtime de esa escena, valida compras/gastos, limita el Mana a la capacidad y emite `gold_changed`/`mana_changed`. `refill_mana_to_max()` restaura el Mana al máximo efectivo al comenzar cada ronda de campaña. La UI escucha esas señales, pero no modifica los saldos directamente; el contador de Mana se presenta como entero y el Gold aplica feedback visual al cambiar. El Gold de construcción se reinicia con el perfil de arranque de la run y no es `MetaProgression.meta_currency`; M12 conserva la moneda permanente por separado y pasa los bonuses de upgrades al configurar la economía de la siguiente run. El perfil provisional actual empieza con 150 Gold y 100/100 Mana, con una tasa interna de 1.5 Mana/s. Las tasas fraccionarias se describen al jugador como equivalencias de cantidades enteras por intervalos enteros, sin cambiar el valor runtime.

## CardModifierOperation
```text
type
affected_tower_id: optional
affected_damage_tags: optional bitmask
affected_status_id: optional
value
```

Tipos disponibles: daño plano/multiplicador, alcance, radio de área, coste de Mana, duración de estado, Mana máximo/regeneración, crítico y suma al multiplicador de una capa H/A/S. La cadencia ya no se modifica mediante cartas; se mantiene fija salvo Frost Keep por cobertura PATH.

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

`PermanentUpgradeOperation` expresa una sola operación por nivel: sumar Gold/Mana inicial, capacidad/regeneración de Mana, multiplicar el daño de torres o desbloquear un ID de contenido. La tienda lee el nivel persistido, valida prerrequisitos y saldo, cobra y persiste; el Resource de definición no se modifica. `MetaProgressionData` configura las torres iniciales, catálogo, base/per-round/bonus de victoria y máximo de recompensa. La demo inicia con Ballista y ofrece cuatro upgrades de stats más el Archivo de cartas; estos datos/costes son provisionales.

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
