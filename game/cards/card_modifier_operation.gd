class_name CardModifierOperation
extends Resource

enum Type {
	TOWER_DAMAGE_ADD,
	TOWER_DAMAGE_MULTIPLIER,
	TOWER_RANGE_ADD,
	TOWER_ATTACK_RATE_MULTIPLIER,
	TOWER_AREA_RADIUS_ADD,
	TOWER_MANA_COST_MULTIPLIER,
	STATUS_DURATION_MULTIPLIER,
	MANA_MAX_ADD,
	MANA_REGEN_ADD,
	TOWER_CRIT_CHANCE_ADD,
	TOWER_HIT_POINT_MULTIPLIER_ADD,
	TOWER_STATUS_DAMAGE_BONUS,
	TOWER_SLOW_FRACTION_ADD,
	TOWER_ELEVATION_RANGE_BONUS_MULTIPLIER_ADD,
	TOWER_AREA_RADIUS_MULTIPLIER_ADD,
	STATUS_MAX_DAMAGE_PER_SECOND_ADD,
	STATUS_CONDITION_LAYER_DAMAGE_ADD,
	STATUS_CRIT_CHANCE_ADD,
	STATUS_CRIT_DAMAGE_CONVERSION_ADD,
	STATUS_SLOW_DAMAGE_SCALING_ADD,
	STATUS_POISON_SLOW_FRACTION_ADD,
	TOWER_CRIT_CHANCE_PER_LEVEL_ADD,
	TOWER_MANA_COST_DAMAGE_RATIO_ADD,
	MANA_REGEN_MAX_PERCENT_ADD,
	MANA_ON_KILL_MAX_PERCENT_ADD,
	GOLD_PER_KILL_ADD,
	ENEMY_BASE_DAMAGE_ADD,
	BASE_MAX_HEALTH_ADD,
	STATUS_STRENGTH_CAP_ADD,
}

@export_enum(
	"Daño de torre +",
	"Daño de torre ×",
	"Alcance de torre +",
	"Cadencia de torre ×",
	"Radio de área +",
	"Coste de Mana ×",
	"Duración de estado ×",
	"Mana máximo +",
	"Regeneración de Mana +",
	"Probabilidad crítica de torre +",
	"Multiplicador H/A/S de torre +",
	"Daño periódico de estado +",
	"Slow por daño +",
	"Bonus de alcance por elevación +",
	"Radio de área porcentual +",
	"Límite de daño por segundo de estado +",
	"Daño contra objetivos con estado +",
	"Crítico contra estado +",
	"Convertir daño periódico al crítico +",
	"Daño Burn según Slow +",
	"Poison se convierte en Slow +",
	"Crítico por nivel de torre +",
	"Coste de Mana como fracción del daño +",
	"Regeneración como fracción del Mana máximo +",
	"Mana recuperado por baja como fracción del máximo +",
	"Gold adicional por baja +",
	"Daño de enemigo a base +",
	"Health máximo de base +",
	"Límite de fuerza de estado +"
) var type: int = Type.TOWER_DAMAGE_ADD
@export var affected_tower_id: StringName = &""
@export_flags("Physical", "Fire", "Arcane", "Poison") var affected_damage_tags: int = 0
@export var affected_status_id: StringName = &""
@export_enum("Health", "Armor", "Shield") var affected_hit_point_layer: int = 0
@export var value: float = 0.0

func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if type < Type.TOWER_DAMAGE_ADD or type > Type.STATUS_STRENGTH_CAP_ADD:
		errors.append("La operación de modificador de carta no existe.")
	if not is_finite(value):
		errors.append("El valor del modificador debe ser finito.")
	if type in [Type.TOWER_DAMAGE_MULTIPLIER, Type.TOWER_ATTACK_RATE_MULTIPLIER, Type.TOWER_MANA_COST_MULTIPLIER, Type.STATUS_DURATION_MULTIPLIER] and value <= 0.0:
		errors.append("Los multiplicadores de carta deben ser mayores que cero.")
	if type == Type.STATUS_DURATION_MULTIPLIER and affected_status_id == &"":
		errors.append("Un modificador de duración requiere el ID del estado.")
	if type == Type.TOWER_HIT_POINT_MULTIPLIER_ADD and (affected_hit_point_layer < 0 or affected_hit_point_layer > 2 or value < 0.0):
		errors.append("El modificador H/A/E de torre requiere una capa y un valor no negativos.")
	if type == Type.TOWER_CRIT_CHANCE_ADD and (value < 0.0 or value > 1.5):
		errors.append("El bonus de probabilidad crítica debe estar entre 0 y 150%.")
	if type in [Type.TOWER_STATUS_DAMAGE_BONUS, Type.STATUS_CRIT_DAMAGE_CONVERSION_ADD, Type.STATUS_POISON_SLOW_FRACTION_ADD] and (value < 0.0 or value > 3.0):
		errors.append("La fracción o bonus de estado debe estar entre 0 y 300%.")
	if type in [Type.TOWER_STATUS_DAMAGE_BONUS, Type.STATUS_MAX_DAMAGE_PER_SECOND_ADD, Type.STATUS_CONDITION_LAYER_DAMAGE_ADD, Type.STATUS_CRIT_CHANCE_ADD, Type.STATUS_CRIT_DAMAGE_CONVERSION_ADD, Type.STATUS_SLOW_DAMAGE_SCALING_ADD, Type.STATUS_POISON_SLOW_FRACTION_ADD, Type.STATUS_STRENGTH_CAP_ADD] and affected_status_id == &"":
		errors.append("La operación requiere un ID de estado afectado.")
	if type in [Type.TOWER_SLOW_FRACTION_ADD, Type.TOWER_ELEVATION_RANGE_BONUS_MULTIPLIER_ADD, Type.TOWER_AREA_RADIUS_MULTIPLIER_ADD, Type.TOWER_MANA_COST_DAMAGE_RATIO_ADD] and affected_tower_id == &"":
		errors.append("La operación requiere una torre afectada.")
	if type == Type.STATUS_CRIT_CHANCE_ADD and (value < 0.0 or value > 1.5):
		errors.append("El bonus de crítico condicional debe estar entre 0 y 150%.")
	if type in [Type.MANA_REGEN_MAX_PERCENT_ADD, Type.MANA_ON_KILL_MAX_PERCENT_ADD] and (value < 0.0 or value > 1.0):
		errors.append("El bonus porcentual de Mana debe estar entre 0 y 100%.")
	if type == Type.TOWER_SLOW_FRACTION_ADD and (value < 0.0 or value > 1.0):
		errors.append("La fracción de Slow por daño debe estar entre 0 y 100%.")
	if type == Type.TOWER_MANA_COST_DAMAGE_RATIO_ADD and (value < 0.0 or value > 1.0):
		errors.append("La fracción de coste de Mana debe estar entre 0 y 100%.")
	if affected_damage_tags < 0:
		errors.append("Los tags de daño afectados no pueden ser negativos.")
	return errors
