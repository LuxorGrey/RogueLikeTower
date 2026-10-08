class_name BaseData
extends Resource

@export var id: StringName = &""
@export var display_name: String = ""
@export_range(1, 100000, 1) var max_health: int = 50

func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if id == &"":
		errors.append("BaseData requiere un ID.")
	if display_name.strip_edges().is_empty():
		errors.append("BaseData requiere un nombre visible.")
	if max_health <= 0:
		errors.append("La salud máxima de la base debe ser mayor que cero.")
	return errors
