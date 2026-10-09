class_name StatusEffectData
extends Resource

enum StackRule { REFRESH, ADD_STACKS }

const DAMAGE_TAG_PHYSICAL: int = 1
const DAMAGE_TAG_FIRE: int = 2
const DAMAGE_TAG_ARCANE: int = 4
const DAMAGE_TAG_POISON: int = 8
const ALL_DAMAGE_TAGS: int = DAMAGE_TAG_PHYSICAL | DAMAGE_TAG_FIRE | DAMAGE_TAG_ARCANE | DAMAGE_TAG_POISON

@export var id: StringName = &""
@export var display_name: String = ""
@export_range(0.05, 60.0, 0.05) var duration: float = 1.0
@export_range(0.0, 60.0, 0.05) var tick_interval: float = 0.0
@export_range(1, 20, 1) var max_stacks: int = 1
@export_enum("Refresh", "Add stacks") var stack_rule: int = StackRule.REFRESH
@export_range(0.05, 1.0, 0.05) var speed_multiplier: float = 1.0
@export_range(0.0, 10000.0, 0.1) var damage_per_tick: float = 0.0
@export_flags("Physical", "Fire", "Arcane", "Poison") var damage_tags: int = DAMAGE_TAG_PHYSICAL
@export_range(0.0, 100.0, 0.05) var health_layer_multiplier: float = 1.0
@export_range(0.0, 100.0, 0.05) var armor_layer_multiplier: float = 1.0
@export_range(0.0, 100.0, 0.05) var shield_layer_multiplier: float = 1.0

func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if id == &"":
		errors.append("StatusEffectData requiere un ID estable.")
	if display_name.strip_edges().is_empty():
		errors.append("StatusEffectData requiere un nombre visible.")
	if duration <= 0.0 or duration > 60.0:
		errors.append("La duración de un estado debe estar entre 0 y 60 segundos.")
	if tick_interval < 0.0 or tick_interval > 60.0:
		errors.append("El intervalo de tick debe estar entre 0 y 60 segundos.")
	if max_stacks < 1 or max_stacks > 20:
		errors.append("Un estado debe admitir entre 1 y 20 acumulaciones.")
	if stack_rule < StackRule.REFRESH or stack_rule > StackRule.ADD_STACKS:
		errors.append("La regla de acumulación del estado no existe.")
	if speed_multiplier < 0.05 or speed_multiplier > 1.0:
		errors.append("El multiplicador de velocidad debe estar en el intervalo [0.05, 1].")
	if damage_per_tick < 0.0 or damage_per_tick > 10000.0:
		errors.append("El daño periódico debe estar entre 0 y 10000.")
	if damage_per_tick > 0.0 and tick_interval <= 0.0:
		errors.append("Un estado con daño periódico requiere un intervalo de tick positivo.")
	if damage_per_tick > 0.0 and (damage_tags <= 0 or (damage_tags & ~ALL_DAMAGE_TAGS) != 0):
		errors.append("El daño periódico requiere tags de daño válidos.")
	if (
		health_layer_multiplier < 0.0 or health_layer_multiplier > 100.0
		or armor_layer_multiplier < 0.0 or armor_layer_multiplier > 100.0
		or shield_layer_multiplier < 0.0 or shield_layer_multiplier > 100.0
	):
		errors.append("Los multiplicadores de daño periódico por capa deben estar entre 0 y 100.")
	if is_equal_approx(speed_multiplier, 1.0) and damage_per_tick <= 0.0:
		errors.append("El estado no modifica velocidad ni causa daño periódico.")
	return errors
