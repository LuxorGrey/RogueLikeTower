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
elevation: int 0..3
buildable: bool
occupied: bool
tower_id: optional
obstacle_type: NONE | BRAMBLE_BUSH | FALLEN_LOG | BRANCH_PILE | TREE_STUMP | ROCK_AND_WOOD | SUPPLY_CRATE | EXPOSED_ROOTS | MOSSY_ROCK_CLUSTER
chest_available: bool
decorative_prop_ids: Array[StringName]
piece_instance_id
path_edges: bitmask/array[6]
flexible_path_edges: bitmask/array[6] derivada en runtime
visual_variant
```

Reglas:
- PATH: elevation 0; buildable false.
- GRASS: buildable true; elevation 1 o 2, sorteada por mapa/oferta.
- MOUNTAIN: elevation 2 o 3, sorteada por mapa/oferta; buildable true.
- Las seis celdas adyacentes a la base tienen elevación máxima 1; si el terreno generado allí fuera Mountain, se normaliza a Grass. PATH permanece a 0.
- `obstacle_type` y `chest_available` son estado de contenido visual/runtime de una celda; no cambian el tipo de terreno, elevación ni PathGraph. Un obstáculo o cofre sin abrir bloquea construcción. En `ROUND_PREP`, el obstáculo se selecciona por su hex y muestra el nombre correspondiente a su sprite. Retirarlo cuesta `25 × n²` Gold, con `n` igual al número de obstáculos retirados previamente en esa run.
- `decorative_prop_ids` contiene cero, uno o dos props visuales, sin selección, hitbox ni efecto de gameplay. Cada PNG compatible del pool del terreno tiene un 10 % de probabilidad independiente por celda; la tirada es determinista por seed/coordenada u oferta y no repite el mismo ID en la celda. Si hay obstáculo, este se dibuja delante.
- Elevation no cambia coordenada lógica.

`TerrainVisualCatalog` asigna `elevation`, `visual_variant`, obstáculos y props determinísticamente según seed y coordenadas/identidad de oferta. PATH siempre queda en 0; Grass sortea 1 o 2; Mountain sortea 2 o 3, excepto en el anillo de base donde la elevación no supera 1 y Mountain se convierte en Grass. Card, ghost y tablero confirmado conservan el contenido asignado a la oferta. En una expansión, el cofre se sortea al confirmar la colocación con seed de run y coordenada axial. Hay tres variantes de cada tipo de terreno; obstáculos con tasas Grass 25 % y Mountain 15 %; y cofres con base 1 %, más +5 puntos porcentuales por nivel de `CHEST_SPAWN_CHANCE_ADD`, hasta 20 % en cuatro niveles (el último incremento se limita por el tope). PATH recibe props decorativos, pero nunca obstáculos ni cofres. El tablero de inicio limita a uno el total de obstáculos y excluye la base y sus seis vecinas; una pieza de expansión admite como máximo dos. Cada uno de los 18 PNG de props tiene un 10 % de probabilidad independiente, con tope de dos IDs únicos por celda. El orden top-down isométrico hace que las celdas delanteras cubran las que quedan detrás. Props, obstáculos y cofres se dibujan en el contenedor Y-sort; los obstáculos de 208×208 se estiran a 94,6×94,6 px, centrados sin desplazamiento, y los props de 96×96 a 39,6×39,6 px con offsets sin solapamiento. Al abrir el cofre, `RunEconomyService` añade Gold temporal; el valor inicial 25 es provisional y configurable en el catálogo.

## TerrainPieceCellData
```text
local_coord: Vector2i
terrain_type: PATH | GRASS | MOUNTAIN
elevation: int 0..3
path_edges: bitmask[6]
flexible_path_edges: bitmask[6] derivada de las salidas externas
visual_variant: StringName
obstacle_type: int # runtime; contenido de la oferta
chest_available: bool # runtime; se asigna al confirmar colocación
decorative_prop_ids: Array[StringName] # runtime; de 0 a 2 IDs decorativos
```

Cada pieza de catálogo contiene exactamente 7 celdas. La forma hexagonal centrada en `(0,0)` más sus seis vecinos es la plantilla de losetas; el tablero de inicio de 19 celdas es un Resource aparte. Las coordenadas exactas y la vista de colores están en [05_HEX_GRID_AND_TERRAIN.md](05_HEX_GRID_AND_TERRAIN.md). Cada celda conserva su tipo de terreno al rotar. `obstacle_type`, `chest_available` y `decorative_prop_ids` son contenido runtime, no parte del catálogo compartido. El obstáculo y los props se fijan en la copia de oferta y se trasladan a miniatura, ghost y terreno confirmado. Si una celda queda adyacente a la base y se normaliza de Mountain a Grass, el ghost y la colocación regeneran juntos los props compatibles con Grass usando la coordenada global; la miniatura sin ancla conserva el tipo y contenido ofertado. `chest_available` queda falso en la oferta y se determina al confirmar el terreno.

Validación vigente del Resource: ID y nombre no vacíos; peso no negativo; coordenadas únicas y conectadas; pivote `(0,0)`; tipos/elevaciones permitidos; PATH a altura 0, Grass a altura 1 o 2, Mountain a altura 2 o 3; solo PATH declara `path_edges`; y toda conexión interna PATH es recíproca y llega a otra celda PATH. `requires_path_connection` exige al menos un socket PATH hacia fuera de la huella. `flexible_path_edges` se deriva al rotar la pieza a partir de las salidas externas y abre las dos caras laterales contiguas que también queden fuera de la huella; no se configura en el `.tres`. Las reglas completas de enlace están en [05_HEX_GRID_AND_TERRAIN.md](05_HEX_GRID_AND_TERRAIN.md).

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

`data/terrain/starting_board.tres` define el hexágono axial de radio 2, la celda de base `(-1,0)` y el camino inicial recto `(-1,0) → (0,0) → (1,0) → (2,0)`, con salida exterior `(3,0)`. Valida coordenadas únicas, elevaciones/terrenos válidos y conectividad de la huella. `Main` instancia sus datos en `HexCell`; la ruta se valida con `PathGraph`, que exige como mínimo cuatro celdas PATH desde cada endpoint activo hasta la base durante la campaña. La base se conserva en `(-1,0)` al rotar el tablero alrededor de ella. Véase [ADR-0056](../decisions/ADR-0056-tablero-inicial-lineal.md).

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

Un snapshot válido necesita que la base esté sobre PATH, que haya al menos un candidato spawn, que cada spawn tenga ruta a la base y que todos los nodos PATH pertenezcan a la red de la base; `Main` pasa el mínimo de cuatro celdas PATH para el tablero inicial y la campaña. El tablero inicial vigente coloca `GameBase` en `(-1,0)`; esa ubicación y su camino recto sustituyen la muestra M4/M5 en `(0,0)` según [ADR-0056](../decisions/ADR-0056-tablero-inicial-lineal.md). El snapshot activo se reconstruye al iniciar o confirmar expansión. Mientras se mueve un ghost legal, `Main` construye aparte un snapshot candidato para actualizar en vivo la vista previa de rutas, spawns y cambios de recorrido; ese cálculo no sustituye ni muta el grafo activo. `TerrainPiecePreview` dibuja ese candidato y la información de debug. `removed_spawn_endpoint_keys` conserva las retiradas de la run, y `get_active_routes()` filtra sus endpoints sin mutar la topología PATH ni la cantidad directa de `WaveData`; con más de tres spawns activos, `WaveDirector` distribuye el total de enemigos entre las salidas restantes. El coste portal es dos veces el coste vigente de retirada de obstáculo, sin incrementar el contador de obstáculos retirados. El algoritmo y sus límites están registrados en [ADR-0007](../decisions/ADR-0007-grafo-logico-de-caminos.md), [ADR-0025](../decisions/ADR-0025-tablero-inicial-y-ruta-minima.md) y [ADR-0063](../decisions/ADR-0063-seleccion-y-retirada-de-objetos-del-terreno.md).

## TowerData : Resource
```text
id
unlock_id
display_name
build_cost
meta_unlock_cost
upgrade_base_cost_by_layer[Health, Armor, Shield]
upgrade_cost_growth_factor
targeting_xp_required_per_level
targeting_xp_growth_factor
max_layer_upgrades
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

