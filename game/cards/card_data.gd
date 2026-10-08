class_name CardData
extends Resource

enum Rarity { COMMON, UNCOMMON, RARE }

@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export_enum("Común", "Poco común", "Rara") var rarity: int = Rarity.COMMON
@export var unlock_requirement: StringName = &""
@export var tags: Array[StringName] = []
@export var modifier_operations: Array[Resource] = []
@export_range(0.0, 100.0, 0.1) var offer_weight: float = 1.0
@export_range(1, 20, 1) var max_per_run: int = 1

func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if id == &"":
		errors.append("CardData requiere un ID estable.")
	if display_name.strip_edges().is_empty():
		errors.append("CardData requiere un título.")
	if description.strip_edges().is_empty():
		errors.append("CardData requiere una descripción breve del efecto.")
	if rarity < Rarity.COMMON or rarity > Rarity.RARE:
		errors.append("CardData tiene una rareza no válida.")
	if offer_weight < 0.0 or offer_weight > 100.0:
		errors.append("El peso de oferta debe estar entre 0 y 100.")
	if max_per_run < 1 or max_per_run > 20:
		errors.append("El máximo de copias debe estar entre 1 y 20 por run.")
	if modifier_operations.is_empty():
		errors.append("CardData requiere al menos una operación de modificador.")
	for operation in modifier_operations:
		if operation == null or not operation.has_method("validate"):
			errors.append("Cada operación de CardData debe ser CardModifierOperation válida.")
			continue
		var operation_errors: PackedStringArray = operation.call("validate")
		for message in operation_errors:
			errors.append("%s: %s" % [id, message])
	return errors
