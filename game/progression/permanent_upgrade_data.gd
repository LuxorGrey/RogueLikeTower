class_name PermanentUpgradeData
extends Resource

@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export_range(1, 20, 1) var max_level: int = 1
@export var cost_by_level: Array[int] = []
@export var prerequisites: Array[StringName] = []
@export var operations_by_level: Array[PermanentUpgradeOperation] = []

func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if id == &"":
		errors.append("PermanentUpgradeData requiere un ID estable.")
	if display_name.strip_edges().is_empty():
		errors.append("PermanentUpgradeData requiere un nombre visible.")
	if max_level < 1:
		errors.append("Una mejora permanente debe permitir al menos un nivel.")
	if cost_by_level.size() != max_level:
		errors.append("La mejora permanente requiere un coste por cada nivel.")
	for cost in cost_by_level:
		if cost < 0:
			errors.append("Los costes de mejoras permanentes no pueden ser negativos.")
			break
	if operations_by_level.size() != max_level:
		errors.append("La mejora permanente requiere una operación por cada nivel.")
	for operation in operations_by_level:
		if operation == null:
			errors.append("La mejora permanente contiene una operación vacía.")
			continue
		errors.append_array(operation.validate())
	var unique_prerequisites: Dictionary[StringName, bool] = {}
	for prerequisite in prerequisites:
		if prerequisite == &"" or unique_prerequisites.has(prerequisite):
			errors.append("Los prerrequisitos deben tener IDs no vacíos y únicos.")
			break
		unique_prerequisites[prerequisite] = true
	return errors

func get_cost_for_next_level(current_level: int) -> int:
	if current_level < 0 or current_level >= max_level or current_level >= cost_by_level.size():
		return -1
	return cost_by_level[current_level]