M6 implementa en `data/towers/tower_data.gd`: identidad, daño base, RPM/cadencia, alcance, terrenos, prioridades, elevación, niveles, costes y escena. M12 agrega `unlock_id` y `meta_unlock_cost`, que se presenta como coste en XP de perfil. Ballista, Mortar y Tesla Coil se desbloquean al inicio; el roster construible de una run comienza únicamente con Ballista. Mortar/Tesla y las torres que se desbloqueen permanentemente entran como opciones de reclutamiento de cartas, no como botones de construcción hasta ser reclutadas. Frost Keep, Flame Thrower y Poison Sprayer requieren 50 XP de perfil y Shredder 100. M12A añade build-cost increment, Mana por ataque/segundo y escalado, RPM de base, multiplicadores Health/Armor/Shield, chance crítica, bonus de elevación, umbral de XP y parámetros Frost. Frost incluye cadencia por PATH, fracción de daño convertida en Slow y parámetros configurables de caída/contacto del copo. M13 añade `visual_icon_size`, que dimensiona por Resource el sprite y el pedestal de cada torre. Tras ADR-0041, los perfiles usan 84 px frente a los 54 px originales; el icono de preview usa el mismo tamaño. Los patrones soportan objetivo único, área, chain, cono, sawblade, todos-en-rango (Tesla) y caída/contacto de copos (Frost). Tesla Coil y Flame Thrower siguen los ajustes del changelog oficial en ADR-0036; Frost Keep usa daño 6 y 180 RPM según changelog oficial, con comportamiento de copos basado en su página específica comunitaria y ADR-0059. La progresión actual usa tres contadores de mejoras de 0 a 15, tres costes base por capa y factores exponenciales configurables para coste Gold y XP. Los valores iniciales 1,15 son provisionales; mejorar no muta el Resource compartido.

