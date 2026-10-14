class_name TerrainSurfaceOccluder
extends Node2D

const TERRAIN_VISUAL_CATALOG_SCRIPT: Script = preload("res://game/board/terrain_visual_catalog.gd")
const HEX_RADIUS: float = 52.0

var _terrain_type: int = HexCell.TerrainType.GRASS
var _visual_variant: StringName = &""
var _coord: Vector2i = Vector2i.ZERO
var _elevation: int = 0
var _outline_edge_indices: PackedInt32Array = PackedInt32Array()

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR

func configure_surface(
	terrain_type: int,
	visual_variant: StringName,
	coord: Vector2i,
	elevation: int,
	outline_edge_indices: PackedInt32Array = PackedInt32Array()
) -> void:
	_terrain_type = terrain_type
	_visual_variant = visual_variant
	_coord = coord
	_elevation = elevation
	_outline_edge_indices = outline_edge_indices.duplicate()
	queue_redraw()

func _draw() -> void:
	var radius: float = HEX_RADIUS
	var corners := _hex_corners(radius)
	var texture: Texture2D = TERRAIN_VISUAL_CATALOG_SCRIPT.get_terrain_texture(
		_terrain_type,
		_visual_variant,
		_coord
	)
	draw_colored_polygon(
		corners,
		TERRAIN_VISUAL_CATALOG_SCRIPT.get_elevation_tint(_elevation),
		_hex_texture_uvs(),
		texture
	)
	_draw_region_outline(corners)

func _draw_region_outline(corners: PackedVector2Array) -> void:
	if _outline_edge_indices.is_empty():
		return
	var outline_color: Color = TERRAIN_VISUAL_CATALOG_SCRIPT.get_region_outline_color(
		_terrain_type
	)
	var stroke_width: float = 3.0
	var stroke_inset: float = 1.4
	for direction_variant in _outline_edge_indices:
		var direction_index: int = int(direction_variant)
		var edge_start: Vector2 = corners[posmod(direction_index + 1, 6)]
		var edge_end: Vector2 = corners[posmod(direction_index + 2, 6)]
		var inward_offset: Vector2 = (-(edge_start + edge_end) * 0.5).normalized() * stroke_inset
		var tangent_offset: Vector2 = (edge_end - edge_start).normalized() * stroke_width * 0.5
		draw_line(
			edge_start + inward_offset - tangent_offset,
			edge_end + inward_offset + tangent_offset,
			outline_color,
			stroke_width,
			true
		)

func _hex_corners(radius: float) -> PackedVector2Array:
	var corners := PackedVector2Array()
	var axial_coord := HexCoord.new(_coord.x, _coord.y)
	var center: Vector2 = HexMath.axial_to_world(axial_coord, radius)
	for corner_index in range(6):
		corners.append(HexMath.axial_hex_corner(axial_coord, corner_index, radius) - center)
	return corners

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

func _hex_texture_uvs() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(0.5, 0.0),
		Vector2(1.0, 0.25),
		Vector2(1.0, 0.75),
		Vector2(0.5, 1.0),
		Vector2(0.0, 0.75),
		Vector2(0.0, 0.25),
	])
