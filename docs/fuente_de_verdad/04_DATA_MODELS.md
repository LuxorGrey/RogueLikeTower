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
visual_variant: StringName
```

Cada pieza contiene exactamente 7 celdas. La huella inicial es el centro axial `(0,0)` más sus seis vecinos; las coordenadas exactas y la vista de colores están en [05_HEX_GRID_AND_TERRAIN.md](05_HEX_GRID_AND_TERRAIN.md). Cada celda conserva su tipo de terreno al rotar. La primera mezcla y la paleta de colores son placeholders editables, no balance ni arte final.

## TerrainPieceData : Resource
```text
id
display_name
cells: Array[TerrainPieceCellData] # exactamente 7
weight
tags
```

Rotación:
- rotar coordenadas locales alrededor del origen.
- rotar `path_edges` el mismo número de pasos.
- nunca editar el Resource original; generar transformación temporal.

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
