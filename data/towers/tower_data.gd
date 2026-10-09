class_name TowerData
extends Resource

enum TargetingMode {
	FIRST_PROGRESS,
	LAST_PROGRESS,
	LOWEST_TOTAL_HIT_POINTS,
	HIGHEST_HEALTH,
	HIGHEST_ARMOR,
	HIGHEST_SHIELD,
	LOWEST_HEALTH,
	LOWEST_ARMOR,
	LOWEST_SHIELD,
	SLOWEST,
	FASTEST,
}
enum AttackPattern { SINGLE_TARGET, AREA, CHAIN, CONE, SAWBLADE, ALL_IN_RANGE }
enum VisualArchetype { BALLISTA, MORTAR, TESLA, FROST, FLAME, POISON, SHREDDER }

const GRASS_FLAG: int = 1 << HexCell.TerrainType.GRASS
const MOUNTAIN_FLAG: int = 1 << HexCell.TerrainType.MOUNTAIN
const DAMAGE_TAG_PHYSICAL: int = 1
const DAMAGE_TAG_FIRE: int = 2
const DAMAGE_TAG_ARCANE: int = 4
const DAMAGE_TAG_POISON: int = 8
const ALL_DAMAGE_TAGS: int = DAMAGE_TAG_PHYSICAL | DAMAGE_TAG_FIRE | DAMAGE_TAG_ARCANE | DAMAGE_TAG_POISON

@export var id: StringName = &""
@export var unlock_id: StringName = &""
@export var display_name: String = ""
@export_multiline var role_summary: String = ""
@export_range(0, 1000000, 1) var meta_unlock_cost: int = 0
@export_range(0, 1000000, 1) var build_cost: int = 0
@export_range(0, 1000000, 1) var build_cost_increment: int = 0
@export var upgrade_costs: Array[int] = [20, 35]
@export_range(0.0, 100000.0, 0.5) var mana_cost_per_attack: float = 0.0
@export_range(0.0, 100000.0, 0.1) var mana_cost_per_second: float = 0.0
@export var mana_cost_scales_with_damage: bool = false
@export_range(1, 100000, 1) var base_damage: int = 10
@export_range(0.05, 100.0, 0.05) var attack_rate: float = 1.0
@export_range(0.0, 10000.0, 1.0) var rounds_per_minute: float = 0.0
@export_range(0.25, 20.0, 0.25) var range_hexes: float = 3.0
@export_enum("Single target", "Area", "Chain", "Cone", "Sawblade along path", "All enemies in range")
var attack_pattern: int = AttackPattern.SINGLE_TARGET
@export_range(0.0, 10.0, 0.1) var attack_area_radius_hexes: float = 0.0
@export_range(1, 12, 1) var max_targets: int = 1
@export_range(1.0, 180.0, 1.0) var cone_angle_degrees: float = 60.0
@export_range(50.0, 2000.0, 10.0) var projectile_speed: float = 560.0
@export_range(1.0, 64.0, 1.0) var projectile_hit_radius: float = 16.0
@export_range(0.0, 100.0, 0.5) var pierce_damage_loss_per_hit: float = 1.0
@export_range(0.0, 100.0, 0.05) var health_damage_multiplier: float = 1.0
@export_range(0.0, 100.0, 0.05) var armor_damage_multiplier: float = 1.0
@export_range(0.0, 100.0, 0.05) var shield_damage_multiplier: float = 1.0
@export_range(0.0, 1.5, 0.01) var base_crit_chance: float = 0.0
@export_flags("Physical", "Fire", "Arcane", "Poison") var damage_tags: int = DAMAGE_TAG_PHYSICAL
## Deprecated for imported M7 fixtures. Current combat uses the three hit-point multipliers above.
@export_range(0.0, 4.0, 0.05) var armor_multiplier: float = 1.0
@export_range(0.0, 4.0, 0.05) var health_multiplier: float = 1.0
@export_range(0.0, 1.0, 0.05) var regen_counter_strength: float = 0.0
@export_range(0.0, 10.0, 0.1) var regen_counter_duration: float = 1.0
@export var status_effects: Array[Resource] = []
@export_flags("Path (no construible)", "Grass", "Mountain")
var allowed_terrain_mask: int = GRASS_FLAG | MOUNTAIN_FLAG
@export_enum("Progress", "Least progress", "Near death", "Most health", "Most armor", "Most shield", "Least health", "Least armor", "Least shield", "Slowest", "Fastest")
var targeting_mode: int = TargetingMode.FIRST_PROGRESS
@export_range(0.0, 2.0, 0.05) var height_range_bonus_per_level: float = 0.5
@export_range(0.0, 100.0, 0.1) var elevation_damage_bonus_per_level: float = 1.0
@export_range(0.0, 1000.0, 1.0) var targeting_xp_required_per_level: float = 100.0
@export_range(0.0, 1000.0, 1.0) var frost_rpm_per_path_cell: float = 18.0
@export_range(0.0, 1.0, 0.05) var frost_slow_fraction: float = 0.5
@export_range(1, 10, 1) var max_level: int = 3
@export_range(0, 100000, 1) var upgrade_damage_per_level: int = 5
@export_range(0.0, 10.0, 0.05) var upgrade_range_per_level: float = 0.25
@export_range(0.0, 10.0, 0.05) var upgrade_attack_rate_per_level: float = 0.0
@export_enum("Ballista", "Mortar", "Tesla Coil", "Frost Keep", "Flame Thrower", "Poison Sprayer", "Shredder")
var visual_archetype: int = VisualArchetype.BALLISTA
## Visual width/height of the tower icon; independent from hex occupancy and range.
@export_range(32.0, 128.0, 1.0) var visual_icon_size: float = 62.0
@export var visual_color: Color = Color(0.28, 0.64, 0.78)
@export var scene: PackedScene

