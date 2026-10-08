class_name TerrainPiecePreview
extends Node2D

signal hover_changed(local_coord: Vector2i, terrain_type: int, elevation: int)
signal hover_cleared

const HEX_RADIUS: float = 52.0
const ELEVATION_PIXEL_OFFSET: float = 18.0
const HEX_OUTLINE: Color = Color(0.82, 0.87, 0.84)
const LIGHT_LABEL_COLOR: Color = Color(0.98, 0.98, 0.93)
const DARK_LABEL_COLOR: Color = Color(0.12, 0.14, 0.13)
const PATH_COLOR: Color = Color(0.35, 0.40, 0.43)
const GRASS_COLOR: Color = Color(0.28, 0.57, 0.34)
const MOUNTAIN_COLOR: Color = Color(0.63, 0.58, 0.48)
const PATH_HOVER_COLOR: Color = Color(0.51, 0.75, 0.90)
const GRASS_HOVER_COLOR: Color = Color(0.50, 0.88, 0.52)
const MOUNTAIN_HOVER_COLOR: Color = Color(0.96, 0.76, 0.36)
const CLIFF_DARKEN_FACTOR: float = 0.38
const CLIFF_MIN_SCREEN_DEPTH: float = 6.0
const ROUTE_DEBUG_COLORS: Array[Color] = [
	Color(0.25, 0.78, 1.0, 0.92),
	Color(1.0, 0.76, 0.25, 0.92),
	Color(0.92, 0.42, 0.86, 0.92),
	Color(0.48, 0.94, 0.52, 0.92),
]

var _piece_data: TerrainPieceData
var _rotation_steps: int = 0
var _display_cells: Array[TerrainPieceCellData] = []
var _board_cells: Dictionary[Vector2i, HexCell] = {}
var _board_mode: bool = false
var _placement_active: bool = false
var _placement_anchor: Vector2i = Vector2i.ZERO
var _placement_is_valid: bool = false
var _board_display_cells: Array[TerrainPieceCellData] = []
var _ghost_coords: Dictionary[Vector2i, bool] = {}
var _hovered_cell: TerrainPieceCellData
var _path_graph: PathGraph
var _path_debug_visible: bool = false
var _tower_build_preview_active: bool = false
var _tower_preview_coord: Vector2i = Vector2i.ZERO
var _tower_preview_is_valid: bool = false
var _tower_preview_range_pixels: float = 0.0

func set_piece(piece_data: TerrainPieceData) -> void:
	_piece_data = piece_data
	_rebuild_display_cells()
	_refresh_hovered_cell()
	queue_redraw()

func set_board_cells(board_cells: Dictionary[Vector2i, HexCell]) -> void:
	_board_mode = true
	_board_cells = board_cells
	_rebuild_display_cells()
	_refresh_hovered_cell()
	queue_redraw()

func set_path_graph(path_graph: PathGraph) -> void:
	_path_graph = path_graph
	queue_redraw()

func set_path_debug_visible(debug_enabled: bool) -> void:
	_path_debug_visible = debug_enabled
	queue_redraw()

func set_tower_build_preview(
	active: bool,
	coord: Vector2i = Vector2i.ZERO,
	is_valid: bool = false,
	range_pixels: float = 0.0
) -> void:
	_tower_build_preview_active = active
	_tower_preview_coord = coord
	_tower_preview_is_valid = is_valid
	_tower_preview_range_pixels = maxf(range_pixels, 0.0)
	queue_redraw()

func set_placement_preview(
	piece_data: TerrainPieceData,
	anchor_coord: Vector2i,
	rotation_steps: int,
	is_valid: bool,
	active: bool = true
) -> void:
	_board_mode = true
	_piece_data = piece_data
	_rotation_steps = posmod(rotation_steps, 6)
	_placement_anchor = anchor_coord
	_placement_is_valid = is_valid
	_placement_active = active
	_rebuild_display_cells()
	_refresh_hovered_cell()
	queue_redraw()

func set_rotation_steps(steps: int) -> void:
	_rotation_steps = posmod(steps, 6)
	_rebuild_display_cells()
	_refresh_hovered_cell()
	queue_redraw()

func _process(_delta: float) -> void:
	_refresh_hovered_cell()

func _draw() -> void:
	if _piece_data == null and _board_cells.is_empty():
		return

	var cells: Array[TerrainPieceCellData] = _active_display_cells()
	var cells_by_coord: Dictionary[Vector2i, TerrainPieceCellData] = {}
	for cell in cells:
		cells_by_coord[cell.local_coord] = cell

	_draw_cliffs(cells, cells_by_coord)
	for cell in cells:
		_draw_cell_top(cell, _ghost_coords.has(cell.local_coord))
	if _board_mode and _path_debug_visible and _path_graph != null:
		_draw_path_debug_overlay()
	if _tower_build_preview_active:
		_draw_tower_build_preview()

