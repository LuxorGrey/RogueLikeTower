class_name BaseData
extends Resource

@export var id: StringName = &""
@export var display_name: String = ""
@export_range(1, 100000, 1) var max_health: int = 10
@export var sprite_texture: Texture2D

func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if id == &"":
		errors.append("BaseData requiere un ID.")
	if display_name.strip_edges().is_empty():
		errors.append("BaseData requiere un nombre visible.")
	if max_health <= 0:
		errors.append("El Health máximo de la base debe ser mayor que cero.")
	if sprite_texture == null:
		errors.append("BaseData requiere una textura de sprite.")
	return errors
