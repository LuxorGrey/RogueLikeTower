class_name TerrainPiecePreview
extends Node2D

const HEX_RADIUS: float = 52.0
const HEX_OUTLINE: Color = Color(0.82, 0.87, 0.84)
const LIGHT_LABEL_COLOR: Color = Color(0.98, 0.98, 0.93)
const DARK_LABEL_COLOR: Color = Color(0.12, 0.14, 0.13)
const PATH_COLOR: Color = Color(0.35, 0.40, 0.43)
const GRASS_COLOR: Color = Color(0.28, 0.57, 0.34)
const MOUNTAIN_COLOR: Color = Color(0.63, 0.58, 0.48)

var _piece_data: TerrainPieceData
var _rotation_steps: int = 0

func set_piece(piece_data: TerrainPieceData) -> void:
	_piece_data = piece_data
	queue_redraw()

func set_rotation_steps(steps: int) -> void:
	_rotation_steps = posmod(steps, 6)
	queue_redraw()

func _draw() -> void:
	if _piece_data == null:
		return

	for cell in _piece_data.rotated_cells(_rotation_steps):
		var coord := HexCoord.new(cell.local_coord.x, cell.local_coord.y)
		var center := HexMath.axial_to_world(coord, HEX_RADIUS)
		var corners := _hex_corners(center)
		var closed_corners := corners.duplicate()
		closed_corners.append(corners[0])
		var label_color := _label_color(cell.terrain_type)
		draw_colored_polygon(corners, _terrain_color(cell.terrain_type))
		draw_polyline(closed_corners, HEX_OUTLINE, 2.0, true)
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
			"%d,%d" % [cell.local_coord.x, cell.local_coord.y],
			HORIZONTAL_ALIGNMENT_CENTER,
			HEX_RADIUS * 2.0,
			13,
			label_color
		)

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

func _label_color(terrain_type: int) -> Color:
	if terrain_type == HexCell.TerrainType.MOUNTAIN:
		return DARK_LABEL_COLOR
	return LIGHT_LABEL_COLOR

func _hex_corners(center: Vector2) -> PackedVector2Array:
	var corners := PackedVector2Array()
	for corner_index in range(6):
		var angle_radians: float = deg_to_rad(-90.0 + 60.0 * float(corner_index))
		corners.append(center + Vector2(cos(angle_radians), sin(angle_radians)) * HEX_RADIUS)
	return corners
