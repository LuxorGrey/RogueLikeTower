class_name TerrainPieceData
extends Resource

const REQUIRED_CELL_COUNT: int = 7

@export var id: StringName = &""
@export var display_name: String = ""
@export var cells: Array[TerrainPieceCellData] = []

func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if cells.size() != REQUIRED_CELL_COUNT:
		errors.append("Una pieza de terreno debe contener exactamente 7 hexágonos.")

	var cells_by_coord: Dictionary[Vector2i, TerrainPieceCellData] = {}
	for cell in cells:
		if cell == null:
			errors.append("La pieza contiene una celda vacía.")
			continue
		if cells_by_coord.has(cell.local_coord):
			errors.append("La coordenada %s está repetida." % cell.local_coord)
			continue
		cells_by_coord[cell.local_coord] = cell
		if cell.terrain_type < HexCell.TerrainType.PATH or cell.terrain_type > HexCell.TerrainType.MOUNTAIN:
			errors.append("La celda %s tiene un terreno desconocido." % cell.local_coord)
		if cell.elevation < 0 or cell.elevation > 2:
			errors.append("La elevación de %s debe estar entre 0 y 2." % cell.local_coord)
		if cell.path_edges < 0 or cell.path_edges > 63:
			errors.append("Las conexiones de camino de %s no caben en seis bits." % cell.local_coord)

	if not cells_by_coord.is_empty() and not _is_connected(cells_by_coord):
		errors.append("Los siete hexágonos de la pieza deben formar un grupo conectado.")
	return errors

func rotated_cells(steps: int) -> Array[TerrainPieceCellData]:
	var result: Array[TerrainPieceCellData] = []
	var normalized_steps: int = posmod(steps, 6)
	for source_cell in cells:
		if source_cell == null:
			continue
		var rotated_cell := source_cell.duplicate(true) as TerrainPieceCellData
		if rotated_cell == null:
			continue
		var source_coord := HexCoord.new(source_cell.local_coord.x, source_cell.local_coord.y)
		rotated_cell.local_coord = source_coord.rotated60(normalized_steps).to_key()
		rotated_cell.path_edges = _rotate_path_edges(source_cell.path_edges, normalized_steps)
		result.append(rotated_cell)
	return result

func _is_connected(cells_by_coord: Dictionary[Vector2i, TerrainPieceCellData]) -> bool:
	var first_coord: Vector2i = cells_by_coord.keys()[0]
	var pending: Array[Vector2i] = [first_coord]
	var visited: Dictionary[Vector2i, bool] = {}
	while not pending.is_empty():
		var coord: Vector2i = pending.pop_back()
		if visited.has(coord):
			continue
		visited[coord] = true
		for offset in HexCoord.DIRECTION_OFFSETS:
			var neighbor_coord: Vector2i = coord + offset
			if cells_by_coord.has(neighbor_coord) and not visited.has(neighbor_coord):
				pending.append(neighbor_coord)
	return visited.size() == cells_by_coord.size()

func _rotate_path_edges(edge_mask: int, steps: int) -> int:
	var result: int = 0
	for direction_index in range(HexCoord.DIRECTION_OFFSETS.size()):
		if (edge_mask & (1 << direction_index)) == 0:
			continue
		var rotated_index: int = HexCoord.rotated_direction_index(direction_index, steps)
		result = result | (1 << rotated_index)
	return result
