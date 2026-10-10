class_name TerrainHoverOverlay
extends Node2D

const HEX_RADIUS: float = 52.0
const ELEVATION_PIXEL_OFFSET: float = 18.0
const REDRAW_INTERVAL: float = 1.0 / 30.0

var _cells: Array[TerrainPieceCellData] = []
var _hovered_cell: TerrainPieceCellData
var _pulse_time: float = 0.0
var _redraw_timer: float = 0.0

func set_hover_state(
	cells: Array[TerrainPieceCellData],
	hovered_cell: TerrainPieceCellData
) -> void:
	_cells = cells.duplicate()
	_hovered_cell = hovered_cell
	_pulse_time = 0.0
	_redraw_timer = 0.0
	set_process(_hovered_cell != null)
	queue_redraw()

func _process(delta: float) -> void:
	_pulse_time += delta
	_redraw_timer -= delta
	if _redraw_timer <= 0.0:
		_redraw_timer = REDRAW_INTERVAL
		queue_redraw()

func _draw() -> void:
	if _hovered_cell == null:
		return
	for cell in _cells:
		var distance: int = _hex_distance(cell.local_coord, _hovered_cell.local_coord)
		if distance > 2:
			continue
		var opacity: float = _grid_opacity(distance)
		var center := _top_center(cell.local_coord, cell.elevation)
		var corners := _hex_corners(center)
		var closed_corners := corners.duplicate()
		closed_corners.append(corners[0])
		var color: Color = _terrain_hover_color(cell.terrain_type)
		color.a = opacity * (0.76 if distance == 0 else 0.62)
		if distance == 0:
			var pulse: float = 0.5 + 0.5 * sin(_pulse_time * TAU / 1.5)
			var glow := color
			glow.a = 0.16 + pulse * 0.08
			draw_polyline(closed_corners, glow, 10.0 + pulse * 2.0, true)
			color.a = 0.80 + pulse * 0.16
			draw_polyline(closed_corners, color, 3.0, true)
		else:
			draw_polyline(closed_corners, color, 2.0, true)
		_draw_path_edges(cell, center, corners, opacity)

func _draw_path_edges(
	cell: TerrainPieceCellData,
	center: Vector2,
	corners: PackedVector2Array,
	opacity: float
) -> void:
	if cell.terrain_type != HexCell.TerrainType.PATH:
		return
	for direction_index in range(HexCoord.DIRECTION_OFFSETS.size()):
		var edge_bit: int = 1 << direction_index
		var is_explicit_edge: bool = (cell.path_edges & edge_bit) != 0
		var is_flexible_edge: bool = (cell.flexible_path_edges & edge_bit) != 0
		if not is_explicit_edge and not is_flexible_edge:
			continue
		var edge_start: int = posmod(direction_index + 1, 6)
		var edge_end: int = posmod(direction_index + 2, 6)
		var edge_midpoint: Vector2 = (corners[edge_start] + corners[edge_end]) * 0.5
		var color := Color(0.90, 0.96, 1.0, opacity * (0.82 if is_explicit_edge else 0.50))
		draw_line(center, edge_midpoint, color, 3.0 if is_explicit_edge else 2.5, true)
		draw_circle(edge_midpoint, 3.5 if is_explicit_edge else 3.0, color)

func _grid_opacity(distance: int) -> float:
	match distance:
		0:
			return 1.0
		1:
			return 0.54
		2:
			return 0.20
		_:
			return 0.0

func _hex_distance(a: Vector2i, b: Vector2i) -> int:
	var delta: Vector2i = a - b
	return maxi(absi(delta.x), maxi(absi(delta.y), absi(delta.x + delta.y)))

func _top_center(coord: Vector2i, elevation: int) -> Vector2:
	return HexMath.axial_to_world(HexCoord.new(coord.x, coord.y), HEX_RADIUS) - Vector2(
		0.0,
		float(elevation) * ELEVATION_PIXEL_OFFSET
	)

func _hex_corners(center: Vector2) -> PackedVector2Array:
	var corners := PackedVector2Array()
	for corner_index in range(6):
		var angle_radians: float = deg_to_rad(-90.0 + 60.0 * float(corner_index))
		corners.append(center + Vector2(cos(angle_radians), sin(angle_radians)) * HEX_RADIUS)
	return corners

func _terrain_hover_color(terrain_type: int) -> Color:
	match terrain_type:
		HexCell.TerrainType.GRASS:
			return Color(0.50, 0.88, 0.52)
		HexCell.TerrainType.MOUNTAIN:
			return Color(0.96, 0.76, 0.36)
		_:
			return Color(0.51, 0.75, 0.90)
