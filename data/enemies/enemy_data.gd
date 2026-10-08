class_name EnemyData
extends Resource

@export var id: StringName = &""
@export var display_name: String = ""
@export_range(1, 100000, 1) var max_health: int = 20
@export_range(1.0, 1000.0, 0.1) var move_speed: float = 90.0
@export_range(0, 100000, 1) var base_damage: int = 10
@export_range(0, 100000, 1) var armor: int = 0
@export var scene: PackedScene

func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if id == &"":
		errors.append("EnemyData requiere un ID.")
	if display_name.strip_edges().is_empty():
		errors.append("EnemyData requiere un nombre visible.")
	if max_health <= 0:
		errors.append("La salud máxima del enemigo debe ser mayor que cero.")
	if move_speed <= 0.0:
		errors.append("La velocidad del enemigo debe ser mayor que cero.")
	if base_damage < 0:
		errors.append("El daño del enemigo no puede ser negativo.")
	if armor < 0:
		errors.append("La armadura del enemigo no puede ser negativa.")
	if scene == null:
		errors.append("EnemyData requiere una escena de enemigo.")
	return errors
