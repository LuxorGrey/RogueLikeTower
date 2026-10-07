class_name TerrainPieceData
extends Resource

const REQUIRED_CELL_COUNT: int = 7

@export var id: StringName = &""
@export var display_name: String = ""
@export_range(0.0, 1000.0, 0.1) var weight: float = 1.0
@export var tags: Array[StringName] = []
@export var requires_path_connection: bool = true
@export var cells: Array[TerrainPieceCellData] = []

func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if id == &"":
		errors.append("La pieza necesita un ID estable.")
	if display_name.strip_edges().is_empty():
		errors.append("La pieza necesita un nombre visible.")
	if weight < 0.0:
		errors.append("El peso de selección no puede ser negativo.")
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
		if cell.terrain_type == HexCell.TerrainType.PATH and cell.elevation != 0:
			errors.append("PATH debe tener elevación 0 (%s)." % cell.local_coord)
		if cell.terrain_type == HexCell.TerrainType.MOUNTAIN and cell.elevation != 2:
			errors.append("MOUNTAIN debe tener elevación 2 (%s)." % cell.local_coord)
		if cell.path_edges < 0 or cell.path_edges > 63:
			errors.append("Las conexiones de camino de %s no caben en seis bits." % cell.local_coord)
		if cell.terrain_type != HexCell.TerrainType.PATH and cell.path_edges != 0:
			errors.append("Solo PATH puede declarar conexiones de camino (%s)." % cell.local_coord)

	if not cells_by_coord.has(Vector2i.ZERO):
		errors.append("La pieza debe contener una celda en (0,0), que actúa como pivote.")
	if not cells_by_coord.is_empty() and not _is_connected(cells_by_coord):
		errors.append("Los siete hexágonos de la pieza deben formar un grupo conectado.")
	var has_external_path_edge := false
	for coord in cells_by_coord:
		var cell: TerrainPieceCellData = cells_by_coord[coord]
		for direction_index in range(HexCoord.DIRECTION_OFFSETS.size()):
			if not _has_edge(cell.path_edges, direction_index):
				continue
			var neighbor_coord: Vector2i = coord + HexCoord.DIRECTION_OFFSETS[direction_index]
			if not cells_by_coord.has(neighbor_coord):
				has_external_path_edge = true
				continue
			var neighbor: TerrainPieceCellData = cells_by_coord[neighbor_coord]
			if neighbor.terrain_type != HexCell.TerrainType.PATH:
				errors.append("La salida PATH de %s apunta a terreno no PATH en %s." % [coord, neighbor_coord])
				continue
			var opposite_direction: int = posmod(direction_index + 3, 6)
			if not _has_edge(neighbor.path_edges, opposite_direction):
				errors.append("La conexión interna entre %s y %s no es recíproca." % [coord, neighbor_coord])
	if requires_path_connection and not has_external_path_edge:
		errors.append("La pieza requiere al menos una salida PATH hacia otra pieza.")
	return errors

func rotated_cells(steps: int) -> Array[TerrainPieceCellData]:
	var result: Array[TerrainPieceCellData] = []
	var normalized_steps: int = posmod(steps, 6)
	var cells_by_coord: Dictionary[Vector2i, TerrainPieceCellData] = {}
	for source_cell in cells:
		if source_cell != null:
			cells_by_coord[source_cell.local_coord] = source_cell

	for source_cell in cells:
		if source_cell == null:
			continue
		var rotated_cell := source_cell.duplicate(true) as TerrainPieceCellData
		if rotated_cell == null:
			continue
		var source_coord := HexCoord.new(source_cell.local_coord.x, source_cell.local_coord.y)
		rotated_cell.local_coord = source_coord.rotated60(normalized_steps).to_key()
		rotated_cell.path_edges = _rotate_path_edges(source_cell.path_edges, normalized_steps)
		rotated_cell.flexible_path_edges = _rotate_path_edges(
			_flexible_boundary_edges(source_cell, cells_by_coord),
			normalized_steps
		)
		result.append(rotated_cell)
	return result

func _flexible_boundary_edges(
	cell: TerrainPieceCellData,
	cells_by_coord: Dictionary[Vector2i, TerrainPieceCellData]
) -> int:
	if cell.terrain_type != HexCell.TerrainType.PATH:
		return 0

	var explicit_boundary_exits: int = 0
	for direction_index in range(HexCoord.DIRECTION_OFFSETS.size()):
		if not _has_edge(cell.path_edges, direction_index):
			continue
		var neighbor_coord: Vector2i = cell.local_coord + HexCoord.DIRECTION_OFFSETS[direction_index]
		if not cells_by_coord.has(neighbor_coord):
			explicit_boundary_exits |= 1 << direction_index

	var flexible_edges: int = 0
	for direction_index in range(HexCoord.DIRECTION_OFFSETS.size()):
		if not _has_edge(explicit_boundary_exits, direction_index):
			continue
		for lateral_step in [-1, 1]:
			var lateral_direction: int = posmod(direction_index + lateral_step, 6)
			var lateral_coord: Vector2i = (
				cell.local_coord + HexCoord.DIRECTION_OFFSETS[lateral_direction]
			)
			if not cells_by_coord.has(lateral_coord) and not _has_edge(cell.path_edges, lateral_direction):
				flexible_edges |= 1 << lateral_direction
	return flexible_edges

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

func _has_edge(edge_mask: int, direction_index: int) -> bool:
	return (edge_mask & (1 << direction_index)) != 0
