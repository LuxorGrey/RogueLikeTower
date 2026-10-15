class_name ShorelineFoamOverlay
extends Node2D

const FOAM_SHADER: Shader = preload("res://game/board/shoreline_foam.gdshader")
const HEX_RADIUS: float = 52.0

@export_range(0.0, 16.0, 0.5) var foam_inset: float = 3.0
@export_range(2.0, 28.0, 0.5) var foam_outset: float = 10.0
@export var foam_color: Color = Color("#fffffff2")
@export_range(0.1, 4.0, 0.1) var breakup_scale: float = 1.0

var _surface_elevations: Dictionary[Vector2i, int] = {}
var _foam_material: ShaderMaterial

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_foam_material = ShaderMaterial.new()
	_foam_material.shader = FOAM_SHADER
	_foam_material.set_shader_parameter("foam_color", foam_color)
	_foam_material.set_shader_parameter("breakup_scale", breakup_scale)
	material = _foam_material

func set_surface_cells(
	board_cells: Dictionary[Vector2i, HexCell],
	decorative_cells: Array[TerrainPieceCellData]
) -> void:
	_surface_elevations.clear()
	for coord_variant in board_cells:
		var coord: Vector2i = coord_variant
		var cell: HexCell = board_cells[coord] as HexCell
		if cell != null:
			_surface_elevations[coord] = cell.elevation
	for cell in decorative_cells:
		if cell == null or _surface_elevations.has(cell.local_coord):
			continue
		_surface_elevations[cell.local_coord] = cell.elevation
	queue_redraw()

func _draw() -> void:
	if _surface_elevations.is_empty():
		return
	var coords: Array[Vector2i] = []
	coords.assign(_surface_elevations.keys())
	coords.sort_custom(Callable(self, "_sort_axial_coords"))
	for coord in coords:
		var elevation: int = int(_surface_elevations[coord])
		var center: Vector2 = _top_center(coord, elevation)
		for direction_index in range(HexCoord.DIRECTION_OFFSETS.size()):
			var neighbor_coord: Vector2i = coord + HexCoord.DIRECTION_OFFSETS[direction_index]
			if _surface_elevations.has(neighbor_coord):
				continue
			_draw_foam_edge(coord, direction_index, elevation, center)

func _draw_foam_edge(
	coord: Vector2i,
	direction_index: int,
	elevation: int,
	center: Vector2
) -> void:
	var axial_coord := HexCoord.new(coord.x, coord.y)
	var start_corner: int = posmod(direction_index + 1, 6)
	var end_corner: int = posmod(direction_index + 2, 6)
	var vertical_offset := Vector2(0.0, float(elevation) * HexMath.TERRAIN_ELEVATION_PIXEL_OFFSET)
	var start: Vector2 = HexMath.axial_hex_corner(axial_coord, start_corner, HEX_RADIUS) - vertical_offset
	var end: Vector2 = HexMath.axial_hex_corner(axial_coord, end_corner, HEX_RADIUS) - vertical_offset
	var outward: Vector2 = ((start + end) * 0.5 - center).normalized()
	var points := PackedVector2Array([
		start - outward * foam_inset,
		end - outward * foam_inset,
		end + outward * foam_outset,
		start + outward * foam_outset,
	])
	var tangent: Vector2 = (end - start).normalized()
	var u_start: float = start.dot(tangent) / 72.0
	var u_end: float = end.dot(tangent) / 72.0
	var uvs := PackedVector2Array([
		Vector2(u_start, 0.0),
		Vector2(u_end, 0.0),
		Vector2(u_end, 1.0),
		Vector2(u_start, 1.0),
	])
	var colors := PackedColorArray([foam_color, foam_color, foam_color, foam_color])
	draw_polygon(points, colors, uvs)

func _top_center(coord: Vector2i, elevation: int) -> Vector2:
	return HexMath.axial_to_world(HexCoord.new(coord.x, coord.y), HEX_RADIUS) - Vector2(
		0.0,
		float(elevation) * HexMath.TERRAIN_ELEVATION_PIXEL_OFFSET
	)

func _sort_axial_coords(a: Vector2i, b: Vector2i) -> bool:
	if a.x != b.x:
		return a.x < b.x
	return a.y < b.y
