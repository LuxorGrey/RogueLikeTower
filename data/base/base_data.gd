class_name BaseData
extends Resource

@export var id: StringName = &""
@export var display_name: String = ""
@export_range(1, 100000, 1) var max_health: int = 50
@export var sprite_texture: Texture2D
@export var sprite_size: Vector2 = Vector2(112.0, 112.0)

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
	if sprite_size.x <= 0.0 or sprite_size.y <= 0.0:
		errors.append("El tamaño del sprite de la base debe ser positivo.")
	return errors