`Tower` mantiene un total de mejoras para el +1 de daño base por subida y un nivel independiente por capa. Cada capa empieza en 0/15; la compra Gold o el XP de la capa activa sube solo esa capa y su multiplicador, mientras que el XP de las otras capas y sus niveles no cambian. El primer requisito de XP y el primer coste usan el valor base del Resource; cada subida multiplica el siguiente requisito/coste por su factor exponencial. El XP runtime sigue `0.5 + 1 / (2 × alcance_hex)` por segundo mientras conserva un objetivo válido. La UI muestra XP/umbral y progreso visual por capa; el total es 0–45. Elevación añade +1 daño base y +0.5 de rango por nivel. El RPM es fijo salvo Frost Keep, cuya cobertura suma 18 RPM por PATH cubierto. Build price escala como `build_cost + same_type_count × build_cost_increment`; demoler reduce ese conteo y devuelve el precio marginal del slot que libera (ADR-0064). `TowerData` contiene los patrones `SINGLE_TARGET`, `AREA`, `CHAIN`, `CONE`, `SAWBLADE`, `ALL_IN_RANGE` y `FROST_SNOWFALL`; Ballista/Mortar tienen proyectiles, Mortar hace splash al aterrizar, Frost deja caer copos sobre PATH dentro de su cobertura cuadrada y Shredder sigue una ruta PATH. Ver [ADR-0023](../decisions/ADR-0023-reglas-de-torres-y-capas-de-vida.md), [ADR-0046](../decisions/ADR-0046-progresion-de-mejoras-y-feedback-de-seleccion.md) y [ADR-0059](../decisions/ADR-0059-frost-keep-comportamiento-de-copos.md).
Los campos antiguos `upgrade_damage_per_level`, `upgrade_range_per_level` y `upgrade_attack_rate_per_level` se retiraron de `TowerData` y sus Resources porque no controlaban la fórmula real. El incremento vigente es fijo: +1 daño base y +1 al multiplicador de la capa que sube. `frost_slow_fraction` determina cuánto del daño aplicado se convierte en fuerza Slow para Frost; no se usa para los demás perfiles. `max_targets` solo limita el patrón `CHAIN`; no limita `ALL_IN_RANGE` (Tesla Coil), por lo que su Resource usa 1 como valor neutral. La revisión detallada está en la [auditoría del sistema de torres](15_AUDITORIA_SISTEMA_DE_TORRES.md).