func _draw_tower_build_preview() -> void:
	var cell: HexCell = _board_cells.get(_tower_preview_coord) as HexCell
	if cell == null:
		return
	var center := _top_center(_tower_preview_coord, cell.elevation)
	var tint: Color = Color(0.26, 0.95, 0.43, 0.78) if _tower_preview_is_valid else Color(1.0, 0.25, 0.20, 0.78)
	if _tower_preview_range_pixels > 0.0:
		draw_arc(center, _tower_preview_range_pixels, 0.0, TAU, 72, Color(tint.r, tint.g, tint.b, 0.28), 2.0, true)
	var corners := _hex_corners(center)
	corners.append(corners[0])
	draw_polyline(corners, tint, 3.0, true)
	draw_circle(center + Vector2(0.0, -7.0), 9.0, tint)
	draw_line(center + Vector2(0.0, -7.0), center + Vector2(15.0, -7.0), tint.lightened(0.18), 4.0, true)

func _draw_path_debug_overlay() -> void:
	for route_index in range(_path_graph.routes.size()):
		var route: PathRoute = _path_graph.routes[route_index]
		var route_color: Color = ROUTE_DEBUG_COLORS[
			route_index % ROUTE_DEBUG_COLORS.size()
		]
		if not route.is_reachable:
			route_color = Color(1.0, 0.22, 0.20, 0.95)
		var route_points := PackedVector2Array()
		for coord in route.cells:
			route_points.append(_top_center(coord, 0))
		if route_points.size() >= 2:
			draw_polyline(route_points, Color(0.04, 0.05, 0.06, 0.86), 8.0, true)
			draw_polyline(route_points, route_color, 4.0, true)

		var endpoint: PathEndpoint = route.spawn_endpoint
		if endpoint == null:
			continue
		var path_center: Vector2 = _top_center(endpoint.cell_coord, 0)
		var spawn_center: Vector2 = _top_center(endpoint.outside_coord, 0)
		draw_line(path_center, spawn_center, Color(0.04, 0.05, 0.06, 0.86), 7.0, true)
		draw_line(path_center, spawn_center, route_color, 3.5, true)
		draw_circle(spawn_center, 7.0, route_color)
		draw_arc(spawn_center, 9.0, 0.0, TAU, 20, Color(0.03, 0.04, 0.05), 2.0, true)

	if _path_graph.base_endpoint != null:
		var base_center: Vector2 = _top_center(_path_graph.base_endpoint.cell_coord, 0)
		draw_circle(base_center, 12.0, Color(0.04, 0.05, 0.06, 0.92))
		draw_circle(base_center, 8.0, Color(1.0, 0.85, 0.28, 1.0))

func _draw_cliffs(
	cells: Array[TerrainPieceCellData],
	cells_by_coord: Dictionary[Vector2i, TerrainPieceCellData]
) -> void:
	for cell in cells:
		for direction_index in range(HexCoord.DIRECTION_OFFSETS.size()):
			var neighbor_coord: Vector2i = cell.local_coord + HexCoord.DIRECTION_OFFSETS[direction_index]
			var neighbor_cell: TerrainPieceCellData = cells_by_coord.get(neighbor_coord) as TerrainPieceCellData
			var neighbor_elevation: int = 0
			if neighbor_cell != null:
				neighbor_elevation = neighbor_cell.elevation
			if cell.elevation <= neighbor_elevation:
				continue

			var high_center := _top_center(cell.local_coord, cell.elevation)
			var high_corners := _hex_corners(high_center)
			var edge_start: int = posmod(direction_index + 1, 6)
			var edge_end: int = posmod(direction_index + 2, 6)
			var face_offset := Vector2(
				0.0,
				float(cell.elevation - neighbor_elevation) * ELEVATION_PIXEL_OFFSET
			)
			var upper_start: Vector2 = high_corners[edge_start]
			var upper_end: Vector2 = high_corners[edge_end]
			var cliff_edge: Vector2 = upper_end - upper_start
			if absf(cliff_edge.cross(face_offset)) < 0.01:
				var edge_midpoint: Vector2 = (upper_start + upper_end) * 0.5
				face_offset += (edge_midpoint - high_center).normalized() * CLIFF_MIN_SCREEN_DEPTH
			var lower_start: Vector2 = upper_start + face_offset
			var lower_end: Vector2 = upper_end + face_offset
			var cliff_color := _terrain_color(cell.terrain_type).darkened(CLIFF_DARKEN_FACTOR)
			# El grosor mínimo evita caras degeneradas cuando la arista y la altura
			# proyectan en la misma dirección de pantalla.
			draw_colored_polygon(PackedVector2Array([upper_start, upper_end, lower_end]), cliff_color)
			draw_colored_polygon(PackedVector2Array([upper_start, lower_end, lower_start]), cliff_color)
			var closed_cliff := PackedVector2Array([upper_start, upper_end, lower_end, lower_start, upper_start])
			draw_polyline(closed_cliff, _terrain_color(cell.terrain_type).darkened(0.55), 1.5, true)

