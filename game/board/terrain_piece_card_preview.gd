extends Control

const TERRAIN_VISUAL_CATALOG_SCRIPT: Script = preload("res://game/board/terrain_visual_catalog.gd")
const TERRAIN_REGION_OUTLINE_SCRIPT: Script = preload("res://game/board/terrain_region_outline.gd")

const HEX_RADIUS: float = 52.0
const CLIFF_TEXTURE_PIXEL_DENSITY: float = 20.0

var _piece: TerrainPieceData

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED

func set_piece(piece: TerrainPieceData) -> void:
	_piece = piece
	queue_redraw()

func _draw() -> void:
	if _piece == null or size.x <= 1.0 or size.y <= 1.0:
		return

	var cells: Array[TerrainPieceCellData] = _piece.rotated_cells(0)
	if cells.is_empty():
		return
	cells.sort_custom(Callable(self, "_sort_cells_back_to_front"))
	var elevations_by_coord: Dictionary[Vector2i, int] = {}
	for cell in cells:
		elevations_by_coord[cell.local_coord] = cell.elevation
	var region_ids_by_coord: Dictionary[Vector2i, Vector2i] = {}
	for cell in cells:
		region_ids_by_coord[cell.local_coord] = Vector2i(cell.terrain_type, cell.elevation)
	var exposed_edges_by_coord: Dictionary[Vector2i, PackedInt32Array] = (
		TERRAIN_REGION_OUTLINE_SCRIPT.get_exposed_edges(region_ids_by_coord)
	)

	var bounds := Rect2()
	var has_bounds: bool = false
	for cell in cells:
		var center: Vector2 = _top_center(cell.local_coord, cell.elevation)
		var cell_bounds := Rect2(
			center + Vector2(-HEX_RADIUS, -HEX_RADIUS),
			Vector2(HEX_RADIUS * 2.0, HEX_RADIUS * 2.0 + float(cell.elevation) * HexMath.TERRAIN_ELEVATION_PIXEL_OFFSET)
		)
		bounds = cell_bounds if not has_bounds else bounds.merge(cell_bounds)
		has_bounds = true
	if not has_bounds:
		return

	var padding: float = 10.0
	var render_scale: float = minf(
		(size.x - padding * 2.0) / bounds.size.x,
		(size.y - padding * 2.0) / bounds.size.y
	)
	render_scale = maxf(render_scale, 0.01)
	var source_center: Vector2 = bounds.get_center()
	var rendered_centers: Dictionary[Vector2i, Vector2] = {}
	for cell in cells:
		var source_position: Vector2 = _top_center(cell.local_coord, cell.elevation)
		rendered_centers[cell.local_coord] = (
			size * 0.5 + (source_position - source_center) * render_scale
		)

	for cell in cells:
		_draw_cliffs(
			cell,
			rendered_centers[cell.local_coord],
			render_scale,
			elevations_by_coord
		)
		_draw_cell_top(cell, rendered_centers[cell.local_coord], render_scale)
		_draw_region_outline(
			cell,
			rendered_centers[cell.local_coord],
			render_scale,
			exposed_edges_by_coord.get(cell.local_coord, PackedInt32Array())
		)
		_draw_obstacles([cell], rendered_centers, render_scale)

