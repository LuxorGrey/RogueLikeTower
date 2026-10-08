class_name DamagePacket
extends RefCounted

enum DamageTag {
	PHYSICAL = 1,
	FIRE = 2,
	ARCANE = 4,
}

const ALL_DAMAGE_TAGS: int = DamageTag.PHYSICAL | DamageTag.FIRE | DamageTag.ARCANE

var raw_damage: float = 0.0
var source_id: int = 0
var damage_tags: int = DamageTag.PHYSICAL
## Flat armor points removed per armor point before type and health multipliers.
var armor_multiplier: float = 1.0
var health_multiplier: float = 1.0
var regen_counter_strength: float = 0.0
var regen_counter_duration: float = 0.0
var status_payloads: Array[Resource] = []

func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if raw_damage <= 0.0:
		errors.append("DamagePacket requiere daño bruto positivo.")
	if damage_tags <= 0 or (damage_tags & ~ALL_DAMAGE_TAGS) != 0:
		errors.append("DamagePacket contiene tipos de daño desconocidos.")
	if armor_multiplier < 0.0 or armor_multiplier > 4.0 or health_multiplier < 0.0 or health_multiplier > 4.0:
		errors.append("Los multiplicadores de daño deben estar entre 0 y 4.")
	if regen_counter_strength < 0.0 or regen_counter_strength > 1.0:
		errors.append("La fuerza anti-regeneración debe estar entre 0 y 1.")
	if regen_counter_duration < 0.0:
		errors.append("La duración anti-regeneración no puede ser negativa.")
	return errors
