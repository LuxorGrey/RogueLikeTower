class_name TerrainPiecePreview
extends Node2D

const TERRAIN_VISUAL_CATALOG_SCRIPT: Script = preload("res://game/board/terrain_visual_catalog.gd")
const TERRAIN_CELL_DECORATION_SCRIPT: Script = preload("res://game/board/terrain_cell_decoration.gd")
const TERRAIN_SURFACE_OCCLUDER_SCRIPT: Script = preload("res://game/board/terrain_surface_occluder.gd")
const PATH_FLOW_OVERLAY_SCRIPT: Script = preload("res://game/board/path_flow_overlay.gd")
const TERRAIN_HOVER_OVERLAY_SCRIPT: Script = preload("res://game/board/terrain_hover_overlay.gd")
const TOWER_BUILD_GHOST_SCRIPT: Script = preload("res://game/board/tower_build_ghost.gd")
const SPAWN_PORTAL_SCENE: PackedScene = preload("res://game/board/spawn_portal.tscn")
const MOUNTAIN_CLIFF_TEXTURE: Texture2D = preload("res://assets/terrain/tiles/mountain_cliff_face.png")
const GRASS_CLIFF_TEXTURE: Texture2D = preload("res://assets/terrain/tiles/grass_cliff_face.png")

signal hover_changed(local_coord: Vector2i, terrain_type: int, elevation: int)
signal hover_cleared

const HEX_RADIUS: float = 52.0
const ELEVATION_PIXEL_OFFSET: float = 18.0
const WORLD_ART_OFFSET_Y: float = 6.0
const HEX_OUTLINE: Color = Color(0.82, 0.87, 0.84)
const PATH_COLOR: Color = Color(0.35, 0.40, 0.43)
const GRASS_COLOR: Color = Color(0.28, 0.57, 0.34)
const MOUNTAIN_COLOR: Color = Color(0.63, 0.58, 0.48)
const PATH_HOVER_COLOR: Color = Color(0.51, 0.75, 0.90)
const GRASS_HOVER_COLOR: Color = Color(0.50, 0.88, 0.52)
const MOUNTAIN_HOVER_COLOR: Color = Color(0.96, 0.76, 0.36)
const CLIFF_MIN_SCREEN_DEPTH: float = 6.0
const CLIFF_TEXTURE_PIXEL_DENSITY: float = 20.0
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
var _decoration_parent: Node2D
var _decorations_by_coord: Dictionary[Vector2i, Node2D] = {}
var _terrain_surface_occluders_by_coord: Dictionary[Vector2i, Node2D] = {}
var _spawn_portals_by_key: Dictionary[String, Node2D] = {}
var _path_flow_overlay: Node2D
var _terrain_hover_overlay: Node2D
var _tower_build_ghost: Node2D
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
var _combo_strength_by_coord: Dictionary[Vector2i, int] = {}
var _combo_animation_time: float = 0.0
var _combo_redraw_timer: float = 0.0

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	texture_repeat = CanvasItem.TEXTURE_REPEAT_DISABLED
	_tower_build_ghost = TOWER_BUILD_GHOST_SCRIPT.new() as Node2D
	_tower_build_ghost.name = "TowerBuildGhost"
	add_child(_tower_build_ghost)

func set_piece(piece_data: TerrainPieceData) -> void:
	_piece_data = piece_data
	_rebuild_display_cells()
	_refresh_hovered_cell()
	queue_redraw()

func set_board_cells(board_cells: Dictionary[Vector2i, HexCell]) -> void:
	_board_mode = true
	_board_cells = board_cells
	_sync_elevation_surface_occluders()
	_sync_cell_decorations()
	_rebuild_display_cells()
	_refresh_hovered_cell()
	queue_redraw()

