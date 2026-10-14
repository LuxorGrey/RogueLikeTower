class_name TerrainHoverOverlay
extends Node2D

const HEX_RADIUS: float = 52.0
const REDRAW_INTERVAL: float = 1.0 / 30.0
const TERRAIN_VISUAL_CATALOG_SCRIPT: Script = preload("res://game/board/terrain_visual_catalog.gd")

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
		var corners := _cell_corners(cell.local_coord, cell.elevation)
		var closed_corners := corners.duplicate()
		closed_corners.append(corners[0])
		var color: Color = _terrain_hover_color(cell.terrain_type)
		color.a = opacity * (0.72 if distance == 0 else 0.48)
		if distance == 0:
			var pulse: float = 0.5 + 0.5 * sin(_pulse_time * TAU / 1.5)
			var glow := color
			glow.a = 0.055 + pulse * 0.035
			_draw_smooth_polyline(closed_corners, glow, 6.0 + pulse)
			color.a = 0.68 + pulse * 0.10
			_draw_smooth_polyline(closed_corners, color, 2.5)
		else:
			_draw_smooth_polyline(closed_corners, color, 1.8)

func _draw_smooth_polyline(points: PackedVector2Array, color: Color, width: float) -> void:
	draw_polyline(points, color, width, true)
	for point_index in range(points.size() - 1):
		draw_circle(points[point_index], width * 0.5, color)
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

func _cell_corners(coord: Vector2i, elevation: int) -> PackedVector2Array:
	var corners := PackedVector2Array()
	var axial_coord := HexCoord.new(coord.x, coord.y)
	for corner_index in range(6):
		var corner: Vector2 = HexMath.axial_hex_corner(axial_coord, corner_index, HEX_RADIUS)
		corner.y -= float(elevation) * HexMath.TERRAIN_ELEVATION_PIXEL_OFFSET
		corners.append(corner)
	return corners

func _terrain_hover_color(terrain_type: int) -> Color:
	return TERRAIN_VISUAL_CATALOG_SCRIPT.get_region_outline_color(terrain_type)