Las prioridades incluyen progreso, menor suma actual de Health+Armor+Shield, valores más altos/bajos por capa y velocidad. Tres selectores numerados guardan posiciones 1–3; repetir un criterio en otra posición lo intercambia con el criterio de esa posición, para mantener opciones únicas y hacer explícito el orden. `DamageService.apply_damage` centraliza daño directo, crítico, tags y las tres capas. El modelo de cada enemigo contiene Health, Armor y Shield; cada perfil configura los tres máximos y cero desactiva una capa para esa unidad. Los ataques directos solo afectan a la capa activa en orden Shield→Armor→Health y usan su multiplicador. Si el objetivo tiene Bleed, Burn o Poison, los ataques directos suman +1 al multiplicador de Health, Armor o Shield, respectivamente; es un bonus único por estado activo y no escala con sus acumulaciones. Los ticks de estado usan los multiplicadores por capa del efecto: 1.0 en la capa asociada y 0.5 en las otras. `Enemy` dibuja una fila por cada capa con máximo positivo, y segmenta Health. La demo incluye el dummy DEBUG y los 45 perfiles de campaña; los perfiles que tengan Shield muestran esa capa en juego. El exceso al vaciar una capa se descarta en el mismo impacto; el artículo de referencia confirma el orden y el acceso solo a la capa activa, pero no especifica expresamente el destino del exceso, así que esta política sigue marcada como provisional.

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

`EnemyData.sprite_extent` configura individualmente el lado del PNG de cada enemigo en juego; los perfiles estándar pasan a 72 px y los perfiles grandes escalan proporcionalmente. La ilustración se dibuja 6 px por debajo del anclaje del PathFollower. `placeholder_radius` se usa para el placeholder vectorial y la colocación de barras/estados; no representa una hitbox ni cambia movimiento, selección, ocupación o colisión lógica. Si no hay textura se conserva el dibujo vectorial. `EnemyData` no exporta `defense_tags` ni `status_resistances`: los tags del paquete se definen en `DamagePacket` y el Resource sí configura multiplicadores recibidos por cada tag. Las resistencias de estado no están implementadas.

`Enemy` usa el `EnemyData.id` estable para elegir el color claro del outline del sprite; los perfiles DEBUG sin color dedicado usan el valor de reserva. El mapa de colores es de presentación y no se serializa dentro de `EnemyData`. Ver [ADR-0097](../decisions/ADR-0097-outline-de-base-y-enemigos.md).

## BaseData / HealthComponent