func set_decoration_parent(parent: Node2D) -> void:
	_decoration_parent = parent
	if parent == null or parent.get_parent() == null:
		return
	var board_parent: Node = parent.get_parent()
	if _path_flow_overlay == null:
		_path_flow_overlay = PATH_FLOW_OVERLAY_SCRIPT.new() as Node2D
		_path_flow_overlay.name = "PathFlowOverlay"
		board_parent.add_child(_path_flow_overlay)
		board_parent.move_child(_path_flow_overlay, parent.get_index())
	if _terrain_hover_overlay == null:
		_terrain_hover_overlay = TERRAIN_HOVER_OVERLAY_SCRIPT.new() as Node2D
		_terrain_hover_overlay.name = "TerrainHoverOverlay"
		board_parent.add_child(_terrain_hover_overlay)
		_terrain_hover_overlay.z_index = 1
	if _path_flow_overlay != null:
		_path_flow_overlay.global_position = global_position
	if _terrain_hover_overlay != null:
		_terrain_hover_overlay.global_position = global_position
	_sync_path_flow_overlay()
	_sync_elevation_surface_occluders()
	_sync_cell_decorations()
	_sync_spawn_portals()
	_sync_terrain_hover_overlay()

func refresh_cell_decorations() -> void:
	_sync_cell_decorations()

func set_path_graph(path_graph: PathGraph) -> void:
	_path_graph = path_graph
	_sync_path_flow_overlay()
	_sync_spawn_portals()
	queue_redraw()

func get_spawn_portals() -> Array[SpawnPortal]:
	var portals: Array[SpawnPortal] = []
	for portal_variant in _spawn_portals_by_key.values():
		var portal := portal_variant as SpawnPortal
		if portal != null and is_instance_valid(portal):
			portals.append(portal)
	return portals

func set_path_debug_visible(debug_enabled: bool) -> void:
	_path_debug_visible = debug_enabled
	queue_redraw()

func set_tower_build_preview(
	active: bool,
	coord: Vector2i = Vector2i.ZERO,
	is_valid: bool = false,
	range_pixels: float = 0.0,
	icon_texture: Texture2D = null,
	icon_size: float = 54.0
) -> void:
	if _tower_build_ghost != null:
		_tower_build_ghost.call(
			"set_preview",
			active,
			coord,
			is_valid,
			range_pixels,
			icon_texture,
			icon_size,
			_board_cells
		)

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
	_sync_path_flow_overlay()
	_sync_spawn_portals()
	_rebuild_display_cells()
	_refresh_hovered_cell()
	queue_redraw()

func set_rotation_steps(steps: int) -> void:
	_rotation_steps = posmod(steps, 6)
	_sync_path_flow_overlay()
	_rebuild_display_cells()
	_refresh_hovered_cell()
	queue_redraw()

func _process(delta: float) -> void:
	_refresh_hovered_cell()
	if not _combo_strength_by_coord.is_empty():
		_combo_animation_time += delta
		_combo_redraw_timer -= delta
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

func _draw_cliffs(
	cells: Array[TerrainPieceCellData],
	cells_by_coord: Dictionary[Vector2i, TerrainPieceCellData]
) -> void:
	var corner_fills: Dictionary = {}
	for cell in cells:
		for direction_index in range(HexCoord.DIRECTION_OFFSETS.size()):
			# Las aristas traseras (noroeste/noreste) quedan debajo del terreno.
			# Solo se dibujan las fachadas visibles desde el frente y los laterales.
			if direction_index >= 4:
				continue
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
			# Un quad por fachada mantiene su topología cerrada; el UV toma solo
			# la región necesaria para conservar la escala del arte en este desnivel.
			var cliff_quad := PackedVector2Array([upper_start, upper_end, lower_end, lower_start])
			var cliff_texture: Texture2D = MOUNTAIN_CLIFF_TEXTURE
			if cell.terrain_type == HexCell.TerrainType.GRASS:
				cliff_texture = GRASS_CLIFF_TEXTURE
			var texture_size: Vector2i = cliff_texture.get_size()
			var uv_span := Vector2(
				cliff_edge.length() * CLIFF_TEXTURE_PIXEL_DENSITY / float(texture_size.x),
				face_offset.length() * CLIFF_TEXTURE_PIXEL_DENSITY / float(texture_size.y)
			)
			var max_u_start: float = maxf(1.0 - uv_span.x, 0.0)
			var uv_seed: float = (
				high_center.x + high_center.y * 1.73 + float(direction_index) * HEX_RADIUS
			) * CLIFF_TEXTURE_PIXEL_DENSITY / float(texture_size.x)
			var uv_left: float = fposmod(uv_seed, max_u_start) if max_u_start > 0.0 else 0.0
			var cliff_uvs := PackedVector2Array([
				Vector2(uv_left, 0.0),
				Vector2(uv_left + uv_span.x, 0.0),
				Vector2(uv_left + uv_span.x, uv_span.y),
				Vector2(uv_left, uv_span.y),
			])
			draw_colored_polygon(cliff_quad, Color.WHITE, cliff_uvs, cliff_texture)
			_register_cliff_corner(corner_fills, upper_start, lower_start, cell.terrain_type)
			_register_cliff_corner(corner_fills, upper_end, lower_end, cell.terrain_type)
	_draw_cliff_corner_caps(corner_fills)

