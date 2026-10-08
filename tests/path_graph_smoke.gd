extends Node

const STARTING_PIECE: TerrainPieceData = preload("res://data/terrain/starting_terrain_piece.tres")

var _failures: PackedStringArray = PackedStringArray()

func _ready() -> void:
	_test_seed_route_and_endpoint()
	_test_exact_to_flexible_connection()
	_test_flexible_offer_is_not_spawn()
	_test_explicit_edge_into_non_path_is_invalid()
	_test_exact_edge_without_complement_is_invalid()
	_test_disconnected_path_is_invalid()
	_test_branch_convergence_and_deterministic_shortest_route()
	if _failures.is_empty():
		print("PathGraph M4 smoke: 7 escenarios correctos.")
	else:
		for failure in _failures:
			push_error("PathGraph M4 smoke: %s" % failure)
	await get_tree().create_timer(1.0).timeout
	get_tree().quit(0 if _failures.is_empty() else 1)

func _test_seed_route_and_endpoint() -> void:
	var seed_cells := TerrainPlacementValidator.instantiate_cells(
		STARTING_PIECE,
		Vector2i.ZERO,
		0,
		0
	)
	var graph := PathGraph.new()
	graph.rebuild(seed_cells, Vector2i.ZERO)
	_expect(graph.is_valid, "la loseta inicial debe tener ruta spawn-base")
	_expect(graph.nodes.size() == 2, "la loseta inicial debe aportar dos nodos PATH")
	_expect(graph.spawn_endpoints.size() == 1, "la salida inicial abierta debe ser el único spawn")
	if graph.routes.size() == 1:
		_expect(
			graph.routes[0].cells == [Vector2i(0, -1), Vector2i.ZERO],
			"la ruta inicial debe ir del borde PATH a la base"
		)
	else:
		_expect(false, "la ruta de la salida inicial debe estar cacheada")

func _test_exact_to_flexible_connection() -> void:
	var board := _new_board([Vector2i.ZERO, Vector2i(1, 0)])
	_connect_cells(board, Vector2i.ZERO, 0, false, true)
	_add_open_spawn(board, Vector2i(1, 0), 0)
	var graph := PathGraph.new()
	graph.rebuild(board, Vector2i.ZERO)
	_expect(graph.is_valid, "un socket exacto debe conectar con el flexible recíproco")
	var base_neighbors: Array = graph.adjacency.get(Vector2i.ZERO, [])
	_expect(base_neighbors.has(Vector2i(1, 0)), "la pareja exacto-flexible debe crear arista")

func _test_flexible_offer_is_not_spawn() -> void:
	var board := _new_board([Vector2i.ZERO])
	var cell: HexCell = board[Vector2i.ZERO]
	cell.flexible_path_edges = 1 << 0
	var graph := PathGraph.new()
	graph.rebuild(board, Vector2i.ZERO)
	_expect(graph.spawn_endpoints.is_empty(), "un socket solo flexible no debe crear spawn")
	_expect(not graph.is_valid, "sin una salida explícita no debe poder iniciarse oleada")

func _test_explicit_edge_into_non_path_is_invalid() -> void:
	var board := _new_board([Vector2i.ZERO, Vector2i(1, 0)])
	_add_open_spawn(board, Vector2i.ZERO, 0)
	var grass := HexCell.new(HexCoord.new(1, 0))
	grass.terrain_type = HexCell.TerrainType.GRASS
	grass.elevation = 1
	grass.buildable = true
	board[Vector2i(1, 0)] = grass
	var graph := PathGraph.new()
	graph.rebuild(board, Vector2i.ZERO)
	_expect(not graph.is_valid, "una salida PATH exacta no puede entrar en GRASS")
	_expect(not graph.errors.is_empty(), "el grafo debe explicar el socket inválido")

func _test_exact_edge_without_complement_is_invalid() -> void:
	var board := _new_board([Vector2i.ZERO, Vector2i(1, 0)])
	_add_open_spawn(board, Vector2i.ZERO, 5)
	_add_open_spawn(board, Vector2i(1, 0), 0)
	board[Vector2i.ZERO].path_edges |= 1 << 0
	var graph := PathGraph.new()
	graph.rebuild(board, Vector2i.ZERO)
	_expect(not graph.is_valid, "un socket exact frente a PATH sin oferta complementaria debe invalidar")
	var explains_socket_mismatch: bool = false
	for error in graph.errors:
		if error.contains("socket complementario"):
			explains_socket_mismatch = true
	_expect(explains_socket_mismatch, "el grafo debe describir que falta el socket complementario")