func _draw_cliffs(
	cell: TerrainPieceCellData,
	center: Vector2,
	render_scale: float,
	elevations_by_coord: Dictionary[Vector2i, int]
) -> void:
	if cell.elevation <= 0:
		return
	var upper_corners: PackedVector2Array = _rendered_cell_corners(cell, center, render_scale)
	var cliff_texture: Texture2D = TERRAIN_VISUAL_CATALOG_SCRIPT.get_cliff_texture(cell.terrain_type)
	var texture_size: Vector2i = cliff_texture.get_size()
	var source_center: Vector2 = _top_center(cell.local_coord, cell.elevation)
	for direction_index in [1, 2]:
		var neighbor_coord: Vector2i = (
			cell.local_coord + HexCoord.DIRECTION_OFFSETS[direction_index]
		)
		var neighbor_elevation: int = int(elevations_by_coord.get(neighbor_coord, 0))
		var exposed_levels: int = cell.elevation - neighbor_elevation
		if exposed_levels <= 0:
			continue
		var vertical_offset := Vector2(
			0.0,
			float(exposed_levels) * HexMath.TERRAIN_ELEVATION_PIXEL_OFFSET * render_scale
		)
		var edge_start: int = posmod(direction_index + 1, 6)
		var edge_end: int = posmod(direction_index + 2, 6)
		var upper_start: Vector2 = upper_corners[edge_start]
		var upper_end: Vector2 = upper_corners[edge_end]
		var lower_start: Vector2 = upper_start + vertical_offset
		var lower_end: Vector2 = upper_end + vertical_offset
		var cliff_edge: Vector2 = upper_end - upper_start
		var cliff_quad := PackedVector2Array([upper_start, upper_end, lower_end, lower_start])
		var uv_span := Vector2(
			cliff_edge.length() / render_scale * CLIFF_TEXTURE_PIXEL_DENSITY / float(texture_size.x),
			vertical_offset.length() / render_scale * CLIFF_TEXTURE_PIXEL_DENSITY / float(texture_size.y)
		)
		var max_u_start: float = maxf(1.0 - uv_span.x, 0.0)
		var uv_seed: float = (
			source_center.x
			+ source_center.y * 1.73
			+ float(direction_index) * HEX_RADIUS
		) * CLIFF_TEXTURE_PIXEL_DENSITY / float(texture_size.x)
		var uv_left: float = fposmod(uv_seed, max_u_start) if max_u_start > 0.0 else 0.0
		var cliff_uvs := PackedVector2Array([
			Vector2(uv_left, 0.0),
			Vector2(uv_left + uv_span.x, 0.0),
			Vector2(uv_left + uv_span.x, uv_span.y),
			Vector2(uv_left, uv_span.y),
		])
		draw_polygon(
			cliff_quad,
			TERRAIN_VISUAL_CATALOG_SCRIPT.get_cliff_face_colors(cell.terrain_type),
			cliff_uvs,
			cliff_texture
		)

func _draw_cell_top(cell: TerrainPieceCellData, center: Vector2, render_scale: float) -> void:
	var corners: PackedVector2Array = _rendered_cell_corners(cell, center, render_scale)
	draw_colored_polygon(corners, _terrain_color(cell.terrain_type))
	draw_colored_polygon(
		corners,
		TERRAIN_VISUAL_CATALOG_SCRIPT.get_elevation_tint(cell.elevation),
		_hex_texture_uvs(),
		TERRAIN_VISUAL_CATALOG_SCRIPT.get_terrain_texture(
			cell.terrain_type,
			cell.visual_variant,
			cell.local_coord
		)
	)

func _draw_region_outline(
	cell: TerrainPieceCellData,
	center: Vector2,
	render_scale: float,
	edge_indices: PackedInt32Array
) -> void:
	if edge_indices.is_empty():
		return
	var corners: PackedVector2Array = _rendered_cell_corners(cell, center, render_scale)
	var outline_color: Color = TERRAIN_VISUAL_CATALOG_SCRIPT.get_region_outline_color(
		cell.terrain_type
	)
	var stroke_width: float = maxf(1.0, 2.4 * render_scale)
	var stroke_inset: float = 1.2 * render_scale
	for direction_variant in edge_indices:
		var direction_index: int = int(direction_variant)
		var edge_start: Vector2 = corners[posmod(direction_index + 1, 6)]
		var edge_end: Vector2 = corners[posmod(direction_index + 2, 6)]
		var inward_offset: Vector2 = (
			(center - (edge_start + edge_end) * 0.5).normalized() * stroke_inset
		)
		var tangent_offset: Vector2 = (
			(edge_end - edge_start).normalized() * stroke_width * 0.5
		)
		draw_line(
			edge_start + inward_offset - tangent_offset,
			edge_end + inward_offset + tangent_offset,
			outline_color,
			stroke_width,
			true
		)

