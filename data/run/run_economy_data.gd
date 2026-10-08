class_name RunEconomyData
extends Resource

@export_range(0, 100000, 1) var starting_gold: int = 150
@export_range(0.0, 100000.0, 0.5) var starting_mana: float = 30.0
@export_range(1.0, 100000.0, 0.5) var maximum_mana: float = 100.0
@export_range(0.0, 10000.0, 0.1) var mana_regen_per_second: float = 1.5

func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if starting_gold < 0:
		errors.append("El oro inicial no puede ser negativo.")
	if starting_mana < 0.0 or starting_mana > maximum_mana:
		errors.append("El maná inicial debe estar entre cero y su capacidad máxima.")
	if maximum_mana <= 0.0:
		errors.append("La capacidad máxima de maná debe ser mayor que cero.")
	if mana_regen_per_second < 0.0:
		errors.append("La regeneración de maná no puede ser negativa.")
	return errors
