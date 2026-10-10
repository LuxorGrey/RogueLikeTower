class_name StartingBoardData
extends Resource

const REQUIRED_CELL_COUNT: int = 19

@export var id: StringName = &""
@export var display_name: String = ""
@export var base_coord: Vector2i = Vector2i.ZERO
@export_range(1, 20, 1) var minimum_spawn_route_cells: int = 4
@export var cells: Array[TerrainPieceCellData] = []

func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if id == &"":
		errors.append("El tablero inicial necesita un ID estable.")
	if display_name.strip_edges().is_empty():
		errors.append("El tablero inicial necesita un nombre visible.")
	if cells.size() != REQUIRED_CELL_COUNT:
		errors.append("El tablero inicial debe contener exactamente %d hexágonos." % REQUIRED_CELL_COUNT)
	if minimum_spawn_route_cells < 1:
		errors.append("La ruta mínima de spawn debe tener al menos una celda PATH.")
	if cells.is_empty():
		errors.append("El tablero inicial debe contener celdas.")
		return errors

	var cells_by_coord: Dictionary[Vector2i, TerrainPieceCellData] = {}
	for cell in cells:
		if cell == null:
			errors.append("El tablero inicial contiene una celda vacía.")
			continue
		if cells_by_coord.has(cell.local_coord):
			errors.append("La coordenada inicial %s está repetida." % cell.local_coord)
			continue
		cells_by_coord[cell.local_coord] = cell
		if cell.terrain_type < HexCell.TerrainType.PATH or cell.terrain_type > HexCell.TerrainType.MOUNTAIN:
			errors.append("La celda %s tiene un terreno desconocido." % cell.local_coord)
		if cell.elevation < 0 or cell.elevation > 2:
			errors.append("La elevación de %s debe estar entre 0 y 2." % cell.local_coord)
		if cell.terrain_type == HexCell.TerrainType.PATH and cell.elevation != 0:
			errors.append("PATH debe tener elevación 0 (%s)." % cell.local_coord)
		if cell.terrain_type == HexCell.TerrainType.MOUNTAIN and cell.elevation != 2:
			errors.append("MOUNTAIN debe tener elevación 2 (%s)." % cell.local_coord)
		if cell.path_edges < 0 or cell.path_edges > 63:
			errors.append("Las conexiones PATH de %s exceden los seis bits disponibles." % cell.local_coord)
		if cell.terrain_type != HexCell.TerrainType.PATH and cell.path_edges != 0:
			errors.append("Solo PATH puede declarar conexiones (%s)." % cell.local_coord)

	if not cells_by_coord.has(base_coord):
		errors.append("La coordenada de base %s no pertenece al tablero inicial." % base_coord)
	elif cells_by_coord[base_coord].terrain_type != HexCell.TerrainType.PATH:
		errors.append("La base inicial debe ocupar una celda PATH (%s)." % base_coord)
	else:
		for direction in HexCoord.DIRECTION_OFFSETS:
			var neighbor_coord: Vector2i = base_coord + direction
			var neighbor_cell: TerrainPieceCellData = cells_by_coord.get(neighbor_coord) as TerrainPieceCellData
			if neighbor_cell == null:
				errors.append("Falta el hexágono %s alrededor de la base." % neighbor_coord)
			elif neighbor_cell.elevation != 0:
				errors.append("El anillo inmediato de la base debe tener elevación 0 (%s)." % neighbor_coord)
	if not cells_by_coord.is_empty() and not _is_connected(cells_by_coord):
		errors.append("Las celdas del tablero inicial deben formar una sola región conectada.")
	return errors

func instantiate_cells(rotation_steps: int = 0) -> Dictionary[Vector2i, HexCell]:
	var result: Dictionary[Vector2i, HexCell] = {}
	var normalized_steps: int = posmod(rotation_steps, HexCoord.DIRECTION_OFFSETS.size())
	for cell_data in cells:
		if cell_data == null:
			continue
		var relative_coord: Vector2i = cell_data.local_coord - base_coord
		var rotated_relative: Vector2i = HexCoord.new(relative_coord.x, relative_coord.y).rotated60(normalized_steps).to_key()
		var rotated_coord: Vector2i = base_coord + rotated_relative
		var cell := HexCell.new(HexCoord.new(rotated_coord.x, rotated_coord.y))
		cell.terrain_type = cell_data.terrain_type
		cell.elevation = cell_data.elevation
		cell.buildable = cell_data.terrain_type != HexCell.TerrainType.PATH
		cell.path_edges = _rotate_edge_mask(cell_data.path_edges, normalized_steps)
		cell.flexible_path_edges = _rotate_edge_mask(cell_data.flexible_path_edges, normalized_steps)
		cell.visual_variant = cell_data.visual_variant
		cell.piece_instance_id = 0
		result[rotated_coord] = cell
	return result

func _rotate_edge_mask(edge_mask: int, rotation_steps: int) -> int:
	var rotated_mask: int = 0
	for direction_index in range(HexCoord.DIRECTION_OFFSETS.size()):
		if (edge_mask & (1 << direction_index)) == 0:
			continue
		var rotated_index: int = HexCoord.rotated_direction_index(direction_index, rotation_steps)
		rotated_mask |= 1 << rotated_index
	return rotated_mask

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
