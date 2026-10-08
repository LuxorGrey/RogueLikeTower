class_name PathGraph
extends RefCounted

var nodes: Array[Vector2i] = []
var adjacency: Dictionary[Vector2i, Array] = {}
var spawn_endpoints: Array[PathEndpoint] = []
var base_endpoint: PathEndpoint
var routes: Array[PathRoute] = []
var errors: PackedStringArray = PackedStringArray()
var is_valid: bool = false

func rebuild(
	board_cells: Dictionary[Vector2i, HexCell],
	base_coord: Vector2i,
	minimum_spawn_route_cells: int = 1
) -> void:
	nodes.clear()
	adjacency.clear()
	spawn_endpoints.clear()
	routes.clear()
	errors.clear()
	base_endpoint = null
	is_valid = false

	var path_cells: Dictionary[Vector2i, HexCell] = {}
	for coord in board_cells:
		var cell: HexCell = board_cells[coord]
		if cell == null or cell.terrain_type != HexCell.TerrainType.PATH:
			continue
		path_cells[coord] = cell
		nodes.append(coord)
		var neighbors: Array[Vector2i] = []
		adjacency[coord] = neighbors
	nodes.sort_custom(Callable(self, "_coord_precedes"))

	if nodes.is_empty():
		errors.append("El tablero no contiene celdas PATH.")
		return
	if minimum_spawn_route_cells < 1:
		errors.append("La ruta mínima de spawn debe contener al menos una celda PATH.")
		return

	if not path_cells.has(base_coord):
		errors.append("La base provisional debe estar sobre una celda PATH en %s." % base_coord)
	else:
		base_endpoint = PathEndpoint.new(PathEndpoint.Role.BASE, base_coord)

	_build_adjacency(board_cells, path_cells)
	_collect_spawn_endpoints(board_cells, path_cells)

	if base_endpoint == null:
		return
	if spawn_endpoints.is_empty():
		errors.append("El tablero no tiene salidas externas PATH que puedan actuar como spawn.")

	var reachable_from_base := _collect_reachable(base_coord)
	var unreachable_coords: Array[Vector2i] = []
	for coord in nodes:
		if not reachable_from_base.has(coord):
			unreachable_coords.append(coord)
	if not unreachable_coords.is_empty():
		errors.append("Hay %d celdas PATH sin conexión con la base; primera: %s." % [
		unreachable_coords.size(),
		unreachable_coords[0],
	])

	for endpoint in spawn_endpoints:
		var route := PathRoute.new()
		route.spawn_endpoint = endpoint
		route.base_endpoint = base_endpoint
		route.cells = find_route(endpoint.cell_coord, base_coord)
		route.is_reachable = not route.cells.is_empty()
		routes.append(route)
		if not route.is_reachable:
			errors.append("El endpoint spawn %s (dirección %d) no tiene ruta a la base." % [
			endpoint.cell_coord,
			endpoint.edge_direction,
		])
		elif route.cells.size() < minimum_spawn_route_cells:
			errors.append("La ruta del spawn %s hasta la base tiene %d celdas PATH; el mínimo es %d." % [
			endpoint.cell_coord,
			route.cells.size(),
			minimum_spawn_route_cells,
		])

	is_valid = errors.is_empty()

func find_route(start_coord: Vector2i, goal_coord: Vector2i) -> Array[Vector2i]:
	var route: Array[Vector2i] = []
	if not adjacency.has(start_coord) or not adjacency.has(goal_coord):
		return route
	if start_coord == goal_coord:
		route.append(start_coord)
		return route

	var pending: Array[Vector2i] = [start_coord]
	var queue_head: int = 0
	var visited: Dictionary[Vector2i, bool] = {start_coord: true}
	var parent_by_coord: Dictionary[Vector2i, Vector2i] = {}
	while queue_head < pending.size():
		var current_coord: Vector2i = pending[queue_head]
		queue_head += 1
		var neighbors: Array[Vector2i] = adjacency[current_coord]
		for neighbor_coord in neighbors:
			if visited.has(neighbor_coord):
				continue
			visited[neighbor_coord] = true
			parent_by_coord[neighbor_coord] = current_coord
			if neighbor_coord == goal_coord:
				return _reconstruct_route(start_coord, goal_coord, parent_by_coord)
			pending.append(neighbor_coord)
	return route

func get_branch_count() -> int:
	var branch_count: int = 0
	for coord in nodes:
		var neighbors: Array[Vector2i] = adjacency[coord]
		if neighbors.size() >= 3:
			branch_count += 1
	return branch_count

