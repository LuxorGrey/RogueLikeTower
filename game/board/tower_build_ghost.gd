class_name TowerBuildGhost
extends Node2D

const HEX_RADIUS: float = 52.0
const ELEVATION_PIXEL_OFFSET: float = 18.0
const ART_OFFSET_Y: float = 6.0
const TOWER_GHOST_SHADER: Shader = preload("res://game/board/tower_placement_ghost.gdshader")

var _board_cells: Dictionary[Vector2i, HexCell] = {}
var _active: bool = false
var _coord: Vector2i = Vector2i.ZERO
var _is_valid: bool = false
var _range_pixels: float = 0.0
var _icon: Texture2D
var _icon_size: float = 54.0
var _icon_sprite: Sprite2D
var _ghost_material: ShaderMaterial

func _ready() -> void:
	z_as_relative = false
	z_index = 4096
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_icon_sprite = Sprite2D.new()
	_icon_sprite.name = "PlacementGhostSprite"
	_icon_sprite.centered = true
	_icon_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_ghost_material = ShaderMaterial.new()
	_ghost_material.shader = TOWER_GHOST_SHADER
	_icon_sprite.material = _ghost_material
	add_child(_icon_sprite)

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
	_sync_ghost_sprite()
	queue_redraw()

func _sync_ghost_sprite() -> void:
	if _icon_sprite == null:
		return
	_icon_sprite.texture = _icon
	_icon_sprite.visible = _active and _icon != null
	if not _icon_sprite.visible:
		return
	var cell: HexCell = _board_cells.get(_coord) as HexCell
	if cell == null:
		_icon_sprite.visible = false
		return
	var center: Vector2 = HexMath.axial_to_world(HexCoord.new(_coord.x, _coord.y), HEX_RADIUS)
	center.y -= float(cell.elevation) * ELEVATION_PIXEL_OFFSET
	_icon_sprite.position = center + Vector2(0.0, -_icon_size * 0.5 + ART_OFFSET_Y)
	_icon_sprite.scale = Vector2.ONE * _icon_size / Vector2(_icon.get_size())
	_ghost_material.set_shader_parameter(
		"ghost_color",
		Color("#55f28a") if _is_valid else Color("#ff5056")
	)

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
	if _icon == null:
		draw_circle(center + Vector2(0.0, -7.0 + ART_OFFSET_Y), 9.0, tint)
