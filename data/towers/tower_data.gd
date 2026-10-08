class_name TowerData
extends Resource

enum TargetingMode { FIRST_PROGRESS, LAST_PROGRESS, HIGHEST_HEALTH, HIGHEST_ARMOR }

const GRASS_FLAG: int = 1 << HexCell.TerrainType.GRASS
const MOUNTAIN_FLAG: int = 1 << HexCell.TerrainType.MOUNTAIN

@export var id: StringName = &""
@export var display_name: String = ""
@export_range(1, 100000, 1) var base_damage: int = 10
@export_range(0.05, 100.0, 0.05) var attack_rate: float = 1.0
@export_range(0.25, 20.0, 0.25) var range_hexes: float = 3.0
@export_flags("Path (no construible)", "Grass", "Montaña")
var allowed_terrain_mask: int = GRASS_FLAG | MOUNTAIN_FLAG
@export_enum("First progress", "Last progress", "Highest health", "Highest armor")
var targeting_mode: int = TargetingMode.FIRST_PROGRESS
@export_range(0.0, 2.0, 0.05) var height_range_bonus_per_level: float = 0.25
@export_range(1, 10, 1) var max_level: int = 3
@export_range(0, 100000, 1) var upgrade_damage_per_level: int = 5
@export_range(0.0, 10.0, 0.05) var upgrade_range_per_level: float = 0.25
@export_range(0.0, 10.0, 0.05) var upgrade_attack_rate_per_level: float = 0.0
@export var scene: PackedScene

func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if id == &"":
		errors.append("TowerData requiere un ID estable.")
	if display_name.strip_edges().is_empty():
		errors.append("TowerData requiere un nombre visible.")
	if base_damage <= 0:
		errors.append("El daño base de la torre debe ser mayor que cero.")
	if attack_rate <= 0.0:
		errors.append("La cadencia de la torre debe ser mayor que cero.")
	if range_hexes <= 0.0:
		errors.append("El alcance de la torre debe ser mayor que cero.")
	if allowed_terrain_mask == 0:
		errors.append("La torre debe permitir al menos un tipo de terreno construible.")
	if targeting_mode < TargetingMode.FIRST_PROGRESS or targeting_mode > TargetingMode.HIGHEST_ARMOR:
		errors.append("La prioridad de objetivo configurada no existe.")
	if max_level < 1:
		errors.append("La torre debe tener al menos un nivel.")
	if upgrade_damage_per_level < 0 or upgrade_range_per_level < 0.0 or upgrade_attack_rate_per_level < 0.0:
		errors.append("Los incrementos de mejora no pueden ser negativos.")
	if scene == null:
		errors.append("TowerData requiere una escena de torre.")
	return errors

func allows_terrain(terrain_type: int) -> bool:
	if terrain_type < HexCell.TerrainType.PATH or terrain_type > HexCell.TerrainType.MOUNTAIN:
		return false
	return (allowed_terrain_mask & (1 << terrain_type)) != 0
