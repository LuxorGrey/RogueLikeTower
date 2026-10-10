class_name TowerBuildGhost
extends Node2D

const HEX_RADIUS: float = 52.0
const ELEVATION_PIXEL_OFFSET: float = 18.0
const ART_OFFSET_Y: float = 6.0

var _board_cells: Dictionary[Vector2i, HexCell] = {}
var _active: bool = false
var _coord: Vector2i = Vector2i.ZERO
var _is_valid: bool = false
var _range_pixels: float = 0.0
var _icon: Texture2D
var _icon_size: float = 54.0

func _ready() -> void:
	z_as_relative = false
	z_index = 4096
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR

func set_preview(
	active: bool,
	coord: Vector2i,
	is_valid: bool,
	range_pixels: float,
	icon: Texture2D,
	icon_size: float,
	board_cells: Dictionary[Vector2i, HexCell]
) -> void:
	_active = active
	_coord = coord
	_is_valid = is_valid
	_range_pixels = maxf(range_pixels, 0.0)
	_icon = icon
	_icon_size = maxf(icon_size, 1.0)
	_board_cells = board_cells
	visible = active
	queue_redraw()

func _draw() -> void:
	if not _active:
		return
	var cell: HexCell = _board_cells.get(_coord) as HexCell
	if cell == null:
		return
	var center: Vector2 = HexMath.axial_to_world(HexCoord.new(_coord.x, _coord.y), HEX_RADIUS)
	center.y -= float(cell.elevation) * ELEVATION_PIXEL_OFFSET
	var valid_tint := Color(0.22, 1.0, 0.40, 0.96)
	var invalid_tint := Color(1.0, 0.12, 0.10, 0.98)
	var tint: Color = valid_tint if _is_valid else invalid_tint
	if _range_pixels > 0.0:
		draw_arc(center, _range_pixels, 0.0, TAU, 72, Color(tint.r, tint.g, tint.b, 0.38), 2.0, true)
	var corners := PackedVector2Array()
	for corner_index in range(6):
		var angle_radians: float = deg_to_rad(-90.0 + 60.0 * float(corner_index))
		corners.append(center + Vector2(cos(angle_radians), sin(angle_radians)) * HEX_RADIUS)
	corners.append(corners[0])
	draw_polyline(corners, tint, 4.0, true)
	if _icon != null:
		var size := Vector2.ONE * _icon_size
		var ghost_tint := Color(1.0, 0.76, 0.76, 0.92) if not _is_valid else Color(1.0, 1.0, 1.0, 0.92)
		draw_texture_rect(_icon, Rect2(center + Vector2(-size.x * 0.5, -size.y + ART_OFFSET_Y), size), false, ghost_tint)
	else:
		draw_circle(center + Vector2(0.0, -7.0 + ART_OFFSET_Y), 9.0, tint)