func _register_cliff_corner(
	corner_fills: Dictionary,
	upper_point: Vector2,
	lower_point: Vector2,
	terrain_type: int
) -> void:
	var key := Vector2i(roundi(upper_point.x * 10.0), roundi(upper_point.y * 10.0))
	var entry: Dictionary = corner_fills.get(key, {})
	var lower_points: Array = entry.get("lower_points", [])
	for existing_variant in lower_points:
		var existing_point: Vector2 = existing_variant
		if existing_point.distance_to(lower_point) <= 0.25:
			return
	lower_points.append(lower_point)
	entry["upper_point"] = upper_point
	entry["lower_points"] = lower_points
	entry["terrain_type"] = terrain_type
	corner_fills[key] = entry

func _draw_cliff_corner_caps(corner_fills: Dictionary) -> void:
	for entry_variant in corner_fills.values():
		var entry: Dictionary = entry_variant
		var lower_points: Array = entry.get("lower_points", [])
		if lower_points.size() < 2:
			continue
		var upper_point: Vector2 = entry["upper_point"]
		var sorted_lower_points: Array[Vector2] = []
		for lower_variant in lower_points:
			sorted_lower_points.append(lower_variant)
		sorted_lower_points.sort_custom(func(a: Vector2, b: Vector2) -> bool:
			return (a - upper_point).angle() < (b - upper_point).angle()
		)
		var seam_color: Color = _cliff_seam_color(int(entry.get("terrain_type", HexCell.TerrainType.GRASS)))
		for point_index in range(sorted_lower_points.size()):
			var next_index: int = (point_index + 1) % sorted_lower_points.size()
			var cap := PackedVector2Array([
				upper_point,
				sorted_lower_points[point_index],
				sorted_lower_points[next_index],
			])
			draw_colored_polygon(cap, seam_color)

func _cliff_seam_color(terrain_type: int) -> Color:
	if terrain_type == HexCell.TerrainType.MOUNTAIN:
		return Color("#777383")
	return Color("#a86f3e")

func _draw_cell_top(cell: TerrainPieceCellData, is_ghost: bool = false) -> void:
	var center := _top_center(cell.local_coord, cell.elevation)
	var corners := _hex_corners(center)
	var closed_corners := corners.duplicate()
	closed_corners.append(corners[0])
	var is_hovered := _is_hovered(cell)
	var grid_opacity: float = _grid_opacity_for_cell(cell)
	var fill_color := _terrain_color(cell.terrain_type)
	var outline_color := HEX_OUTLINE
	var outline_width: float = 2.0 if grid_opacity > 0.0 else 0.0
	var placement_tint: Color = Color(0.20, 0.92, 0.37) if _placement_is_valid else Color(0.96, 0.20, 0.16)
	if is_ghost:
		fill_color = fill_color.lerp(placement_tint, 0.48)
		fill_color.a = 0.78
		outline_color = placement_tint.lightened(0.12)
		outline_width = 2.5
		grid_opacity = 1.0
	if is_hovered:
		fill_color = _terrain_hover_color(cell.terrain_type)
		if is_ghost:
			fill_color = fill_color.lerp(placement_tint, 0.3)
			fill_color.a = 0.88
		outline_color = placement_tint.lightened(0.10) if is_ghost else fill_color.lightened(0.18)
		outline_width = 4.5 if is_ghost else 3.5
	draw_colored_polygon(corners, fill_color)
	var tile_size := Vector2(HEX_RADIUS * sqrt(3.0), HEX_RADIUS * 2.0)
	var tile_rect := Rect2(center - tile_size * 0.5, tile_size)
	var tile_tint: Color = Color(1.0, 1.0, 1.0, 0.86 if is_ghost else 1.0)
	draw_texture_rect(
		TERRAIN_VISUAL_CATALOG_SCRIPT.get_terrain_texture(
			cell.terrain_type,
			cell.visual_variant,
			cell.local_coord
		),
		tile_rect,
		false,
		tile_tint
	)
	if is_ghost or is_hovered:
		var interaction_overlay: Color = placement_tint if is_ghost else _terrain_hover_color(cell.terrain_type)
		interaction_overlay.a = 0.24 if is_ghost else 0.17
		draw_colored_polygon(corners, interaction_overlay)
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
		outline_color.a = (0.42 + pulse * 0.18) * grid_opacity
		outline_width = (2.5 if combo_strength < 5 else 3.0) if grid_opacity > 0.0 else 0.0
	if not is_ghost:
		outline_color.a *= grid_opacity if combo_strength < 3 else 1.0
	if outline_width > 0.0 and (not _board_mode or is_ghost or combo_strength >= 3):
		draw_polyline(closed_corners, outline_color, outline_width, true)
	if not _board_mode or is_ghost:
		_draw_path_edges(cell, center, corners, is_ghost)