`BaseData` configura el ID, nombre, Health máxima y `sprite_texture` de la base. La textura RGBA es un PNG individual sustituible desde el Resource; `GameBase` conserva intacto el PNG de 270×352 px y actualmente lo dibuja con escalas independientes X/Y, a 1,8 × el radio de huella de ancho por 2,8 × de alto, con el borde inferior anclado. La deformación es visual/provisional y no altera la huella lógica de un hexágono, según [ADR-0096](../decisions/ADR-0096-base-mas-alta-y-visible.md). `HealthComponent` inicializa Health, aplica daño/curación acotados y emite `health_changed` y `health_depleted`; en M5 lo consumen `GameBase` y `Enemy`. La barra del HUD divide Health en segmentos de 10 (el último puede ser parcial). La coordenada inicial vigente de la base es `(-1,0)`, según [ADR-0056](../decisions/ADR-0056-tablero-inicial-lineal.md). `data/base/base_data.tres` define 10 HP base; `MetaProgression` suma +1 por cada nivel de Fortification permanente hasta 20 HP en nivel X, con costes y requisito secuencial de [ADR-0074](../decisions/ADR-0074-vida-de-base-y-derrota-por-jefe.md). Las cards de run aplican sus propios aumentos acumulables de +3 HP.

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

M8 implementa estos campos en `game/combat/status_effect_data.gd`. `duration` siempre es positiva; `tick_interval` puede ser cero si el efecto no hace daño periódico. `REFRESH` deja una acumulación y reinicia la duración; `ADD_STACKS` suma una acumulación hasta `max_stacks` y también reinicia la duración. Reaplicar no reinicia el reloj del próximo tick. El daño por tick se multiplica por las acumulaciones y pasa por `DamageService` con los `damage_tags` configurados. Si una torre reaplica el mismo ID, la definición y el `source_id` activos pasan a ser los de la aplicación más reciente. Cada enemigo guarda sus propias instancias runtime y no modifica los Resources compartidos. Los efectos de velocidad se combinan usando el menor multiplicador activo; al quitar el último efecto se restaura `1.0`. Slow puede declarar `strength_cap` y `strength_decay_per_second`: su fuerza se convierte en reducción porcentual de movimiento y decae linealmente. Frost usa ese modo y pasa al controlador la mitad del daño realmente aplicado por impacto. Muerte y llegada a la base limpian todos los estados. El campo de resistencias queda fuera mientras el diseño no lo necesite. Slow, Burn, Bleed y el Poison de M9.5 son datos configurables provisionales; el fixture de oleada M8 se retiró en M64 y Bleed también se usa en Shredder.

`TowerData.status_effects` es una lista de estos Resources, sin IDs repetidos dentro de una torre. `DamagePacket.status_payloads` transporta esa lista del impacto al `DamageService`, y `DamageResult.applied_status_ids` permite auditar qué se aplicó. El override de presupuesto no modifica el Resource compartido: el controlador guarda el total y los ticks restantes en la instancia del estado de cada enemigo.

## EnemyAbilityData

EnemyData incluye boss_tier y abilities: Array[EnemyAbilityData]. Cada habilidad declara un trigger (aparición, cerca de la base, armor agotado, shield agotado, muerte o periódica), un efecto (Haste, Fortification, invocar, transformar o teletransportar), política de objetivo, fuerza/intervalo/radio y los datos u overrides del enemigo afectado. Los radios de juego aprobados son cinco hexágonos para cercanía a la base y dos hexágonos para auras. Haste/Fortification tienen fuerza máxima 60 y decaen 6 puntos por segundo; Haste suma su porcentaje a la velocidad y Fortification resta cinco al daño base recibido por golpe. Los parámetros de invocación y transformación pertenecen a cada perfil.

## WaveData

Campos: round_number, encounter_type STANDARD/BOSS/TIER_2_BOSS, groups, round_reward. Cada grupo declara enemy_data, count, spawn_interval, spawn_endpoint_policy y delay_before_group.

M5 implementa WaveData y WaveEnemyGroupData como Resources validados. Los fixtures de diagnóstico conservan FIRST_SORTED/ROUND_ROBIN como políticas configurables.

En la campaña, count es la cantidad directa de enemigos del grupo. WaveDirector crea un enemigo por intervalo y rota las rutas alcanzables round-robin; la cantidad no depende del número de endpoints abiertos. Los grupos se ejecutan en el orden de la tabla, que define [14 — Campaña de 45 rondas](14_CAMPANA_45_RONDAS.md). Los enemigos invocados cuentan como apariciones adicionales y permanecen dentro de la misma oleada. Una transformación conserva la instancia, progreso y recompensa de la baja original.

