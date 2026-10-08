class_name EnemyData
extends Resource

const DAMAGE_TAG_PHYSICAL: int = 1
const DAMAGE_TAG_FIRE: int = 2
const DAMAGE_TAG_ARCANE: int = 4
const DAMAGE_TAG_POISON: int = 8

@export var id: StringName = &""
@export var display_name: String = ""
@export_range(1, 100000, 1) var max_health: int = 20
@export_range(1.0, 1000.0, 0.1) var move_speed: float = 90.0
@export_range(0, 100000, 1) var base_damage: int = 10
@export_range(0, 1000000, 1) var kill_reward: int = 0
@export_range(0, 100000, 1) var armor: int = 0
@export_range(0.0, 1000.0, 0.1) var regen_per_second: float = 0.0
@export_range(0.0, 4.0, 0.05) var physical_damage_multiplier: float = 1.0
@export_range(0.0, 4.0, 0.05) var fire_damage_multiplier: float = 1.0
@export_range(0.0, 4.0, 0.05) var arcane_damage_multiplier: float = 1.0
@export_range(0.0, 4.0, 0.05) var poison_damage_multiplier: float = 1.0
@export var scene: PackedScene

func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if id == &"":
		errors.append("EnemyData requiere un ID.")
	if display_name.strip_edges().is_empty():
		errors.append("EnemyData requiere un nombre visible.")
	if max_health <= 0:
		errors.append("La salud máxima del enemigo debe ser mayor que cero.")
	if move_speed <= 0.0:
		errors.append("La velocidad del enemigo debe ser mayor que cero.")
	if base_damage < 0:
		errors.append("El daño del enemigo no puede ser negativo.")
	if kill_reward < 0:
		errors.append("La recompensa por derrota no puede ser negativa.")
	if armor < 0:
		errors.append("La armadura del enemigo no puede ser negativa.")
	if regen_per_second < 0.0:
		errors.append("La regeneración del enemigo no puede ser negativa.")
	if (
		physical_damage_multiplier < 0.0 or physical_damage_multiplier > 4.0
		or fire_damage_multiplier < 0.0 or fire_damage_multiplier > 4.0
		or arcane_damage_multiplier < 0.0 or arcane_damage_multiplier > 4.0
		or poison_damage_multiplier < 0.0 or poison_damage_multiplier > 4.0
	):
		errors.append("Los multiplicadores de daño recibido deben estar entre 0 y 4.")
	if scene == null:
		errors.append("EnemyData requiere una escena de enemigo.")
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
