class_name TerrainPiecePreview
extends Node2D

signal hover_changed(local_coord: Vector2i, terrain_type: int, elevation: int)
signal hover_cleared

const HEX_RADIUS: float = 52.0
const ELEVATION_PIXEL_OFFSET: float = 18.0
const HEX_OUTLINE: Color = Color(0.82, 0.87, 0.84)
const PATH_COLOR: Color = Color(0.35, 0.40, 0.43)
const GRASS_COLOR: Color = Color(0.28, 0.57, 0.34)
const MOUNTAIN_COLOR: Color = Color(0.63, 0.58, 0.48)
const PATH_HOVER_COLOR: Color = Color(0.51, 0.75, 0.90)
const GRASS_HOVER_COLOR: Color = Color(0.50, 0.88, 0.52)
const MOUNTAIN_HOVER_COLOR: Color = Color(0.96, 0.76, 0.36)
const CLIFF_DARKEN_FACTOR: float = 0.38
const CLIFF_MIN_SCREEN_DEPTH: float = 6.0
const SPAWN_MARKER_DARK: Color = Color(0.035, 0.05, 0.06, 0.96)
const SPAWN_MARKER_COLOR: Color = Color(0.94, 0.27, 0.18, 1.0)
const SPAWN_NEXT_COLOR: Color = Color("#55e39a")
const SPAWN_RETAINED_COLOR: Color = Color("#5dcfff")
const SPAWN_CLOSING_COLOR: Color = Color("#ff7068")
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
var _placement_path_graph: PathGraph
var _path_debug_visible: bool = false
var _tower_build_preview_active: bool = false
var _tower_preview_coord: Vector2i = Vector2i.ZERO
var _tower_preview_is_valid: bool = false
var _tower_preview_range_pixels: float = 0.0
var _tower_preview_icon: Texture2D
var _combo_strength_by_coord: Dictionary[Vector2i, int] = {}
var _combo_animation_time: float = 0.0
var _combo_redraw_timer: float = 0.0

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
	range_pixels: float = 0.0,
	icon_texture: Texture2D = null
) -> void:
	_tower_build_preview_active = active
	_tower_preview_coord = coord
	_tower_preview_is_valid = is_valid
	_tower_preview_range_pixels = maxf(range_pixels, 0.0)
	_tower_preview_icon = icon_texture
	queue_redraw()

func set_placement_preview(
	piece_data: TerrainPieceData,
	anchor_coord: Vector2i,
	rotation_steps: int,
	is_valid: bool,
	active: bool = true,
	placement_path_graph: PathGraph = null
) -> void:
	_board_mode = true
	_piece_data = piece_data
	_rotation_steps = posmod(rotation_steps, 6)
	_placement_anchor = anchor_coord
	_placement_is_valid = is_valid
	_placement_active = active
	_placement_path_graph = placement_path_graph
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
	if not _combo_strength_by_coord.is_empty():
		_combo_animation_time += _delta
		_combo_redraw_timer -= _delta
		if _combo_redraw_timer <= 0.0:
			_combo_redraw_timer = 0.12
			queue_redraw()

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
	if _board_mode and _path_graph != null:
		if _path_debug_visible:
			_draw_path_debug_overlay()
		_draw_spawn_markers()
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
	if _tower_preview_icon != null:
		draw_texture_rect(_tower_preview_icon, Rect2(center + Vector2(-27.0, -54.0), Vector2(54.0, 54.0)), false)
	else:
		draw_circle(center + Vector2(0.0, -7.0), 9.0, tint)

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

	if _path_graph.base_endpoint != null:
		var base_center: Vector2 = _top_center(_path_graph.base_endpoint.cell_coord, 0)
		draw_circle(base_center, 12.0, Color(0.04, 0.05, 0.06, 0.92))
		draw_circle(base_center, 8.0, Color(1.0, 0.85, 0.28, 1.0))

func _draw_spawn_markers() -> void:
	var preview_is_active: bool = (
		_placement_active
		and _placement_is_valid
		and _placement_path_graph != null
		and _placement_path_graph.is_valid
	)
	if not preview_is_active:
		for route in _path_graph.routes:
			if route.is_reachable and route.spawn_endpoint != null:
				_draw_spawn_marker(route.spawn_endpoint, SPAWN_MARKER_COLOR, "SPAWN")
		return

	var current_spawn_keys: Dictionary = {}
	var preview_spawn_keys: Dictionary = {}
	for route in _path_graph.routes:
		if route.is_reachable and route.spawn_endpoint != null:
			current_spawn_keys[_spawn_endpoint_key(route.spawn_endpoint)] = true
	for route in _placement_path_graph.routes:
		if route.is_reachable and route.spawn_endpoint != null:
			preview_spawn_keys[_spawn_endpoint_key(route.spawn_endpoint)] = true

	for route in _path_graph.routes:
		if not route.is_reachable or route.spawn_endpoint == null:
			continue
		var current_key: String = _spawn_endpoint_key(route.spawn_endpoint)
		if not preview_spawn_keys.has(current_key):
			_draw_spawn_marker(route.spawn_endpoint, SPAWN_CLOSING_COLOR, "CIERRA", true)

	for route in _placement_path_graph.routes:
		if not route.is_reachable or route.spawn_endpoint == null:
			continue
		var candidate_key: String = _spawn_endpoint_key(route.spawn_endpoint)
		var is_new_spawn: bool = not current_spawn_keys.has(candidate_key)
		_draw_spawn_marker(
			route.spawn_endpoint,
			SPAWN_NEXT_COLOR if is_new_spawn else SPAWN_RETAINED_COLOR,
			"NUEVO" if is_new_spawn else "SIGUE"
		)

