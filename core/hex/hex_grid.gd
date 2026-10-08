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

func get_enclosed_void_coords() -> Array[Vector2i]:
	var enclosed_coords: Array[Vector2i] = []
	if cells.size() < 7:
		return enclosed_coords

	var min_q: int = 2147483647
	var max_q: int = -2147483648
	var min_r: int = 2147483647
	var max_r: int = -2147483648
	var min_s: int = 2147483647
	var max_s: int = -2147483648
	for coord in cells:
		var s_value: int = -coord.x - coord.y
		min_q = mini(min_q, coord.x)
		max_q = maxi(max_q, coord.x)
		min_r = mini(min_r, coord.y)
		max_r = maxi(max_r, coord.y)
		min_s = mini(min_s, s_value)
		max_s = maxi(max_s, s_value)

	var exterior_voids: Dictionary[Vector2i, bool] = {}
	var pending: Array[Vector2i] = []
	for q_value in range(min_q, max_q + 1):
		for r_value in range(min_r, max_r + 1):
			var coord := Vector2i(q_value, r_value)
			if not _inside_axial_bounds(coord, min_q, max_q, min_r, max_r, min_s, max_s):
				continue
			if cells.has(coord) or not _is_axial_boundary(coord, min_q, max_q, min_r, max_r, min_s, max_s):
				continue
			exterior_voids[coord] = true
			pending.append(coord)
	for coord in cells:
		var cell: HexCell = cells[coord]
		if cell == null or cell.terrain_type != HexCell.TerrainType.PATH:
			continue
		for direction_index in range(HexCoord.DIRECTION_OFFSETS.size()):
			if (cell.path_edges & (1 << direction_index)) == 0:
				continue
			var open_path_coord: Vector2i = coord + HexCoord.DIRECTION_OFFSETS[direction_index]
			if cells.has(open_path_coord) or exterior_voids.has(open_path_coord):
				continue
			if not _inside_axial_bounds(open_path_coord, min_q, max_q, min_r, max_r, min_s, max_s):
				continue
			exterior_voids[open_path_coord] = true
			pending.append(open_path_coord)

	var queue_head: int = 0
	while queue_head < pending.size():
		var current: Vector2i = pending[queue_head]
		queue_head += 1
		for offset in HexCoord.DIRECTION_OFFSETS:
			var neighbor: Vector2i = current + offset
			if cells.has(neighbor) or exterior_voids.has(neighbor):
				continue
			if not _inside_axial_bounds(neighbor, min_q, max_q, min_r, max_r, min_s, max_s):
				continue
			exterior_voids[neighbor] = true
			pending.append(neighbor)

	for q_value in range(min_q, max_q + 1):
		for r_value in range(min_r, max_r + 1):
			var coord := Vector2i(q_value, r_value)
			if not _inside_axial_bounds(coord, min_q, max_q, min_r, max_r, min_s, max_s):
				continue
			if not cells.has(coord) and not exterior_voids.has(coord):
				enclosed_coords.append(coord)
	return enclosed_coords

func _inside_axial_bounds(
	coord: Vector2i,
	min_q: int,
	max_q: int,
	min_r: int,
	max_r: int,
	min_s: int,
	max_s: int
) -> bool:
	var s_value: int = -coord.x - coord.y
	return (
		coord.x >= min_q and coord.x <= max_q
		and coord.y >= min_r and coord.y <= max_r
		and s_value >= min_s and s_value <= max_s
	)

func _is_axial_boundary(
	coord: Vector2i,
	min_q: int,
	max_q: int,
	min_r: int,
	max_r: int,
	min_s: int,
	max_s: int
) -> bool:
	var s_value: int = -coord.x - coord.y
	return (
		coord.x == min_q or coord.x == max_q
		or coord.y == min_r or coord.y == max_r
		or s_value == min_s or s_value == max_s
	)