WaveCampaignData exige 45 WaveData consecutivas y 1.093 enemigos directos. Valida el número de ronda, el tipo de encuentro calculado desde boss_tier y el total fijo. Las tasas globales de Health, daño a base y recompensa por baja están en cero; no se cambia EnemyData al escalar la ronda. Las recompensas de limpieza y cadencias se especifican en ADR-0037 y se mantienen provisionales donde se indica. El juego termina al limpiar la ronda 45; tras las rondas 1–44 hay una expansión. No existen designaciones Miniboss propias en 17/19. Los diagnósticos siguen aislados de la campaña.

## RunEconomyData / RunEconomyService
`RunEconomyData` es una configuración Resource de una run: `starting_gold`, `starting_mana`, `maximum_mana` y `mana_regen_per_second`. `RunEconomyService` es un Node hijo de `Main`, no Autoload: es dueño de los saldos runtime de esa escena, valida compras/gastos, limita el Mana a la capacidad y emite `gold_changed`/`mana_changed`. `refill_mana_to_max()` restaura el Mana al máximo efectivo al comenzar cada ronda de campaña. La UI escucha esas señales, pero no modifica los saldos directamente; el contador de Mana se presenta como entero y el Gold aplica feedback visual al cambiar. El Gold de construcción se reinicia con el perfil de arranque de la run y no es `MetaProgression.meta_currency`; `MetaProgression` conserva la moneda permanente y entrega los bonuses antes de configurar la siguiente economía. La configuración activa inicia con 1.000 Gold y 100/100 Mana; Starting Coffers suma 100 Gold por nivel hasta +1.000 y el máximo de 2.000. La tasa interna base de Mana es 1.5/s. Las tasas fraccionarias se describen al jugador como equivalencias de cantidades enteras por intervalos enteros, sin cambiar el valor runtime.

## CardModifierOperation
```text
type
affected_tower_id: optional
affected_damage_tags: optional bitmask
affected_status_id: optional
value
```

Tipos disponibles: daño plano/multiplicador, alcance, radio de área, coste de Mana, duración de estado, Mana máximo/regeneración, crítico, suma al multiplicador H/A/S, daño/cap/fuerza de estados, alcance por elevación, radio porcentual, conversión de daño de Mana, Mana por baja, Gold por baja, daño a base, vida de base y crítico por nivel. Los efectos nuevos que no tienen equivalencia directa se implementan como operaciones configurables. Frost Keep también añade RPM por cobertura PATH; ninguna de las 190 cards de mejora define una operación de RPM. Las seis cards de reclutamiento tampoco tienen operaciones de modificador.

## CardData
```text
id
display_name
description
rarity
unlock_requirement: optional content ID
grant_tower_id: optional TowerData ID
required_card_ids[]
any_required_card_ids[]
tags[]
modifier_operations: Array[CardModifierOperation]
offer_weight
max_per_run
```

Una carta describe una mejora temporal de la run o, si `grant_tower_id` está definido, recluta una torre sin aplicar modificadores. Las operaciones no modifican el `TowerData` ni otros `.tres` compartidos. Las operaciones aditivas se suman y los multiplicadores se combinan multiplicando. `unlock_requirement` vacío indica una carta global; los IDs de torre usan `tower:<TowerData.id>`. `required_card_ids` y `any_required_card_ids` expresan las cadenas y ramas del árbol de cartas; solo se ofrecen tras elegir sus prerrequisitos. Las cartas de reclutamiento requieren el unlock permanente y desaparecen cuando la torre ya está en el roster de esa run; los modificadores específicos solo aparecen después de reclutar la torre afectada.