func _draw_spawn_marker(endpoint: PathEndpoint, marker_color: Color, label: String, is_closing: bool = false) -> void:
	var spawn_center: Vector2 = _top_center(endpoint.outside_coord, 0)
	var path_center: Vector2 = _top_center(endpoint.cell_coord, 0)
	var inward_direction: Vector2 = (path_center - spawn_center).normalized()
	var path_corners: PackedVector2Array = _hex_corners(path_center)
	var edge_start: int = posmod(endpoint.edge_direction + 1, 6)
	var edge_end: int = posmod(endpoint.edge_direction + 2, 6)
	var path_edge_midpoint: Vector2 = (path_corners[edge_start] + path_corners[edge_end]) * 0.5
	# El color separa el spawn futuro de los actuales sin tapar las caras del terreno.
	draw_line(path_edge_midpoint, spawn_center, SPAWN_MARKER_DARK, 9.0, true)
	draw_line(path_edge_midpoint, spawn_center, marker_color, 5.5, true)
	draw_circle(spawn_center, 17.0, SPAWN_MARKER_DARK)
	draw_circle(spawn_center, 12.5, marker_color)
	draw_arc(spawn_center, 14.5, 0.0, TAU, 24, marker_color.lightened(0.35), 2.5, true)
	if is_closing:
		draw_line(spawn_center + Vector2(-6.0, -6.0), spawn_center + Vector2(6.0, 6.0), Color.WHITE, 2.5, true)
		draw_line(spawn_center + Vector2(6.0, -6.0), spawn_center + Vector2(-6.0, 6.0), Color.WHITE, 2.5, true)
	else:
		var arrow_tip: Vector2 = spawn_center + inward_direction * 8.0
		var arrow_back: Vector2 = spawn_center - inward_direction * 6.0
		var arrow_side: Vector2 = inward_direction.orthogonal() * 4.5
		draw_colored_polygon(PackedVector2Array([
			arrow_tip,
			arrow_back + arrow_side,
			arrow_back - arrow_side,
		]), marker_color.lightened(0.35))

	var label_rect := Rect2(spawn_center + Vector2(16.0, -11.0), Vector2(76.0, 22.0))
	draw_rect(label_rect, SPAWN_MARKER_DARK, true)
	draw_rect(label_rect, marker_color.lightened(0.18), false, 1.2)
	draw_string(
		ThemeDB.fallback_font,
		label_rect.position + Vector2(5.0, 15.0),
		label,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1.0,
		12,
		marker_color.lightened(0.42)
	)

func _spawn_endpoint_key(endpoint: PathEndpoint) -> String:
	return "%d,%d,%d" % [endpoint.cell_coord.x, endpoint.cell_coord.y, endpoint.edge_direction]

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
	var combo_strength: int = int(_combo_strength_by_coord.get(cell.local_coord, 0))
	if combo_strength >= 3:
		var combo_color := _combo_color(cell.terrain_type)
		var pulse: float = 0.5 + 0.5 * sin(_combo_animation_time * 2.0)
		var glow_alpha: float = 0.055 + pulse * 0.035
		if combo_strength >= 5:
			glow_alpha += 0.025
		combo_color.a = glow_alpha
		draw_colored_polygon(corners, combo_color)
		outline_color = _combo_color(cell.terrain_type)
		outline_color.a = 0.42 + pulse * 0.18
		outline_width = 2.5 if combo_strength < 5 else 3.0
	draw_polyline(closed_corners, outline_color, outline_width, true)
	_draw_path_edges(cell, center, corners, is_ghost)

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
	_rebuild_combo_highlights()

func _rebuild_combo_highlights() -> void:
	_combo_strength_by_coord.clear()
	var terrain_by_coord: Dictionary[Vector2i, int] = {}
	for cell in _board_display_cells:
		if cell.terrain_type == HexCell.TerrainType.PATH:
			continue
		terrain_by_coord[cell.local_coord] = cell.terrain_type

	var visited: Dictionary[Vector2i, bool] = {}
	for coord in terrain_by_coord:
		if visited.has(coord):
			continue
		var terrain_type: int = terrain_by_coord[coord]
		var component: Array[Vector2i] = []
		var pending: Array[Vector2i] = [coord]
		visited[coord] = true
		while not pending.is_empty():
			var current: Vector2i = pending.pop_back()
			component.append(current)
			for offset in HexCoord.DIRECTION_OFFSETS:
				var neighbor: Vector2i = current + offset
				if visited.has(neighbor) or terrain_by_coord.get(neighbor, -1) != terrain_type:
					continue
				visited[neighbor] = true
				pending.append(neighbor)
		if component.size() < 3:
			continue
		var combo_strength: int = 5 if component.size() >= 5 else 3
		for component_coord in component:
			_combo_strength_by_coord[component_coord] = combo_strength

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

func _combo_color(terrain_type: int) -> Color:
	match terrain_type:
		HexCell.TerrainType.GRASS:
			return Color(0.77, 1.0, 0.82)
		HexCell.TerrainType.MOUNTAIN:
			return Color(1.0, 0.91, 0.68)
		_:
			return Color.WHITE

func _hex_corners(center: Vector2) -> PackedVector2Array:
	var corners := PackedVector2Array()
	for corner_index in range(6):
		var angle_radians: float = deg_to_rad(-90.0 + 60.0 * float(corner_index))
		corners.append(center + Vector2(cos(angle_radians), sin(angle_radians)) * HEX_RADIUS)
	return corners