func _draw_cell_top(cell: TerrainPieceCellData, is_ghost: bool = false) -> void:
	var center := _top_center(cell.local_coord, cell.elevation)
	var corners := _hex_corners(center)
	var closed_corners := corners.duplicate()
	closed_corners.append(corners[0])
	var is_hovered := _is_hovered(cell)
	var label_color := _label_color(cell.terrain_type, is_hovered)
	var fill_color := _terrain_color(cell.terrain_type)
	var outline_color := HEX_OUTLINE
	var outline_width := 2.0
	var placement_tint: Color = Color(0.20, 0.92, 0.37) if _placement_is_valid else Color(0.96, 0.20, 0.16)
	if is_ghost:
		fill_color = fill_color.lerp(placement_tint, 0.48)
		fill_color.a = 0.78
		outline_color = placement_tint.lightened(0.12)
		outline_width = 2.5
	if is_hovered:
		fill_color = _terrain_hover_color(cell.terrain_type)
		if is_ghost:
			fill_color = fill_color.lerp(placement_tint, 0.3)
			fill_color.a = 0.88
		outline_color = fill_color.lightened(0.18)
		outline_width = 3.5
	draw_colored_polygon(corners, fill_color)
	draw_polyline(closed_corners, outline_color, outline_width, true)
	_draw_path_edges(cell, center, corners, is_ghost)
	draw_string(
		ThemeDB.fallback_font,
		center + Vector2(-HEX_RADIUS, 8.0),
		_terrain_initial(cell.terrain_type),
		HORIZONTAL_ALIGNMENT_CENTER,
		HEX_RADIUS * 2.0,
		24,
		label_color
	)
	draw_string(
		ThemeDB.fallback_font,
		center + Vector2(-HEX_RADIUS, 31.0),
		"%d,%d · h%d" % [cell.local_coord.x, cell.local_coord.y, cell.elevation],
		HORIZONTAL_ALIGNMENT_CENTER,
		HEX_RADIUS * 2.0,
		12,
		label_color
	)

func _refresh_hovered_cell() -> void:
	var next_hovered_cell := _find_hovered_cell(get_local_mouse_position())
	if next_hovered_cell == null:
		if _hovered_cell != null:
			_hovered_cell = null
			hover_cleared.emit()
			queue_redraw()
		return

	if _hovered_cell != null:
		var same_cell: bool = (
			_hovered_cell.local_coord == next_hovered_cell.local_coord
			and _hovered_cell.terrain_type == next_hovered_cell.terrain_type
			and _hovered_cell.elevation == next_hovered_cell.elevation
		)
		if same_cell:
			return

	_hovered_cell = next_hovered_cell
	hover_changed.emit(
		_hovered_cell.local_coord,
		_hovered_cell.terrain_type,
		_hovered_cell.elevation
	)
	queue_redraw()

func _find_hovered_cell(mouse_position: Vector2) -> TerrainPieceCellData:
	var cells := _active_display_cells()
	for cell_index in range(cells.size() - 1, -1, -1):
		var cell: TerrainPieceCellData = cells[cell_index]
		var top_face := _hex_corners(_top_center(cell.local_coord, cell.elevation))
		if Geometry2D.is_point_in_polygon(mouse_position, top_face):
			return cell
	return null

func _rebuild_display_cells() -> void:
	_display_cells.clear()
	_board_display_cells.clear()
	_ghost_coords.clear()
	if _piece_data != null:
		_display_cells = _piece_data.rotated_cells(_rotation_steps)
	_display_cells.sort_custom(Callable(self, "_sort_cells_back_to_front"))
	if not _board_mode:
		return
	for coord in _board_cells:
		var source: HexCell = _board_cells[coord]
		if source == null:
			continue
		var cell := TerrainPieceCellData.new()
		cell.local_coord = coord
		cell.terrain_type = source.terrain_type
		cell.elevation = source.elevation
		cell.path_edges = source.path_edges
		cell.flexible_path_edges = source.flexible_path_edges
		cell.visual_variant = source.visual_variant
		_board_display_cells.append(cell)
	if _placement_active and _piece_data != null:
		for local_cell in _display_cells:
			var ghost_cell := local_cell.duplicate(true) as TerrainPieceCellData
			if ghost_cell == null:
				continue
			ghost_cell.local_coord = _placement_anchor + local_cell.local_coord
			_ghost_coords[ghost_cell.local_coord] = true
			_board_display_cells.append(ghost_cell)
	_board_display_cells.sort_custom(Callable(self, "_sort_cells_back_to_front"))