## CardPoolData / RunCardService
`CardPoolData` combina las 18 cards propias (incluida Advanced Circuits) y 172 Resources nuevos en catálogos `CardCatalogData`: son 190 IDs de mejora que representan 173 entries compatibles de referencia. M35 añade seis Resources de reclutamiento; el pool runtime contiene 196 IDs. Un catálogo puede requerir cards del pool anfitrión; `CardPoolData` resuelve los prerequisitos después de unir todos los catálogos. La fuente de verdad fija tres opciones y el calendario configurable. La demo ofrece una mejora después de las rondas 3–42 en intervalos de tres, una vez colocada la expansión de la ronda; no hay oferta posterior a la 45. `RunCardService` filtra por unlock permanente, roster de run, peso, prerequisitos y límite de copias, y construye una oferta de exactamente tres cartas sin duplicados. Los reclutamientos iniciales de Mortar y Tesla Coil se mezclan con mejoras elegibles en la primera oferta; cada torre reclutada queda disponible para construir y habilita sus mejoras específicas. Los reclutamientos que no se eligen permanecen elegibles en ofertas futuras. `card_draw` se conserva como ID legado en el catálogo persistente, pero no se muestra en el mapa ni altera el tamaño fijo de oferta. `RunCardService` es local a `Main`; `MetaProgression` alimenta los filtros con los IDs persistentes y `RunManager` con los IDs reclutados en la run.

## RunManager
`RunManager` es Autoload de estado efímero de partida. `begin_run()` reinicia el roster a Ballista y limpia los contadores de construcción/daño. Un `grant_tower_id` seleccionado añade una torre al roster actual. Cada instancia construida asocia su ID de torre para sumar daño de `DamageResult` a su categoría; el resumen incluye cantidad construida y daño por tipo, filtrado por los unlocks permanentes al terminar. No se persiste el roster ni las métricas temporales.

## PermanentUpgradeData
```text
id
display_name
description
max_level
cost_by_level[]
prerequisites[]
prerequisite_unlock_ids[]
operations_by_level[]: PermanentUpgradeOperation
```

`PermanentUpgradeOperation` expresa una sola operación por nivel: economía inicial, Mana, daño de torre, desbloqueo, cofre, Gold por baja, vida/reparación de base y bonus H/A/S de torre. El tamaño de oferta ya no es una operación activa; el tipo antiguo y el ID `card_draw` se conservan solo para compatibilidad con perfiles anteriores. `prerequisites` conecta mejoras usando el ID exacto de `PermanentUpgradeData.id`; la validación rechaza IDs que no existan. Por ejemplo, Archivo de cartas requiere `meta:chest_finder`, ID persistente de Suerte del explorador. `prerequisite_unlock_ids` limita las mejoras de torre al unlock persistente correspondiente. Las tres mejoras H/A/S de cada torre comparten ese unlock y no se prerequisitan entre sí; en el mapa sus tres conexiones salen directamente del nodo de torre. Fortification I–X añade +1 HP por nivel, cuesta 20, 40, 60, 80, 100, 120, 140, 160, 180 y 200 XP (1.100 en total); solo se compra el siguiente nivel, por lo que cada nivel superior requiere el anterior. No se añaden requisitos de cantidad de cartas desbloqueadas. El mapa de tienda comparte una escena de nodo para todas las categorías, muestra el icono del sistema o torre afectada, el coste y los prerequisitos y emite partículas al comprar; los tooltips describen cómo habilitar nodos bloqueados. La tienda se reutiliza desde menú y final de run; los efectos comprados se aplican desde la siguiente run y el Resource de definición no se modifica. `MetaProgressionData` combina el catálogo propio con catálogos `PermanentUpgradeCatalogData`. El contenido actual reúne seis mejoras propias y 25 mejoras incorporadas de referencia, incluida la entrada legada `card_draw` que no está disponible para comprar; los valores y límites continúan configurables. Ver [ADR-0081](../decisions/ADR-0081-mejoras-de-torre-en-ramas-paralelas.md) y ADR-0093.

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
