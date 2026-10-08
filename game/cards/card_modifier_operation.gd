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
}

@export_enum(
	"Daño de torre +",
	"Daño de torre ×",
	"Alcance de torre +",
	"Cadencia de torre ×",
	"Radio de área +",
	"Coste de maná ×",
	"Duración de estado ×",
	"Maná máximo +",
	"Regeneración de maná +"
) var type: int = Type.TOWER_DAMAGE_ADD
@export var affected_tower_id: StringName = &""
@export_flags("Físico", "Fuego", "Arcano", "Veneno") var affected_damage_tags: int = 0
@export var affected_status_id: StringName = &""
@export var value: float = 0.0

func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if type < Type.TOWER_DAMAGE_ADD or type > Type.MANA_REGEN_ADD:
		errors.append("La operación de modificador de carta no existe.")
	if not is_finite(value):
		errors.append("El valor del modificador debe ser finito.")
	if type in [Type.TOWER_DAMAGE_MULTIPLIER, Type.TOWER_ATTACK_RATE_MULTIPLIER, Type.TOWER_MANA_COST_MULTIPLIER, Type.STATUS_DURATION_MULTIPLIER] and value <= 0.0:
		errors.append("Los multiplicadores de carta deben ser mayores que cero.")
	if type == Type.STATUS_DURATION_MULTIPLIER and affected_status_id == &"":
		errors.append("Un modificador de duración requiere el ID del estado.")
	if affected_damage_tags < 0:
		errors.append("Los tags de daño afectados no pueden ser negativos.")
	return errors
