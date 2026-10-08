class_name TowerData
extends Resource

enum TargetingMode { FIRST_PROGRESS, LAST_PROGRESS, HIGHEST_HEALTH, HIGHEST_ARMOR }

const GRASS_FLAG: int = 1 << HexCell.TerrainType.GRASS
const MOUNTAIN_FLAG: int = 1 << HexCell.TerrainType.MOUNTAIN
const DAMAGE_TAG_PHYSICAL: int = 1
const DAMAGE_TAG_FIRE: int = 2
const DAMAGE_TAG_ARCANE: int = 4
const ALL_DAMAGE_TAGS: int = DAMAGE_TAG_PHYSICAL | DAMAGE_TAG_FIRE | DAMAGE_TAG_ARCANE

@export var id: StringName = &""
@export var display_name: String = ""
@export_range(0, 1000000, 1) var build_cost: int = 0
@export var upgrade_costs: Array[int] = [20, 35]
@export_range(0.0, 100000.0, 0.5) var mana_cost_per_attack: float = 0.0
@export_range(1, 100000, 1) var base_damage: int = 10
@export_range(0.05, 100.0, 0.05) var attack_rate: float = 1.0
@export_range(0.25, 20.0, 0.25) var range_hexes: float = 3.0
@export_flags("Físico", "Fuego", "Arcano") var damage_tags: int = DAMAGE_TAG_PHYSICAL
@export_range(0.0, 4.0, 0.05) var armor_multiplier: float = 1.0
@export_range(0.0, 4.0, 0.05) var health_multiplier: float = 1.0
@export_range(0.0, 1.0, 0.05) var regen_counter_strength: float = 0.0
@export_range(0.0, 10.0, 0.1) var regen_counter_duration: float = 1.0
@export var status_effects: Array[Resource] = []
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
	if build_cost < 0:
		errors.append("El coste de construcción no puede ser negativo.")
	if mana_cost_per_attack < 0.0:
		errors.append("El coste de maná por ataque no puede ser negativo.")
	if base_damage <= 0:
		errors.append("El daño base de la torre debe ser mayor que cero.")
	if attack_rate <= 0.0:
		errors.append("La cadencia de la torre debe ser mayor que cero.")
	if range_hexes <= 0.0:
		errors.append("El alcance de la torre debe ser mayor que cero.")
	if damage_tags <= 0 or (damage_tags & ~ALL_DAMAGE_TAGS) != 0:
		errors.append("La torre debe tener tipos de daño válidos.")
	if armor_multiplier < 0.0 or armor_multiplier > 4.0 or health_multiplier < 0.0 or health_multiplier > 4.0:
		errors.append("Los multiplicadores del perfil de daño deben estar entre 0 y 4.")
	if regen_counter_strength < 0.0 or regen_counter_strength > 1.0 or regen_counter_duration < 0.0:
		errors.append("El perfil anti-regeneración configurado no es válido.")
	var seen_status_ids: Dictionary[StringName, bool] = {}
	for status_effect in status_effects:
		if status_effect == null or not status_effect.has_method("validate"):
			errors.append("TowerData contiene un estado sin StatusEffectData válido.")
			continue
		var status_errors: PackedStringArray = status_effect.call("validate")
		if not status_errors.is_empty():
			errors.append_array(status_errors)
			continue
		var status_id: StringName = status_effect.get("id")
		if seen_status_ids.has(status_id):
			errors.append("TowerData no puede aplicar dos payloads con el mismo ID de estado.")
		seen_status_ids[status_id] = true
	if allowed_terrain_mask == 0:
		errors.append("La torre debe permitir al menos un tipo de terreno construible.")
	if targeting_mode < TargetingMode.FIRST_PROGRESS or targeting_mode > TargetingMode.HIGHEST_ARMOR:
		errors.append("La prioridad de objetivo configurada no existe.")
	if max_level < 1:
		errors.append("La torre debe tener al menos un nivel.")
	if upgrade_costs.size() < maxi(max_level - 1, 0):
		errors.append("TowerData requiere un coste de mejora por cada nivel alcanzable.")
	for upgrade_cost in upgrade_costs:
		if upgrade_cost < 0:
			errors.append("Los costes de mejora no pueden ser negativos.")
			break
	if upgrade_damage_per_level < 0 or upgrade_range_per_level < 0.0 or upgrade_attack_rate_per_level < 0.0:
		errors.append("Los incrementos de mejora no pueden ser negativos.")
	if scene == null:
		errors.append("TowerData requiere una escena de torre.")
	return errors

func allows_terrain(terrain_type: int) -> bool:
	if terrain_type < HexCell.TerrainType.PATH or terrain_type > HexCell.TerrainType.MOUNTAIN:
		return false
	return (allowed_terrain_mask & (1 << terrain_type)) != 0

func get_upgrade_cost(current_level: int) -> int:
	if current_level < 1 or current_level >= max_level:
		return -1
	var cost_index: int = current_level - 1
	if cost_index >= upgrade_costs.size():
		return -1
	return upgrade_costs[cost_index]