func _active_display_cells() -> Array[TerrainPieceCellData]:
	return _board_display_cells if _board_mode else _display_cells

func _draw_path_edges(
	cell: TerrainPieceCellData,
	center: Vector2,
	corners: PackedVector2Array,
	is_ghost: bool
) -> void:
	if cell.terrain_type != HexCell.TerrainType.PATH:
		return
	var edge_color := Color(0.86, 0.91, 0.93, 0.9)
	var flexible_edge_color := Color(0.86, 0.91, 0.93, 0.55)
	if is_ghost:
		var placement_tint: Color = Color(0.20, 0.92, 0.37) if _placement_is_valid else Color(0.96, 0.20, 0.16)
		edge_color = placement_tint.lightened(0.28)
		flexible_edge_color = edge_color.darkened(0.08)
	for direction_index in range(HexCoord.DIRECTION_OFFSETS.size()):
		var edge_bit: int = 1 << direction_index
		var is_explicit_edge: bool = (cell.path_edges & edge_bit) != 0
		var is_flexible_edge: bool = (cell.flexible_path_edges & edge_bit) != 0
		if not is_explicit_edge and not is_flexible_edge:
			continue
		var edge_start: int = posmod(direction_index + 1, 6)
		var edge_end: int = posmod(direction_index + 2, 6)
		var edge_midpoint: Vector2 = (corners[edge_start] + corners[edge_end]) * 0.5
		var socket_color: Color = edge_color if is_explicit_edge else flexible_edge_color
		var line_width: float = 3.0 if is_explicit_edge else 2.5
		draw_line(center, edge_midpoint, socket_color, line_width, true)
		draw_circle(edge_midpoint, 3.5 if is_explicit_edge else 3.0, socket_color)

func _is_hovered(cell: TerrainPieceCellData) -> bool:
	if _hovered_cell == null:
		return false
	return (
		_hovered_cell.local_coord == cell.local_coord
		and _hovered_cell.terrain_type == cell.terrain_type
		and _hovered_cell.elevation == cell.elevation
	)

func _sort_cells_back_to_front(a: TerrainPieceCellData, b: TerrainPieceCellData) -> bool:
	var a_base := _top_center(a.local_coord, 0)
	var b_base := _top_center(b.local_coord, 0)
	if not is_equal_approx(a_base.y, b_base.y):
		return a_base.y < b_base.y
	return a_base.x < b_base.x

func _top_center(coord: Vector2i, elevation: int) -> Vector2:
	var hex_coord := HexCoord.new(coord.x, coord.y)
	var ground_position := HexMath.axial_to_world(hex_coord, HEX_RADIUS)
	return ground_position + Vector2(0.0, -float(elevation) * ELEVATION_PIXEL_OFFSET)

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

func _terrain_hover_color(terrain_type: int) -> Color:
	match terrain_type:
		HexCell.TerrainType.PATH:
			return PATH_HOVER_COLOR
		HexCell.TerrainType.GRASS:
			return GRASS_HOVER_COLOR
		HexCell.TerrainType.MOUNTAIN:
			return MOUNTAIN_HOVER_COLOR
		_:
			return Color.WHITE

func _terrain_initial(terrain_type: int) -> String:
	match terrain_type:
		HexCell.TerrainType.PATH:
			return "P"
		HexCell.TerrainType.GRASS:
			return "G"
		HexCell.TerrainType.MOUNTAIN:
			return "M"
		_:
			return "?"

func _label_color(terrain_type: int, is_hovered: bool = false) -> Color:
	if is_hovered:
		return DARK_LABEL_COLOR
	if terrain_type == HexCell.TerrainType.MOUNTAIN:
		return DARK_LABEL_COLOR
	return LIGHT_LABEL_COLOR

func _hex_corners(center: Vector2) -> PackedVector2Array:
	var corners := PackedVector2Array()
	for corner_index in range(6):
		var angle_radians: float = deg_to_rad(-90.0 + 60.0 * float(corner_index))
		corners.append(center + Vector2(cos(angle_radians), sin(angle_radians)) * HEX_RADIUS)
	return corners
