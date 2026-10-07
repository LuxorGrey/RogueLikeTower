class_name TerrainPlacementResult
extends RefCounted

var is_valid: bool = false
var errors: PackedStringArray = PackedStringArray()
var placed_cells: Dictionary[Vector2i, HexCell] = {}
var touching_board: bool = false
var path_connection_count: int = 0

func message() -> String:
	if is_valid:
		return "Colocación válida."
	if errors.is_empty():
		return "Colocación inválida."
	return "; ".join(errors)
