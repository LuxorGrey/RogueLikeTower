class_name DamagePacket
extends RefCounted

enum DamageTag {
	PHYSICAL = 1,
	FIRE = 2,
	ARCANE = 4,
	POISON = 8,
}

const ALL_DAMAGE_TAGS: int = DamageTag.PHYSICAL | DamageTag.FIRE | DamageTag.ARCANE | DamageTag.POISON

var raw_damage: float = 0.0
var critical_multiplier: float = 1.0
var source_id: int = 0
var damage_tags: int = DamageTag.PHYSICAL
## Per-layer tower multipliers. Damage is resolved Shield -> Armor -> Health.
var health_damage_multiplier: float = 1.0
var armor_multiplier: float = 1.0
var health_multiplier: float = 1.0
var armor_damage_multiplier: float = 1.0
var shield_damage_multiplier: float = 1.0
## True for a periodic status tick; status ticks do not receive the matching-layer attack bonus.
var is_status_damage: bool = false
var regen_counter_strength: float = 0.0
var regen_counter_duration: float = 0.0
var status_payloads: Array[Resource] = []
## Optional total raw damage budgets, distributed across the effect's ticks.
var status_total_damage_overrides: Dictionary[StringName, int] = {}
var status_damage_multipliers: Dictionary[StringName, float] = {}
var status_max_damage_per_second: Dictionary[StringName, float] = {}
var status_condition_layer_damage_adds: Dictionary[StringName, float] = {}
var status_crit_damage_conversion_fractions: Dictionary[StringName, float] = {}
## Slow strength added per point of direct damage, used by Frost Keep's snowflakes.
var slow_fraction_of_damage: float = 0.0
var slow_strength_cap_add: float = 0.0
var poison_slow_fraction: float = 0.0
var is_status_bonus_damage: bool = false

func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if raw_damage <= 0.0:
		errors.append("DamagePacket requiere daño bruto positivo.")
	if critical_multiplier < 1.0 or critical_multiplier > 4.0:
		errors.append("El multiplicador crítico debe estar entre ×1 y ×4.")
	if damage_tags <= 0 or (damage_tags & ~ALL_DAMAGE_TAGS) != 0:
		errors.append("DamagePacket contiene tipos de daño desconocidos.")
	if (
		health_damage_multiplier < 0.0 or health_damage_multiplier > 100.0
		or armor_damage_multiplier < 0.0 or armor_damage_multiplier > 100.0
		or shield_damage_multiplier < 0.0 or shield_damage_multiplier > 100.0
		or armor_multiplier < 0.0 or armor_multiplier > 4.0
		or health_multiplier < 0.0 or health_multiplier > 4.0
	):
		errors.append("Los multiplicadores por capa deben estar entre 0 y 100.")
	if regen_counter_strength < 0.0 or regen_counter_strength > 1.0:
		errors.append("La fuerza anti-regeneración debe estar entre 0 y 1.")
	if regen_counter_duration < 0.0:
		errors.append("La duración anti-regeneración no puede ser negativa.")
	if slow_fraction_of_damage < 0.0 or slow_fraction_of_damage > 1.0:
		errors.append("La fracción de daño convertida en Slow debe estar entre 0 y 1.")
	if slow_strength_cap_add < 0.0 or slow_strength_cap_add > 40.0 or poison_slow_fraction < 0.0 or poison_slow_fraction > 1.0:
		errors.append("Los parámetros de conversión a Slow están fuera de rango.")
	for status_id: StringName in status_damage_multipliers:
		if status_id == &"" or status_damage_multipliers[status_id] < 1.0 or not is_finite(status_damage_multipliers[status_id]):
			errors.append("Los multiplicadores periódicos deben tener ID y ser finitos desde ×1.")
	for status_id: StringName in status_max_damage_per_second:
		if status_id == &"" or status_max_damage_per_second[status_id] <= 0.0 or not is_finite(status_max_damage_per_second[status_id]):
			errors.append("Los límites de estado deben tener ID y DPS positivo.")
	for status_id: StringName in status_condition_layer_damage_adds:
		if status_id == &"" or status_condition_layer_damage_adds[status_id] < 0.0 or not is_finite(status_condition_layer_damage_adds[status_id]):
			errors.append("Los bonus contra estados deben tener ID y valor finito no negativo.")
	for status_id: StringName in status_crit_damage_conversion_fractions:
		if status_id == &"" or status_crit_damage_conversion_fractions[status_id] < 0.0 or not is_finite(status_crit_damage_conversion_fractions[status_id]):
			errors.append("Las conversiones críticas de estados deben tener ID y fracción válida.")
	var status_ids: Dictionary[StringName, bool] = {}
	for status_effect: Resource in status_payloads:
		if status_effect == null or not status_effect.has_method("validate"):
			errors.append("DamagePacket incluye un payload de estado no válido.")
			continue
		var status_errors: PackedStringArray = status_effect.call("validate")
		for status_error in status_errors:
			errors.append("Payload de estado: %s" % status_error)
		status_ids[StringName(status_effect.get("id"))] = true
	for effect_id: StringName in status_total_damage_overrides:
		if not status_ids.has(effect_id):
			errors.append("DamagePacket define daño total para un estado que no incluye.")
		if status_total_damage_overrides[effect_id] < 0:
			errors.append("El daño total de un estado no puede ser negativo.")
	return errors

func get_hit_point_multiplier(layer: int) -> float:
	match layer:
		0:
			return health_damage_multiplier
		1:
			return armor_damage_multiplier
		2:
			return shield_damage_multiplier
		_:
			return 0.0