func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if id == &"":
		errors.append("TowerData requiere un ID estable.")
	if display_name.strip_edges().is_empty():
		errors.append("TowerData requiere un nombre visible.")
	if meta_unlock_cost < 0:
		errors.append("El coste meta de desbloqueo no puede ser negativo.")
	if build_cost_increment < 0:
		errors.append("El incremento de coste de construcción no puede ser negativo.")
	if meta_unlock_cost > 0 and unlock_id == &"":
		errors.append("Una torre comprable requiere un unlock_id estable.")
	if build_cost < 0:
		errors.append("El coste de construcción no puede ser negativo.")
	if mana_cost_per_attack < 0.0 or mana_cost_per_second < 0.0:
		errors.append("El coste de Mana de una torre no puede ser negativo.")
	if base_damage <= 0:
		errors.append("El daño base de la torre debe ser mayor que cero.")
	if get_rounds_per_minute() <= 0.0:
		errors.append("La cadencia de la torre debe ser mayor que cero.")
	if range_hexes <= 0.0:
		errors.append("El alcance de la torre debe ser mayor que cero.")
	if attack_pattern < AttackPattern.SINGLE_TARGET or attack_pattern > AttackPattern.ALL_IN_RANGE:
		errors.append("El patrón de ataque configurado no existe.")
	if attack_pattern == AttackPattern.AREA and attack_area_radius_hexes <= 0.0:
		errors.append("Un ataque de área requiere un radio positivo.")
	if attack_pattern == AttackPattern.SAWBLADE and (projectile_speed <= 0.0 or projectile_hit_radius <= 0.0):
		errors.append("La hoja de ruta requiere velocidad y radio de impacto positivos.")
	if pierce_damage_loss_per_hit < 0.0:
		errors.append("La pérdida de daño por perforación no puede ser negativa.")
	if max_targets < 1 or max_targets > 12:
		errors.append("El ataque debe admitir entre 1 y 12 objetivos.")
	if cone_angle_degrees <= 0.0 or cone_angle_degrees > 180.0:
		errors.append("El ángulo de cono debe estar entre 0 y 180 grados.")
	if visual_archetype < VisualArchetype.BALLISTA or visual_archetype > VisualArchetype.SHREDDER:
		errors.append("El arquetipo visual de la torre no existe.")
	if visual_icon_size <= 0.0:
		errors.append("El tamaño visual de la torre debe ser positivo.")
	if (
		health_damage_multiplier < 0.0 or health_damage_multiplier > 100.0
		or armor_damage_multiplier < 0.0 or armor_damage_multiplier > 100.0
		or shield_damage_multiplier < 0.0 or shield_damage_multiplier > 100.0
	):
		errors.append("Los multiplicadores de Health/Armor/Shield deben estar entre 0 y 100.")
	if base_crit_chance < 0.0 or base_crit_chance > 1.5:
		errors.append("La probabilidad crítica base debe estar entre 0 y 150%.")
	if damage_tags <= 0 or (damage_tags & ~ALL_DAMAGE_TAGS) != 0:
		errors.append("La torre debe tener tipos de daño válidos.")
	if armor_multiplier < 0.0 or armor_multiplier > 4.0 or health_multiplier < 0.0 or health_multiplier > 4.0:
		errors.append("Los campos heredados del perfil M7 deben estar entre 0 y 4.")
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
	if targeting_mode < TargetingMode.FIRST_PROGRESS or targeting_mode > TargetingMode.FASTEST:
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
	if targeting_xp_required_per_level <= 0.0:
		errors.append("La experiencia requerida para subir de nivel debe ser positiva.")
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

func get_rounds_per_minute() -> float:
	return rounds_per_minute if rounds_per_minute > 0.0 else attack_rate * 60.0
