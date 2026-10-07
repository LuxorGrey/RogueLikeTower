class_name HexGrid
extends RefCounted

var cells: Dictionary[Vector2i, HexCell] = {}

func clear() -> void:
	cells.clear()

func has_cell(coord: HexCoord) -> bool:
	return coord != null and cells.has(coord.to_key())

func get_cell(coord: HexCoord) -> HexCell:
	if coord == null:
		return null
	return cells.get(coord.to_key()) as HexCell

func add_cell(coord: HexCoord) -> bool:
	if coord == null or has_cell(coord):
		return false
	cells[coord.to_key()] = HexCell.new(coord)
	return true

func add_cells(new_cells: Dictionary[Vector2i, HexCell]) -> bool:
	if new_cells.is_empty():
		return false
	for key in new_cells:
		var cell: HexCell = new_cells[key]
		if cell == null or cell.coord == null or cell.coord.to_key() != key or cells.has(key):
			return false
	for key in new_cells:
		cells[key] = new_cells[key]
	return true

func fill_disc(radius: int) -> void:
	clear()
	if radius < 0:
		push_error("El radio de la cuadrícula no puede ser negativo.")
		return

	var origin := HexCoord.new()
	for q_value in range(-radius, radius + 1):
		for r_value in range(-radius, radius + 1):
			var coord := HexCoord.new(q_value, r_value)
			if origin.distance_to(coord) <= radius:
				add_cell(coord)

func get_neighbors(coord: HexCoord) -> Array[HexCell]:
	var result: Array[HexCell] = []
	if coord == null:
		return result
	for direction_index in range(HexCoord.DIRECTION_OFFSETS.size()):
		var cell := get_cell(coord.neighbor(direction_index))
		if cell != null:
			result.append(cell)
	return result