func _grid_opacity_for_cell(cell: TerrainPieceCellData) -> float:
	if _hovered_cell == null:
		return 0.0
	var delta: Vector2i = cell.local_coord - _hovered_cell.local_coord
	var distance: int = maxi(absi(delta.x), maxi(absi(delta.y), absi(delta.x + delta.y)))
	match distance:
		0:
			return 0.96
		1:
			return 0.48
		2:
			return 0.18
		_:
			return 0.0

func _sync_cell_decorations() -> void:
	if _decoration_parent == null or not is_instance_valid(_decoration_parent):
		return
	var active_coords: Dictionary[Vector2i, bool] = {}
	for coord in _board_cells:
		var cell: HexCell = _board_cells[coord]
		if cell == null or (cell.obstacle_type < 0 and not cell.chest_available):
			continue
		active_coords[coord] = true
		var decoration: Node2D = _decorations_by_coord.get(coord) as Node2D
		if decoration == null or not is_instance_valid(decoration):
			decoration = TERRAIN_CELL_DECORATION_SCRIPT.new() as Node2D
			decoration.name = "CellDecoration_%d_%d" % [coord.x, coord.y]
			_decoration_parent.add_child(decoration)
			_decorations_by_coord[coord] = decoration
		decoration.global_position = global_position + _top_center(coord, cell.elevation)
		decoration.call("configure", cell.obstacle_type, cell.chest_available)
	for coord in _decorations_by_coord.keys():
		if active_coords.has(coord):
			continue
		var decoration_to_remove: Node2D = _decorations_by_coord[coord]
		if is_instance_valid(decoration_to_remove):
			decoration_to_remove.queue_free()
		_decorations_by_coord.erase(coord)
	_sync_obstacle_hover()

func _sync_elevation_surface_occluders() -> void:
	if _decoration_parent == null or not is_instance_valid(_decoration_parent):
		return
	var active_coords: Dictionary[Vector2i, bool] = {}
	for coord in _board_cells:
		var cell: HexCell = _board_cells[coord]
		if cell == null or cell.elevation <= 0:
			continue
		active_coords[coord] = true
		var surface: Node2D = _terrain_surface_occluders_by_coord.get(coord) as Node2D
		if surface == null or not is_instance_valid(surface):
			surface = TERRAIN_SURFACE_OCCLUDER_SCRIPT.new() as Node2D
			surface.name = "TerrainSurface_%d_%d" % [coord.x, coord.y]
			_decoration_parent.add_child(surface)
			# Keep the cover before actors and props when Y positions tie, so an
			# entity standing on this exact tile remains visible above its surface.
			_decoration_parent.move_child(surface, 0)
			_terrain_surface_occluders_by_coord[coord] = surface
		surface.global_position = global_position + _top_center(coord, cell.elevation)
		surface.call("configure_surface", cell.terrain_type, cell.visual_variant, coord)
	for coord in _terrain_surface_occluders_by_coord.keys():
		if active_coords.has(coord):
			continue
		var removed_surface: Node2D = _terrain_surface_occluders_by_coord[coord]
		if is_instance_valid(removed_surface):
			removed_surface.queue_free()
		_terrain_surface_occluders_by_coord.erase(coord)

