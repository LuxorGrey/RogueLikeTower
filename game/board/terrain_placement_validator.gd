class_name TerrainPlacementValidator
extends RefCounted

static func evaluate(
	piece: TerrainPieceData,
	anchor_coord: Vector2i,
	rotation_steps: int,
	board_cells: Dictionary[Vector2i, HexCell]
) -> TerrainPlacementResult:
	var result := TerrainPlacementResult.new()
	if piece == null:
		result.errors.append("No se seleccionó una pieza.")
		return result
	if board_cells.is_empty():
		result.errors.append("No hay tablero al que expandirse.")
		return result

	var piece_errors := piece.validate()
	if not piece_errors.is_empty():
		result.errors.append_array(piece_errors)
		return result

	var candidate_data: Dictionary[Vector2i, TerrainPieceCellData] = {}
	for cell in piece.rotated_cells(rotation_steps):
		var global_coord: Vector2i = anchor_coord + cell.local_coord
		if board_cells.has(global_coord):
			result.errors.append("Solapa una casilla existente en %s." % global_coord)
			continue
		candidate_data[global_coord] = cell

	if not result.errors.is_empty():
		return result

	result.placed_cells = instantiate_cells(piece, anchor_coord, rotation_steps)

	for global_coord in candidate_data:
		for offset in HexCoord.DIRECTION_OFFSETS:
			if board_cells.has(global_coord + offset):
				result.touching_board = true
				break
		if result.touching_board:
			break
	if not result.touching_board:
		result.errors.append("La pieza debe compartir al menos un borde con el tablero.")

	for global_coord in candidate_data:
		var candidate: TerrainPieceCellData = candidate_data[global_coord]
		for direction_index in range(HexCoord.DIRECTION_OFFSETS.size()):
			var neighbor_coord: Vector2i = global_coord + HexCoord.DIRECTION_OFFSETS[direction_index]
			if not board_cells.has(neighbor_coord):
				continue
			var existing: HexCell = board_cells[neighbor_coord]
			var candidate_has_path_edge: bool = _has_edge(candidate.path_edges, direction_index)
			var candidate_has_flexible_edge: bool = _has_edge(candidate.flexible_path_edges, direction_index)
			var opposite_direction: int = posmod(direction_index + 3, 6)
			var existing_has_path_edge: bool = _has_edge(existing.path_edges, opposite_direction)
			var existing_has_flexible_edge: bool = _has_edge(existing.flexible_path_edges, opposite_direction)

			if candidate.terrain_type != HexCell.TerrainType.PATH or existing.terrain_type != HexCell.TerrainType.PATH:
				if candidate_has_path_edge:
					result.errors.append("La salida PATH de %s entra en terreno no PATH (%s)." % [global_coord, neighbor_coord])
				if existing_has_path_edge:
					result.errors.append("La salida PATH existente de %s entraría en terreno no PATH (%s)." % [neighbor_coord, global_coord])
				continue

			var candidate_offers_connection: bool = candidate_has_path_edge or candidate_has_flexible_edge
			var existing_offers_connection: bool = existing_has_path_edge or existing_has_flexible_edge
			if candidate_has_path_edge and not existing_offers_connection:
				result.errors.append("La salida PATH de %s no encuentra una entrada en %s." % [global_coord, neighbor_coord])
			elif existing_has_path_edge and not candidate_offers_connection:
				result.errors.append("La salida PATH existente de %s no encuentra una entrada en %s." % [neighbor_coord, global_coord])
			elif candidate_offers_connection and existing_offers_connection:
				result.path_connection_count += 1

	if piece.requires_path_connection and result.path_connection_count == 0:
		result.errors.append("La pieza debe conectar al menos una salida PATH con un camino existente.")

	result.is_valid = result.errors.is_empty()
	return result

static func instantiate_cells(
	piece: TerrainPieceData,
	anchor_coord: Vector2i,
	rotation_steps: int,
	piece_instance_id: int = -1
) -> Dictionary[Vector2i, HexCell]:
	var instantiated: Dictionary[Vector2i, HexCell] = {}
	if piece == null:
		return instantiated
	for cell_data in piece.rotated_cells(rotation_steps):
		var global_coord: Vector2i = anchor_coord + cell_data.local_coord
		var cell := HexCell.new(HexCoord.new(global_coord.x, global_coord.y))
		cell.terrain_type = cell_data.terrain_type
		cell.elevation = cell_data.elevation
		cell.buildable = cell_data.terrain_type != HexCell.TerrainType.PATH
		cell.path_edges = cell_data.path_edges
		cell.flexible_path_edges = cell_data.flexible_path_edges
		cell.visual_variant = cell_data.visual_variant
		cell.piece_instance_id = piece_instance_id
		instantiated[global_coord] = cell
	return instantiated

static func _has_edge(edge_mask: int, direction_index: int) -> bool:
	return (edge_mask & (1 << direction_index)) != 0