func _draw_obstacles(
	cells: Array[TerrainPieceCellData],
	centers: Dictionary[Vector2i, Vector2],
	render_scale: float
) -> void:
	for cell in cells:
		var center: Vector2 = centers[cell.local_coord]
		var prop_offsets: Array[Vector2] = _prop_offsets(cell.decorative_prop_ids.size(), render_scale)
		for prop_index in cell.decorative_prop_ids.size():
			var prop_texture: Texture2D = TERRAIN_VISUAL_CATALOG_SCRIPT.get_prop_texture(
				cell.decorative_prop_ids[prop_index]
			)
			if prop_texture == null:
				continue
			var prop_size: Vector2 = TERRAIN_VISUAL_CATALOG_SCRIPT.PROP_DISPLAY_SIZE * render_scale
			var prop_center: Vector2 = center + prop_offsets[prop_index]
			draw_texture_rect(prop_texture, Rect2(prop_center - prop_size * 0.5, prop_size), false)
		if cell.obstacle_type == HexCell.ObstacleType.NONE:
			continue
		var obstacle_size: Vector2 = TERRAIN_VISUAL_CATALOG_SCRIPT.OBSTACLE_DISPLAY_SIZE * render_scale
		draw_texture_rect(
			TERRAIN_VISUAL_CATALOG_SCRIPT.get_obstacle_texture(cell.obstacle_type),
			Rect2(center - obstacle_size * 0.5, obstacle_size),
			false
		)

func _prop_offsets(prop_count: int, render_scale: float) -> Array[Vector2]:
	var offsets: Array[Vector2] = []
	if prop_count >= 2:
		offsets.append(Vector2(-16.0, 5.0) * render_scale)
		offsets.append(Vector2(16.0, 5.0) * render_scale)
	elif prop_count == 1:
		offsets.append(Vector2(0.0, 5.0) * render_scale)
	return offsets

func _top_center(coord: Vector2i, elevation: int) -> Vector2:
	var ground_center: Vector2 = HexMath.axial_to_world(HexCoord.new(coord.x, coord.y), HEX_RADIUS)
	return ground_center - Vector2(0.0, float(elevation) * HexMath.TERRAIN_ELEVATION_PIXEL_OFFSET)

func _ground_center(coord: Vector2i) -> Vector2:
	return HexMath.axial_to_world(HexCoord.new(coord.x, coord.y), HEX_RADIUS)

func _sort_cells_back_to_front(a: TerrainPieceCellData, b: TerrainPieceCellData) -> bool:
	# Elevation only lifts the surface; depth remains tied to axial ground position.
	var a_ground: Vector2 = _ground_center(a.local_coord)
	var b_ground: Vector2 = _ground_center(b.local_coord)
	if not is_equal_approx(a_ground.y, b_ground.y):
		return a_ground.y < b_ground.y
	return a_ground.x < b_ground.x

func _rendered_cell_corners(
	cell: TerrainPieceCellData,
	rendered_center: Vector2,
	render_scale: float
) -> PackedVector2Array:
	var corners := PackedVector2Array()
	var axial_coord := HexCoord.new(cell.local_coord.x, cell.local_coord.y)
	var source_center: Vector2 = _top_center(cell.local_coord, cell.elevation)
	for corner_index in range(6):
		var source_corner: Vector2 = (
			HexMath.axial_hex_corner(axial_coord, corner_index, HEX_RADIUS)
			- Vector2(0.0, float(cell.elevation) * HexMath.TERRAIN_ELEVATION_PIXEL_OFFSET)
		)
		corners.append(rendered_center + (source_corner - source_center) * render_scale)
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

func _terrain_color(terrain_type: int) -> Color:
	match terrain_type:
		HexCell.TerrainType.PATH:
			return Color(0.35, 0.40, 0.43)
		HexCell.TerrainType.GRASS:
			return Color(0.28, 0.57, 0.34)
		HexCell.TerrainType.MOUNTAIN:
			return Color(0.63, 0.58, 0.48)
		_:
			return Color.MAGENTA