func get_reachable_node_count() -> int:
	if base_endpoint == null:
		return 0
	return _collect_reachable(base_endpoint.cell_coord).size()

func _build_adjacency(
	board_cells: Dictionary[Vector2i, HexCell],
	path_cells: Dictionary[Vector2i, HexCell]
) -> void:
	for coord in nodes:
		var cell: HexCell = path_cells[coord]
		for direction_index in range(HexCoord.DIRECTION_OFFSETS.size()):
			var neighbor_coord: Vector2i = coord + HexCoord.DIRECTION_OFFSETS[direction_index]
			if not board_cells.has(neighbor_coord):
				continue
			var neighbor: HexCell = board_cells[neighbor_coord]
			if neighbor == null:
				continue
			if neighbor.terrain_type != HexCell.TerrainType.PATH:
				if _has_edge(cell.path_edges, direction_index):
					errors.append("La salida PATH de %s apunta a terreno no PATH en %s." % [coord, neighbor_coord])
				continue

			var opposite_direction: int = posmod(direction_index + 3, 6)
			var cell_offers: bool = _offers_edge(cell, direction_index)
			var neighbor_offers: bool = _offers_edge(neighbor, opposite_direction)
			if cell_offers and neighbor_offers:
				var neighbors: Array[Vector2i] = adjacency[coord]
				neighbors.append(neighbor_coord)
				adjacency[coord] = neighbors

			if not _coord_precedes(coord, neighbor_coord):
				continue
			var cell_has_explicit_edge: bool = _has_edge(cell.path_edges, direction_index)
			var neighbor_has_explicit_edge: bool = _has_edge(neighbor.path_edges, opposite_direction)
			if cell_has_explicit_edge and not neighbor_offers:
				errors.append("La salida PATH de %s no encuentra socket complementario en %s." % [coord, neighbor_coord])
			if neighbor_has_explicit_edge and not cell_offers:
				errors.append("La salida PATH de %s no encuentra socket complementario en %s." % [neighbor_coord, coord])

func _collect_spawn_endpoints(
	board_cells: Dictionary[Vector2i, HexCell],
	path_cells: Dictionary[Vector2i, HexCell]
) -> void:
	for coord in nodes:
		var cell: HexCell = path_cells[coord]
		for direction_index in range(HexCoord.DIRECTION_OFFSETS.size()):
			if not _has_edge(cell.path_edges, direction_index):
				continue
			var outside_coord: Vector2i = coord + HexCoord.DIRECTION_OFFSETS[direction_index]
			if board_cells.has(outside_coord):
				continue
			spawn_endpoints.append(PathEndpoint.new(
				PathEndpoint.Role.SPAWN,
				coord,
				direction_index,
				outside_coord
			))

func _collect_reachable(start_coord: Vector2i) -> Dictionary[Vector2i, bool]:
	var visited: Dictionary[Vector2i, bool] = {}
	if not adjacency.has(start_coord):
		return visited
	var pending: Array[Vector2i] = [start_coord]
	var queue_head: int = 0
	visited[start_coord] = true
	while queue_head < pending.size():
		var current_coord: Vector2i = pending[queue_head]
		queue_head += 1
		var neighbors: Array[Vector2i] = adjacency[current_coord]
		for neighbor_coord in neighbors:
			if visited.has(neighbor_coord):
				continue
			visited[neighbor_coord] = true
			pending.append(neighbor_coord)
	return visited

func _reconstruct_route(
	start_coord: Vector2i,
	goal_coord: Vector2i,
	parent_by_coord: Dictionary[Vector2i, Vector2i]
) -> Array[Vector2i]:
	var route: Array[Vector2i] = [goal_coord]
	var cursor: Vector2i = goal_coord
	while cursor != start_coord:
		if not parent_by_coord.has(cursor):
			return []
		cursor = parent_by_coord[cursor]
		route.append(cursor)
	route.reverse()
	return route

func _offers_edge(cell: HexCell, direction_index: int) -> bool:
	return (
		_has_edge(cell.path_edges, direction_index)
		or _has_edge(cell.flexible_path_edges, direction_index)
	)

func _has_edge(edge_mask: int, direction_index: int) -> bool:
	return (edge_mask & (1 << direction_index)) != 0

func _coord_precedes(a: Vector2i, b: Vector2i) -> bool:
	if a.x != b.x:
		return a.x < b.x
	return a.y < b.y