func _sync_spawn_portals() -> void:
	if _decoration_parent == null or not is_instance_valid(_decoration_parent):
		return
	var graph: PathGraph = _path_graph
	var using_candidate_graph: bool = (
		_placement_active
		and _placement_is_valid
		and _placement_path_graph != null
		and _placement_path_graph.is_valid
	)
	if using_candidate_graph:
		graph = _placement_path_graph
	var active_keys: Dictionary[String, bool] = {}
	if graph != null and graph.is_valid:
		for route in graph.routes:
			if not route.is_reachable or route.spawn_endpoint == null:
				continue
			var endpoint: PathEndpoint = route.spawn_endpoint
			var key: String = "%d,%d,%d" % [endpoint.cell_coord.x, endpoint.cell_coord.y, endpoint.edge_direction]
			active_keys[key] = true
			var portal: SpawnPortal = _spawn_portals_by_key.get(key) as SpawnPortal
			if portal == null or not is_instance_valid(portal):
				portal = SPAWN_PORTAL_SCENE.instantiate() as SpawnPortal
				if portal == null:
					continue
				portal.name = "SpawnPortal_%d_%d_%d" % [endpoint.cell_coord.x, endpoint.cell_coord.y, endpoint.edge_direction]
				_decoration_parent.add_child(portal)
				_spawn_portals_by_key[key] = portal
			portal.global_position = global_position + _top_center(endpoint.outside_coord, 0)
			portal.set_endpoint_key(key)
			portal.set_candidate_preview(using_candidate_graph)
	for key in _spawn_portals_by_key.keys():
		if active_keys.has(key):
			continue
		var removed_portal: Node2D = _spawn_portals_by_key[key]
		if is_instance_valid(removed_portal):
			removed_portal.queue_free()
		_spawn_portals_by_key.erase(key)

func _sync_path_flow_overlay() -> void:
	if _path_flow_overlay == null or not is_instance_valid(_path_flow_overlay):
		return
	var preview_graph: PathGraph = null
	if _placement_active and _placement_is_valid and _placement_path_graph != null and _placement_path_graph.is_valid:
		preview_graph = _placement_path_graph
	_path_flow_overlay.call("set_path_graphs", _path_graph, preview_graph)

func _refresh_hovered_cell() -> void:
	var next_hovered_cell := _find_hovered_cell(get_local_mouse_position())
	if next_hovered_cell == null:
		if _hovered_cell != null:
			_hovered_cell = null
			_sync_terrain_hover_overlay()
			_sync_obstacle_hover()
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
	_sync_terrain_hover_overlay()
	_sync_obstacle_hover()
	hover_changed.emit(
		_hovered_cell.local_coord,
		_hovered_cell.terrain_type,
		_hovered_cell.elevation
	)
	queue_redraw()

func _sync_terrain_hover_overlay() -> void:
	if _terrain_hover_overlay == null or not is_instance_valid(_terrain_hover_overlay):
		return
	_terrain_hover_overlay.global_position = global_position
	_terrain_hover_overlay.call("set_hover_state", _board_display_cells, _hovered_cell)

func _sync_obstacle_hover() -> void:
	for coord in _decorations_by_coord:
		var decoration: Node2D = _decorations_by_coord[coord] as Node2D
		if decoration == null or not is_instance_valid(decoration):
			continue
		decoration.call("set_obstacle_hovered", _hovered_cell != null and _hovered_cell.local_coord == coord)

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
	_sync_terrain_hover_overlay()

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
	var edge_opacity: float = 1.0 if is_ghost else _grid_opacity_for_cell(cell)
	if edge_opacity <= 0.0:
		return
	var edge_color := Color(0.86, 0.91, 0.93, 0.9)
	var flexible_edge_color := Color(0.86, 0.91, 0.93, 0.55)
	if is_ghost:
		var placement_tint: Color = Color(0.20, 0.92, 0.37) if _placement_is_valid else Color(0.96, 0.20, 0.16)
		edge_color = placement_tint.lightened(0.28)
		flexible_edge_color = edge_color.darkened(0.08)
	else:
		edge_color.a *= edge_opacity
		flexible_edge_color.a *= edge_opacity
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
	var a_base := _top_center(a.local_coord, a.elevation)
	var b_base := _top_center(b.local_coord, b.elevation)
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
