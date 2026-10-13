class_name PermanentUpgradeOperation
extends Resource

enum EffectType {
	STARTING_GOLD_ADD,
	STARTING_MANA_ADD,
	MAXIMUM_MANA_ADD,
	MANA_REGEN_ADD,
	TOWER_DAMAGE_MULTIPLIER,
	UNLOCK_CONTENT,
	CHEST_SPAWN_CHANCE_ADD,
	GOLD_PER_KILL_ADD,
	CARD_OFFER_SIZE_ADD,
	BASE_MAX_HEALTH_ADD,
	BASE_REPAIR_MAX_CHANCE_ADD,
	TOWER_HIT_POINT_MULTIPLIER_ADD,
}

@export_enum("Starting Gold", "Starting Mana", "Mana Capacity", "Mana Regeneration", "Global Damage Multiplier", "Unlock Content", "Chest Chance", "Gold per Kill", "Card Offer Size", "Base Maximum Health", "Base Repair Chance", "Tower H/A/S Damage")
var effect_type: int = EffectType.STARTING_GOLD_ADD
@export var value: float = 0.0
@export var affected_tower_id: StringName = &""
@export_enum("Health", "Armor", "Shield") var affected_hit_point_layer: int = 0
@export var unlocked_content_id: StringName = &""

func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if effect_type < EffectType.STARTING_GOLD_ADD or effect_type > EffectType.TOWER_HIT_POINT_MULTIPLIER_ADD:
		errors.append("El efecto permanente configurado no existe.")
	if not is_finite(value):
		errors.append("El valor de una operación permanente debe ser finito.")
	elif effect_type == EffectType.UNLOCK_CONTENT:
		if unlocked_content_id == &"":
			errors.append("Un efecto de desbloqueo requiere un ID de contenido.")
	elif effect_type == EffectType.TOWER_DAMAGE_MULTIPLIER:
		if value <= 0.0 or value > 4.0:
			errors.append("El multiplicador de daño permanente debe estar entre 0 y 4.")
	elif effect_type == EffectType.BASE_REPAIR_MAX_CHANCE_ADD:
		if value < 0.0 or value > 1.0:
			errors.append("La probabilidad máxima de reparación debe estar entre 0 y 100%.")
	elif effect_type == EffectType.TOWER_HIT_POINT_MULTIPLIER_ADD:
		if value < 0.0 or value > 100.0 or affected_tower_id == "" or affected_hit_point_layer < 0 or affected_hit_point_layer > 2:
			errors.append("El bonus permanente H/A/S requiere torre, capa y valor válidos.")
	elif effect_type == EffectType.CARD_OFFER_SIZE_ADD:
		if value < 0.0 or value > 3.0 or not is_equal_approx(value, roundf(value)):
			errors.append("El tamaño de oferta debe aumentar entre cero y tres opciones enteras.")
	elif value < 0.0:
		errors.append("El valor de una mejora permanente no puede ser negativo.")
	return errors
