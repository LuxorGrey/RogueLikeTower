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
allowed_terrain
height_rules
unlock_id
scene
```

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
scene
```

## DamagePacket
```text
raw_damage
source_id
damage_tags
armor_multiplier
health_multiplier
regen_counter_strength
status_payloads
critical? # mantener desactivado si no se aprueba
```

## StatusEffectData
```text
id
duration
tick_interval
max_stacks
stack_rule
speed_multiplier
damage_per_tick
tags
```

## WaveData
```text
round_number
groups[]
  enemy_data
  count
  spawn_interval
  spawn_endpoint_policy
  delay_before_group
round_reward
```

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
