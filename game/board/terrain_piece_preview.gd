class_name TerrainPiecePreview
extends Node2D

const TERRAIN_VISUAL_CATALOG_SCRIPT: Script = preload("res://game/board/terrain_visual_catalog.gd")
const NO_BASE_COORD: Vector2i = Vector2i(-9999999, -9999999)
const TERRAIN_CELL_DECORATION_SCRIPT: Script = preload("res://game/board/terrain_cell_decoration.gd")
const TERRAIN_SURFACE_OCCLUDER_SCRIPT: Script = preload("res://game/board/terrain_surface_occluder.gd")
const TERRAIN_CLIFF_OCCLUDER_SCRIPT: Script = preload("res://game/board/terrain_cliff_occluder.gd")
const PATH_FLOW_OVERLAY_SCRIPT: Script = preload("res://game/board/path_flow_overlay.gd")
const TERRAIN_HOVER_OVERLAY_SCRIPT: Script = preload("res://game/board/terrain_hover_overlay.gd")
const TOWER_BUILD_GHOST_SCRIPT: Script = preload("res://game/board/tower_build_ghost.gd")
const SPAWN_PORTAL_SCENE: PackedScene = preload("res://game/board/spawn_portal.tscn")
signal hover_changed(local_coord: Vector2i, terrain_type: int, elevation: int)
signal hover_cleared

const HEX_RADIUS: float = 52.0
const WORLD_ART_OFFSET_Y: float = 6.0
const HEX_OUTLINE: Color = Color(0.82, 0.87, 0.84)
const PATH_COLOR: Color = Color(0.35, 0.40, 0.43)
const GRASS_COLOR: Color = Color(0.28, 0.57, 0.34)
const MOUNTAIN_COLOR: Color = Color(0.63, 0.58, 0.48)
const PATH_HOVER_COLOR: Color = Color(0.51, 0.75, 0.90)
const GRASS_HOVER_COLOR: Color = Color(0.50, 0.88, 0.52)
const MOUNTAIN_HOVER_COLOR: Color = Color(0.96, 0.76, 0.36)
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
var _terrain_cliff_occluders_by_edge: Dictionary[Vector3i, Node2D] = {}
var _spawn_portals_by_key: Dictionary[String, Node2D] = {}
var _portal_animation_phase_by_key: Dictionary[String, float] = {}
var _next_portal_animation_phase_index: int = 0
var _path_flow_overlay: Node2D
var _terrain_hover_overlay: Node2D
var _tower_build_ghost: Node2D
var _board_mode: bool = false
var _placement_active: bool = false
var _placement_anchor: Vector2i = Vector2i.ZERO
var _base_coord: Vector2i = NO_BASE_COORD
var _run_seed: int = 0
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
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
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
	_sync_elevation_cliff_occluders()
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
	_sync_elevation_cliff_occluders()
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
	icon_size: float = 54.0,
	elevation_damage_bonus_per_level: float = 1.0
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
			_board_cells,
			elevation_damage_bonus_per_level
		)

func set_placement_preview(
	piece_data: TerrainPieceData,
	anchor_coord: Vector2i,
	rotation_steps: int,
	is_valid: bool,
	active: bool = true,
	placement_path_graph: PathGraph = null,
	base_coord: Vector2i = NO_BASE_COORD,
	run_seed: int = 0
) -> void:
	_board_mode = true
	_piece_data = piece_data
	_rotation_steps = posmod(rotation_steps, 6)
	_placement_anchor = anchor_coord
	_placement_is_valid = is_valid
	_placement_active = active
	_placement_path_graph = placement_path_graph
	_base_coord = base_coord
	_run_seed = run_seed
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
	cells.sort_custom(Callable(self, "_sort_cells_back_to_front"))
	var cliff_geometry: Dictionary = _build_cliff_geometry(cells)
	for cell in cells:
		var is_ghost: bool = _ghost_coords.has(cell.local_coord)
		if not _board_mode or is_ghost:
			_draw_cell_cliff_faces(cell.local_coord, cliff_geometry)
		_draw_cell_top(cell, is_ghost)
		if is_ghost:
			_draw_ghost_cell_content(cell)
	if _board_mode and _path_graph != null:
		if _path_debug_visible and not _placement_active:
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