func _test_disconnected_path_is_invalid() -> void:
	var board := _new_board([Vector2i.ZERO, Vector2i(5, 0)])
	_add_open_spawn(board, Vector2i.ZERO, 4)
	_add_open_spawn(board, Vector2i(5, 0), 0)
	var graph := PathGraph.new()
	graph.rebuild(board, Vector2i.ZERO)
	_expect(not graph.is_valid, "una subred PATH aislada debe invalidar la red")
	_expect(graph.routes.size() == 2, "debe producir un resultado por cada spawn")
	_expect(not graph.routes[1].is_reachable, "el spawn aislado no debe recibir ruta")

func _test_branch_convergence_and_deterministic_shortest_route() -> void:
	var base_coord := Vector2i.ZERO
	var branch_coord := Vector2i(0, -1)
	var alternate_coord := Vector2i(1, -1)
	var fork_coord := Vector2i(0, 1)
	var board := _new_board([base_coord, branch_coord, alternate_coord, fork_coord])
	_connect_cells(board, base_coord, 4)
	_connect_cells(board, base_coord, 5)
	_connect_cells(board, base_coord, 1)
	_connect_cells(board, branch_coord, 0)
	_add_open_spawn(board, branch_coord, 4)
	_add_open_spawn(board, fork_coord, 0)
	var graph := PathGraph.new()
	graph.rebuild(board, base_coord)
	_expect(graph.is_valid, "la red con rama y convergencia debe ser válida")
	_expect(graph.get_branch_count() == 1, "el nodo común de tres caminos debe contar como bifurcación")
	var branch_neighbors: Array = graph.adjacency.get(branch_coord, [])
	var alternate_neighbors: Array = graph.adjacency.get(alternate_coord, [])
	_expect(branch_neighbors.has(base_coord), "la rama debe conservar el enlace directo a base")
	_expect(branch_neighbors.has(alternate_coord), "la rama debe conservar su alternativa")
	_expect(alternate_neighbors.has(base_coord), "la alternativa debe converger de nuevo a base")
	var first_graph_route: Array[Vector2i] = graph.find_route(branch_coord, base_coord)
	var repeated_graph := PathGraph.new()
	repeated_graph.rebuild(board, base_coord)
	var repeated_route: Array[Vector2i] = repeated_graph.find_route(branch_coord, base_coord)
	_expect(first_graph_route == [branch_coord, base_coord], "BFS debe escoger el enlace directo mínimo")
	_expect(first_graph_route == repeated_route, "el desempate/ruta debe ser reproducible")

func _new_board(coords: Array[Vector2i]) -> Dictionary[Vector2i, HexCell]:
	var board: Dictionary[Vector2i, HexCell] = {}
	for coord in coords:
		board[coord] = HexCell.new(HexCoord.new(coord.x, coord.y))
	return board

func _connect_cells(
	board: Dictionary[Vector2i, HexCell],
	coord: Vector2i,
	direction_index: int,
	use_flexible_on_first: bool = false,
	use_flexible_on_second: bool = false
) -> void:
	var neighbor_coord: Vector2i = coord + HexCoord.DIRECTION_OFFSETS[direction_index]
	var opposite_direction: int = posmod(direction_index + 3, 6)
	var first: HexCell = board[coord]
	var second: HexCell = board[neighbor_coord]
	if use_flexible_on_first:
		first.flexible_path_edges |= 1 << direction_index
	else:
		first.path_edges |= 1 << direction_index
	if use_flexible_on_second:
		second.flexible_path_edges |= 1 << opposite_direction
	else:
		second.path_edges |= 1 << opposite_direction

func _add_open_spawn(board: Dictionary[Vector2i, HexCell], coord: Vector2i, direction_index: int) -> void:
	var cell: HexCell = board[coord]
	cell.path_edges |= 1 << direction_index

func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures.append(message)
