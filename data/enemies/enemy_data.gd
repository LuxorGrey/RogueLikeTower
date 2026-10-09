class_name EnemyData
extends Resource

const DAMAGE_TAG_PHYSICAL: int = 1
const DAMAGE_TAG_FIRE: int = 2
const DAMAGE_TAG_ARCANE: int = 4
const DAMAGE_TAG_POISON: int = 8

@export var id: StringName = &""
@export var display_name: String = ""
@export_range(0, 3, 1) var boss_tier: int = 0
@export_range(1, 100000, 1) var max_health: int = 20
@export_range(1.0, 1000.0, 0.1) var move_speed: float = 90.0
@export_range(0, 100000, 1) var base_damage: int = 10
@export_range(0, 1000000, 1) var kill_reward: int = 0
@export_range(0, 100000, 1) var armor: int = 0
@export_range(0, 100000, 1) var shield: int = 0
@export_range(0.0, 1000.0, 0.1) var regen_per_second: float = 0.0
@export_range(0.0, 1000.0, 0.1) var armor_regen_per_second: float = 0.0
@export_range(0.0, 1000.0, 0.1) var shield_regen_per_second: float = 0.0
@export_range(0.0, 4.0, 0.05) var physical_damage_multiplier: float = 1.0
@export_range(0.0, 4.0, 0.05) var fire_damage_multiplier: float = 1.0
@export_range(0.0, 4.0, 0.05) var arcane_damage_multiplier: float = 1.0
@export_range(0.0, 4.0, 0.05) var poison_damage_multiplier: float = 1.0
@export var placeholder_color: Color = Color(0.82, 0.30, 0.27)
## Presentation radius for sprite fallback, shadow, hit-point bars, and status icons; not a collider.
@export_range(7.0, 28.0, 0.1) var placeholder_radius: float = 11.5
@export var sprite_texture: Texture2D
## Side length in pixels for this enemy's individual sprite.
@export_range(16.0, 256.0, 0.1) var sprite_extent: float = 55.2
@export var scene: PackedScene
@export var abilities: Array[EnemyAbilityData] = []

func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if id == &"":
		errors.append("EnemyData requiere un ID.")
	if display_name.strip_edges().is_empty():
		errors.append("EnemyData requiere un nombre visible.")
	if max_health <= 0:
		errors.append("El Health máximo del enemigo debe ser mayor que cero.")
	if move_speed <= 0.0:
		errors.append("La velocidad del enemigo debe ser mayor que cero.")
	if placeholder_radius <= 0.0 or sprite_extent <= 0.0:
		errors.append("El tamaño visual del enemigo debe ser positivo.")
	if base_damage < 0:
		errors.append("El daño del enemigo no puede ser negativo.")
	if kill_reward < 0:
		errors.append("La recompensa por derrota no puede ser negativa.")
	if armor < 0 or shield < 0:
		errors.append("Las capas Armor y Shield del enemigo no pueden ser negativas.")
	if regen_per_second < 0.0 or armor_regen_per_second < 0.0 or shield_regen_per_second < 0.0:
		errors.append("La regeneración por capa del enemigo no puede ser negativa.")
	if (
		physical_damage_multiplier < 0.0 or physical_damage_multiplier > 4.0
		or fire_damage_multiplier < 0.0 or fire_damage_multiplier > 4.0
		or arcane_damage_multiplier < 0.0 or arcane_damage_multiplier > 4.0
		or poison_damage_multiplier < 0.0 or poison_damage_multiplier > 4.0
	):
		errors.append("Los multiplicadores de daño recibido deben estar entre 0 y 4.")
	if scene == null:
		errors.append("EnemyData requiere una escena de enemigo.")
	if boss_tier < 0 or boss_tier > 3:
		errors.append("EnemyData tiene un tier de jefe no válido.")
	for ability_index in range(abilities.size()):
		var ability: EnemyAbilityData = abilities[ability_index]
		if ability == null:
			errors.append("EnemyData tiene una habilidad vacía en el índice %d." % ability_index)
		else:
			errors.append_array(ability.validate())
	return errors

func get_damage_tag_multiplier(damage_tags: int) -> float:
	var multiplier: float = 1.0
	if (damage_tags & DAMAGE_TAG_PHYSICAL) != 0:
		multiplier *= physical_damage_multiplier
	if (damage_tags & DAMAGE_TAG_FIRE) != 0:
		multiplier *= fire_damage_multiplier
	if (damage_tags & DAMAGE_TAG_ARCANE) != 0:
		multiplier *= arcane_damage_multiplier
	if (damage_tags & DAMAGE_TAG_POISON) != 0:
		multiplier *= poison_damage_multiplier
	return multiplier
