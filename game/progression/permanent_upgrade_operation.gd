class_name PermanentUpgradeOperation
extends Resource

enum EffectType {
	STARTING_GOLD_ADD,
	STARTING_MANA_ADD,
	MAXIMUM_MANA_ADD,
	MANA_REGEN_ADD,
	TOWER_DAMAGE_MULTIPLIER,
	UNLOCK_CONTENT,
}

@export_enum("Starting Gold", "Starting Mana", "Mana Capacity", "Mana Regeneration", "Global Damage Multiplier", "Unlock Content")
var effect_type: int = EffectType.STARTING_GOLD_ADD
@export var value: float = 0.0
@export var affected_tower_id: StringName = &""
@export var unlocked_content_id: StringName = &""

func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if effect_type < EffectType.STARTING_GOLD_ADD or effect_type > EffectType.UNLOCK_CONTENT:
		errors.append("El efecto permanente configurado no existe.")
	if not is_finite(value):
		errors.append("El valor de una operación permanente debe ser finito.")
	elif effect_type == EffectType.UNLOCK_CONTENT:
		if unlocked_content_id == &"":
			errors.append("Un efecto de desbloqueo requiere un ID de contenido.")
	elif effect_type == EffectType.TOWER_DAMAGE_MULTIPLIER:
		if value <= 0.0 or value > 4.0:
			errors.append("El multiplicador de daño permanente debe estar entre 0 y 4.")
	elif value < 0.0:
		errors.append("El valor de una mejora permanente no puede ser negativo.")
	return errors
