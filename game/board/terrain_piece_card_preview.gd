extends Control

const HEX_RADIUS: float = 52.0
const ELEVATION_PIXEL_OFFSET: float = 18.0
const HEX_OUTLINE: Color = Color(0.82, 0.87, 0.84)
const PATH_COLOR: Color = Color(0.35, 0.40, 0.43)
const GRASS_COLOR: Color = Color(0.28, 0.57, 0.34)
const MOUNTAIN_COLOR: Color = Color(0.63, 0.58, 0.48)

var _piece: TerrainPieceData

func set_piece(piece: TerrainPieceData) -> void:
	_piece = piece
	queue_redraw()

func _draw() -> void:
	if _piece == null or size.x <= 1.0 or size.y <= 1.0:
		return

	var cells: Array[TerrainPieceCellData] = _piece.rotated_cells(0)
	var centers: Dictionary[Vector2i, Vector2] = {}
	var cells_by_coord: Dictionary[Vector2i, TerrainPieceCellData] = {}
	var bounds := Rect2()
	var has_bounds: bool = false
	for cell in cells:
		var center := _cell_center(cell)
		centers[cell.local_coord] = center
		cells_by_coord[cell.local_coord] = cell
		var cell_bounds := Rect2(
			center + Vector2(-HEX_RADIUS, -HEX_RADIUS),
			Vector2(HEX_RADIUS * 2.0, HEX_RADIUS * 2.0 + float(cell.elevation) * ELEVATION_PIXEL_OFFSET)
		)
		bounds = cell_bounds if not has_bounds else bounds.merge(cell_bounds)
		has_bounds = true
	if not has_bounds:
		return

	var padding: float = 5.0
	var render_scale: float = minf(
		(size.x - padding * 2.0) / bounds.size.x,
		(size.y - padding * 2.0) / bounds.size.y
	)
	render_scale = maxf(render_scale, 0.01)
	var source_center: Vector2 = bounds.get_center()
	var target_center: Vector2 = size * 0.5
	var rendered_centers: Dictionary[Vector2i, Vector2] = {}
	for coord in centers:
		rendered_centers[coord] = target_center + (centers[coord] - source_center) * render_scale

	cells.sort_custom(Callable(self, "_sort_cells_back_to_front"))
	_draw_cliffs(cells, cells_by_coord, rendered_centers, render_scale)
	for cell in cells:
		var center: Vector2 = rendered_centers[cell.local_coord]
		var corners := _hex_corners(center, HEX_RADIUS * render_scale)
		var closed_corners := corners.duplicate()
		closed_corners.append(corners[0])
		draw_colored_polygon(corners, _terrain_color(cell.terrain_type))
		draw_polyline(closed_corners, HEX_OUTLINE, maxf(1.0, 1.8 * render_scale), true)
		_draw_path_edges(cell, center, corners, render_scale)

func _draw_cliffs(
	cells: Array[TerrainPieceCellData],
	cells_by_coord: Dictionary[Vector2i, TerrainPieceCellData],
	centers: Dictionary[Vector2i, Vector2],
	render_scale: float
) -> void:
	for cell in cells:
		for direction_index in range(HexCoord.DIRECTION_OFFSETS.size()):
			var neighbor_coord: Vector2i = cell.local_coord + HexCoord.DIRECTION_OFFSETS[direction_index]
			var neighbor: TerrainPieceCellData = cells_by_coord.get(neighbor_coord) as TerrainPieceCellData
			var neighbor_elevation: int = neighbor.elevation if neighbor != null else 0
			if cell.elevation <= neighbor_elevation:
				continue

			var center: Vector2 = centers[cell.local_coord]
			var corners := _hex_corners(center, HEX_RADIUS * render_scale)
			var edge_start: int = posmod(direction_index + 1, 6)
			var edge_end: int = posmod(direction_index + 2, 6)
			var upper_start: Vector2 = corners[edge_start]
			var upper_end: Vector2 = corners[edge_end]
			var face_offset := Vector2(
				0.0,
				float(cell.elevation - neighbor_elevation) * ELEVATION_PIXEL_OFFSET * render_scale
			)
			var lower_start: Vector2 = upper_start + face_offset
			var lower_end: Vector2 = upper_end + face_offset
			var cliff_color: Color = _terrain_color(cell.terrain_type).darkened(0.38)
			draw_colored_polygon(PackedVector2Array([upper_start, upper_end, lower_end]), cliff_color)
			draw_colored_polygon(PackedVector2Array([upper_start, lower_end, lower_start]), cliff_color)

func _draw_path_edges(
	cell: TerrainPieceCellData,
	center: Vector2,
	corners: PackedVector2Array,
	render_scale: float
) -> void:
	if cell.terrain_type != HexCell.TerrainType.PATH:
		return
	for direction_index in range(HexCoord.DIRECTION_OFFSETS.size()):
		var edge_bit: int = 1 << direction_index
		var explicit_edge: bool = (cell.path_edges & edge_bit) != 0
		var flexible_edge: bool = (cell.flexible_path_edges & edge_bit) != 0
		if not explicit_edge and not flexible_edge:
			continue
		var edge_start: int = posmod(direction_index + 1, 6)
		var edge_end: int = posmod(direction_index + 2, 6)
		var midpoint: Vector2 = (corners[edge_start] + corners[edge_end]) * 0.5
		var color := Color(0.9, 0.94, 0.95, 0.92 if explicit_edge else 0.58)
		draw_line(center, midpoint, color, maxf(1.0, (3.0 if explicit_edge else 2.5) * render_scale), true)
		draw_circle(midpoint, maxf(1.5, (3.5 if explicit_edge else 3.0) * render_scale), color)

func _cell_center(cell: TerrainPieceCellData) -> Vector2:
	var coord := HexCoord.new(cell.local_coord.x, cell.local_coord.y)
	var ground_position: Vector2 = HexMath.axial_to_world(coord, HEX_RADIUS)
	return ground_position - Vector2(0.0, float(cell.elevation) * ELEVATION_PIXEL_OFFSET)

func _sort_cells_back_to_front(a: TerrainPieceCellData, b: TerrainPieceCellData) -> bool:
	return _cell_center(a).y < _cell_center(b).y

func _hex_corners(center: Vector2, radius: float) -> PackedVector2Array:
	var corners := PackedVector2Array()
	for corner_index in range(6):
		var angle_radians: float = deg_to_rad(-90.0 + 60.0 * float(corner_index))
		corners.append(center + Vector2(cos(angle_radians), sin(angle_radians)) * radius)
	return corners

func _terrain_color(terrain_type: int) -> Color:
	match terrain_type:
		HexCell.TerrainType.PATH:
			return PATH_COLOR
		HexCell.TerrainType.GRASS:
			return GRASS_COLOR
		HexCell.TerrainType.MOUNTAIN:
			return MOUNTAIN_COLOR
		_:
			return Color.MAGENTA