func _build_cliff_geometry(
	cells: Array[TerrainPieceCellData]
) -> Dictionary:
	var faces_by_coord: Dictionary[Vector2i, Array] = {}
	var elevations_by_coord: Dictionary[Vector2i, int] = {}
	for cell in cells:
		if cell != null:
			elevations_by_coord[cell.local_coord] = cell.elevation
	for cell in cells:
		var cell_faces: Array[Dictionary] = []
		if cell.elevation <= 0:
			continue
		# Con pointy-top, las direcciones axiales 1 y 2 son las dos caras
		# delanteras. Las cuatro caras traseras/laterales no generan geometría.
		for direction_index in [1, 2]:
			var neighbor_coord: Vector2i = (
				cell.local_coord + HexCoord.DIRECTION_OFFSETS[direction_index]
			)
			var neighbor_elevation: int = int(elevations_by_coord.get(neighbor_coord, 0))
			var exposed_levels: int = cell.elevation - neighbor_elevation
			if exposed_levels <= 0:
				continue
			var edge_start: int = posmod(direction_index + 1, 6)
			var edge_end: int = posmod(direction_index + 2, 6)
			var vertical_offset := Vector2(
				0.0,
				float(exposed_levels) * HexMath.TERRAIN_ELEVATION_PIXEL_OFFSET
			)
			var high_center: Vector2 = _top_center(cell.local_coord, cell.elevation)
			var upper_start: Vector2 = _cell_corner(cell.local_coord, edge_start, cell.elevation)
			var upper_end: Vector2 = _cell_corner(cell.local_coord, edge_end, cell.elevation)
			var cliff_edge: Vector2 = upper_end - upper_start
			var lower_start: Vector2 = upper_start + vertical_offset
			var lower_end: Vector2 = upper_end + vertical_offset
			# La fachada termina en la tapa vecina. No invade la cara superior
			# de un hexágono a menor altura.
			var cliff_quad := PackedVector2Array([upper_start, upper_end, lower_end, lower_start])
			var cliff_texture: Texture2D = TERRAIN_VISUAL_CATALOG_SCRIPT.get_cliff_texture(cell.terrain_type)
			var texture_size: Vector2i = cliff_texture.get_size()
			var uv_span := Vector2(
				cliff_edge.length() * CLIFF_TEXTURE_PIXEL_DENSITY / float(texture_size.x),
				vertical_offset.length() * CLIFF_TEXTURE_PIXEL_DENSITY / float(texture_size.y)
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
			cell_faces.append({
				"points": cliff_quad,
				"uvs": cliff_uvs,
				"colors": TERRAIN_VISUAL_CATALOG_SCRIPT.get_cliff_face_colors(cell.terrain_type),
				"texture": cliff_texture,
			})
		if not cell_faces.is_empty():
			faces_by_coord[cell.local_coord] = cell_faces
	return {
		"faces_by_coord": faces_by_coord,
	}

func _draw_cell_cliff_faces(coord: Vector2i, geometry: Dictionary) -> void:
	var faces_by_coord: Dictionary = geometry.get("faces_by_coord", {})
	for face_variant in faces_by_coord.get(coord, []):
		var face: Dictionary = face_variant
		draw_polygon(
			face["points"],
			face["colors"],
			face["uvs"],
			face["texture"]
		)
func _draw_cell_top(cell: TerrainPieceCellData, is_ghost: bool = false) -> void:
	var center := _top_center(cell.local_coord, cell.elevation)
	var corners := _cell_corners(cell.local_coord, cell.elevation)
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
	var tile_tint: Color = TERRAIN_VISUAL_CATALOG_SCRIPT.get_elevation_tint(cell.elevation)
	tile_tint.a = 0.86 if is_ghost else 1.0
	draw_colored_polygon(
		corners,
		tile_tint,
		_hex_texture_uvs(),
		TERRAIN_VISUAL_CATALOG_SCRIPT.get_terrain_texture(
			cell.terrain_type,
			cell.visual_variant,
			cell.local_coord
		)
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

func _draw_ghost_cell_content(cell: TerrainPieceCellData) -> void:
	var center: Vector2 = _top_center(cell.local_coord, cell.elevation)
	var content_tint := Color(1.0, 1.0, 1.0, 0.88)
	var prop_offsets: Array[Vector2] = _prop_offsets(cell.decorative_prop_ids.size())
	for prop_index in cell.decorative_prop_ids.size():
		var prop_texture: Texture2D = TERRAIN_VISUAL_CATALOG_SCRIPT.get_prop_texture(
			cell.decorative_prop_ids[prop_index]
		)
		if prop_texture == null:
			continue
		var prop_size: Vector2 = TERRAIN_VISUAL_CATALOG_SCRIPT.PROP_DISPLAY_SIZE
		var prop_center: Vector2 = center + prop_offsets[prop_index]
		draw_texture_rect(prop_texture, Rect2(prop_center - prop_size * 0.5, prop_size), false, content_tint)
	if cell.obstacle_type != HexCell.ObstacleType.NONE:
		var obstacle_size: Vector2 = TERRAIN_VISUAL_CATALOG_SCRIPT.OBSTACLE_DISPLAY_SIZE
		draw_texture_rect(
			TERRAIN_VISUAL_CATALOG_SCRIPT.get_obstacle_texture(cell.obstacle_type),
			Rect2(center - obstacle_size * 0.5, obstacle_size),
			false,
			content_tint
		)

func _prop_offsets(prop_count: int) -> Array[Vector2]:
	var offsets: Array[Vector2] = []
	if prop_count >= 2:
		offsets.append(Vector2(-16.0, 5.0))
		offsets.append(Vector2(16.0, 5.0))
	elif prop_count == 1:
		offsets.append(Vector2(0.0, 5.0))
	return offsets

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
		if (
			cell == null
			or (cell.obstacle_type < 0 and not cell.chest_available and cell.decorative_prop_ids.is_empty())
		):
			continue
		active_coords[coord] = true
		var decoration: Node2D = _decorations_by_coord.get(coord) as Node2D
		if decoration == null or not is_instance_valid(decoration):
			decoration = TERRAIN_CELL_DECORATION_SCRIPT.new() as Node2D
			decoration.name = "CellDecoration_%d_%d" % [coord.x, coord.y]
			_decoration_parent.add_child(decoration)
			_decorations_by_coord[coord] = decoration
		decoration.global_position = global_position + _top_center(coord, cell.elevation)
		decoration.call(
			"configure",
			cell.obstacle_type,
			cell.chest_available,
			cell.decorative_prop_ids
		)
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
	var elevated_coords: Array[Vector2i] = []
	for coord in _board_cells:
		var cell: HexCell = _board_cells[coord]
		if cell == null or cell.elevation <= 0:
			continue
		active_coords[coord] = true
		elevated_coords.append(coord)
	elevated_coords.sort_custom(Callable(self, "_sort_surface_coords_back_to_front"))
	for coord in elevated_coords:
		var cell: HexCell = _board_cells[coord]
		var surface: Node2D = _terrain_surface_occluders_by_coord.get(coord) as Node2D
		if surface == null or not is_instance_valid(surface):
			surface = TERRAIN_SURFACE_OCCLUDER_SCRIPT.new() as Node2D
			surface.name = "TerrainSurface_%d_%d" % [coord.x, coord.y]
			_decoration_parent.add_child(surface)
			_terrain_surface_occluders_by_coord[coord] = surface
		surface.global_position = global_position + _top_center(coord, cell.elevation)
		surface.call("configure_surface", cell.terrain_type, cell.visual_variant, coord, cell.elevation)
	# Mantiene las tapas elevadas antes de actores y props. El orden estable
	# del grupo resuelve empates de Y-sort por profundidad y coordenada axial.
	for surface_index in range(elevated_coords.size()):
		var surface: Node2D = _terrain_surface_occluders_by_coord[elevated_coords[surface_index]]
		if is_instance_valid(surface):
			_decoration_parent.move_child(surface, surface_index)
	for coord in _terrain_surface_occluders_by_coord.keys():
		if active_coords.has(coord):
			continue
		var removed_surface: Node2D = _terrain_surface_occluders_by_coord[coord]
		if is_instance_valid(removed_surface):
			removed_surface.queue_free()
		_terrain_surface_occluders_by_coord.erase(coord)

func _sync_elevation_cliff_occluders() -> void:
	if _decoration_parent == null or not is_instance_valid(_decoration_parent):
		return
	var active_edges: Dictionary[Vector3i, bool] = {}
	for coord in _board_cells:
		var cell: HexCell = _board_cells[coord]
		if cell == null or cell.elevation <= 0:
			continue
		for direction_index in [1, 2]:
			var neighbor_coord: Vector2i = coord + HexCoord.DIRECTION_OFFSETS[direction_index]
			var neighbor_cell: HexCell = _board_cells.get(neighbor_coord) as HexCell
			var neighbor_elevation: int = neighbor_cell.elevation if neighbor_cell != null else 0
			if cell.elevation <= neighbor_elevation:
				continue
			var edge_key := Vector3i(coord.x, coord.y, direction_index)
			active_edges[edge_key] = true
			var cliff: Node2D = _terrain_cliff_occluders_by_edge.get(edge_key) as Node2D
			if cliff == null or not is_instance_valid(cliff):
				cliff = TERRAIN_CLIFF_OCCLUDER_SCRIPT.new() as Node2D
				cliff.name = "TerrainCliff_%d_%d_%d" % [coord.x, coord.y, direction_index]
				_decoration_parent.add_child(cliff)
				_terrain_cliff_occluders_by_edge[edge_key] = cliff
			var axial_coord := HexCoord.new(coord.x, coord.y)
			var ground_center: Vector2 = HexMath.axial_to_world(axial_coord, HEX_RADIUS)
			var edge_start: int = posmod(direction_index + 1, 6)
			var edge_end: int = posmod(direction_index + 2, 6)
			var lower_offset := Vector2(
				0.0,
				float(neighbor_elevation) * HexMath.TERRAIN_ELEVATION_PIXEL_OFFSET
			)
			var corner_start: Vector2 = HexMath.axial_hex_corner(axial_coord, edge_start, HEX_RADIUS)
			var corner_end: Vector2 = HexMath.axial_hex_corner(axial_coord, edge_end, HEX_RADIUS)
			var sort_anchor: Vector2 = (corner_start + corner_end) * 0.5 - ground_center - lower_offset
			cliff.global_position = global_position + ground_center + sort_anchor
			cliff.call(
				"configure_cliff",
				cell.terrain_type,
				coord,
				cell.elevation,
				neighbor_elevation,
				direction_index
			)
	for edge_key in _terrain_cliff_occluders_by_edge.keys():
		if active_edges.has(edge_key):
			continue
		var removed_cliff: Node2D = _terrain_cliff_occluders_by_edge[edge_key]
		if is_instance_valid(removed_cliff):
			removed_cliff.queue_free()
		_terrain_cliff_occluders_by_edge.erase(edge_key)

func _sort_surface_coords_back_to_front(a: Vector2i, b: Vector2i) -> bool:
	var a_cell: HexCell = _board_cells[a] as HexCell
	var b_cell: HexCell = _board_cells[b] as HexCell
	var a_top: Vector2 = _top_center(a, a_cell.elevation)
	var b_top: Vector2 = _top_center(b, b_cell.elevation)
	if not is_equal_approx(a_top.y, b_top.y):
		return a_top.y < b_top.y
	var a_ground: Vector2 = HexMath.axial_to_world(HexCoord.new(a.x, a.y), HEX_RADIUS)
	var b_ground: Vector2 = HexMath.axial_to_world(HexCoord.new(b.x, b.y), HEX_RADIUS)
	if not is_equal_approx(a_ground.y, b_ground.y):
		return a_ground.y < b_ground.y
	if not is_equal_approx(a_top.x, b_top.x):
		return a_top.x < b_top.x
	if a.x != b.x:
		return a.x < b.x
	return a.y < b.y

func _sync_spawn_portals() -> void:
	if _decoration_parent == null or not is_instance_valid(_decoration_parent):
		return
	var using_candidate_graph: bool = _placement_active and _placement_path_graph != null
	var display_graph: PathGraph = _placement_path_graph if using_candidate_graph else _path_graph
	var visible_keys: Dictionary[String, bool] = {}
	var candidate_keys: Dictionary[String, bool] = {}
	if display_graph != null:
		for route in display_graph.get_active_routes():
			if route == null or not route.is_reachable or route.spawn_endpoint == null:
				continue
			var endpoint: PathEndpoint = route.spawn_endpoint
			var key: String = _spawn_endpoint_key(endpoint)
			visible_keys[key] = true
			candidate_keys[key] = true
			var portal: SpawnPortal = _get_or_create_spawn_portal(endpoint, key)
			if portal == null:
				continue
			portal.global_position = global_position + _top_center(endpoint.outside_coord, 0)
			portal.set_endpoint_key(key)
			portal.set_animation_phase(_get_portal_animation_phase(key))
			portal.set_candidate_preview(
				using_candidate_graph
				and _placement_is_valid
				and _placement_path_graph.is_valid
			)
			portal.set_closing_preview(false)

	# Keep the active portals visible while moving the ghost so a disappearing
	# endpoint can be marked in place instead of vanishing without warning.
	if using_candidate_graph and _path_graph != null:
		for route in _path_graph.get_active_routes():
			if route == null or not route.is_reachable or route.spawn_endpoint == null:
				continue
			var endpoint: PathEndpoint = route.spawn_endpoint
			var key: String = _spawn_endpoint_key(endpoint)
			if candidate_keys.has(key):
				continue
			visible_keys[key] = true
			var closing_portal: SpawnPortal = _get_or_create_spawn_portal(endpoint, key)
			if closing_portal == null:
				continue
			closing_portal.global_position = global_position + _top_center(endpoint.outside_coord, 0)
			closing_portal.set_endpoint_key(key)
			closing_portal.set_animation_phase(_get_portal_animation_phase(key))
			closing_portal.set_candidate_preview(false)
			closing_portal.set_closing_preview(true)
	for key in _spawn_portals_by_key.keys():
		if visible_keys.has(key):
			continue
		var removed_portal: Node2D = _spawn_portals_by_key[key]
		if is_instance_valid(removed_portal):
			removed_portal.queue_free()
		_spawn_portals_by_key.erase(key)

func _get_or_create_spawn_portal(endpoint: PathEndpoint, key: String) -> SpawnPortal:
	var portal: SpawnPortal = _spawn_portals_by_key.get(key) as SpawnPortal
	if portal != null and is_instance_valid(portal):
		return portal
	portal = SPAWN_PORTAL_SCENE.instantiate() as SpawnPortal
	if portal == null:
		return null
	portal.name = "SpawnPortal_%d_%d_%d" % [
		endpoint.cell_coord.x,
		endpoint.cell_coord.y,
		endpoint.edge_direction,
	]
	_decoration_parent.add_child(portal)
	_spawn_portals_by_key[key] = portal
	return portal

func _spawn_endpoint_key(endpoint: PathEndpoint) -> String:
	return PathGraph.get_spawn_endpoint_key(endpoint)

func _get_portal_animation_phase(endpoint_key: String) -> float:
	if _portal_animation_phase_by_key.has(endpoint_key):
		return _portal_animation_phase_by_key[endpoint_key]
	# El paso irracional distribuye endpoints nuevos por el ciclo sin repetir
	# fases ni reiniciar los portales que ya estaban visibles.
	var phase: float = fposmod(float(_next_portal_animation_phase_index) * 0.6180339887498948, 1.0)
	_next_portal_animation_phase_index += 1
	_portal_animation_phase_by_key[endpoint_key] = phase
	return phase

func _sync_path_flow_overlay() -> void:
	if _path_flow_overlay == null or not is_instance_valid(_path_flow_overlay):
		return
	_path_flow_overlay.visible = not _placement_active
	var preview_graph: PathGraph = null
	if _placement_active and _placement_is_valid and _placement_path_graph != null and _placement_path_graph.is_valid:
		preview_graph = _placement_path_graph
	_path_flow_overlay.call("set_path_graphs", _path_graph, preview_graph)

func _refresh_hovered_cell() -> void:
	if not is_inside_tree() or get_viewport() == null:
		_hovered_cell = null
		return
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
		var is_hovered: bool = _hovered_cell != null and _hovered_cell.local_coord == coord
		decoration.call("set_obstacle_hovered", is_hovered)
		decoration.call("set_chest_hovered", is_hovered)

func _find_hovered_cell(mouse_position: Vector2) -> TerrainPieceCellData:
	var cells := _active_display_cells()
	for cell_index in range(cells.size() - 1, -1, -1):
		var cell: TerrainPieceCellData = cells[cell_index]
		var top_face := _cell_corners(cell.local_coord, cell.elevation)
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
		cell.obstacle_type = source.obstacle_type
		cell.chest_available = source.chest_available
		cell.decorative_prop_ids = source.decorative_prop_ids.duplicate()
		_board_display_cells.append(cell)
	if _placement_active and _piece_data != null:
		for local_cell in _display_cells:
			var ghost_cell := local_cell.duplicate(true) as TerrainPieceCellData
			if ghost_cell == null:
				continue
			ghost_cell.obstacle_type = local_cell.obstacle_type
			ghost_cell.chest_available = local_cell.chest_available
			ghost_cell.decorative_prop_ids = local_cell.decorative_prop_ids.duplicate()
			ghost_cell.local_coord = _placement_anchor + local_cell.local_coord
			_apply_base_ring_elevation(ghost_cell)
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

func _apply_base_ring_elevation(cell: TerrainPieceCellData) -> void:
	if cell == null or _base_coord == NO_BASE_COORD:
		return
	for direction in HexCoord.DIRECTION_OFFSETS:
		if cell.local_coord != _base_coord + direction:
			continue
		if cell.terrain_type == HexCell.TerrainType.MOUNTAIN:
			cell.terrain_type = HexCell.TerrainType.GRASS
		cell.elevation = 0 if cell.terrain_type == HexCell.TerrainType.PATH else 1
		cell.visual_variant = TERRAIN_VISUAL_CATALOG_SCRIPT.get_random_visual_variant(cell.terrain_type, _run_seed, cell.local_coord)
		cell.decorative_prop_ids = TERRAIN_VISUAL_CATALOG_SCRIPT.get_decorative_prop_ids(cell.terrain_type, _run_seed, cell.local_coord)
		return

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
	# La elevación desplaza la imagen, pero no cambia qué celda del grid queda
	# delante. El orden de dibujo sigue los anclajes proyectados de suelo.
	var a_base := HexMath.axial_to_world(HexCoord.new(a.local_coord.x, a.local_coord.y), HEX_RADIUS)
	var b_base := HexMath.axial_to_world(HexCoord.new(b.local_coord.x, b.local_coord.y), HEX_RADIUS)
	if not is_equal_approx(a_base.y, b_base.y):
		return a_base.y < b_base.y
	return a_base.x < b_base.x

func _top_center(coord: Vector2i, elevation: int) -> Vector2:
	var hex_coord := HexCoord.new(coord.x, coord.y)
	var ground_position := HexMath.axial_to_world(hex_coord, HEX_RADIUS)
	return ground_position + Vector2(0.0, -float(elevation) * HexMath.TERRAIN_ELEVATION_PIXEL_OFFSET)

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

func _cell_corner(coord: Vector2i, corner_index: int, elevation: int) -> Vector2:
	var axial_coord := HexCoord.new(coord.x, coord.y)
	return HexMath.axial_hex_corner(axial_coord, corner_index, HEX_RADIUS) - Vector2(
		0.0,
		float(elevation) * HexMath.TERRAIN_ELEVATION_PIXEL_OFFSET
	)

func _cell_corners(coord: Vector2i, elevation: int) -> PackedVector2Array:
	var corners := PackedVector2Array()
	for corner_index in range(6):
		corners.append(_cell_corner(coord, corner_index, elevation))
	return corners

func _hex_texture_uvs() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(0.5, 0.0),
		Vector2(1.0, 0.25),
		Vector2(1.0, 0.75),
		Vector2(0.5, 1.0),
		Vector2(0.0, 0.75),
		Vector2(0.0, 0.25),
	])
